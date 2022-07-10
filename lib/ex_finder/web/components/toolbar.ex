defmodule ExFinder.Web.Toolbar do
  @moduledoc false

  use ExFinder.Web, :live_component

  alias ExFinder.{File, Folder}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="toolbar">
      <button class="btn" id="btn-tree-toggle" phx-hook="TreeToggle">
        <i class="icon fa fa-bars"></i>
      </button>

      <%= if file_focused?(@focus) do %>
        <button class="btn" phx-click="tb_select">
          <i class="icon fa fa-circle-check"></i>
          <span class="label">Select file</span>
        </button>
      <% end %>

      <button class="btn" phx-click="tb_refresh">
        <i class="icon fa fa-refresh"></i>
        <span class="label">Refresh</span>
      </button>

      <%= if can_rename_or_delete_folder?(@focus) do %>
        <button class="btn" phx-click="tb_item_rename">
          <i class="icon fa fa-folder"></i>
          <span class="label">Rename</span>
        </button>

        <button class="btn" phx-click="tb_item_delete">
          <i class="icon fa fa-folder"></i>
          <span class="label">Delete</span>
        </button>
      <% end %>

      <%= if can_rename_or_delete_file?(@focus) do %>
        <button class="btn" phx-click="tb_item_rename">
          <i class="icon fa fa-file"></i>
          <span class="label">Rename</span>
        </button>

        <button class="btn" phx-click="tb_item_delete">
          <i class="icon fa fa-file"></i>
          <span class="label">Delete</span>
        </button>
      <% end %>
    </div>
    """
  end

  def can_upload_files?(%Folder{}), do: true
  def can_upload_files?(_focus), do: false

  def can_rename_or_delete_file?(%File{}), do: true
  def can_rename_or_delete_file?(_focus), do: false

  def can_rename_or_delete_folder?(%Folder{root?: false}), do: true
  def can_rename_or_delete_folder?(_focus), do: false

  def file_focused?(%File{}), do: true
  def file_focused?(_focus), do: false
end
