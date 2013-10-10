class Invoice < ActiveRecord::Base
  belongs_to :website
  
  def self.add_addons_to_invoices(website = false)
    if website
      websites = [website]
    else
      websites = Website.connected_to_stripe
    end
    
    for website in websites
      begin
        upcoming = Stripe::Invoice.upcoming(customer: website.customer_token)
      rescue
      end
      
      if !upcoming || upcoming.lines.data.size <= 1
        for a in Addonship.where(website_id: website.id)
          p ">>> GETS HERE 3"
          addon = a.addon
          description = addon.name
          description = "#{addon.name} (#{Invoice.helpers.number_to_currency addon.price / 100} x #{a.quantity})" if addon.quantifiable?
          addon.quantifiable? ? addon_price = addon.price * a.quantity : addon_price = addon.price
        
          item = Stripe::InvoiceItem.create(
            customer: website.customer_token,
            amount: addon_price,
            currency: "cad",
            description: description
          )
        end
      end
    end
  end
  
  def self.helpers
    ActionController::Base.helpers
  end
end
