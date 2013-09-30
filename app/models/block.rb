class Block < ActiveRecord::Base
  attr_accessor :initial_id
  
  belongs_to :website
  
  default_scope -> { order(:ordinal) }
  
  def data
    @data = details || {}
  end
end
