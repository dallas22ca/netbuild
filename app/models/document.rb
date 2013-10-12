class Document < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :theme, touch: true
  
  scope :html, -> { where(extension: "html") }
  scope :css, -> { where(extension: "css") }
  scope :js, -> { where(extension: "js") }
end
