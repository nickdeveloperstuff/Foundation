defmodule FoundationWeb.Components.LayoutHelpers do
  @spacing_scale %{
    1 => "4px",
    2 => "8px", 
    3 => "12px",
    4 => "16px",
    5 => "20px",
    6 => "24px",
    8 => "32px",
    10 => "40px",
    12 => "48px",
    16 => "64px",
    20 => "80px",
    24 => "96px"
  }

  def spacing_value(scale) when is_integer(scale) do
    Map.get(@spacing_scale, scale, "#{scale * 4}px")
  end

  def grid_span_class(span) when span in 1..12 do
    "span-#{span}"
  end

  def responsive_columns(base, tablet, desktop) do
    [
      "grid-cols-#{base}",
      "@md:grid-cols-#{tablet}",
      "@lg:grid-cols-#{desktop}"
    ]
  end
end