defmodule ExFinder.Web.LayoutView do
  use ExFinder.Web, :view

  def live_socket_path(conn) do
    [conn.private.live_socket_path]
  end

  def assets_prefix(conn) do
    conn.private.assets_prefix
  end
end
