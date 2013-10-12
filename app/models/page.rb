class Page < ActiveRecord::Base
  belongs_to :website
  belongs_to :layout, class_name: "Document", foreign_key: "document_id"
  
  belongs_to :parent, class_name: "Page", primary_key: "parent_id"
  has_many :children, class_name: "Page", foreign_key: "parent_id"
  has_many :wrappers
  
  before_validation :permalink_is_not_safe, if: Proc.new { |p| %w[webmail manage pages blocks media invoices sign_out].include? p.permalink }
  validates_uniqueness_of :permalink, scope: :website_id
  validates_presence_of :document_id
  validates_presence_of :title, allow_blank: false
  
  default_scope -> { order(:ordinal) }
  
  scope :roots, -> { where parent_id: nil }
  scope :visible, -> { where visible: true }
  
  def permalink_is_not_safe
    self.errors.add :permalink, "is a reserved word and cannot be used."
  end
  
  def siblings
    website.pages.where(parent_id: parent_id)
  end
  
  def root?
    parent_id == nil
  end
end
