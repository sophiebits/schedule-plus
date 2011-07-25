require 'openssl'
###############
# Remove this code after setting up SSL
if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
###############

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, 'f1e98cfb98bf5b2199e7ebe904d30ba3', 'f9aebad3c781b9b8271acf9b2330d5ee'
end