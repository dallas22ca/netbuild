class Block < ActiveRecord::Base
  attr_accessor :initial_id
  
  belongs_to :website
  belongs_to :wrapper, foreign_key: "parent", primary_key: "indentifier"
  
  default_scope -> { order(:ordinal) }
  
  def data
    @data = details || {}
  end
end
