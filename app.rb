# require app dependencies
require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'shopify_api'
require 'byebug'

def init
  ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@textattak.myshopify.com/admin"
  Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
end

# create a route to render the home page
get '/' do
  erb :index
end
 
# create a route to handle the POST request to the form
post '/arnold' do
  client = init
  byebug
  # Get POST parameters submitted by the user through the form
  to_number = params[:phone].split(',')
  message = params[:message]
  media_url = [
    'http://cdn3.whatculture.com/wp-content/uploads/2012/08/Arnold-Schwarzenegger-Is-BackIn-Bronze1.jpg',
    'http://static.comicvine.com/uploads/original/6/64275/1222155-arnoldschwarzenegger.jpg',
    'http://www.craveonline.com/images/stories/2011/2013/January/Film/Commando_Arnold_Schwarzenegger.jpg',
    'http://screenrant.com/wp-content/uploads/The-Legend-of-Conan-Arnold-Schwarzenegger.jpg',
    'http://vignette1.wikia.nocookie.net/mst3k/images/9/91/RiffTrax_Presents-_Arnold_Schwarzenegger_in_The_Running_Man.jpg/revision/latest?cb=20140628084153',
    'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQTOeAfavj-fET-IBdGtHgVzhpile23s-9W0t2lmKzol5B4o0aA6w',
    'http://klyker.com/wp-content/uploads/2014/06/this-wax-statue-of-arnold-schwarzenegger-is-gross-2.jpg',
    'http://www.btchflcks.com/wp-content/uploads/2014/12/Arnold-Schwarzenegger.jpg',
    'https://hippoversuswhale.files.wordpress.com/2010/03/predator_1.jpg',
    'http://www.geeksofdoom.com/GoD/img/2011/11/2011-11-20-schwarzeneggerrecall-533x288.png',
    'http://i.imgur.com/j6Vabrd.jpg',
    'http://www.joblo.com/newsimages1/MJ-arnold-3.jpg',
    'http://esq.h-cdn.co/assets/cm/15/06/54d400c012e46_-_junior.gif',
    'http://ewpopwatch.files.wordpress.com/2011/01/predator-04_510.jpg',
    'http://t.fod4.com/t/dc84abe538/c480x270_37.jpg',
    'http://coolspotters.com/files/photos/407615/arnold-schwarzenegger-profile.jpg'
  ]
  message_text = [
    'Milk is for babies. When you grow up you have to drink beer.',
    'Your clothes, give them to me, now!',
    'If it bleeds, we can kill it!',
    'See you at the party Richter!',
    'I’ll be back',
    'Get to the chopper!',
    'Hasta La Vista, Baby!',
    "It's not a tumor!",
    'Dillon, you son of a bitch!',
    'Oh, come on...Stop whining! You kids are soft. You lack discipline.',
    "You're not gonna have your mommies run around you anymore and wipe your little tushies!",
    'There is no bathroom!!!',
    'Valor pleases you Krom',
    'Who is your daddy and what does he do?',
    'I like you Cindy',
    'I am cumming all the time'
  ]
  to_number.each do |number|
    1.times.each do 
      message = client.account.messages.create(
        :to => number,
        :body => message_text.sample.upcase,
        :media_url => media_url.sample,
     
        :from => ENV['TWILIO_NUMBER']
      )
    end
  end
 
  # Send back a simple text response that the message was sent
  "Message sent! SID: #{message.sid}"
end