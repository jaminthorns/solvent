defmodule ExHTML do
  import ExHTML.Util
  alias Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Kernel, except: [div: 2]
      import ExHTML
      import ExHTML.Elements
    end
  end

  @doc """
  Allows you to write a `List` of elements as a block.

  This macro gives you the functionality of writing children like the element
  macros, but without a wrapping element.

  ## Examples

      iex> fragment do
      ...>   p(do: "Lorem ipsum")
      ...>   br()
      ...>   p(do: "Lorem ipsum")
      ...> end |> render()
      "<p>Lorem ipsum</p><br><p>Lorem ipsum</p>"
  """
  defmacro fragment(do: expr) do
    quote bind_quoted: [children: children(expr)] do
      HTML.html_escape(children)
    end
  end

  @doc """
  Convert the result of the element macros or `fragment/1` to an HTML string.

  ## Examples

      iex> div(class: "my-class", do: "Lorem ipsum") |> render()
      "<div class=\\"my-class\\">Lorem ipsum</div>"
  """
  defdelegate render(content), to: HTML, as: :safe_to_string
end
