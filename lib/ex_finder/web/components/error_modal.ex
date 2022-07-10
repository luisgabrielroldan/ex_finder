defmodule ExFinder.Web.ErrorModal do
  @moduledoc false

  use ExFinder.Web, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div for="modal" class="modal-background"></div>
      <div id={@id} class="modal" style={"height: #{@height}"} phx-hook="Modal">
        <div class="modal-header">
          <h3><%= @title %></h3>
          <div class="btn-close" phx-click={@close_click}>
            <i class="fa fa-close"></i>
          </div>
        </div>
        <div class="modal-body">
          <%= render_block(@inner_block) %>
        </div>
        <div class="modal-footer">
          <button class="btn btn-cancel" phx-click={@close_click}>Ok</button>
        </div>
      </div>
    </div>
    """
  end
end
