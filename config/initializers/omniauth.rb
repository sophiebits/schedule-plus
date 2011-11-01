require 'openssl'
###############
# Remove this code after setting up SSL
if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
###############

if Rails.env.development?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :cmu, 
    provider :facebook, '119881658106353', '4adba05bdb0854316f6f48f07eff4e9f', 
      :scope => 'email', :display => "popup"
  end
else
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, '197503913647031', '0d836d3236c6fc4b6f9bcbb10fa49d43',
      :scope => 'email', :display => "popup"
  end
end

 
