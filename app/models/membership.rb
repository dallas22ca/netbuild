class Membership < ActiveRecord::Base
  attr_accessor :password
  
  belongs_to :user
  belongs_to :website
  
  scope :admin, -> { where(security: "admin") }
  scope :with_email_account, -> { where(has_email_account: true) }
  
  before_create :set_security
  validates_uniqueness_of :username, scope: :website_id
  after_validation :manage_cpanel, if: Proc.new { website.email_addon }
  after_save :update_website_email_addresses_count, if: :has_email_account_changed?
  
  def update_website_email_addresses_count
    website.update_email_addresses_count
  end
  
  def set_security
    self.security = "admin" if self.security.nil?
  end
  
  def cpanel_create_email_account
    RestClient.get "https://dallasca:D4a5l1l9a8S8@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: website.permalink,
        cpanel_jsonapi_module: "Email", 
        cpanel_jsonapi_func: "addpop",
        email: username, 
        domain: website.stripped_domain(website.domain),
        password: password, 
        quota: 0
      }
    }
  end
  
  def cpanel_update_email_password
    RestClient.get "https://dallasca:D4a5l1l9a8S8@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: website.permalink,
        cpanel_jsonapi_module: "Email", 
        cpanel_jsonapi_func: "passwdpop",
        email: username, 
        domain: website.stripped_domain(website.domain),
        password: password
      }
    }
  end
  
  def cpanel_delete_forward
    forward_to_was.to_s.split(",").each do |forward|
      forward = forward.strip
      RestClient.get "https://dallasca:D4a5l1l9a8S8@netbuild.co:2087/json-api/cpanel", { 
        params: { 
          "cpanel_jsonapi_user" => website.permalink,
          "cpanel_jsonapi_apiversion" => 1,
          "cpanel_jsonapi_module" => "Email", 
          "cpanel_jsonapi_func" => "delforward",
          "arg-0" => "#{username}@#{website.stripped_domain(website.domain)}=#{forward}"
        }
      }
    end
  end
  
  def cpanel_create_forward
    forward_to.to_s.split(",").each do |forward|
      forward = forward.strip
      RestClient.get "https://dallasca:D4a5l1l9a8S8@netbuild.co:2087/json-api/cpanel", { 
        params: { 
          cpanel_jsonapi_user: website.permalink,
          cpanel_jsonapi_module: "Email", 
          cpanel_jsonapi_func: "addforward",
          email: username, 
          domain: website.stripped_domain(website.domain),
          fwdopt: "fwd",
          fwdemail: forward
        }
      }
    end
  end
  
  def cpanel_delete_email_account
    RestClient.get "https://dallasca:D4a5l1l9a8S8@netbuild.co:2087/json-api/cpanel", { 
      params: { 
        cpanel_jsonapi_user: website.permalink,
        cpanel_jsonapi_module: "Email", 
        cpanel_jsonapi_func: "delpop",
        email: username, 
        domain: website.stripped_domain(website.domain)
      }
    }

    self.username = nil
    self.has_email_account = false
    self.forward_to = nil
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
          cpanel_create_email_account
          
          if forward_to_changed?
            cpanel_delete_forward
        
            unless forward_to.blank?
              cpanel_create_forward
            end
          end
        end
      else
        if !password.blank?
          cpanel_update_email_password
        end
        
        if forward_to_changed?
          cpanel_delete_forward
        
          unless forward_to.blank?
            cpanel_create_forward
          end
        end
      end
    elsif has_email_account_changed?
      cpanel_delete_forward
      cpanel_delete_email_account
    end
  end
end
