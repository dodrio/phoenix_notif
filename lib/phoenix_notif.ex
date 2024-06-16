defmodule PhoenixNotif do
  @moduledoc false
  use Phoenix.Component

  alias PhoenixNotif.Flash
  alias PhoenixNotif.LiveComponent
  alias PhoenixNotif.System

  attr :id, :string, default: "notification-group", doc: "the DOM id of notification group"
  attr :layout, :atom,
    values: [:top_left, :top_right, :bottom_left, :bottom_right],
    default: :bottom_right,
    doc: "the location for showing notifications"

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :connected, :boolean, default: false

  @doc false
  def notification_group(assigns) do
    default_classes = "fixed z-50 max-h-screen w-full md:max-w-[420px] p-4 grid pointer-events-none"

    class =
      case assigns.layout do
        :bottom_left -> "bottom-0 left-0 #{default_classes} sm:top-auto items-end"
        :bottom_right -> "bottom-0 right-0 #{default_classes} sm:top-auto items-end"
        :top_left -> "top-0 left-0 #{default_classes} sm:bottom-auto items-start"
        :top_right -> "top-0 right-0 #{default_classes} sm:bottom-auto items-start"
      end

    assigns = assign(assigns, :class, class)

    ~H"""
    <%= if @connected do %>
      <.live_component id={@id} module={LiveComponent} class={@class} layout={@layout} f={@flash} />
    <% else %>
      <div id={@id} class={@class} data-layout={@layout}>
        <Flash.flashes group_id={@id} f={@flash} live={false} />
      </div>
    <% end %>
    """
  end

  defdelegate send_toast(kind, message, options \\ []), to: PhoenixNotif.LiveComponent
end
