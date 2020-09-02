defmodule ExHTML.Elements do
  import ExHTML.Util
  alias Phoenix.HTML.Tag

  @external_resource "priv/tags.txt"
  @tags "priv/tags.txt" |> File.read!() |> String.split() |> Enum.map(&String.to_atom/1)

  for tag <- @tags do
    defmacro unquote(tag)() do
      quote bind_quoted: [tag: unquote(tag)] do
        element(tag, [])
      end
    end

    defmacro unquote(tag)(do: expr) do
      quote bind_quoted: [tag: unquote(tag), children: children(expr)] do
        element(tag, do: children)
      end
    end

    defmacro unquote(tag)(attrs) do
      quote bind_quoted: [tag: unquote(tag), attrs: attrs] do
        element(tag, attrs)
      end
    end

    defmacro unquote(tag)(attrs, do: expr) do
      quote bind_quoted: [tag: unquote(tag), attrs: attrs, children: children(expr)] do
        element(tag, Keyword.put(attrs, :do, children))
      end
    end
  end

  @doc false
  def element(tag, attrs) do
    case Keyword.pop(attrs, :do) do
      {nil, []} -> Tag.tag(tag)
      {nil, attrs} -> Tag.tag(tag, attrs)
      {children, []} -> Tag.content_tag(tag, children)
      {children, attrs} -> Tag.content_tag(tag, children, attrs)
    end
  end
end
