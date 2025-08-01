defmodule FoundationWeb.Live.Subscriptions do
  @moduledoc """
  ⚠️ CUSTOM CONVENTION ⚠️
  
  Utilities for safe Phoenix.PubSub subscriptions in LiveViews.
  
  WHY THIS EXISTS:
  - Standard Phoenix.PubSub.subscribe/2 can error during LiveView mount
  - The socket isn't connected during the first mount/3 call
  - This causes subscription errors in the logs
  
  STANDARD PHOENIX WAY:
    def mount(_, _, socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "topic")  # Can error!
      {:ok, socket}
    end
  
  OUR WAY:
    def mount(_, _, socket) do
      socket = Subscriptions.safe_subscribe(socket, "topic")
      {:ok, socket}
    end
  
  This ensures subscriptions only happen when the socket is connected.
  """
  
  require Logger
  
  def safe_subscribe(socket, topic) when is_binary(topic) do
    if Phoenix.LiveView.connected?(socket) do
      Phoenix.PubSub.subscribe(Foundation.PubSub, topic)
      Logger.debug("Subscribed to #{topic}")
    end
    socket
  end
  
  def safe_subscribe_many(socket, topics) when is_list(topics) do
    Enum.reduce(topics, socket, &safe_subscribe(&2, &1))
  end
end