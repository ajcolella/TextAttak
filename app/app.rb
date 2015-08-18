require_relative 'base'

class TextAttakApi < TextAttak
  helpers Sinatra::AuthHelpers
  helpers Sinatra::MessageHelpers

  before do
    # Accept any cross-site requests from the client.
    response['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] #|| request.env['SERVER_NAME'] # TODO <-- this is for localhost
    return if request.options? # Do not require authentication for preflight requests
    authenticate!(params) unless request.env['HTTP_ORIGIN'] == 'https://checkout.shopify.com' #TODO actual request auth with shopify
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

  get '/shopify' do
    byebug if ENV['RACK_ENV'] == 'development'
  end

  post '/new_attak' do
    raise "You didn't say the magic word!" if params[:password] != ENV['TA_ATTAK_SECRET'] || params.nil?
    raise 'You must name the Attak' if params[:name].empty?
    raise 'You specify how many messages in the attak' if params[:count].empty?
    raise 'This attak needs a variant_id from schtopify' if params[:variant_id].empty?
    # TODO validate image_url mime types
    ordered = params[:ordered] || 0
    paired = params[:paired] || 0 # TODO not implemented yet
    if attak = Attak.first_or_create(variant_id: params[:variant_id])
      attak.update(name: params[:name], count: params[:count], ordered: ordered, paired: paired)
      img_urls = params[:urls].delete("\r").split("\n")
      img_urls.each { |url| Image.create(image_url: url, attak_id: attak.id) }
      texts = params[:texts].delete("\r").split("\n")
      texts.each { |text| Text.create(message: text, attak_id: attak.id) }
    end

    'ATTTAK CREATED'
  end

  post '/unsubscribe' do
    raise 'Number does not exist' if phone = params[:phone].nil?
    raise 'User does not exist' if user = User.first_or_create(phone: phone)
    user.update(opt_out: :true)
    puts "#{phone} has opted out"
    "Sorry to see you go! #{phone} has opted out."
  end

  post '/attak' do
    raise 'TODO missing params fail' if params[:id].nil?
    begin
      order = ShopifyAPI::Order.first(id: params[:id])
    rescue
      puts 'TODO fail'
    end
    attributes = order.attributes
    raise 'TODO order already fulfilled' if (fulfilled = attributes['fulfillment_status']) == 'fulfilled'
    msg_attributes = attributes['note_attributes']
    line_items = attributes['line_items']
    
    # Loop through line items for variant ids
    line_items.each do |item|
      if item.fulfillment_status == 'fulfilled'
        raise 'Order already fulfilled' # TODO
      else

        recipient_numbers = []
        item.quantity.times do |i|
          i += 1
          # Loop through number of items for "variant_id-item_number" ex: '4957917571-3'
          recipient_number = msg_attributes.select { |note| note.name == "#{item.variant_id}-#{i}" }[0].value
          # Ensure recipient has not opted out
          number = validate_recipient(recipient_number)
          recipient_numbers << number unless number.nil?
        end
        sender_name = msg_attributes.select { |note| note.name == "#{item.variant_id}-name" }[0].value
        note = msg_attributes.select { |note| note.name == "#{item.variant_id}-note" }[0].value

        message_success = send_attak(recipient_numbers, item.variant_id, sender_name, note) # TODO check successes
        fulfill_order(order, item)
      end
    end

    puts "***************** Attak sent! #{order.name} - #{order.id} *****************"
  end
end