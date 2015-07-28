require 'sinatra/base'

module Sinatra
  module TextAttakHelpers
    def init_api_keys
      ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@textattak.myshopify.com/admin"
      @twilio = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    end

    
  end
  helpers TextAttakHelpers
end