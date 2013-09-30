class Wrapper < ActiveRecord::Base
  belongs_to :page
  belongs_to :website
  
  has_many :blocks
end
