class Addon < ActiveRecord::Base
  has_many :addonships
  has_many :websites, through: :addonships
  
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
end
