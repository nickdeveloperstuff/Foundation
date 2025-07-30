defmodule FoundationWeb.Storybook.Layouts.DashboardExample do
  use Phoenix.LiveView
  
  def render(assigns) do
    ~H"""
    <.dashboard_layout>
      <:sidebar>
        <.navigation_widget brand="Dashboard">
          <:nav_item path="/dashboard" active>Overview</:nav_item>
          <:nav_item path="/users">Users</:nav_item>
          <:nav_item path="/settings">Settings</:nav_item>
        </.navigation_widget>
      </:sidebar>
      
      <.grid_layout>
        <.card_widget span={4}>
          <:header>Total Users</:header>
          <div class="text-3xl font-bold">1,234</div>
        </.card_widget>
        
        <.card_widget span={4}>
          <:header>Active Sessions</:header>
          <div class="text-3xl font-bold">89</div>
        </.card_widget>
        
        <.card_widget span={4}>
          <:header>Revenue</:header>
          <div class="text-3xl font-bold">$12,345</div>
        </.card_widget>
      </.grid_layout>
    </.dashboard_layout>
    """
  end
end