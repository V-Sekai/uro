defmodule UroWeb.TestView do
  use UroWeb, :view
  alias UroWeb.TestView

  def render("index.json", %{tests: tests}) do
    %{data: render_many(tests, TestView, "test.json")}
  end

  def render("show.json", %{test: test}) do
    %{data: render_one(test, TestView, "test.json")}
  end

  def render("test.json", %{test: test}) do
    %{id: test.id,
      name: test.name,
      age: test.age}
  end
end
