require_relative 'base'

class TextAttakApi < TextAttak
  helpers Sinatra::AuthHelpers
  helpers Sinatra::MessageHelpers
  helpers Sinatra::TwitterHelpers

  before do
    response['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] # Accept any cross-site requests from the client.
    return if request.options? # Do not require authentication for preflight requests
    authenticate!(params) unless request.env['HTTP_ORIGIN'] == 'https://checkout.shopify.com' #TODO actual request auth with shopify
    init_api_keys
  end

  get '/' do
    @client_token = Braintree::ClientToken.generate
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
    begin
      ShopifyAPI::Product.all.map(&:variants).flatten.map(&:attributes).each { |var| puts var['sku'], var['id'] }
    rescue
      'OOPs'
    end
  end

  get '/twitter' do
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
    puts ordered, '***ORDERED***'
    if attak = Attak.where(variant_id: params[:variant_id]).first_or_create
      attak.update(name: params[:name], count: params[:count], ordered: ordered, paired: paired)
      img_urls = params[:urls].delete("\r").split("\n")
      img_urls.each { |url| Image.where(image_url: url, attak_id: attak.id).first_or_create }
      texts = params[:texts].delete("\r").split("\n")
      texts.each { |text| Text.where(message: text, attak_id: attak.id).first_or_create }
    end

    'ATTTAK CREATED'
  end

  post '/unsubscribe' do
    raise 'Number does not exist' if params[:phone].nil?
    user = validate_recipient(params[:phone])
    user.update(opt_out: true)
    puts "#{user.phone} has opted out"
    "Sorry to see you go! #{user.phone} has opted out."
  end

  post '/checkout' do
    puts params
    if params[:_csrf].nil? || params[:optionsRadios].nil? || params[:nonce].nil? ||
      params[:name].nil? || (params[:phone].nil? && params[:phones].nil?)
      raise "Missing Params #{params}" 
    end
    phone_numbers = []
    phone_numbers << params[:phones].join(',') unless params[:phones].nil?
    phone_numbers << params[:phone] unless params[:phone].nil?
    phone_numbers.map! { |num| num.gsub(/\+1 \(|\) |-/,"")}
    phone_numbers.select! { |num| num != "+1 "}
    type = 
      case params[:optionsRadios]
      when "1"
        [0.99, 8, "The Mouth Breather"]
      when "2"
        [1.25, 15, "🇨🇳🇨🇳 The China China 🇨🇳🇨🇳"] 
      when "3"
        [1.75, 30, "💩 THE TRUMPF DUMP 💩"]
      end
    amount = type[0] * phone_numbers.length
    if params[:nonce] != "fake_nonce"
      res = Braintree::Transaction.sale(
        :amount => amount.to_s,
        :payment_method_nonce => params[:nonce],
        :options => {
          :submit_for_settlement => true
        }
      )
      raise "**** Payment Failed! #{params[:name]} - #{phone_numbers}" if !res.success?
    end
    variant_id = ENV['TEXTATTAK_VARIANT_ID']
    send_attak(phone_numbers, variant_id, params[:name], params[:message], type[1])
    puts "***************** Attak sent! #{params[:name]} - #{phone_numbers} *****************"
    @bomb_name = type[2]
    erb :checkout
  end

  post '/attak' do
    raise 'TODO missing params fail' if params[:id].nil?
    begin
      order = ShopifyAPI::Order.first(id: params[:id])
    rescue
      puts 'TODO Shopify API fail'
    end
    raise 'TODO Order has been fulfilled' if order.nil?
    msg_attributes = order.attributes['note_attributes']
    line_items = order.attributes['line_items']
    
    # Loop through line items for variant ids
    line_items.each do |item|
      if item.fulfillment_status == 'fulfilled'
        raise 'Order already fulfilled' # TODO
      else
        recipient_numbers = []
        item.quantity.times do |i|
          i += 1
          # Loop through number of items for "variant_id-item_number" ex: '4957917571-3'
          if !(recipient_number = msg_attributes.select { |note| note.name == "#{item.variant_id}-#{i}" }[0]).nil?
            # Ensure recipient has not opted out
            number = validate_recipient(recipient_number.value, order, item).phone
            recipient_numbers << number unless number.nil?
          end
        end
        sender_name = 
          if !(name = msg_attributes.select { |note| note.name == "#{item.variant_id}-name" }[0]).nil?
            name.value 
          else
            "!"
          end
        note = 
          if !(msg = msg_attributes.select { |note| note.name == "#{item.variant_id}-note" }[0]).nil?
            msg.value
          else
            ""
          end

        message_success = send_attak(recipient_numbers, item.variant_id, sender_name, note) # TODO check successes
        fulfill_order(order, item)
      end
    end

    puts "***************** Attak sent! #{order.name} - #{order.id} *****************"
  end
end