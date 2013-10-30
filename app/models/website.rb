class Website < ActiveRecord::Base
  attr_accessor :duplicate_theme, :card_token, :warnings
  
  belongs_to :theme, touch: true
  belongs_to :home, class_name: "Page", foreign_key: "home_id"
  
  has_many :wrappers, dependent: :destroy
  has_many :blocks, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :themes, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :addonships, dependent: :destroy
  has_many :addons, through: :addonships
  has_many :invoices
  
  accepts_nested_attributes_for :members
  
  before_validation :permalink_is_not_safe, if: Proc.new { |p| %w[app secure www help manage support].include? p.permalink }
  before_validation :theme_does_not_have_default_document, if: Proc.new { theme_id_changed? && theme.default_document_id.blank? }
  before_validation :create_permalink, if: Proc.new { permalink.blank? }
  before_validation :set_defaults
  
  validates_associated :addonships
  validates_presence_of :title, :permalink, :theme_id
  validates_length_of :permalink, minimum: 1, maximum: 8
  validates_uniqueness_of :permalink
  validates_uniqueness_of :domain, allow_blank: true
  
  before_save :update_email_addresses_count, if: :free_email_addresses_changed?
  before_save :billing_info_required, if: Proc.new { billing_info_required? && card_token.blank? && customer_token.blank? }
  before_save :stripify, if: Proc.new { billing_info_required? && !card_token.blank? }
  after_create :seed_content, if: :theme_id?
  after_save :remove_all_email_accounts, if: :domain_changed?
  after_save :clone_theme, if: :duplicate_theme
  after_save :update_page_templates, if: :theme_id_changed?
  after_save :manage_cpanel
  
  scope :connected_to_stripe, -> { where("customer_token is not ?", nil) }
  
  def billing_info_required
    self.errors.add :base, "With this setup, billing information is required."
    false
  end
  
  def permalink_is_not_safe
    self.errors.add :permalink, "is a reserved permalink and cannot be used."
  end
  
  def billing_info_required?
    price > 0
  end
  
  def has_payment_info?
    !customer_token.blank?
  end
  
  def stripify
    customer = Stripe::Customer.retrieve(customer_token) unless customer_token.blank?
    
    if customer
      customer.card = card_token
      customer.save
      self.last_4 = customer.cards.data.first.last4
    else
      customer = Stripe::Customer.create(
        card: card_token,
        email: admins.last.email,
        description: permalink
      )
      
      self.last_4 = customer.cards.data.first.last4
      self.customer_token = customer.id

      if Invoice.add_addons_to_invoices(self)
       customer.update_subscription(plan: "WEH")
      end
    end
  end
  
  def update_page_templates
    self.pages.update_all document_id: self.theme.default_document
  end
  
  def theme_does_not_have_default_document
    self.errors.add :base, "You cannot use this theme because it doesn't have a default document assigned."
  end
  
  def set_defaults
    self.primary_colour = "rgb(240, 110, 48)" if self.primary_colour.blank?
    self.secondary_colour = "rgb(12, 118, 177)" if self.secondary_colour.blank?
    self.permalink = self.permalink.parameterize
    
    if !domain.blank?
      self.domain = self.domain.to_s.downcase.gsub(/http:\/\/|https:\/\//, "")
      self.domain = "www.#{self.domain}" if get_subdomain(domain).blank?
    end
  end
  
  def seed_content
    home = pages.create(
      title: "Welcome",
      permalink: "welcome",
      description: "Welcome to our website",
      visible: true,
      deleteable: false,
      ordinal: 1,
      document_id: theme.default_document.id
    )
    
    self.update_attributes home_id: home.id
    
    sign_in = pages.create(
      title: "Sign In",
      permalink: "sign_in",
      description: "Sign in to our website",
      visible: false,
      deleteable: false,
      ordinal: 999,
      document_id: theme.default_document.id
    )
    
    sitemap = pages.create(
      title: "Sitemap",
      permalink: "sitemap",
      description: "Sitemap of our website",
      visible: false,
      deleteable: false,
      ordinal: 998,
      document_id: theme.default_document.id
    )
    
    search = pages.create(
      title: "Search",
      permalink: "search",
      description: "Search our website",
      visible: false,
      deleteable: false,
      ordinal: 997,
      document_id: theme.default_document.id
    )
  end
  
  def clone_theme
    chosen = available_themes.find(self.duplicate_theme)
    self.duplicate_theme = false
    
    if chosen
      new_theme = chosen.dup
      new_theme.website_id = id
      new_theme.name = "My #{chosen.name}"
      new_theme.pristine = false
      new_theme.save
    
      for doc in chosen.documents
        new_doc = doc.dup
        new_doc.theme_id = new_theme.id
        new_doc.save
      end
    end
  end
  
  def create_permalink
    self.permalink = self.title.parameterize
  end
  
  def editable_themes
    Theme.where(website_id: id)
  end
  
  def available_themes
    Theme.where(id: editable_themes.pluck(:id) + Theme.pristine.pluck(:id))
  end
  
  def theme_locked?
    theme.try(:pristine?)
  end
  
  def price
    price = 0
    price += 4000 if !domain.blank?
    addonships.where(addon_id: self.addon_ids).map{ |a| price += a.addon.price * (a.addon.quantifiable? ? a.quantity : 1) }
    price
  end
  
  def admins
    members.where("memberships.security = ?", "admin")
  end
  
  def adminable_by(user)
    if user.admin? || admins.include?(user)
      @adminable_by ||= true
    else
      @adminable_by ||= false
    end
  end
  
  def email_addon
    addon = addons.where(permalink: "email").first
    addonships.where(addon_id: addon.id).first if addon
  end
  
  def money_addon
    addon = addons.where(permalink: "money").first
    addonships.where(addon_id: addon.id).first if addon
  end
  
  def can_accept_money?
    money_addon && "STRIPE CREDENTIALS"
  end
  
  def stripped_domain(full)
    strip = full.split(".")
    "#{strip[strip.length - 2]}.#{strip.last}"
  end
  
  def update_email_addresses_count
    quantity = memberships.with_email_account.count - free_email_addresses
    quantity = 0 if quantity < 0
    email_addon.update_columns quantity: quantity
  end
  
  def manage_cpanel
    if domain_changed?
      if !domain_was.blank? && domain.blank?
        WHMWorker.perform_async id, "suspend_domain", { domain: domain, domain_was: domain_was }
      elsif domain_was.blank? && !domain.blank?
        WHMWorker.perform_async id, "create_domain", { domain: domain, domain_was: domain_was }
      else
        WHMWorker.perform_async id, "update_domain", { domain: domain, domain_was: domain_was }
      end
    end
  end
  
  def cpanel_delete_www_redirect(d = false, dwas = false)
    d = domain unless d
    dwas = domain_was unless dwas
    
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        "cpanel_jsonapi_user" => permalink,
        "cpanel_jsonapi_apiversion" => 1,
        "cpanel_jsonapi_module" => "Mime", 
        "cpanel_jsonapi_func" => "del_redirect",
        "arg-0" => "",
        "arg-1" => stripped_domain(d),
        "arg-2" => ""
      }
    }
  end
  
  def cpanel_redirect_to_www(d = false, dwas = false)
    d = domain unless d
    dwas = domain_was unless dwas
    
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        "cpanel_jsonapi_user" => permalink,
        "cpanel_jsonapi_apiversion" => 1,
        "cpanel_jsonapi_module" => "Mime", 
        "cpanel_jsonapi_func" => "add_redirect",
        "arg-0" => "",
        "arg-1" => "permanent",
        "arg-2" => "http://#{domain}",
        "arg-3" => stripped_domain(d),
        "arg-4" => 1,
        "arg-5" => 0
      }
    }
  end
  
  def cpanel_delete_previous_record(d = false, dwas = false)
    d = domain unless d
    dwas = domain_was unless dwas
    
    line = false
    zonefile = JSON.parse RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: permalink,
        cpanel_jsonapi_module: "ZoneEdit", 
        cpanel_jsonapi_func: "fetchzone",
        domain: stripped_domain(dwas)
      }
    }
    
    if zonefile["cpanelresult"] && zonefile["cpanelresult"]["data"] && zonefile["cpanelresult"]["data"][0] && zonefile["cpanelresult"]["data"][0]["record"]
      zonefile["cpanelresult"]["data"][0]["record"].each do |zone|
        unless zone["cname"].blank?
          if zone["name"] == "#{dwas}."
            line = zone["line"]
          end
        end
      end
    end
  
    if line
      zonefile = JSON.parse RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
        params: { 
          cpanel_jsonapi_user: permalink,
          cpanel_jsonapi_module: "ZoneEdit", 
          cpanel_jsonapi_func: "remove_zone_record",
          domain: stripped_domain(dwas),
          line: line
        }
      }
    end
  end
  
  def cpanel_create_zone_records(d = false, dwas = false)
    d = domain unless d
    dwas = domain_was unless dwas
    
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: permalink,
        cpanel_jsonapi_module: "ZoneEdit", 
        cpanel_jsonapi_func: "add_zone_record",
        domain: stripped_domain(d),
        name: get_subdomain(d),
        type: "CNAME",
        cname: "#{permalink}.#{CONFIG["domain"]}",
        ttl: 14400
      }
    }
  end
  
  def cpanel_update_domain(d = false, dwas = false)
    d = domain unless d
    dwas = domain_was unless dwas
    
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/modifyacct", { 
      params: {
        user: permalink, 
        domain: stripped_domain(d)
      }
    }
  end
  
  def cpanel_suspend_account(d = false, dwas = false)
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/suspendacct", { 
      params: {
        user: permalink, 
        reason: "Set domain to be empty on #{Time.now}."
      }
    }
  end
  
  def cpanel_unsuspend_account
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/unsuspendacct", { 
      params: {
        user: permalink
      }
    }
  end
  
  def cpanel_create_account(d = false, dwas = false)
    d = domain unless d
    dwas = domain_was unless dwas
    
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/createacct", { 
      params: {
        username: permalink, 
        domain: stripped_domain(d),
        plan: "#{CONFIG["whm_user"]}_Basic",
        contactemail: admins.first.email
      }
    }
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/modifyacct", { 
      params: {
        user: permalink, 
        HASDKIM: 1,
        HASSPF: 1,
        HASCGI: 0
      }
    }
  end
  
  def remove_all_email_accounts
    memberships.update_all has_email_account: false
  end
  
  def get_subdomain(full)
    split = full.split(".")
    
    if split.size > 2
      split[0..split.size - 3].join(".")
    else
      ""
    end
  end
end