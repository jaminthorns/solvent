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

  Any children passed through the `:do` key will be added under the `:children`
  key of `props`.

  ## Examples

      iex> defmodule Components do
      ...>   def my_button(props) do
      ...>     button class: "blue #{props[:class]}" do
      ...>       props[:children]
      ...>     end
      ...>   end
      ...> end
      ...>
      ...> component &Components.my_button/1, class: "rounded" do
      ...>   "Click Me!"
      ...> end
      ...> |> render()
      "<button class=\"blue rounded\">Click Me!</button>"
  """
  defmacro component(fun) do
    quote do: unquote(fun).([])
  end

  defmacro component(fun, do: expr) do
    quote do: unquote(fun).(children: unquote(children(expr)))
  end

  defmacro component(fun, props) do
    quote do: unquote(fun).(unquote(props))
  end

  defmacro component(fun, props, do: expr) do
    quote do: unquote(fun).(Keyword.put(unquote(props), :children, unquote(children(expr))))
  end

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
