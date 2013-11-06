class Message < ActiveRecord::Base
  serialize :to, Array
  belongs_to :website
  belongs_to :user
  
  has_many :deliveries
  has_many :memberships, through: :deliveries
  has_many :members, through: :memberships, source: :user
  
  validates_presence_of :subject, :plain, :user_id, :website_id
  
  before_validation :reject_empties
  after_create :deliver
  
  def reject_empties
    self.to = self.to.reject(&:blank?)
  end
  
  def deliver
    to.each do |membership_id|
      Bulk.sender(id, membership_id).deliver
    end
  end
end