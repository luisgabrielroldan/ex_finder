defmodule ExFinder.Router do
  @moduledoc """
  Provides routing macros for ExFinder.
  """

  @doc """
  Mounts the ExFinder static assets in the Endpoint.

  ## Options

    * `assets_prefix` - Configures the assets prefix. It must match the
      `assets_prefix` option used with `ex_finder/1` in the Router.
  """
  defmacro ex_finder_assets(opts \\ []) do
    at = Keyword.get(opts, :assets_prefix, "/ex_finder_assets")

    quote bind_quoted: binding() do
      plug(
        Plug.Static,
        at: at,
        from: {:ex_finder, "priv/static"},
        gzip: true,
        cache_control_for_etags: "public, max-age=86400"
      )
    end
  end

  @doc """
  Defines the ExFinder route.

  It expects the `path` the file manager will be mounted at
  and a set of options.


  ## Options

    * `live_socket_path` - Configures the socket path. It must match the
      `socket "/live", Phoenix.LiveView.Socket` in your endpoint.

    * `assets_prefix` - Configures the assets prefix. It must match the
      `assets_prefix` option used with `ex_finder_assets/1` in the Endpoint.
  """
  defmacro ex_finder(path, opts \\ []) do
    live_socket_path = Keyword.get(opts, :live_socket_path, "/live")
    assets_prefix = Keyword.get(opts, :assets_prefix, "/ex_finder_assets")

    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        route_opts = [
          private: %{
            live_socket_path: live_socket_path,
            assets_prefix: assets_prefix
          },
          as: :ex_finder
        ]

        live_session :ex_finder, root_layout: {ExFinder.Web.LayoutView, :root} do
          # All helpers are public contracts and cannot be changed
          live("/", ExFinder.Web.PageLive, :home, route_opts)
        end
      end
    end
  end
end
