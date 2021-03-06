class Message < ActiveRecord::Base
  serialize :filters, Array
  serialize :to, Array
  belongs_to :website
  belongs_to :user
  
  has_many :deliveries
  has_many :memberships, through: :deliveries
  has_many :members, through: :memberships, source: :user
  
  validates_presence_of :subject, :plain, :user_id, :website_id
  
  before_validation :reject_empties
  after_commit :deliver
  
  def reject_empties
    self.to = self.to.reject(&:blank?).map(&:to_i)
  end
  
  def deliver
    if to.any?
      recipients = to
    else
      recipients = (to + website.memberships.filter(filters).emailable.pluck(:id)).uniq
    end
    
    recipients.each do |membership_id|
      Sender.perform_async(id, membership_id)
    end
  end
end
