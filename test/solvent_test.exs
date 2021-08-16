defmodule SolventTest do
  use ExUnit.Case
  use Solvent

  doctest Solvent

  @class "test-class"
  @text "test text"

  describe "element" do
    test "renders with no attributes or children (no closing tag)" do
      div()
      |> renders_to("<div>")
    end

    test "renders with no attributes or children (closing tag)" do
      div(do: nil)
      |> renders_to("<div></div>")
    end

    test "renders with attributes and no children" do
      div(class: @class)
      |> renders_to("<div class=\"#{@class}\">")
    end

    test "renders with child text and no attributes" do
      div(do: @text)
      |> renders_to("<div>#{@text}</div>")
    end

    test "renders with attributes and child text" do
      div(class: @class, do: @text)
      |> renders_to("<div class=\"#{@class}\">#{@text}</div>")
    end

    test "renders with child elements and no attributes" do
      child = "<span>#{@text}</span>"

      div do
        span(do: @text)
        span(do: @text)
      end
      |> renders_to("<div>#{child}#{child}</div>")
    end

    test "renders with attributes and child elements" do
      child = "<span>#{@text}</span>"

      div class: @class do
        span(do: @text)
        span(do: @text)
      end
      |> renders_to("<div class=\"#{@class}\">#{child}#{child}</div>")
    end
  end

  describe "fragment" do
    test "renders without wrapping element" do
      child = "<span>#{@text}</span>"

      fragment do
        span(do: @text)
        span(do: @text)
      end
      |> renders_to("#{child}#{child}")
    end
  end

  describe "component" do
    test "renders with props and no children" do
      component(&my_button/1, toggled?: true)
      |> renders_to("<button class=\"toggled\"></button>")
    end

    test "renders with children passed through keyword and no props" do
      component(&my_button/1, do: @text)
      |> renders_to("<button>#{@text}</button>")
    end

    test "renders with props and children passed through keyword" do
      component(&my_button/1, toggled?: true, do: @text)
      |> renders_to("<button class=\"toggled\">#{@text}</button>")
    end

    test "renders with props and children passed through block" do
      component &my_button/1, toggled?: true do
        @text
      end
      |> renders_to("<button class=\"toggled\">#{@text}</button>")
    end
  end

  describe "sigil_j" do
    test "renders JavaScript within a <script> tag" do
      ~j"console.log('test')"
      |> renders_to("<script>console.log('test')</script>")
    end
  end

  defp my_button(props) do
    toggled? = Keyword.get(props, :toggled?, false)
    class = if(toggled?, do: "toggled")

    button class: class do
      props[:children]
    end
  end

  defp renders_to(content, html) do
    assert render(content) == html
  end
end
