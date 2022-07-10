defmodule ExFinder.Folder do
  @moduledoc false

  alias ExFinder.Adapter

  @type t :: %__MODULE__{}

  @type folder_tree :: [t()]

  defstruct name: nil,
            path: nil,
            open?: false,
            root?: false,
            grandchildren_preload?: false,
            children: nil

  def tree_build(adapter) do
    [
      %__MODULE__{
        name: "Files",
        path: "/",
        root?: true
      }
    ]
    |> Enum.map(&Adapter.preload_children(adapter, &1))
  end

  def tree_get_folder!(tree, folder_path) do
    try do
      tree_walk_post_order(tree, fn folder ->
        if folder.path == folder_path do
          throw(folder)
        else
          folder
        end
      end)

      raise "Path doesn't exist"
    catch
      %__MODULE__{} = folder -> folder
    end
  end

  def tree_open_toggle(tree, folder_path, adapter) do
    tree_walk_post_order(tree, fn folder ->
      if folder.path == folder_path do
        open? = !folder.open?

        folder =
          if open? do
            preload_grandchildren(folder, adapter)
          else
            folder
          end

        %{folder | open?: open?}
      else
        folder
      end
    end)
  end

  def tree_open_path(tree, folder_path, adapter) do
    tree_walk_pre_order(tree, fn folder ->
      if String.starts_with?(folder_path, folder.path) do
        folder = preload_grandchildren(folder, adapter)
        %{folder | open?: true}
      else
        folder
      end
    end)
  end

  defp preload_grandchildren(
         %__MODULE__{
           grandchildren_preload?: false,
           children: children
         } = folder,
         adapter
       ) do
    children = Enum.map(children, &Adapter.preload_children(adapter, &1))

    %{folder | children: children, grandchildren_preload?: true}
  end

  defp preload_grandchildren(folder, _adapter) do
    folder
  end

  defp tree_walk_post_order(tree, updater) do
    tree_walk_post_order(tree, updater, [])
  end

  defp tree_walk_post_order([], _updater, acc) do
    Enum.reverse(acc)
  end

  defp tree_walk_post_order([folder | rest], updater, acc) do
    children =
      if is_list(folder.children) do
        tree_walk_post_order(folder.children, updater)
      else
        folder.children
      end

    folder = %__MODULE__{folder | children: children}

    tree_walk_post_order(rest, updater, [updater.(folder) | acc])
  end

  defp tree_walk_pre_order(tree, updater) do
    tree_walk_pre_order(tree, updater, [])
  end

  defp tree_walk_pre_order([], _updater, acc) do
    Enum.reverse(acc)
  end

  defp tree_walk_pre_order([folder | rest], updater, acc) do
    folder = updater.(folder)

    children =
      if is_list(folder.children) do
        tree_walk_pre_order(folder.children, updater)
      else
        folder.children
      end

    folder = %__MODULE__{folder | children: children}

    tree_walk_pre_order(rest, updater, [folder | acc])
  end
end
