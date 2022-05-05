defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    topic = "room:" <> params["id"]
    username = params["username"] || Faker.Internet.user_name
     if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, username, %{})
     end

    {:ok,
      assign(
        socket,
        room_name: params["id"],
        topic: topic,
        username: username,
        message: "",
        messages: [%{username: "System", content: "Welcome to the chat :)"}],
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

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages = joins
      |> Map.keys()
      |> Enum.map(fn username -> %{username: "System", content: "#{username} joined"} end)
    leave_messages = leaves
      |> Map.keys()
      |> Enum.map(fn username -> %{username: "System", content: "#{username} left"} end)
    {:noreply, assign(socket, messages: join_messages ++ leave_messages, nbr_messages: (socket.assigns.nbr_messages + 1))}
  end

end