require 'sinatra/base'

module Sinatra
  module AuthHelpers 
    def init_api_keys
      ShopifyAPI::Base.site ||= "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@textattak.myshopify.com/admin"
      @twilio ||= Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    end

    def authenticate!(params)
      # session[:csrf] ||= SecureRandom.hex(32)
      # response.set_cookie 'ta_auth_token', {
      #   value: session[:csrf],
      #   expires: Time.now + (60 * 60 * 24 * 180), # 180 days
      #   path: '/',
      #   httponly: true
      # }
      # unless request.safe?
      #   unless session[:csrf] == params['_csrf'] && session[:csrf] == request.cookies['ta_auth_token']
      #     halt 403, 'CSRF failed'
      #   end
      # end
    end

  end
  helpers AuthHelpers
end