defmodule ExHTML.Util do
  @moduledoc false

  @doc false
  def children({:__block__, _, children}) do
    quote bind_quoted: [children: children] do
      case Enum.reject(children, &is_nil/1) do
        [] -> nil
        children -> children
      end
    end
  end

  def children(child), do: child
end
