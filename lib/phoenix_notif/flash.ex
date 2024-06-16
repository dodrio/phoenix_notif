defmodule PhoenixNotif.Flash do
  @moduledoc """
  The flash system for DeadView and LiveView.
  """

  use Phoenix.Component

  alias PhoenixNotif.Base

  @doc """
  Flashes are derived from `PhoenixNotif.Base`.

  They won't disappear util you dismiss them.
  """
  attr :group_id, :string, required: true
  attr :f, :map, required: true
  attr :live, :boolean, default: false

  def flashes(assigns) do
    assigns =
      assign_new(assigns, :type, fn ->
        if assigns.live, do: :"lv-flash", else: :flash
      end)

    ~H"""
    <%= for kind <- Base.kinds() do %>
      <Base.notification
        :if={message = Phoenix.Flash.get(@f, kind)}
        id={"#{@type}-#{kind}"}
        group_id={@group_id}
        type={@type}
        kind={kind}
        duration={0}
        title={kind |> to_string() |> String.capitalize()}
        message={message}
        phx-update="ignore"
      />
    <% end %>
    """
  end
end
