defmodule ExFinder.File do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct name: nil,
            path: nil
end
