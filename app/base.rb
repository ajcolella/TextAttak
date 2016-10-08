require 'rubygems'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'twilio-ruby'
require 'shopify_api'
require 'byebug'
require 'rack/ssl'
require 'tilt/erubis'
require 'phony'
require 'twitter'
require 'braintree'

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/views/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/tasks/*.rake'].each {|file| require file }

class TextAttak < Sinatra::Base

  Braintree::Configuration.environment = :production
  Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
  Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
  Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']

  ALLOW_HEADERS = 'Accept, Authorization'
  ALLOW_METHODS = 'GET, POST'
  ALLOW_MAX_AGE = 20 * 60

  register Sinatra::ActiveRecordExtension
  use Rack::SSL
  enable :sessions

  configure do
    Sinatra::Application.reset!
    use Rack::Reloader

    db_url = (ENV['RACK_ENV'] == 'production') ? ENV['DATABASE_URL'] : ENV['TA_DATABASE_URL']
    db = URI.parse(db_url)
    ActiveRecord::Base.establish_connection(
     :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
     :host     => db.host,
     :username => db.user,
     :password => db.password,
     :database => db.path[1..-1],
     :encoding => 'utf8'
    )
  end

  # options ['http*://*textattak.com', 'https://checkout.shopify.com'] do
  options '*' do
    headers 'Access-Control-Allow-Headers' => ALLOW_HEADERS,
            'Access-Control-Allow-Methods' => ALLOW_METHODS,
            'Access-Control-Max-Age'       => ALLOW_MAX_AGE
  end
end