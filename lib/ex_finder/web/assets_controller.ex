defmodule ExFinder.Web.AssetsController do
  @moduledoc false

  use ExFinder.Web, :controller

  def assets(conn, %{"file" => file_slugs}) do
    filename = Path.join([:code.priv_dir(:ex_finder) | ["static" | file_slugs]])

    if File.exists?(filename) do
      send_file(conn, 200, filename)
    else
      send_resp(conn, 404, "Not found")
    end
  end
end
