defmodule ExFinder do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)
end
