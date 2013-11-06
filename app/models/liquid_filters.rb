module LiquidFilters
  def rgba(rgb, alpha)
    LiquidFilters.rgba(rgb, alpha)
  end
  
  def LiquidFilters.rgba(rgb, alpha)
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