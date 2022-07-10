defmodule ExFinder.Web.FolderTree do
  @moduledoc false

  use ExFinder.Web, :live_component

  alias ExFinder.Web.FolderTreeItem

  @impl true
  def render(assigns) do
    ~H"""
    <ul class="folder-tree">
      <%= for folder <- @folders do %>
        <.live_component module={FolderTreeItem}
          id={item_id(folder.path)}
          deep={@deep}
          folder={folder}
          current_path={@current_path} />
      <% end %>
    </ul>
    """
  end

  def item_id(path) do
    "folder-#{path}"
  end
end
