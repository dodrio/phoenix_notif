defmodule PhoenixNotif.System do
  @moduledoc false

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :id, :string, default: "connection-group", doc: "the DOM id of connection group"
  attr :position, :atom, default: :top, values: [:top, :bottom], doc: "the position for showing UI"
  attr :client_error_message, :string, default: "Network error, attempting to reconnect..."
  attr :server_error_message, :string, default: "Service error, attempting to recover..."

  def connection_group(assigns) do
    assigns =
      assign_new(assigns, :position_class, fn ->
        case assigns.position do
          :top -> "top-0 left-0 border-b"
          :bottom -> "bottom-0 left-0 border-t"
        end
      end)

    ~H"""
    <div id={@id}>
      <div
        id="lv-client-error"
        role="alert"
        class={[
          "fixed #{@position_class} z-[100] w-full px-4 py-2",
          "hidden justify-center items-center",
          "bg-red-100 text-sm text-red-700 border-red-200 shadow"
        ]}
        phx-disconnected={show(".phx-client-error #lv-client-error", position: @position)}
        phx-connected={hide("#lv-client-error", position: @position)}
        hidden
      >
        <.svg name="loader-circle" class="w-4 h-4 mr-2 animate-spin" />
        <p><%= @client_error_message %></p>
      </div>

      <div
        id="lv-server-error"
        role="alert"
        class={[
          "fixed #{@position_class} z-[100] w-full px-4 py-2",
          "hidden justify-center items-center",
          "bg-red-100 text-sm text-red-700 border-b border-red-200 shadow"
        ]}
        phx-disconnected={show(".phx-server-error #lv-server-error", position: @position)}
        phx-connected={hide("#lv-server-error", position: @position)}
      >
        <.svg name="loader-circle" class="w-4 h-4 mr-2 animate-spin" />
        <p><%= @server_error_message %></p>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true, doc: "the name of the icon"
  attr :rest, :global, doc: "other html attributes"

  defp svg(%{name: "loader-circle"} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      {@rest}
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none" /><path d="M12 3a9 9 0 1 0 9 9" />
    </svg>
    """
  end

  defp show(js \\ %JS{}, selector, position: position) do
    transition =
      case position do
        :top ->
          {"transition-all transform ease-in duration-300", "opacity-0 -translate-y-full", "opacity-100 translate-y-0"}

        :bottom ->
          {"transition-all transform ease-in duration-300", "opacity-0 translate-y-full", "opacity-100 translate-y-0"}
      end

    JS.show(js,
      to: selector,
      time: 300,
      transition: transition,
      display: "flex"
    )
  end

  defp hide(js \\ %JS{}, selector, position: position) do
    transition =
      case position do
        :top ->
          {"transition-all transform ease-out duration-300", "opacity-0 translate-y-0", "opacity-100 -translate-y-full"}

        :bottom ->
          {"transition-all transform ease-out duration-300", "opacity-100 translate-y-0", "opacity-0 translate-y-full"}
      end

    JS.hide(js,
      to: selector,
      time: 300,
      transition: transition
    )
  end
end
