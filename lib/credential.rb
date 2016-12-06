class Credential
  def self.http_basic_user
    Rails.application.secrets.http_basic_user
  end
  
  def self.http_basic_password
    Rails.application.secrets.http_basic_password
  end
  
  def self.stripe_api_key
    Rails.application.config.x.stripe.api_key = STRIPE_CONFIG['api_key']
  end
  
  def self.stripe_api_secret
    Rails.application.config.x.stripe.api_secret = STRIPE_CONFIG['api_secret']
  end
end