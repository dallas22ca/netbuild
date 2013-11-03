class Invoice < ActiveRecord::Base
  serialize :lines, Array
  belongs_to :membership
  has_one :website, through: :membership
  
  before_validation :set_visible_id
  validates_presence_of :visible_id
  
  def set_visible_id
    if stripe_id.blank?
      self.visible_id = SecureRandom.hex(4).upcase
    else
      self.visible_id = self.stripe_id.to_s.gsub("in_", "").to_i.to_s(36).upcase
    end
  end
  
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
  
  def self.helpers
    ActionController::Base.helpers
  end
  
  def to_param
    visible_id
  end
  
  def tax
    total - subtotal
  end
  
  def tax_in_dollars
    tax_in_dollars = '%.2f' % (tax / 100.00)
    tax_in_dollars = '%.2f' % 0 unless tax_in_dollars 
  end
  
  def total_in_dollars
    '%.2f' % (total / 100.00) if total
  end

  def total_in_dollars=(dollars)
    self.total = dollars.to_f * 100 if dollars.present?
  end
  
  def subtotal_in_dollars
    '%.2f' % (subtotal / 100.00) if subtotal
  end

  def subtotal_in_dollars=(dollars)
    self.subtotal = dollars.to_f * 100 if dollars.present?
  end
end
