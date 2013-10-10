class Website < ActiveRecord::Base
  attr_accessor :duplicate_theme, :card_token
  
  belongs_to :theme, touch: true
  belongs_to :home, class_name: "Page", foreign_key: "home_id"
  
  has_many :wrappers, dependent: :destroy
  has_many :blocks, through: :wrappers, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :themes, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :addonships
  has_many :addons, through: :addonships
  has_many :invoices
  
  accepts_nested_attributes_for :members
  
  validates_presence_of :title, :permalink, :theme_id
  before_validation :permalink_is_not_safe, if: Proc.new { |p| %w[app secure www help].include? p.permalink }
  validates_uniqueness_of :permalink
  before_validation :theme_does_not_have_default_document, if: Proc.new { theme_id_changed? && theme.default_document_id.blank? }
  before_validation :create_permalink, if: Proc.new { permalink.blank? }
  before_save :set_defaults
  before_save :stripify, if: Proc.new { billing_info_required? || !card_token.blank? }
  after_create :seed_content
  after_save :clone_theme, if: :duplicate_theme
  after_save :update_page_templates, if: :theme_id_changed?
  
  scope :connected_to_stripe, -> { where("customer_token is not ?", nil) }
  
  def permalink_is_not_safe
    self.errors.add :permalink, "is a reserved word and cannot be used."
  end
  
  def billing_info_required?
    customer_token.blank? && price > 0
  end
  
  def has_payment_info?
    !customer_token.blank?
  end
  
  def stripify
    if card_token.blank?
      self.errors.add :base, "Billing information is required to use a domain name."
      false
    else
      customer = Stripe::Customer.retrieve(customer_token) unless customer_token.blank?
      
      if customer
        customer.card = card_token
        customer.save
        self.last_4 = customer.cards.data.first.last4
      else
        customer = Stripe::Customer.create(
          card: card_token,
          email: website.admins.last.email,
          plan: "WEH",
          description: permalink
        )
        
        self.last_4 = customer.cards.data.first.last4
        self.customer_token = customer.id
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
    self.primary_colour = "rgb(240, 110, 48)"
    self.secondary_colour = "rgb(12, 118, 177)"
  end
  
  def seed_content
    if theme
      home = pages.create(
        title: "Welcome",
        permalink: "welcome",
        description: "Welcome to our website",
        visible: true,
        deleteable: false,
        ordinal: 1,
        document_id: theme.default_document
      )
      
      self.update_attributes home_id: home.id
      
      sign_in = pages.create(
        title: "Sign In",
        permalink: "sign_in",
        description: "Sign in to our website",
        visible: false,
        deleteable: false,
        ordinal: 999,
        document_id: theme.default_document
      )
      
      sitemap = pages.create(
        title: "Sitemap",
        permalink: "sitemap",
        description: "Sitemap of our website",
        visible: false,
        deleteable: false,
        ordinal: 998,
        document_id: theme.default_document
      )
      
      search = pages.create(
        title: "Search",
        permalink: "search",
        description: "Search our website",
        visible: false,
        deleteable: false,
        ordinal: 997,
        document_id: theme.default_document
      )
      
      members = pages.create(
        title: "Members",
        permalink: "members",
        description: "Members",
        visible: false,
        deleteable: false,
        ordinal: 995,
        document_id: theme.default_document
      )
    end
  end
  
  def clone_theme
    self.duplicate_theme = false
    
    new_theme = self.theme.clone
    new_theme.website_id = id
    new_theme.name = "My #{theme.name}"
    new_theme.pristine = false
    new_theme.save
    
    for doc in theme.documents
      new_doc = doc.clone
      new_doc.theme_id = new_theme.id
      new_doc.save
    end
    
    self.update_attributes theme_id: new_theme.id
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
    price += 4000 unless domain.blank?
    addonships.map { |a| price += a.addon.price * (a.quantity.blank? ? 1 : a.quantity) }
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
end