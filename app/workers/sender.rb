class Sender
  include Sidekiq::Worker
  
  sidekiq_options queue: "Sender"
  
  def perform(id, membership_id)
    Bulk.sender(id, membership_id).deliver
  end
end