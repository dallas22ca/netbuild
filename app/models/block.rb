class Block < ActiveRecord::Base
  serialize :data, JSON
  attr_accessor :initial_id
  
  belongs_to :wrapper, touch: true
  belongs_to :website
  
  default_scope -> { order(:ordinal) }
  
  before_validation :set_defaults
  
  def set_defaults
    if self.details.blank?
      if self.genre == "text"
        self.data = { "style" => "p", "content" => "This is a placeholder." }
      end
    end
  end
  
  def safe_data
    @safe_data = data
    @safe_data ||= {}
  end
end
