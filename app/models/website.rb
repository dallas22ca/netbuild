class Website < ActiveRecord::Base
  attr_accessor :duplicate_theme
  
  belongs_to :theme, touch: true
  belongs_to :home, class_name: "Page", foreign_key: "home_id"
  
  has_many :wrappers, dependent: :destroy
  has_many :blocks, through: :wrappers, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :themes, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :media, dependent: :destroy
  
  accepts_nested_attributes_for :members
  
  validates_presence_of :title, :permalink, :theme_id
  validates_uniqueness_of :permalink
  before_validation :create_permalink, if: Proc.new { |w| w.permalink.blank? }
  after_save :clone_theme, if: Proc.new { |w| self.duplicate_theme }
  after_save :update_page_templates
  after_create :seed_content
  
  def update_page_templates
    self.pages.update_all document_id: self.theme.default_document
  end
  
  def seed_content
    if Theme.any?
      home = pages.create(
        title: "Welcome",
        permalink: "welcome",
        description: "Welcome to our website",
        visible: true,
        deleteable: false,
        ordinal: 1,
        document_id: theme.default_document
      )
      
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
      
      live = pages.create(
        title: "Live",
        permalink: "live",
        description: "Live",
        visible: false,
        deleteable: false,
        ordinal: 996,
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
end
