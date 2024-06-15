import { animate } from "motion"

function isHidden(el) {
  if (el === null) {
    return true
  }

  return el.offsetParent === null
}

function doAnimations(
  notificationGroupId,
  notificationToRemove,
  {
    gapBetweenNotifications: gapBetweenNotifications = 15,
    maxShownNotifications: maxShownNotifications = 3,
  } = {},
) {
  const notificationGroup = document.querySelector(`#${notificationGroupId}`)
  const notifications = Array.from(
    notificationGroup.querySelectorAll(`[phx-hook="PhoenixNotif"]`),
  )
    .filter((n) => !isHidden(n))
    .filter((n) => n !== notificationToRemove)
    .reverse()
    .map((notification, index) => {
      notification.new = notification.order == undefined
      notification.order = index
      return notification
    })

  for (let notification of notifications) {
    // if the element moved past the max limit, disable pointer events on it
    if (notification.order >= maxShownNotifications) {
      notification.classList.remove("pointer-events-auto")
    } else {
      notification.classList.add("pointer-events-auto")
    }

    // decrease z-index of the element
    notification.style.zIndex = `${50 - 1 - notification.order}`

    // calculate axis y of the element
    const direction = notificationGroup.dataset.layout.startsWith("bottom_") ? "-" : ""
    let y = 0
    for (let i = 0; i < notification.order; i++) {
      y += notifications[i].offsetHeight + gapBetweenNotifications
    }
    notification.targetY = `${direction}${y}px`

    // calculate opacity of the element
    const opacity = notification.order >= maxShownNotifications ? 0 : 1

    const keyframes = { y: [`${direction}${y}px`], opacity: [opacity] }
    if (notification.new) {
      // if element is entering for the first time, give it extra keyframes
      const y = notification.offsetHeight + gapBetweenNotifications
      const oppositeDirection = direction === "-" ? "" : "-"
      keyframes.y.unshift(`${oppositeDirection}${y}px`)
      keyframes.opacity.unshift(0)
    }

    animate(notification, keyframes, {
      duration: 0.55,
      easing: [0.22, 1.0, 0.36, 1.0],
    })
  }
}

async function animateOut(notificationGroupId, notification) {
  const notificationGroup = document.querySelector(`#${notificationGroupId}`)

  const direction = notificationGroup.dataset.layout.startsWith("bottom_") ? "" : "-"
  const y = notification.order * notification.offsetHeight

  const animation = animate(
    notification,
    { y: `${direction}${y}px`, opacity: 0 },
    {
      y: {
        duration: 0.5,
        easing: "ease-out",
      },
      opacity: {
        duration: 0.3,
        easing: "ease-out",
      },
    },
  )

  await animation.finished
}

export default function createPhoenixNotifHook(animateOptions) {
  return {
    mounted() {
      const type = this.type()
      const groupId = this.groupId()
      const duration = this.duration()

      this.el.addEventListener("notification-dismiss", async (event) => {
        event.stopPropagation()

        doAnimations(groupId, this.el, animateOptions)
        await animateOut(groupId, this.el)

        switch (type) {
          case "flash":
            this.el.remove()
            break

          case "lv-flash":
            this.el.remove()
            const kind = this.kind()
            this.pushEvent("lv:clear-flash", { key: kind })
            break

          case "lv-toast":
            this.el.remove()
            this.pushEventTo(`#${this.groupId()}`, "clear-toast", { id: this.el.id })
            break

          default:
            throw `unknown notification type - ${type}`
        }
      })

      doAnimations(groupId, null, animateOptions)

      if (duration > 0) {
        window.setTimeout(() => {
          const event = new Event("notification-dismiss")
          this.el.dispatchEvent(event)
        }, duration)
      }
    },

    updated() {
      // place the element to its destination immediately when something is updated.
      const keyframes = { y: [this.el.targetY] }
      animate(this.el, keyframes, { duration: 0 })
    },

    type() {
      return this.el.dataset.type
    },

    kind() {
      return this.el.dataset.kind
    },

    groupId() {
      return this.el.dataset.groupId
    },

    duration() {
      return Number.parseInt(this.el.dataset.duration)
    },
  }
}
