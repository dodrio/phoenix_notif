defmodule PhoenixNotif.LiveComponent do
  @moduledoc """
  The notification system for LiveView.
  """

  use Phoenix.LiveComponent

  alias Phoenix.LiveView
  alias PhoenixNotif.Base
  alias PhoenixNotif.Flash
  alias PhoenixNotif.Toast

  @typedoc "`Phoenix.Component` that renders a part of the toast message."
  @type component_fn() :: (map() -> Phoenix.LiveView.Rendered.t())

  @typedoc "Set of public options to augment the default toast behavior."
  @type option() ::
          {:uuid, Ecto.UUID.t()}
          | {:duration, non_neg_integer()}
          | {:icon, component_fn()}
          | {:title, binary()}
          | {:action, component_fn()}
          | {:component, component_fn()}
          | {:group_id, binary()}

  @doc """
  Send a new toast message to the PhoenixNotif component.

  Returns the UUID of the new toast message. This UUID can be passed back
  to another call to `send_toast/3` to update the properties of an existing toast.

  ## Examples

      iex> send_toast(:info, "Thank you for logging in!", title: "Welcome")
      "00c90156-56d1-4bca-a9e2-6353d49c974a"

  """
  @spec send_toast(Base.kind(), binary(), [option()]) :: Ecto.UUID.t()
  def send_toast(kind, message, options \\ []) do
    uuid = options[:uuid] || Ecto.UUID.generate()
    group_id = options[:group_id] || "notification-group"

    toast = %Toast{
      uuid: uuid,
      kind: kind,
      duration: options[:duration],
      icon: options[:icon],
      title: options[:title],
      message: message,
      action: options[:action],
      component: options[:component]
    }

    LiveView.send_update(__MODULE__, id: group_id, toasts: [toast])

    uuid
  end

  @doc """
  Helper function around `send_toast/3` that is useful in pipelines.

  Unlike `send_toast/3`, this function does not expose the UUID of the
  new toast, so if you need to update the toast after showing it, you
  should use `send_toast/3` directly.

  ## Examples

      iex> put_toast(socket, :info, "Thank you for logging in!")
      %LiveView.Socket{...}

  """
  @spec put_toast(LiveView.Socket.t(), Base.kind(), binary(), [option()]) :: LiveView.Socket.t()
  def put_toast(%LiveView.Socket{} = socket, kind, message, options \\ []) do
    send_toast(kind, message, options)
    socket
  end

  @impl Phoenix.LiveComponent
  def mount(socket) do
    socket =
      socket
      |> stream_configure(:toasts,
        dom_id: fn %Toast{uuid: id} -> "lv-toast-#{id}" end
      )
      |> stream(:toasts, [])
      |> assign(:toast_count, 0)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {toasts, assigns} = Map.pop(assigns, :toasts)
    toasts = toasts || []

    socket =
      socket
      |> assign(assigns)
      |> stream(:toasts, toasts)
      |> assign(:toast_count, socket.assigns.toast_count + length(toasts))

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id={@id} class={@class} data-position={@position} phx-update="stream">
      <Base.notification
        :for={
          {dom_id,
           %Toast{
             kind: kind,
             duration: duration,
             icon: icon,
             title: title,
             message: message,
             action: action,
             component: component
           }} <- @streams.toasts
        }
        id={dom_id}
        group_id={@id}
        type={:"lv-toast"}
        kind={kind}
        duration={duration}
        icon={icon}
        title={title}
        message={message}
        action={action}
        component={component}
      />
      <Flash.flashes group_id={@id} f={@f} live={true} />
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("clear-toast", %{"id" => "lv-toast-" <> _uuid} = payload, socket) do
    socket =
      socket
      |> stream_delete_by_dom_id(:toasts, payload["id"])
      |> assign(:toast_count, socket.assigns.toast_count - 1)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("clear-toast", _payload, socket) do
    {:noreply, socket}
  end
end
