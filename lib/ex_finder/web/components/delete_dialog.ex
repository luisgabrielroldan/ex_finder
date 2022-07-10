defmodule ExFinder.Web.DeleteDialog do
  @moduledoc false

  use ExFinder.Web, :live_component

  alias ExFinder.{File, Folder}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div for="modal" class="modal-background" phx-click={@close_click}></div>
      <div id={@id} class="modal" style="height: 140px" phx-hook="Modal">
        <div class="modal-header">
          <h3><%= title(@item) %></h3>
          <div class="btn-close" phx-click={@close_click}>
            <i class="fa fa-close"></i>
          </div>
        </div>
        <div class="modal-body">
          <%= message(@item) %>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ok" phx-click="do_delete" phx-target={@myself}>Delete</button>
          <button class="btn btn-cancel" phx-click={@close_click}>Cancel</button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("do_delete", _params, socket) do
    send(self(), :delete_item)
    {:noreply, socket}
  end

  defp title(%Folder{}), do: "Rename folder"
  defp title(%File{}), do: "Rename file"

  defp message(%Folder{name: name}) do
    "Are you sure you want to delete the folder: \"#{name}\"?"
  end

  defp message(%File{name: name}) do
    "Are you sure you want to delete the file: \"#{name}\"?"
  end
end
