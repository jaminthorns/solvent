defmodule ExHTMLTest do
  use ExUnit.Case
  use ExHTML

  doctest ExHTML

  @class "test-class"
  @text "test text"

  test "generates an element with no attributes or children" do
    div()
    |> renders_to("<div>")
  end

  test "generates an element with attributes and no children" do
    div(class: @class)
    |> renders_to("<div class=\"#{@class}\">")
  end

  test "generates an element with child text and no attributes" do
    div(do: @text)
    |> renders_to("<div>#{@text}</div>")
  end

  test "generates an element with attributes and child text" do
    div(class: @class, do: @text)
    |> renders_to("<div class=\"#{@class}\">#{@text}</div>")
  end

  test "generates an element with child elements and no attributes" do
    span_html = "<span>#{@text}</span>"

    div do
      span(do: @text)
      span(do: @text)
    end
    |> renders_to("<div>#{span_html}#{span_html}</div>")
  end

  test "generates an element with attributes and child elements" do
    child_tag = "<span>#{@text}</span>"

    div class: @class do
      span(do: @text)
      span(do: @text)
    end
    |> renders_to("<div class=\"#{@class}\">#{child_tag}#{child_tag}</div>")
  end

  test "generates an element with interspersed child text and elements" do
    child_tag = "<span>#{@text}</span>"
    children = "#{@text}#{child_tag}#{@text}#{child_tag}#{@text}"

    div class: @class do
      @text
      span(do: @text)
      @text
      span(do: @text)
      @text
    end
    |> renders_to("<div class=\"#{@class}\">#{children}</div>")
  end

  test "generates an element with interspersed child elements and fragments" do
    child_tag = "<span>#{@text}</span>"
    children = "#{child_tag}#{child_tag}#{child_tag}#{child_tag}"

    div class: @class do
      span(do: @text)

      fragment do
        span(do: @text)
        span(do: @text)
      end

      span(do: @text)
    end
    |> renders_to("<div class=\"#{@class}\">#{children}</div>")
  end

  test "generates an element with child elements as variables" do
    child_tag = "<span>#{@text}</span>"
    children = "#{child_tag}#{child_tag}#{child_tag}"

    element = span(do: @text)

    elements =
      fragment do
        span(do: @text)
        span(do: @text)
      end

    div class: @class do
      element
      elements
    end
    |> renders_to("<div class=\"#{@class}\">#{children}</div>")
  end

  defp renders_to(content, html) do
    assert render(content) == html
  end
end
