require_relative 'base'

class TextAttakApi < TextAttak
  helpers Sinatra::AuthHelpers
  helpers Sinatra::MessageHelpers

  before do
    # Accept any cross-site requests from the client.
    response['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] #|| request.env['SERVER_NAME'] # TODO <-- this is for localhost
    return if request.options? # Do not require authentication for preflight requests
    authenticate!(params) #TODO actual request auth with shopify
    init_api_keys
  end

  get '/' do
    erb :index
  end

  get '/new_attak' do
    erb :new_attak
  end

  get '/unsubscribe' do
    erb :unsubscribe
  end

  post '/new_attak' do
    byebug
    raise "You didn't say the magic word!" if params[:password].empty? || params.nil? #TODO change password
    raise 'You must name the Attak' if params[:name].empty?
    # TODO validate image_url mime types
    if attak = Attak.first_or_create(name: params[:name])
      (1..10).each do |i|
        Image.create(image_url: params[i.to_s], attak_id: attak.id) unless params[i.to_s].empty?
        Text.create(message: params[(i + 20).to_s], attak_id: attak.id) unless params[(i + 20).to_s].empty?
      end
    end

    'ATTTAK CREATED'
  end

  post '/unsubscribe' do
    raise 'Number does not exist' if phone = params[:phone].nil?
    raise 'User does not exist' if user = User.first(phone: phone)
    user.update(opt_out: :true)
    
    # TODO create unsubscribe list
  end

  # post '/validate' do
  #   # TODO validate phone numbers before checkout screen and add them to the order
  #   from_user = valid_user(order.user_id) #TODO valid phone number check
  #   order.notes.wahtever.whatever.each do |to_number|
  #     validate_recipient(to_number)
  # end

  post '/attak' do
    byebug
    params['id'] = 879120067
    raise 'TODO missing params fail' if params[:id].nil?
    begin
      order = ShopifyAPI::Order.first(id: params[:id])
    rescue
      puts 'TODO fail'
    end
    raise 'TODO order already fulfilled' if order.fulfilment_status == 'fulfilled'
    raise 'TODO invalid type' if type = params[:type].nil?
    # TODO check that user will receive texts
    to_numbers = params[:phone].length > 1 ? params[:phone].split(',') : [params[:phone]]
    # from_number = ENV['TWILIO_NUMBER'] # TODO generate twilio numbers
    send_attak(order.sku, to_numbers)
    puts 'ATTAk'
  end

  # post '/arnold' do
  #   Images.all()
  #   media_url = [
  #     'http://cdn3.whatculture.com/wp-content/uploads/2012/08/Arnold-Schwarzenegger-Is-BackIn-Bronze1.jpg',
  #     'http://static.comicvine.com/uploads/original/6/64275/1222155-arnoldschwarzenegger.jpg',
  #     'http://www.craveonline.com/images/stories/2011/2013/January/Film/Commando_Arnold_Schwarzenegger.jpg',
  #     'http://screenrant.com/wp-content/uploads/The-Legend-of-Conan-Arnold-Schwarzenegger.jpg',
  #     'http://vignette1.wikia.nocookie.net/mst3k/images/9/91/RiffTrax_Presents-_Arnold_Schwarzenegger_in_The_Running_Man.jpg/revision/latest?cb=20140628084153',
  #     'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQTOeAfavj-fET-IBdGtHgVzhpile23s-9W0t2lmKzol5B4o0aA6w',
  #     'http://www.btchflcks.com/wp-content/uploads/2014/12/Arnold-Schwarzenegger.jpg',
  #     'https://hippoversuswhale.files.wordpress.com/2010/03/predator_1.jpg',
  #     'http://www.geeksofdoom.com/GoD/img/2011/11/2011-11-20-schwarzeneggerrecall-533x288.png',
  #     'http://i.imgur.com/j6Vabrd.jpg',
  #     'http://www.joblo.com/newsimages1/MJ-arnold-3.jpg',
  #     'http://esq.h-cdn.co/assets/cm/15/06/54d400c012e46_-_junior.gif',
  #     'http://ewpopwatch.files.wordpress.com/2011/01/predator-04_510.jpg',
  #     'http://t.fod4.com/t/dc84abe538/c480x270_37.jpg',
  #     'http://coolspotters.com/files/photos/407615/arnold-schwarzenegger-profile.jpg'
  #   ]
  #   message_text = [
  #     'Milk is for babies. When you grow up you have to drink beer.',
  #     'Your clothes, give them to me, now!',
  #     'If it bleeds, we can kill it!',
  #     'See you at the party Richter!',
  #     'I’ll be back',
  #     'Get to the chopper!',
  #     'Hasta La Vista, Baby!',
  #     "It's not a tumor!",
  #     'Dillon, you son of a bitch!',
  #     'Oh, come on...Stop whining! You kids are soft. You lack discipline.',
  #     "You're not gonna have your mommies run around you anymore and wipe your little tushies!",
  #     'There is no bathroom!!!',
  #     'Valor pleases you Krom',
  #     'Who is your daddy and what does he do?',
  #     'I like you Cindy',
  #     'I am cumming all the time'
  #   ]

  # end
end