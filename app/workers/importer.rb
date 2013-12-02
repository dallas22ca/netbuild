class Importer
  include Sidekiq::Worker
  
  sidekiq_options queue: "Importer"
  
  def perform(id)
    require 'csv'
    
    m = Medium.find(id)

    begin
      memberships = []
      
      CSV.parse open(m.amazon_url).read, headers: true do |row|
        hash = {}
        row.map{ |k, v| hash[k.parameterize] = v }
        email = hash.delete "email"
        user = User.where(email: email).first_or_initialize
        user.no_password = true
        
        if !user.new_record? || (user.new_record? && user.save)
          memberships.push user.memberships.create(website_id: m.website_id, data: hash, security: "user")
        end
      end

      Membership.import memberships
    rescue# CSV::MalformedCSVError => e
      false
    end
    
    m.destroy
  end
end