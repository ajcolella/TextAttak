#\ -p 4567
dir = File.dirname(__FILE__)
require File.join(dir, 'app/app')

TextAttakApi.run! do |server|
  if ENV['RACK_ENV'] == 'development'
    ssl_options = {
      :cert_chain_file => ENV['SSL_CERT'],
      :private_key_file => ENV['SSL_KEY'],
      :verify_peer => false
    }
    server.ssl = true
    server.ssl_options = ssl_options
  end
end
