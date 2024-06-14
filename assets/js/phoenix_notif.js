import { animate } from "motion"

function isHidden(el) {
  if (el === null) {
    return true
  }

  return el.offsetParent === null
}

// number of flashes that aren't hidden
function flashCount() {
  let num = 0

  if (!isHidden(document.getElementById("lv-server-error"))) {
    num += 1
  }

  if (!isHidden(document.getElementById("lv-client-error"))) {
    num += 1
  }

  if (!isHidden(document.getElementById("lv-flash-info"))) {
    num += 1
  }

  if (!isHidden(document.getElementById("lv-flash-error"))) {
    num += 1
  }

  if (!isHidden(document.getElementById("flash-info"))) {
    num += 1
  }

  if (!isHidden(document.getElementById("flash-error"))) {
    num += 1
  }

  return num
}

// time in ms to wait before removal, but after animation
const removalTime = 5
// animation time in ms
const animationTime = 550
// whether flashes should be counted in maxItems
const maxItemsIgnoresFlashes = true
// gap in px between toasts
const gap = 15

let lastTS = []

function getNotificationGroup() {
  return document.querySelector("#notification-group")
}

function doAnimations(notificationGroupId, delayTime, maxItems, notificationToRemove) {
  const ts = []

  const selector = `#${notificationGroupId} [phx-hook="PhoenixNotif"]`
  let notifications = Array.from(document.querySelectorAll(selector))
    .filter((n) => !isHidden(n))
    .reverse()

  if (notificationToRemove) {
    notifications = notifications.filter((n) => n !== notificationToRemove)
  }

  // TODO: remove this block
  // Traverse through all notifications, in order they appear in the dom, for which they
  // are NOT hidden, and assign el.order to their index.
  for (let i = 0; i < notifications.length; i++) {
    const notification = notifications[i]
    if (isHidden(notification)) {
      continue
    }
    notification.order = i

    ts[i] = notification
  }

  // now loop through ts and animate each toast to its position
  for (let i = 0; i < ts.length; i++) {
    const toast = ts[i]
    const max = maxItemsIgnoresFlashes ? maxItems + flashCount() : maxItems

    let direction = ""

    const notificationGroup = getNotificationGroup()
    if (notificationGroup.dataset.layout.startsWith("bottom_")) {
      direction = "-"
    }

    // calculate axis y of the element
    let y = 0
    for (let i = 0; i < toast.order; i++) {
      y += ts[i].offsetHeight + gap
    }

    // calculate opacity of the element
    const opacity = toast.order > max ? 0 : 1 - (toast.order - max + 1)

    // if the element moved past the max limit, disable click events on it
    if (toast.order >= max) {
      toast.classList.remove("pointer-events-auto")
    } else {
      toast.classList.add("pointer-events-auto")
    }

    const keyframes = { y: [`${direction}${y}px`], opacity: [opacity] }

    // if element is entering for the first time, start below the fold
    if (toast.order === 0 && lastTS.includes(toast) === false) {
      const y = toast.offsetHeight + gap
      const oppositeDirection = direction === "-" ? "" : "-"
      keyframes.y.unshift(`${oppositeDirection}${y}px`)
      keyframes.opacity.unshift(0)
    }

    toast.targetDestination = `${direction}${y}px`

    const duration = animationTime / 1000

    animate(toast, keyframes, {
      duration,
      easing: [0.22, 1.0, 0.36, 1.0],
    })
    toast.order += 1

    // decrease z-index of the element
    toast.style.zIndex = `${50 - toast.order}`

    lastTS = ts
  }
}

async function animateOut() {
  const val = (this.el.order - 2) * 100 + (this.el.order - 2) * gap

  let direction = ""

  const notificationGroup = getNotificationGroup()
  if (notificationGroup.dataset.layout.startsWith("bottom_")) {
    direction = "-"
  }

  const animation = animate(
    this.el,
    { y: `${direction}${val}%`, opacity: 0 },
    {
      opacity: {
        duration: 0.2,
        easing: "ease-out",
      },
      duration: 0.3,
      easing: "ease-out",
    },
  )

  await animation.finished
}

export default function createPhoenixNotifHook(duration = 6000, maxItems = 3) {
  return {
    mounted() {
      // for the special flashes, check if they are visible, and if not, return early out of here.
      // if (["lv-server-error", "lv-client-error"].includes(this.el.id)) {
      //   if (isHidden(document.getElementById(this.el.id))) {
      //     return
      //   }
      // }

      const type = this.type()
      const groupId = this.groupId()
      const duration = this.duration()

      this.el.addEventListener("notification-dismiss", async (event) => {
        console.log("dismiss", type, this.kind())
        if (event.target === this.el) {
          doAnimations(groupId, duration, maxItems, this.el)
          await animateOut.bind(this)()

          switch (type) {
            case "system":
              break

            case "flash":
              this.el.remove()
              break

            case "lv-flash":
              this.el.remove()
              const kind = this.kind()
              this.pushEvent("lv:clear-flash", { key: kind })
              break

            case "lv-toast":
              this.pushEventTo(`#${this.groupId()}`, "clear-toast", { id: this.el.id })
              break

            default:
              throw `unknown notification type - ${type}`
          }
        }
      })

      doAnimations(groupId, duration, maxItems)

      if (duration > 0) {
        window.setTimeout(() => {
          const event = new Event("notification-dismiss")
          this.el.dispatchEvent(event)
        }, duration)
      }
    },

    updated() {
      // animate to targetDestination in 0ms
      const keyframes = { y: [this.el.targetDestination] }
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
