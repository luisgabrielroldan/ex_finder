defmodule ExFinder.Web do
  @moduledoc false

  @doc false
  def controller do
    quote do
      use Phoenix.Controller, namespace: ExFinder.Web

      import Plug.Conn
    end
  end

  @doc false
  def view do
    quote do
      @moduledoc false

      use Phoenix.View,
        namespace: ExFinder.Web,
        root: "lib/ex_finder/web/templates"

      unquote(view_helpers())
    end
  end

  @doc false
  def live_view do
    quote do
      @moduledoc false
      use Phoenix.LiveView,
        container: {:div, class: "live-page-container"}

      unquote(view_helpers())
    end
  end

  @doc false
  def live_component do
    quote do
      @moduledoc false
      use Phoenix.LiveComponent
      unquote(view_helpers())
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import convenience functions for LiveView rendering
      import Phoenix.LiveView.Helpers

      # Import dashboard built-in functions
      import ExFinder.Web.Helpers
    end
  end

  @doc """
  Convenience helper for using the functions above.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
