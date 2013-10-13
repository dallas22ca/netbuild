class Document < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :theme, touch: true
  
  validates_uniqueness_of :name, scope: :theme_id
  
  scope :partials, -> { where(extension: "partial") }
  scope :html, -> { where(extension: "html") }
  scope :css, -> { where(extension: "css") }
  scope :js, -> { where(extension: "js") }
end
