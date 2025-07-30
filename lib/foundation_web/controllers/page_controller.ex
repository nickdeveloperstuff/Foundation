defmodule FoundationWeb.PageController do
  use FoundationWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
