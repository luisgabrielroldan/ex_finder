defmodule ExFinder.Web.FolderTreeItem do
  @moduledoc false

  use ExFinder.Web, :live_component

  alias ExFinder.Folder

  alias ExFinder.Web.FolderTree

  @impl true
  def render(assigns) do
    ~H"""
    <li class="folder-tree-group">
      <a class={folder_tree_item_class(@deep, @folder.path, @current_path)}
        phx-click="select_folder"
        phx-value-path={@folder.path}
        title={@folder.name}
        href="#">

        <%= if @folder.open? do %>
          <i class="icon fa fa-folder-open"></i>
        <% else %>
          <i class="icon fa fa-folder"></i>
        <% end %>

        <div class="label"><%= @folder.name %></div>
      </a>

      <%= if has_children?(@folder) do %>
      <a class="expander" phx-click="open_toggle" phx-value-path={@folder.path}>
        <%= if @folder.open? do %>
          <i class="fa fa-caret-down"></i>
        <% else %>
          <i class="fa fa-caret-right"></i>
        <% end %>
      </a>
      <% end %>

      <%= if @folder.open? and has_children?(@folder) do %>
        <.live_component module={FolderTree}
          id={folder_tree_id(@folder.path)}
          folders={@folder.children}
          deep={@deep + 1}
          current_path={@current_path} />
      <% end %>
    </li>
    """
  end

  defp has_children?(%Folder{children: children}) do
    not is_nil(children) and Enum.any?(children)
  end

  defp folder_tree_id(path) do
    "tree-#{path}"
  end

  defp folder_tree_item_class(deep, path, current_path) do
    class = "folder-tree-item level-#{deep}"

    if path == current_path do
      class <> " active"
    else
      class
    end
  end
end
