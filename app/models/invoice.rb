class Invoice < ActiveRecord::Base
  serialize :lines, Array
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
          addon = a.addon
          description = addon.name
          description = "#{addon.name} (#{Invoice.helpers.number_to_currency addon.price / 100} x #{a.quantity.to_i})" if addon.quantifiable?
          addon.quantifiable? ? addon_price = addon.price.to_i * a.quantity.to_i : addon_price = addon.price.to_i
        
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
  
  def visible_id
    stripe_id.to_s[-10, 8].upcase
  end
  
  def self.helpers
    ActionController::Base.helpers
  end
end
