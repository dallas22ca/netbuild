class Theme < ActiveRecord::Base
  belongs_to :website
  has_many :documents
  has_many :websites
  
  scope :pristine, -> { where(pristine: true) }
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
