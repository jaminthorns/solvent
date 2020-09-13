defmodule Solvent do
  @moduledoc """
  Solvent is a simple
  [DSL](https://elixir-lang.org/getting-started/meta/domain-specific-languages.html)
  that lets you create HTML markup and reusable components directly in Elixir.

  If you look over the available functionality, you might notice several
  similarities to the feature set of the popular JavaScript library
  [React](https://reactjs.org/). This is no coincidence. React has popularized
  the idea of component-based UI and set a new standard for building interfaces.
  The syntax extension to JavaScript that is most often used with React,
  [JSX](https://reactjs.org/docs/introducing-jsx.html), makes markup a
  first-class citizen in code.

  You can think of Solvent like JSX for Elixir. It provides syntax for making
  markup and components easy to write in Elixir, and it builds on top of the
  [`phoenix_html`](https://hex.pm/packages/phoenix_html) library to implement
  HTML rendering. It is intended as an alternative to traditional template
  rendering (like [Phoenix
  templates](https://hexdocs.pm/phoenix/1.4.1/templates.html)).

  ## Usage

  To use Solvent, all you need to do is `use Solvent` in a module:

      use Solvent

  This will `import` all of the functions and macros in `Solvent` and
  `Solvent.Elements`. There is a macro available for [every tag in the HTML
  standard](https://developer.mozilla.org/en-US/docs/Web/HTML/Element).
  Unfortunately, one the most commonly used HTML tags, `div`, clashes with the
  `Kernel.div/2` function. So, if you `use Solvent` and want to use that
  function, you must call `Kernel.div/2` with the fully qualified name.

  You can create a single element like this:

      span()

  Children (text or elements) can be added with the `:do` keyword:

      span(do: "Hello World!")

  You can add attributes by passing additional keywords (see
  `Phoenix.HTML.Tag.tag/1` for information on data and boolean attributes):

      span(id: "greeting", do: "Hello World!")

  Multiple children (or a single child) can be added with a `do/end` block:

      article id: "post" do
        h1(do: "A Grand Adventure")

        p do
          \"\"\"
          I travelled the world this past summer. The landmarks, landscapes, and
          people were all amazing. I cannot recommand it enough.
          \"\"\"
        end
      end

  ### Fragments

  If you want to group some elements with a `do/end` block but don't want the
  extra markup of a wrapping element, use `fragment/1`:

      fragment do
        p(do: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
        p(do: "Maecenas eu porttitor tortor, eu volutpat erat.")
      end

  ### Conditional Rendering

  When `nil` is given as a child in a `do/end` block, it will be ignored. This
  makes conditional rendering straightforward with `if/2` or `unless/2` (which
  both return `nil` when `condition` evaluates to `false` and no `else` clause
  is provided):

      section do
        h1(do: "Your Trinkets")
        if(length(trinkets) > 10, do: aside(do: "That's a lot of trinkets!"))
        ul(do: Enum.map(trinkets, fn trinket -> li(do: trinket.description) end))
      end

  ### Components

  What if you want to reuse a bit of markup? You can easily do that with a
  functions:

      def banner(title, subtitle) do
        section class: "banner" do
          h1(title)
          p(subtitle)
        end
      end

      def items_by_category(items, category) do
        items
        |> Enum.filter(fn item -> item.category == category end)
        |> Enum.map(fn item -> li(do: item.label) end)
      end

      # ...

      main do
        section do
          banner("Electronics", "TVs, Home Audio, Videogames")
          ul(do: items_by_category(items, :home_goods))
        end

        section do
          banner("Home Goods", "Furniture, Storage, Outdoor Tools")
          ul(do: items_by_category(items, :electronics))
        end
      end

  This works just fine in most cases, but for more complex reusable pieces of
  markup, you might benefit from a similar interface as the element macros, with
  a keyword list of named arguments and an optional `do/end` block for children.
  That's what `component/3` is for:

      def question(props) do
        details do
          summary(class: "question", do: props[:question])

          div class: "answer" do
            props[:children]
          end
        end
      end

      # ...

      section class: "questions" do
        component &question/1, question: "How do I enter the race?" do
          p(do: "Submit your details through the entry form.")
        end

        component &question/1, question: "How can I win the race?" do
          ul do
            li(do: "Train regularly")
            li(do: "Eat healthy")
            li(do: "Drink water")
          end
        end
      end

  The function that you pass to `component/3` must be a 1-arity function that
  receives a keyword list (`props`). If children are given with `:do`, they will
  be available under the `:children` key.
  """

  import Solvent.Util
  alias Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Kernel, except: [div: 2]
      import Solvent
      import Solvent.Elements
    end
  end

  @doc """
  Call a "component function" using the same syntax as an element macro.

  See `component/3`.
  """
  defmacro component(fun) do
    quote do: unquote(fun).([])
  end

  @doc """
  Call a "component function" using the same syntax as an element macro.

  See `component/3`.
  """
  defmacro component(fun, do: expr) do
    quote do: unquote(fun).(children: unquote(children(expr)))
  end

  defmacro component(fun, props) do
    quote do: unquote(fun).(unquote(props))
  end

  @doc ~S"""
  Call a "component function" using the same syntax as an element macro.

  Any children passed under the `:do` key will be availabled under the
  `:children` key of `props`.

  ## Examples

      iex> defmodule Components do
      ...>   def link_button(props) do
      ...>     a href: props[:href] do
      ...>       button class: "link #{props[:class]}" do
      ...>         props[:children]
      ...>       end
      ...>     end
      ...>   end
      ...> end
      ...>
      ...> component &Components.link_button/1, href: "/about", class: "rounded" do
      ...>   "About Us"
      ...> end
      ...> |> render()
      "<a href=\"/about\"><button class=\"link rounded\">About Us</button></a>"
  """
  defmacro component(fun, props, children)

  defmacro component(fun, props, do: expr) do
    quote do: unquote(fun).(Keyword.put(unquote(props), :children, unquote(children(expr))))
  end

  @doc """
  Write multiple elements in a block.

  This macro gives you the functionality of writing children in `do/end` block
  like `component/3` or an element macro, but without a wrapping element.

  ## Examples

      iex> fragment do
      ...>   p(do: "Lorem ipsum.")
      ...>   br()
      ...>   p(do: "Maecenas eu.")
      ...> end
      ...> |> render()
      "<p>Lorem ipsum.</p><br><p>Maecenas eu.</p>"
  """
  defmacro fragment(children)

  defmacro fragment(do: expr) do
    quote bind_quoted: [children: children(expr)] do
      HTML.html_escape(children)
    end
  end

  @doc ~S"""
  Convert the result of `component/3`, `fragment/1`, or an element macro to an
  HTML string.

  ## Examples

      iex> div(class: "my-class", do: "Lorem ipsum") |> render()
      "<div class=\"my-class\">Lorem ipsum</div>"
  """
  defdelegate render(content), to: HTML, as: :safe_to_string
end
