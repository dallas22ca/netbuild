class Importer
  include Sidekiq::Worker
  
  sidekiq_options queue: "Importer"
  
  def perform(id)
    require 'csv'
    
    m = Medium.find(id)

    begin
      memberships = []
      
      csv = CSV.parse(open(m.amazon_url).read, headers: true)
      
      csv.headers.each do |header|
        m.website.fields.where(name: header).first_or_create
      end
      
      csv.each do |row|
        hash = {}
        row.map{ |k, v| hash[k.parameterize] = v }
        email = hash["email"]
        user = User.where(email: email).first_or_initialize
        user.no_password = true
        
        if !user.new_record? || (user.new_record? && user.save)
          memberships.push user.memberships.create(website_id: m.website_id, data: hash, security: "user")
        end
      end

      Membership.import memberships
      
      m.destroy
    rescue# CSV::MalformedCSVError => e
      false
    end
  end
end