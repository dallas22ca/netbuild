class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :website
  
  scope :admin, -> { where(security: "admin") }
  
  before_create :set_security
  
  def set_security
    self.security = "admin" if self.security.blank?
  end
end
