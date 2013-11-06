class Delivery < ActiveRecord::Base
  belongs_to :message
  belongs_to :membership
  
  validates_uniqueness_of :message_id, scope: :membership_id
end
