require './app'
TextAttakApi.run! do |server|
  if ENV['RACK_ENV'] == 'development'
    ssl_options = {
      :cert_chain_file => '/Users/ooo/Projects/TextAttak/certs/server.crt',
      :private_key_file => '/Users/ooo/Projects/TextAttak/certs/server.key',
      :verify_peer => false
    }
    server.ssl = true
    server.ssl_options = ssl_options
  end
end
