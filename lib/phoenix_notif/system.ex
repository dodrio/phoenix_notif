defmodule PhoenixNotif.System do
  @moduledoc false

  use Phoenix.Component

  alias PhoenixNotif.Base

  attr :group_id, :string, required: true

  def status(assigns) do
    ~H"""
    <Base.notification
      id="lv-server-error"
      group_id={@group_id}
      type={:system}
      kind={:error}
      duration={0}
      title="Something went wrong!"
      phx-update="ignore"
      phx-disconnected={Base.show(".phx-server-error #lv-server-error")}
      phx-connected={Base.hide("#lv-server-error")}
      hidden
    >
      Hang in there while we get back on track
      <Base.svg name="hero-arrow-path" class="inline-block ml-1 h-3 w-3 animate-spin" />
    </Base.notification>

    <Base.notification
      id="lv-client-error"
      group_id={@group_id}
      type={:system}
      kind={:error}
      title="We can't find the internet"
      phx-update="ignore"
      phx-disconnected={Base.show(".phx-client-error #lv-client-error")}
      phx-connected={Base.hide("#lv-client-error")}
      hidden
    >
      Attempting to reconnect
      <Base.svg name="hero-arrow-path" class="inline-block ml-1 h-3 w-3 animate-spin" />
    </Base.notification>
    """
  end
end
