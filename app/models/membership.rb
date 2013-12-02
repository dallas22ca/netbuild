class Membership < ActiveRecord::Base
  attr_accessor :password
  
  belongs_to :user
  belongs_to :website
  has_many :invoices
  has_many :deliveries
  has_many :messages, through: :deliveries
  
  accepts_nested_attributes_for :user
  
  scope :admin, -> { where(security: "admin") }
  scope :with_email_account, -> { where(has_email_account: true) }
  
  before_create :set_security
  validates_uniqueness_of :username, scope: :website_id, allow_blank: true
  after_validation :manage_cpanel, if: Proc.new { has_email_account_changed? && website && website.has_payment_info? && website.email_addon }
  after_save :update_website_email_addresses_count, if: Proc.new { has_email_account_changed? }
  
  def update_website_email_addresses_count
    website.update_email_addresses_count
  end
  
  def set_security
    self.security = "admin" if self.security.nil?
  end
  
  def cpanel_create_email_account(p = false)
    p = password unless p
    
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: (website.permalink == "nb-www" ? "dallasca" : website.permalink),
        cpanel_jsonapi_module: "Email", 
        cpanel_jsonapi_func: "addpop",
        email: username, 
        domain: (website.permalink == "nb-www" ? "netbuild.co" : website.stripped_domain(website.domain)),
        password: p, 
        quota: 0
      }
    }
  end
  
  def cpanel_update_email_password(p = false)
    p = password unless p

    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: (website.permalink == "nb-www" ? "dallasca" : website.permalink),
        cpanel_jsonapi_module: "Email", 
        cpanel_jsonapi_func: "passwdpop",
        email: username, 
        domain: (website.permalink == "nb-www" ? "netbuild.co" : website.stripped_domain(website.domain)),
        password: p
      }
    }
  end
  
  def cpanel_delete_forward(ftowas = false)
    ftowas = forward_to_was unless ftowas
    
    ftowas.to_s.split(",").each do |forward|
      forward = forward.strip
      RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
        params: { 
          "cpanel_jsonapi_user" => (website.permalink == "nb-www" ? "dallasca" : website.permalink),
          "cpanel_jsonapi_apiversion" => 1,
          "cpanel_jsonapi_module" => "Email", 
          "cpanel_jsonapi_func" => "delforward",
          "arg-0" => "#{username}@#{website.stripped_domain(website.domain)}=#{forward}"
        }
      }
    end
  end
  
  def cpanel_create_forward(fto = false)
    fto = forward_to unless fto
    
    fto.to_s.split(",").each do |forward|
      forward = forward.strip
      RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
        params: { 
          cpanel_jsonapi_user: (website.permalink == "nb-www" ? "dallasca" : website.permalink),
          cpanel_jsonapi_module: "Email", 
          cpanel_jsonapi_func: "addforward",
          email: username, 
          domain: (website.permalink == "nb-www" ? "netbuild.co" : website.stripped_domain(website.domain)),
          fwdopt: "fwd",
          fwdemail: forward
        }
      }
    end
  end
  
  def cpanel_delete_email_account
    RestClient.get "https://#{CONFIG["whm_user"]}:#{CONFIG["whm_pass"]}@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: (website.permalink == "nb-www" ? "dallasca" : website.permalink),
        cpanel_jsonapi_module: "Email", 
        cpanel_jsonapi_func: "delpop",
        email: username, 
        domain: (website.permalink == "nb-www" ? "netbuild.co" : website.stripped_domain(website.domain))
      }
    }

    self.username = nil
    self.has_email_account = false
    self.forward_to = nil
    self.save
  end
  
  def email_account
    if has_email_account?
      "#{username}@#{website.stripped_domain(website.domain)}"
    else
      ""
    end
  end
  
  def manage_cpanel
    if has_email_account?
      if has_email_account_changed?
        if password.blank?
          self.errors.add :base, "You must supply a password for the email account."
          false
        else
          WHMWorker.perform_async id, "create_email_account", { forward_to: forward_to, forward_to_was: forward_to_was, forward_to_changed: forward_to_changed?, p: password }
        end
      else
        WHMWorker.perform_async id, "update_email_account", { forward_to: forward_to, forward_to_was: forward_to_was, forward_to_changed: forward_to_changed?, p: password }
      end
    elsif has_email_account_changed?
      WHMWorker.perform_async id, "delete_email_account", { forward_to_was: forward_to_was }
    end
  end
  
  def name
    @name ||= safe_data.empty? || safe_data["name"].blank? ? user.email : safe_data["name"]
  end
  
  def name_and_email
    @name_and_email ||= safe_data["name"].blank? ? user.email : "#{safe_data["name"]} <#{user.email}>"
  end
  
  def invoice_name
    "#{name}#{" - #{safe_data["company"]}" unless safe_data["company"].blank?}"
  end
  
  def safe_data
    @safe_data = data
    @safe_data ||= {}
    # @safe_data.reverse_merge({ "email" => user.email }) if user && !user.new_record?
  end
  
  def self.to_csv(user_id)
    require 'csv'
    # CSV.generate do |csv|
    #   fields = User.find(user_id).fields
    #   
    #   csv << ["Name"] + fields.pluck(:title)
    #   all.each do |contact|
    #     csv << [contact.name] + fields.map{ |f| contact.d[f.permalink] }
    #   end
    # end
  end
  
  def to_liquid
    {
      "contact" => data.merge({ email: user.email })
    }
  end
  
  def self.filter(requirements = [], q = "", order = "id", direction = "asc", data_type = "string")
    queries = []
    normal_fields = ["created_at", "updated_at", "email", "id"]

    unless normal_fields.include? order
      if data_type == "integer"
        order = "cast(memberships.data -> '#{order}' as numeric)"
      else
        order = "memberships.data -> '#{order}'"
      end
    else
      order = "memberships.#{order}"
    end
    
    unless q.blank?
      q = q.to_s
      queries.push "memberships.name ilike '%#{q}%' or LOWER(CAST(avals(memberships.data) AS text)) ilike '%#{q}%'"
    end
    
    requirements.each do |field, matcher, search, args|
      search = search.to_s unless args.blank?
    
      if normal_fields.include? field
        case matcher
        when "is"
          queries.push "memberships.#{field} = '#{search}'"
        when "is_not"
          queries.push "memberships.#{field} != '#{search}'"
        when "like"
          queries.push "memberships.#{field} ilike '%#{search}%'"
        when "greater_than"
          queries.push "memberships.#{field} > '#{search}'"
        when "less_than"
          queries.push "memberships.#{field} < '#{search}'"
        end  
      else
        case matcher
        when "is"
          queries.push "memberships.data @> hstore('#{field}', '#{search}')"
        when "is_not"
          queries.push "memberships.data -> '#{field}' <> '#{search}'"
        when "like"
          queries.push "memberships.data -> '#{field}' ilike '%#{search}%'"
        when "greater_than"
          queries.push "memberships.data -> '#{field}' > '#{search}'"
        when "less_than"
          queries.push "memberships.data -> '#{field}' < '#{search}'"
        when "recurring"
          start = args[:start]
          finish = args[:finish]
          queries.push "to_char(cast(memberships.data -> '#{field}' as date), 'MMDD') BETWEEN '#{start.strftime("%m%d")}' and '#{finish.strftime("%m%d")}'"
        end
      end
    end
      
    if queries.any?
      where(queries.join(" and ")).order("#{order} #{direction}")
    else
      order("#{order} #{direction}")
    end
  end
end
