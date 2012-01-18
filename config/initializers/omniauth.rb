require 'openssl'
###############
# Remove this code after setting up SSL
if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
###############

if Rails.env.development?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, '119881658106353', '4adba05bdb0854316f6f48f07eff4e9f' 
      #:scope => 'email', :display => "popup"
  end
else
  Rails.application.config.middleware.use OmniAuth::Builder do
    # acm-schedule
    provider :facebook, '197503913647031', '0d836d3236c6fc4b6f9bcbb10fa49d43',
    :scope => ''
    # freezing-dusk-1440
    # provider :facebook, '210051385740775', '0f317afd289116a77f33410e656c60cf'
    #:scope => 'email', :display => "popup"
  end
end

