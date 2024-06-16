defmodule PhoenixNotif.Toast do
  @moduledoc false

  @enforce_keys [:kind, :message]
  defstruct [
    :uuid,
    :kind,
    :duration,
    :icon,
    :title,
    :message,
    :action,
    :component
  ]
end
