class WHMWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "WHMWorker"
  
  def perform(id, type, options = {})
    if type.include? "domain"
      
      w = Website.find(id)
      d = options["domain"]
      dwas = options["domain_was"]
    
      if type == "suspend_domain"
        w.cpanel_delete_previous_record(d, dwas)
        w.cpanel_suspend_account
      elsif type == "create_domain"
        w.cpanel_create_account(d, dwas)
        w.cpanel_unsuspend_account
        w.cpanel_update_domain(d, dwas)
        w.cpanel_delete_www_redirect(d, dwas) if dwas.to_s.include? "www"
        w.cpanel_create_zone_records(d, dwas)
        w.cpanel_redirect_to_www(d, dwas) if d.to_s.include? "www"
      elsif type == "update_domain"
        w.cpanel_update_domain(d, dwas)
        w.cpanel_delete_www_redirect(d, dwas) if dwas.to_s.include? "www"
        w.cpanel_delete_previous_record(d, dwas) unless dwas.to_s.blank?
        w.cpanel_create_zone_records(d, dwas)
        w.cpanel_redirect_to_www(d, dwas) if d.to_s.include? "www"
      end
      
    elsif type.include?("email") || type.include?("forward")
      
      m = Membership.find(id)
      fto = options["forward_to"]
      ftowas = options["forward_to_was"]
      ftochanged = options["forward_to_changed"]
      p = options["p"]
      
      if type == "create_email_account"
        m.cpanel_create_email_account(p)
        m.cpanel_delete_forward(ftowas) if ftochanged
        m.cpanel_create_forward(fto) if ftochanged && !fto.blank?
      elsif type == "update_email_account"
        m.cpanel_update_email_password if !p.blank?
        m.cpanel_delete_forward(ftowas) if ftochanged
        m.cpanel_create_forward(fto) if ftochanged && !fto.blank?
      elsif type == "delete_email_account"
        m.cpanel_delete_forward(ftowas)
        m.cpanel_delete_email_account
      end
      
    end
  end
end