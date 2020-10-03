# Solvent

> An Elixir library for creating HTML markup and
> [React](https://reactjs.org/)-like components.

## Installation

This library is not yet available in Hex, but it can still be directly installed
from GitHub:

```elixir
def deps do
  [
    {:solvent, github: "jaminthorns/solvent"}
  ]
end
```

## Usage

Just `use Solvent` to write HTML directly in Elixir:

```elixir
defmodule Components do
  use Solvent

  def page do
    page_title = "A Blog About Interesting Things"

    html do
      head do
        title(do: page_title)
      end

      body do
        header class: "page-header" do
          h1(class: "page-title", do: page_title)
        end

        main class: "posts" do
          h2(do: "Posts")
          posts()
        end
      end
    end
  end

  defp posts do
    fragment do
      component &post/1, title: "First Post" do
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus non
        faucibus mauris. Cras nec imperdiet justo, pretium elementum felis.
        """
      end

      component &post/1, title: "Second Post" do
        """
        Praesent suscipit, purus sed convallis lacinia, tortor enim
        fermentum diam, vitae mollis justo lectus ut augue. Nam id ornare
        ligula.
        """
      end

      component &post/1, title: "Third Post" do
        """
        Quisque leo augue, vehicula non sem eget, tincidunt pretium sem.
        Duis aliquam purus sed massa porttitor ullamcorper.
        """
      end
    end
  end

  defp post(props) do
    article class: "post" do
      h3(class: "post-title", do: props[:title])
      p(class: "post-text", do: props[:children])
    end
  end
end
```

See the documentation for more details.
