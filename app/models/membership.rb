class Membership < ActiveRecord::Base
  attr_accessor :password
  
  belongs_to :user
  belongs_to :website
  has_many :invoices
  
  accepts_nested_attributes_for :user
  
  scope :admin, -> { where(security: "admin") }
  scope :with_email_account, -> { where(has_email_account: true) }
  
  before_create :set_security
  validates_uniqueness_of :username, scope: :website_id, allow_blank: true
  after_validation :manage_cpanel, if: Proc.new { website && website.has_payment_info? && website.email_addon }
  after_save :update_website_email_addresses_count, if: :has_email_account_changed?
  
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
    user.email
  end
end
