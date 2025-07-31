defmodule FoundationWeb.WidgetData do
  @moduledoc """
  Centralized data management for widgets.
  Handles both static and Ash data sources.
  """
  
  # Import Ash for data operations
  import Ash.Query
  
  @doc """
  Assigns widget data to socket based on data source
  """
  def assign_widget_data(socket, :static) do
    # Use existing static data functions
    socket
  end
  
  def assign_widget_data(socket, :ash) do
    # KPI data
    kpi_data = %{
      revenue: "89,432",
      revenue_growth: 12,
      active_users: "1,892",
      user_growth: 8,
      new_signups: 156,
      signup_rate: 22,
      churn_rate: 2.3,
      churn_change: 0.5
    }
    
    # Activity data
    activities = [
      %{id: 1, time: "2 mins ago", user: "john.doe@example.com", action: "Upgraded to Pro plan", status: "success"},
      %{id: 2, time: "15 mins ago", user: "sarah.smith@example.com", action: "Created new project", status: "success"},
      %{id: 3, time: "1 hour ago", user: "mike.jones@example.com", action: "Payment failed", status: "failed"}
    ]
    
    socket
    |> Phoenix.Component.assign(:kpi_data, kpi_data)
    |> Phoenix.Component.assign(:recent_activities, activities)
  end
  
  @doc """
  Subscribe to real-time updates for widget data
  """
  def subscribe_to_updates(topics) when is_list(topics) do
    Enum.each(topics, fn topic ->
      Phoenix.PubSub.subscribe(Foundation.PubSub, "widget_data:#{topic}")
    end)
    :ok
  end

  @doc """
  Broadcast an update to all subscribed clients
  """
  def broadcast_update(topic, data) do
    Phoenix.PubSub.broadcast(
      Foundation.PubSub,
      "widget_data:#{topic}",
      {:widget_data_updated, topic, data}
    )
  end
  
  @doc """
  Test function to verify module is loaded
  """
  def test_module do
    {:ok, "WidgetData module loaded successfully!"}
  end
end