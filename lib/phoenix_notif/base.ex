defmodule PhoenixNotif.Base do
  @moduledoc """
  Provides base components for deriving various types of notifications.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @types [:flash, :"lv-flash", :"lv-toast"]
  @kinds [:info, :success, :warning, :error]

  @type kind :: :info | :success | :warning | :error

  @doc false
  def kinds, do: @kinds

  @doc """
  Base notification component.

  Based on the look and feel of [Sonner](https://sonner.emilkowal.ski/).
  """
  attr :id, :string, required: true, doc: "the DOM id of notification"
  attr :group_id, :string, required: true, doc: "the DOM id of notification group"
  attr :type, :atom, required: true, values: @types, doc: "the type of notification"
  attr :kind, :atom, required: true, values: @kinds, doc: "the kind of notification message"
  attr :duration, :integer, default: nil, doc: "the time in milliseconds before the message is automatically dismissed"
  attr :icon, :any, default: nil
  attr :title, :string, default: nil
  attr :message, :string, default: nil
  attr :action, :any, default: nil
  attr :component, :any, default: nil

  attr :class_fn, :any,
    default: &__MODULE__.notification_class_fn/1,
    doc: "function to override the look of the notification"

  attr :rest, :global, doc: "the arbitrary attributes to add to the notification container"
  slot :inner_block

  def notification(assigns) do
    ~H"""
    <div
      :if={body = render_slot(@inner_block) || @message}
      id={@id}
      role="alert"
      data-group-id={@group_id}
      data-type={@type}
      data-kind={@kind}
      data-duration={@duration || 4000}
      class={[
        "group/notification",
        "col-start-1 col-end-1 row-start-1 row-end-2",
        @class_fn.(assigns)
      ]}
      phx-hook="PhoenixNotif"
      {@rest}
    >
      <%= if @component do %>
        <%= @component.(Map.merge(assigns, %{body: body})) %>
      <% else %>
        <div class="grow flex flex-col items-start justify-center">
          <p
            :if={@title}
            data-part="title"
            class={[
              if(@icon, do: "mb-2", else: ""),
              "flex items-center text-sm font-semibold leading-6"
            ]}
          >
            <%= if @icon do %>
              <%= @icon.(assigns) %>
            <% end %>
            <%= @title %>
          </p>
          <p class="text-sm leading-5">
            <%= body %>
          </p>
        </div>

        <%= if @action do %>
          <%= @action.(assigns) %>
        <% end %>
      <% end %>
      <button
        type="button"
        class={[
          "group group-has-[[data-part='title']]/notification:absolute right-1.5 top-1.5",
          "p-1",
          "rounded-md text-black/50 transition-all",
          "hover:text-black hover:bg-black/5 group-hover:opacity-100",
          "focus:opacity-100 focus:outline-none focus:ring-2"
        ]}
        aria-label="close"
        phx-click={JS.dispatch("notification-dismiss", to: "##{@id}")}
      >
        <.svg name="hero-x-mark-solid" class="h-[14px] w-[14px] opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc false
  def notification_class_fn(assigns) do
    [
      # base classes
      "relative",
      "flex items-center justify-between",
      "w-full p-4 pointer-events-auto origin-center",
      "border rounded-lg shadow-lg overflow-hidden",
      # start hidden if javascript is enabled
      "[@media(scripting:enabled)]:opacity-0 [@media(scripting:enabled){[data-phx-main]_&}]:opacity-100",
      # override styles per severity
      assigns[:kind] == :info && "bg-white text-black",
      assigns[:kind] == :success && "!text-green-700 !bg-green-100 border-green-200",
      assigns[:kind] == :warning && "!text-yellow-700 !bg-yellow-100 border-yellow-200",
      assigns[:kind] == :error && "!text-red-700 !bg-red-100 border-red-200"
    ]
  end

  attr :name, :string, required: true, doc: "the name of the icon"
  attr :rest, :global, doc: "other html attributes"

  defp svg(%{name: "hero-x-mark-solid"} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
      data-slot="icon"
      {@rest}
    >
      <path
        fill-rule="evenodd"
        d="M5.47 5.47a.75.75 0 0 1 1.06 0L12 10.94l5.47-5.47a.75.75 0 1 1 1.06 1.06L13.06 12l5.47 5.47a.75.75 0 1 1-1.06 1.06L12 13.06l-5.47 5.47a.75.75 0 0 1-1.06-1.06L10.94 12 5.47 6.53a.75.75 0 0 1 0-1.06Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end
end
