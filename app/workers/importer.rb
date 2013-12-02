class Importer
  include Sidekiq::Worker
  
  sidekiq_options queue: "Importer"
  
  def perform(id)
    require 'csv'
    
    m = Medium.find(id)

    begin
      users = []
      
      csv = CSV.parse(open(m.amazon_url).read, headers: true)
      
      csv.headers.each do |header|
        m.website.fields.where(name: header).first_or_create
      end
      
      csv.each do |row|
        hash = {}
        row.map{ |k, v| hash[k.parameterize] = v }
        email = hash.delete "email"
        user = User.where(email: email).first_or_initialize
        user.no_password = true
        
        if !user.new_record? || (user.new_record? && user.save)
          users.push user.create(website_id: m.website_id, data: hash, security: "user")
        end
      end

      User.import users
      
      m.destroy
    rescue# CSV::MalformedCSVError => e
      false
    end
  end
end