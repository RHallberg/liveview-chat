defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(_session, socket) do
    {:ok, assign(socket, msg: "none")}
  end

  @impl
  def handle_event("random-room", _params, socket) do
    random_slug = "/chat/" <> String.downcase(Faker.Nato.format("?-?-?-?"))
    Logger.info(random_slug)
    {:noreply, push_redirect(socket, to: random_slug)}
  end


end