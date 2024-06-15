defmodule PhoenixNotif.LiveComponent do
  @moduledoc false

  use Phoenix.LiveComponent

  alias Phoenix.LiveView
  alias PhoenixNotif.Base
  alias PhoenixNotif.Flash
  alias PhoenixNotif.Toast

  @doc """
  Send a new toast message to the LiveToast component.

  Returns the UUID of the new toast message. This UUID can be passed back
  to another call to `send_toast/3` to update the properties of an existing toast.

  ## Examples

      iex> send_toast(:info, "Thank you for logging in!", title: "Welcome")
      "00c90156-56d1-4bca-a9e2-6353d49c974a"

  """
  def send_toast(kind, message, options \\ []) do
    uuid = options[:uuid] || Ecto.UUID.generate()

    toast = %Toast{
      uuid: uuid,
      kind: kind,
      message: message,
      title: options[:title],
      icon: options[:icon],
      action: options[:action],
      duration: options[:duration],
      component: options[:component]
    }

    LiveView.send_update(__MODULE__, id: "notification-group", toasts: [toast])

    uuid
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
    <div id={@id} class={@class} data-layout={@layout} phx-update="stream">
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
  def handle_event("clear-toast", %{"id" => "lv-toast-" <> uuid} = payload, socket) do
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
