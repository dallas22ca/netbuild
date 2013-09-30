class Website < ActiveRecord::Base
  attr_accessor :duplicate_theme
  
  belongs_to :theme
  belongs_to :home, class_name: "Page", foreign_key: "home_id"
  
  has_many :blocks
  has_many :pages
  has_many :themes
  has_many :memberships
  has_many :members, through: :memberships, source: :user
  
  accepts_nested_attributes_for :members
  
  validates_presence_of :title, :permalink, :theme_id
  validates_uniqueness_of :permalink
  before_validation :create_permalink, if: Proc.new { |w| w.permalink.blank? }
  after_save :clone_theme, if: Proc.new { |w| self.duplicate_theme }
  after_create :seed_content
  
  def seed_content
    home = pages.create(
      title: "Welcome",
      permalink: "welcome",
      description: "Welcome to our website",
      visible: true,
      ordinal: 1,
      document_id: theme.documents.first.id
    )
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
