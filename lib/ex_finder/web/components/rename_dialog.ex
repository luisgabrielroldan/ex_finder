defmodule ExFinder.Web.RenameDialog do
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
          <form phx-change="update_input" phx-target={@myself}>
            <input type="text" name="value" value={@item.name} />
          </form>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ok" disabled={@ok_disabled} phx-click="do_rename" phx-target={@myself}>Rename</button>
          <button class="btn btn-cancel" phx-click={@close_click}>Cancel</button>
        </div>
      </div>
    </div>
    """
  end


  @impl true
  def handle_event("update_input", %{"value" => value}, socket) do
    value = String.trim(value)

    {:noreply,
      socket
      |> assign(:updated_value, value)
      |> assign(:ok_disabled, value == "")
    }
  end

  def handle_event("do_rename", _params, socket) do
    %{assigns: %{updated_value: value}} = socket
    send(self(), {:rename_item, value})
    {:noreply, socket}
  end

  @impl true
  def mount(socket) do
    {:ok,
      socket
      |> assign(:ok_disabled, true)
      |> assign(:updated_value, "")
    }
  end

  defp title(%Folder{}), do: "Delete folder"
  defp title(%File{}), do: "Delete file"

  def rename_disabled(%{assigns: %{updated_value: ""}}), do: true
  def rename_disabled(_socket), do: false
end
