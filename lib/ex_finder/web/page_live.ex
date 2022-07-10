defmodule ExFinder.Web.PageLive do
  @moduledoc false

  use ExFinder.Web, :live_view

  alias ExFinder.Adapter
  alias ExFinder.{File, Folder}

  alias ExFinder.Web.FilesBox
  alias ExFinder.Web.FolderTree
  alias ExFinder.Web.Toolbar
  alias ExFinder.Web.ErrorModal
  alias ExFinder.Web.RenameDialog
  alias ExFinder.Web.DeleteDialog

  @impl true
  def render(assigns) do
    ~H"""

    <%= if @modal_dialog == :rename do %>
      <.live_component module={RenameDialog}
        id="rename_dialog"
        item={@focus}
        close_click="modal_dialog_close" />
    <% end %>

    <%= if @modal_dialog == :delete do %>
      <.live_component module={DeleteDialog}
        id="delete_dialog"
        item={@focus}
        close_click="modal_dialog_close" />
    <% end %>

    <%= if @modal_dialog == :error do %>
      <.live_component module={ErrorModal}
        id="error_dialog"
        height="140px"
        title="Error occured"
        close_click="modal_dialog_close">
      <%= @modal_error_message %>
      </.live_component>
    <% end %>

    <.live_component module={Toolbar} id="toolbar" focus={@focus} />

    <div id="files-wrapper">
      <div id="folder-tree-wrapper">
        <.live_component module={FolderTree}
          id="main-folder-tree"
          folders={@tree}
          current_path={@current_path}
          deep={1} />
      </div>

      <div id="file-list-wrapper">
        <.live_component module={FilesBox}
          id="files-box"
          focus={@focus}
          files={@files} />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    adapter = session_manager().init(session)

    {:ok,
     socket
     |> assign(:modal_dialog, nil)
     |> assign(:current_path, "/")
     |> assign(:adapter, adapter)
     |> fetch_folders()
     |> focus_root_folder()
     |> fetch_files()}
  end

  @impl true
  def handle_info({:rename_item, new_name}, socket) do
    %{
      assigns: %{
        current_path: current_path,
        adapter: adapter,
        focus: %{path: old_path} = item
      }
    } = socket

    case Adapter.rename(adapter, item, new_name) do
      {:ok, %Folder{path: new_path} = updated_folder} ->
        current_path =
          if current_path == old_path do
            new_path
          else
            current_path
          end

        {:noreply,
         socket
         |> assign(:focus, updated_folder)
         |> assign(:current_path, current_path)
         |> hide_modal_dialog()
         |> fetch_folders()
         |> tree_open_path(Path.dirname(current_path))}

      {:ok, %File{} = updated_file} ->
        {:noreply,
         socket
         |> assign(:focus, updated_file)
         |> hide_modal_dialog()
         |> fetch_files()}

      {:error, reason} ->
        {:noreply,
         socket
         |> hide_modal_dialog()
         |> assign(:current_path, "/")
         |> show_error_dialog("An error ocurred when trying to rename the file: #{reason}")
         |> fetch_folders()}
    end
  end

  def handle_info(:delete_item, socket) do
    %{
      assigns: %{
        adapter: adapter,
        focus: item
      }
    } = socket

    case {Adapter.delete(adapter, item), item} do
      {:ok, %Folder{path: path}} ->
        parent_folder = Path.dirname(path)

        {:noreply,
         socket
         |> assign(:focus, nil)
         |> assign(:current_path, parent_folder)
         |> hide_modal_dialog()
         |> fetch_folders()
         |> tree_open_path(parent_folder)
         |> fetch_files()}

      {:ok, %File{path: path}} ->
        parent_folder = Path.dirname(path)

        {:noreply,
         socket
         |> assign(:focus, nil)
         |> hide_modal_dialog()
         |> assign(:current_path, parent_folder)
         |> fetch_files()}

      {{:error, reason}, _item} ->
        {:noreply,
         socket
         |> hide_modal_dialog()
         |> assign(:current_path, item.path)
         |> show_error_dialog("An error ocurred when trying to delete the file: #{reason}")}
    end
  end

  @impl true
  def handle_event("select_folder", %{"path" => path}, socket) do
    folder = Folder.tree_get_folder!(socket.assigns.tree, path)

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> assign(:focus, folder)
     |> fetch_files()}
  end

  def handle_event("select_file", %{"path" => path}, socket) do
    file =
      socket.assigns.files
      |> Enum.find(fn %{path: file_path} -> file_path == path end)

    {:noreply,
     socket
     |> assign(:focus, file)}
  end

  def handle_event("open_toggle", %{"path" => path}, socket) do
    %{assigns: %{adapter: adapter, tree: tree}} = socket

    tree = Folder.tree_open_toggle(tree, path, adapter)

    {:noreply,
     socket
     |> assign(:tree, tree)}
  end

  def handle_event("modal_dialog_close", _params, socket) do
    {:noreply, hide_modal_dialog(socket)}
  end

  def handle_event("tb_select", _params, socket) do
    %{assigns: %{focus: file}} = socket
    url = Adapter.get_url(socket.assigns.adapter, file)
    {:noreply, push_event(socket, "file_selected", %{url: url})}
  end

  def handle_event("tb_refresh", _params, socket) do
    %{assigns: %{current_path: current_path}} = socket

    {:noreply,
     socket
     |> fetch_folders()
     |> tree_open_path(Path.dirname(current_path))
     |> fetch_files()}
  end

  def handle_event("tb_item_rename", _params, socket) do
    {:noreply, show_rename_dialog(socket)}
  end

  def handle_event("tb_item_delete", _params, socket) do
    {:noreply, show_delete_dialog(socket)}
  end

  defp focus_root_folder(socket) do
    %{assigns: %{tree: [root_folder]}} = socket

    socket
    |> assign(:current_path, root_folder.path)
    |> assign(:focus, root_folder)
  end

  defp fetch_folders(socket) do
    %{assigns: %{adapter: adapter}} = socket

    tree =
      adapter
      |> Folder.tree_build()
      |> Folder.tree_open_toggle("/", adapter)

    assign(socket, :tree, tree)
  end

  defp show_error_dialog(socket, message) do
    socket
    |> assign(:modal_dialog, :error)
    |> assign(:modal_error_message, message)
  end

  defp show_rename_dialog(socket) do
    assign(socket, :modal_dialog, :rename)
  end

  defp show_delete_dialog(socket) do
    assign(socket, :modal_dialog, :delete)
  end

  defp hide_modal_dialog(socket) do
    assign(socket, :modal_dialog, nil)
  end

  defp tree_open_path(socket, path) do
    %{assigns: %{adapter: adapter, tree: tree}} = socket

    tree = Folder.tree_open_path(tree, path, adapter)

    assign(socket, :tree, tree)
  end

  defp fetch_files(%{assigns: %{current_path: ""}} = socket) do
    assign(socket, :files, nil)
  end

  defp fetch_files(%{assigns: %{current_path: path}} = socket) do
    files = Adapter.get_files(socket.assigns.adapter, path)

    assign(socket, :files, files)
  end

  defp session_manager do
    Application.fetch_env!(:ex_finder, :session_manager)
  end
end
