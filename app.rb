# require app dependencies
require 'rubygems'
require 'sinatra'
require 'twilio-ruby'


# create a route to render the home page
get '/' do
  erb :index
end
 
# create a route to handle the POST request to the form
post '/send' do

  client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], 
    ENV['TWILIO_AUTH_TOKEN']
 
  # Get POST parameters submitted by the user through the form
  to_number = params[:phone]
  media_url = params[:url]
  message_text = params[:message]
 
  # Send a message!
  message = client.account.messages.create(
    :to => to_number,
    :body => message_text,
    :media_url => media_url,
 
    # This is the MMS enabled number you purchased previously - replace
    # the environment variable with a string like "+16518675309"
    :from => ENV['TWILIO_NUMBER']
  )
 
  # Send back a simple text response that the message was sent
  "Message sent! SID: #{message.sid}"
end