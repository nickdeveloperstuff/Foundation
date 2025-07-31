defmodule FoundationWeb.TestHelper do
  @moduledoc """
  Helper functions for testing widget integration
  """
  
  def screenshot(path, filename, opts \\ []) do
    # Ensure screenshots directory exists
    File.mkdir_p!("screenshots")
    
    # Construct full URL
    url = "http://localhost:4000#{path}"
    full_path = Path.join(["screenshots", filename])
    
    IO.puts("Taking screenshot of #{url}")
    IO.puts("Saving to: #{full_path}")
    
    # For now, return a placeholder
    # Playwright integration will be added by the developer
    {:ok, full_path}
  end
  
  def test_connection do
    {:ok, "Test helper connected successfully!"}
  end
end