class Response < ActiveRecord::Base
  store :data
  
  belongs_to :block
  belongs_to :membership
  belongs_to :website
  
  has_one :user, through: :membership
  has_one :page, through: :block
  
  def safe_data
    @safe_data = data
    @safe_data ||= {}
  end
end
