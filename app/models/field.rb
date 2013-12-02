class Field < ActiveRecord::Base
  belongs_to :website
  
  validates_presence_of :website_id, :name
  
  before_save :set_defaults
  
  def set_defaults
    self.permalink = self.name.parameterize
    self.data_type = "string"
  end
  
  def self.for_filters
    for_filters = {}
    all.map { |f| for_filters[f.permalink] = f }
    for_filters
  end
end
