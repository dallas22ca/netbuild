class Document < ActiveRecord::Base
  belongs_to :theme, touch: true
  
  scope :html, -> { where(extension: "html") }
  scope :css, -> { where(extension: "css") }
  scope :js, -> { where(extension: "js") }
end
