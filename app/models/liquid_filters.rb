module LiquidFilters
  def rgb_alpha(rgb, alpha)
    LiquidFilters.rgb_alpha(rgb, alpha)
  end
  
  def LiquidFilters.rgb_alpha(rgb, alpha)
    rgb.to_s.gsub("rgb", "rgba").gsub(")", ", #{alpha})")
  end
  
  # def render(title)
  #   @website.documents.partials.where(name: title).first.body
  # end
end