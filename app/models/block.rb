class Block < ActiveRecord::Base
  attr_accessor :initial_id
  
  belongs_to :website
  belongs_to :wrapper, touch: true
  
  default_scope -> { order(:ordinal) }
  
  before_validation :set_defaults
  
  def set_defaults
    self.details = { "style" => "p", "content" => "This is a placeholder." } if self.details.blank? && self.genre == "text"
  end
  
  def data
    @data = details || {}
  end
end
