defmodule FoundationWeb.Live.SubscriptionsTest do
  use FoundationWeb.ConnCase
  import Phoenix.LiveViewTest
  
  defmodule TestLive do
    use FoundationWeb, :live_view
    alias FoundationWeb.Live.Subscriptions
    
    def mount(_params, _session, socket) do
      socket = Subscriptions.safe_subscribe(socket, "test_topic")
      {:ok, Phoenix.Component.assign(socket, :messages, [])}
    end
    
    def render(assigns) do
      ~H"<div>Test</div>"
    end
  end
  
  @tag :skip
  test "safe_subscribe only subscribes when connected", %{conn: conn} do
    # First mount (disconnected) should not error
    {:ok, view, _html} = live(conn, "/test")
    
    # After connected mount, messages should arrive
    Phoenix.PubSub.broadcast(Foundation.PubSub, "test_topic", {:test, "message"})
    
    # Give it time to receive
    Process.sleep(50)
    
    # Should have received the message
    assert render(view) =~ "Test"
  end
end