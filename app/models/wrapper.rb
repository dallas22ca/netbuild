class Wrapper < ActiveRecord::Base
  belongs_to :page
  belongs_to :website
  belongs_to :block
  
  has_many :blocks
end
