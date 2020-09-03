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

  @doc ~S"""
  Call a function using the same syntax as an element macro.

  `props` are supplied as a `Keyword` list, but they are passed to your function
  as a `Map`. Any children given through `:do` will be added under the
  `children` key of `props`.

  ## Examples

      iex> defmodule Components do
      ...>   def my_button(props) do
      ...>     button class: "blue #{props[:class]}" do
      ...>       props[:children]
      ...>     end
      ...>   end
      ...> end
      ...>
      ...> component Components.my_button, class: "rounded" do
      ...>   "Click Me!"
      ...> end
      ...> |> render()
      "<button class=\"blue rounded\">Click Me!</button>"
  """
  defmacro component(function) do
    call(function, quote(do: %{}))
  end

  defmacro component(function, do: expr) do
    call(function, quote(do: %{children: unquote(children(expr))}))
  end

  defmacro component(function, props) do
    call(function, quote(do: Map.new(unquote(props))))
  end

  defmacro component(function, props, do: expr) do
    props =
      quote bind_quoted: [props: props, children: children(expr)] do
        props |> Map.new() |> Map.put(:children, children)
      end

    call(function, props)
  end

  defp call({name, meta, _}, props), do: {name, meta, [props]}

  @doc """
  Write a `List` of elements as a block.

  This macro gives you the functionality of writing children like an element
  macro, but without a wrapping element.

  ## Examples

      iex> fragment do
      ...>   p(do: "Lorem ipsum")
      ...>   br()
      ...>   p(do: "Lorem ipsum")
      ...> end
      ...> |> render()
      "<p>Lorem ipsum</p><br><p>Lorem ipsum</p>"
  """
  defmacro fragment(do: expr) do
    quote bind_quoted: [children: children(expr)] do
      HTML.html_escape(children)
    end
  end

  @doc ~S"""
  Convert the result of the element macros or `fragment/1` to an HTML string.

  ## Examples

      iex> div(class: "my-class", do: "Lorem ipsum") |> render()
      "<div class=\"my-class\">Lorem ipsum</div>"
  """
  defdelegate render(content), to: HTML, as: :safe_to_string
end
