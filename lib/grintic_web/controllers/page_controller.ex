defmodule GrinticWeb.PageController do
  use GrinticWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
