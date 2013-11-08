class Wrapper < ActiveRecord::Base
  belongs_to :page
  belongs_to :website, touch: true
  has_many :blocks
end
