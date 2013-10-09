class Theme < ActiveRecord::Base
  belongs_to :website
  belongs_to :default_document, class_name: "Document", foreign_key: "default_document_id"
  
  has_many :documents
  has_many :websites
  
  scope :pristine, -> { where(pristine: true) }
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
