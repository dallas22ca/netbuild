CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
Stripe.api_key = CONFIG["stripe_api_key"]