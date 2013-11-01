module LiquidFilters
  def rgb_alpha(rgb, alpha)
    LiquidFilters.rgb_alpha(rgb, alpha)
  end
  
  def LiquidFilters.rgb_alpha(rgb, alpha)
    rgb.to_s.gsub("rgb", "rgba").gsub(")", ", #{alpha})")
  end
  
  def add_details(nav, *args)
    args.each do |page|
      split = page.to_s.split(":")
      
      if split.size > 1
        nav = nav.gsub(split.first, "#{split.first}<span class=\"detail\">#{split.last}</span>")
      end
    end
    
    nav
  end
end