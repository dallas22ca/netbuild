class Resizer
  include Sidekiq::Worker
  
  sidekiq_options queue: "Resizer"
  
  def perform(id)
    medium = Medium.find(id)
    medium.resize if medium
  end
end