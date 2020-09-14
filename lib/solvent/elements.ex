defmodule Solvent.Elements do
  @moduledoc """
  An "element macro" is a helper for creating an HTML element.

  Their purpose is to provide a nicer syntax around the `Phoenix.HTML.Tag.tag/1`
  and `Phoenix.HTML.Tag.content_tag/2` functions. An element macro is generated
  for every tag in the HTML standard, so you should be able to write all of your
  HTML using these macros.
  """

  import Solvent.Util
  alias Phoenix.HTML.Tag

  @external_resource "priv/tags.txt"
  @tags "priv/tags.txt" |> File.read!() |> String.split() |> Enum.map(&String.to_atom/1)

  for tag <- @tags do
    name = Atom.to_string(tag)
    article = if String.first(name) in ~w(a e i o u), do: "an", else: "a"

    doc = """
    Create #{article} [`#{tag}`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/#{tag}) element.
    """

    @doc doc
    defmacro unquote(tag)() do
      quote bind_quoted: [tag: unquote(tag)] do
        element(tag, [])
      end
    end

    @doc doc
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

    @doc doc
    defmacro unquote(tag)(attrs, do: expr) do
      quote bind_quoted: [tag: unquote(tag), attrs: attrs, children: children(expr)] do
        element(tag, Keyword.put(attrs, :do, children))
      end
    end
  end

  @doc false
  def element(tag, attrs) do
    has_children? = Keyword.has_key?(attrs, :do)
    {children, attrs} = Keyword.pop(attrs, :do)

    case {has_children?, attrs} do
      {false, []} -> Tag.tag(tag)
      {false, attrs} -> Tag.tag(tag, attrs)
      {true, []} -> Tag.content_tag(tag, children)
      {true, attrs} -> Tag.content_tag(tag, children, attrs)
    end
  end
end
