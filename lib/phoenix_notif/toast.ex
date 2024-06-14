defmodule PhoenixNotif.Toast do
  @moduledoc false

  @enforce_keys [:kind, :message]
  defstruct [
    :uuid,
    :kind,
    :message,
    :title,
    :icon,
    :action,
    :component,
    :duration
  ]
end
