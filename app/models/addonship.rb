class Addonship < ActiveRecord::Base
  belongs_to :website
  belongs_to :addon
end
