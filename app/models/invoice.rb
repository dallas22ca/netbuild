class Invoice < ActiveRecord::Base
  attr_accessor :email
  
  serialize :lines, Array
  belongs_to :membership
  has_one :website, through: :membership
  
  before_validation :set_visible_id
  after_create :email_invoice, if: Proc.new { email }
  validates_presence_of :visible_id, :subtotal, :total
  
  def email_invoice
    website.messages.create!(
      to: [membership_id],
      subject: "New Invoice", 
      plain: "Here is a link to your new invoice.\n\n#{Rails.application.routes.url_helpers.public_page_url("invoices", id: visible_id, format: :pdf, subdomain: website.permalink, host: CONFIG["domain"])}\n\n#{website.invoice_blurb}", 
      user_id: website.memberships.admin.first.user_id
    )
    update_columns public_access: true
  end
  
  def set_visible_id
    if stripe_id.blank?
      self.visible_id = SecureRandom.urlsafe_base64(4).gsub(/-|_/, "").upcase
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
  
  def quick_summary
    "#{visible_id} (#{Invoice.helpers.number_to_currency total_in_dollars})"
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
