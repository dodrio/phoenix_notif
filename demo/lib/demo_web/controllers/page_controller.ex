defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def demo(conn, params) do
    conn =
      case params["flash"] do
        nil ->
          conn

        "info" ->
          put_flash(conn, :info, "This is an info flash.")

        "success" ->
          put_flash(conn, :success, "This is a success flash.")

        "warning" ->
          put_flash(conn, :warning, "This is a warning flash.")

        "error" ->
          put_flash(conn, :error, "This is an error flash.")

        "all" ->
          conn
          |> put_flash(:info, "This is an info flash.")
          |> put_flash(:success, "This is a success flash.")
          |> put_flash(:warning, "This is a warning flash.")
          |> put_flash(:error, "This is an error flash.")
      end

    render(conn)
  end
end
