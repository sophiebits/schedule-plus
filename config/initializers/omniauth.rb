require 'openssl'
###############
# Remove this code after setting up SSL
if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
###############

if Rails.env.development?
  Rails.application.config.middleware.use OmniAuth::Builder do
    #provider :facebook, 'f1e98cfb98bf5b2199e7ebe904d30ba3', 'f9aebad3c781b9b8271acf9b2330d5ee'
    provider :facebook, '119881658106353', '4adba05bdb0854316f6f48f07eff4e9f', 
      :scope => 'user_education_history', :display => "popup"
  end
else
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, '197503913647031', '0d836d3236c6fc4b6f9bcbb10fa49d43',
      :scope => 'user_education_history', :display => "popup"
  end
end
