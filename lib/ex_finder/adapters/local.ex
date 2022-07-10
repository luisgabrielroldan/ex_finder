defmodule ExFinder.Adapters.Local do
  @moduledoc """
  Local file system adapter
  """

  alias ExFinder.File, as: FileStruct
  alias ExFinder.Folder

  alias __MODULE__, as: Local

  defstruct [:base_path, :base_uri]

  @opaque t :: %__MODULE__{}
  @type path :: binary()
  @type url :: binary()

  @doc """
  Configures a new adapter with the given configuration
  """

  @spec new(path(), url()) :: t()
  def new(base_path, base_url) do
    %__MODULE__{
      base_path: Path.expand(base_path),
      base_uri: URI.parse(base_url)
    }
  end

  @doc false
  def get_folders(%__MODULE__{} = adapter, path) do
    adapter
    |> file_entries(path)
    |> filter_directories()
    |> Enum.map(fn {relative_path, _dir?} ->
      %Folder{
        name: Path.basename(relative_path),
        path: relative_path,
        children: nil
      }
    end)
    |> Enum.sort_by(fn %{name: name} -> name end)
  end

  @doc false
  def get_files(%__MODULE__{} = adapter, path) do
    adapter
    |> file_entries(path)
    |> filter_files()
    |> Enum.map(fn {relative_path, _dir?} ->
      %FileStruct{
        name: Path.basename(relative_path),
        path: relative_path
      }
    end)
    |> Enum.sort_by(fn %{name: name} -> name end)
  end

  @doc false
  def preload_children(%__MODULE__{} = adapter, %Folder{} = folder) do
    %{folder | children: get_folders(adapter, folder.path)}
  end

  @doc false
  def get_url(%__MODULE__{base_uri: base_uri}, %Folder{path: path}) do
    %{base_uri | path: Path.join([base_uri.path, path])} |> URI.to_string()
  end

  @doc false
  def get_url(%__MODULE__{base_uri: base_uri}, %FileStruct{path: path}) do
    %{base_uri | path: Path.join([base_uri.path, path])} |> URI.to_string()
  end

  @doc false
  def rename(%__MODULE__{} = adapter, %item_type{path: path} = item, new_name)
      when item_type in [Folder, FileStruct] do
    new_path = [Path.dirname(path), new_name] |> Path.join()

    File.rename(
      fullpath(path, adapter),
      fullpath(new_path, adapter)
    )
    |> case do
      :ok -> {:ok, %{item | path: new_path, name: Path.basename(new_path)}}
      {:error, reason} -> {:error, translate_error(reason)}
    end
  end

  @doc false
  def delete(%__MODULE__{} = adapter, %item_type{path: path})
      when item_type in [Folder, FileStruct] do
    path
    |> fullpath(adapter)
    |> File.rm_rf()
    |> case do
      {:ok, _files} -> :ok
      {:error, reason} -> {:error, translate_error(reason)}
    end
  end

  defp translate_error(:enoent), do: "File doesn't exist"
  defp translate_error(:eaccess), do: "Access error"
  defp translate_error(:eperm), do: "Insufficient permissions"
  defp translate_error(:enotdir), do: "Invalid directory"
  defp translate_error(reason), do: "Error: #{reason}"

  defp filter_directories(entries) do
    Enum.filter(entries, fn {_path, dir?} -> dir? end)
  end

  defp filter_files(entries) do
    Enum.filter(entries, fn {_path, dir?} -> not dir? end)
  end

  defp file_entries(adapter, path) do
    path
    |> fullpath(adapter)
    |> File.ls()
    |> case do
      {:ok, list} ->
        Enum.map(list, fn name ->
          relative_path = Path.join([path, name])

          is_dir? =
            relative_path
            |> fullpath(adapter)
            |> File.dir?()

          {relative_path, is_dir?}
        end)

      _ ->
        []
    end
  end

  defp fullpath(path, %__MODULE__{base_path: base_path}) do
    Path.join([base_path, path])
  end

  defimpl ExFinder.Adapter do
    def get_folders(adapter, path) do
      Local.get_folders(adapter, path)
    end

    def get_files(adapter, path) do
      Local.get_files(adapter, path)
    end

    def preload_children(adapter, folder) do
      Local.preload_children(adapter, folder)
    end

    def get_url(adapter, folder) do
      Local.get_url(adapter, folder)
    end

    def rename(adapter, item, new_name) do
      Local.rename(adapter, item, new_name)
    end

    def delete(adapter, item) do
      Local.delete(adapter, item)
    end
  end
end
