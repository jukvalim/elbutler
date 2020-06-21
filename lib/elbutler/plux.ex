defmodule ElButler.HelloWorldPlug do
  import Plug.Conn

  # Serving HTTP is not necessary for functioning of the app, the plug was added
  # just to get the app running in Gigalixir


  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World!\n")
  end
end
