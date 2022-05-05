defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_name}, _session, socket) do
    topic = "room:" <> room_name
    ChatWeb.Endpoint.subscribe(topic)

    {:ok,
      assign(
        socket,
        room_name: room_name,
        topic: topic,
        messages: ["Someone joined the chat"],
        nbr_messages: 1,
        temporary_assigns: [messages: []]
    )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message], nbr_messages: (socket.assigns.nbr_messages + 1))}
  end

end