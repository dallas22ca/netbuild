class Addonship < ActiveRecord::Base
  belongs_to :website
  belongs_to :addon
  
  validates_presence_of :website_id
  validates_presence_of :addon_id
end
