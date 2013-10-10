class Invoice < ActiveRecord::Base
  belongs_to :website
  
  def self.add_addons_to_invoices(id = false)
    if id
      websites = Website.where(id: id)
    else
      websites = Website.all
    end
    
    for website in websites.connected_to_stripe
      upcoming = Stripe::Invoice.upcoming(customer: website.customer_token)
      
      if upcoming.lines.data.size <= 1
        for a in website.addonships
          addon = a.addon
          description = addon.name
          description = "#{addon.name} (#{Invoice.helpers.number_to_currency addon.price / 100} x #{a.quantity})" if addon.quantifiable?
        
          item = Stripe::InvoiceItem.create(
            customer: website.customer_token,
            amount: addon.price * a.quantity,
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
