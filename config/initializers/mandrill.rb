ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_url_options = {
  host: "www.netbuild.co"
}
ActionMailer::Base.smtp_settings = {
  port: 587,
  address: "smtp.mandrillapp.com",
  user_name: CONFIG["mandrill_username"],
  password: CONFIG["mandrill_password"],
  domain: "netbuild.co",
  authentication: :login,
  enable_starttls_auto: true
}