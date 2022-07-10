defmodule ExFinder.Web.FilesBox do
  @moduledoc false

  use ExFinder.Web, :live_component

  alias ExFinder.File

  @impl true
  def render(assigns) do
    ~H"""
    <div id="files-box">
      <%= if @files do %>
        <div class="files-container">
          <%= for file <- @files do %>
            <div class={item_class(file, @focus)} phx-click="select_file" phx-value-path={file.path} title={file.name}>
              <i class={icon_class(file)}></i>
              <div class="name"><%= file.name %></div>
            </div>
          <% end %>
        </div>
      <% else %>
          Select a folder
      <% end %>
    </div>
    """
  end

  defp icon_class(file) do
    "icon " <> file_icon(file)
  end

  defp file_icon(%File{name: name}) do
    ext = Path.extname(name)

    cond do
      ext in ~w(.js .css .png .jpeg .jpg .gif .svg) ->
        "fa fa-file-image"

      true ->
        "far fa-file"
    end
  end

  defp item_class(%File{path: path}, %File{path: path}) do
    "file active"
  end

  defp item_class(_file, _focus) do
    "file"
  end
end
