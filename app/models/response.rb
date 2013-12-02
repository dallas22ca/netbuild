class Response < ActiveRecord::Base
  belongs_to :block
  belongs_to :contact
  belongs_to :website
end
