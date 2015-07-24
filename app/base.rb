require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'twilio-ruby'
require 'shopify_api'
require 'byebug'
require 'rack/ssl'
require 'tilt/erubis'

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/views/*.rb'].each {|file| require file }

class TextAttak < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  use Rack::SSL

  configure do
    Sinatra::Application.reset!
    use Rack::Reloader

    db = URI.parse(ENV['DATABASE_URL'])
    ActiveRecord::Base.establish_connection(
     :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
     :host     => db.host,
     :username => db.user,
     :password => db.password,
     :database => db.path[1..-1],
     :encoding => 'utf8'
    )
  end
end