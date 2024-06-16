# PhoenixNotif

[![Hex.pm](https://img.shields.io/hexpm/v/phoenix_notif.svg)](https://hex.pm/packages/phoenix_notif)

A drop-in replacement for notification system in Phoenix.

## Installation

### 1. add Hex package

Add `:phoenix_notif` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_notif, "~> <version>"}
  ]
end
```

### 2. add NPM package

Import the frontend package shipped with this above Hex package from `../deps/phoenix_notif`.

### 3. create and use the hook

```javascript
import createPhoenixNotifHook from "phoenix_notif"

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: {
    PhoenixNotif: createPhoenixNotifHook(),
  },
})
```

### 4. help Tailwind looking for class names

```javascript
// Edit tailwind.config.js

module.exports = {
  content: [
    // ...
    "../deps/phoenix_notif/lib/**/*.*ex",
    // ...
  ],
}
```

### 5. use components provided by this package

Finally, replace your `<.flash_group />` component with the new components.

It's most likely in the `app.html.heex`:

```heex
<!-- Remove this! -->
<.flash_group flash={@flash} />

<!-- And replace it with this: -->
<PhoenixNotif.connection_group position={:bottom} />
<PhoenixNotif.notification_group flash={@flash} connected={assigns[:socket] != nil} />

<%= @inner_content %>
```

## Usage

`PhoenixNotif` provides two types of notifications.

- Flash
- Toast - allows multiple notifications to show for each kind of toast.

### Using Flash

> It's supported by DeadView and LiveView.

Flash is provided by Phoenix flash system, which only allows one notification to show for each kind of flash.

Use `put_flash/3`.

```elixir
push_flash(conn, :info, "Upload successful.")
push_flash(socket, :info, "Upload successful.")
```

### Using Toast

> It's supported by LiveView only.

Use `put_toast/4`:

```elixir
defmodule DemoWeb.HomeLive do
  def handle_event("submit", _payload, socket) do
    socket = socket
    |> put_toast(:info, "Upload successful.", [title: "Status"])

    {:noreply, socket}
  end
end
```

Use `send_toast/3`:

```elixir
defmodule DemoWeb.HomeLive do
  def handle_event("submit", _payload, socket) do
    PhoenixNotif.send_toast(:info, "Upload successful.", [ title: "Status" ])

    {:noreply, socket}
  end
end
```

## TODO

- [ ] Tune the components by following:
  - https://primer.style/components/flash
  - https://primer.style/components/toast

## License

MIT
