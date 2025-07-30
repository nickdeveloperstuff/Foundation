defmodule FoundationWeb.TesterDemoLive do
  use FoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1>Placeholder Page</h1>
      <p>Replace this with actual content later.</p>
    </div>
    """
  end
end