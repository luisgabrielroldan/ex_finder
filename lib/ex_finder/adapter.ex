defprotocol ExFinder.Adapter do
  @moduledoc false

  def get_folders(adapter, path)
  def get_files(adapter, path)
  def preload_children(adapter, folder)
  def get_url(adapter, item)
  def rename(adapter, item, new_name)
  def delete(adapter, item)
end
