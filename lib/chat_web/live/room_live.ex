defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    topic = "room:" <> params["id"]
    username = params["username"] || Faker.Internet.user_name
    ChatWeb.Endpoint.subscribe(topic)

    {:ok,
      assign(
        socket,
        room_name: params["id"],
        topic: topic,
        username: username,
        message: "",
        messages: [%{username: "System", content: "#{username} joined the chat"}],
        nbr_messages: 1,
        temporary_assigns: [messages: []]
    )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{username: socket.assigns.username , content: message }
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message], nbr_messages: (socket.assigns.nbr_messages + 1))}
  end

end