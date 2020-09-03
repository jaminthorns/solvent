defmodule ExHTML.Util do
  @moduledoc false

  @doc false
  def children({:__block__, _, children}) do
    quote bind_quoted: [children: children] do
      Enum.reject(children, &is_nil/1)
    end
  end

  def children(child), do: child
end
