require 'sinatra/base'

module Sinatra
  module MessageHelpers
    # def validate_user(order)
    #   user = User.first_or_create(shopify_id: order.user_id)
    #   raise 'TODO Invalid User' if user.nil?
    #   raise 'TODO check relationship between to and send users' if false
    #   user
    # end

    def send_attak(recipient_numbers, variant_id, sender_name, note)
      raise 'No such Attak' if (attak = Attak.where(variant_id: variant_id)[0]).nil?
      from_number = ENV['TWILIO_NUMBER']
      media_urls = Image.where(attak_id: attak)
      message_texts = Text.where(attak_id: attak)
      puts media_urls.map(&:id)
      puts message_texts.map(&:id)
      if attak.ordered != 1
        puts 'shuffle'
        media_urls = media_urls.shuffle.take(attak.count)
        message_texts = message_texts.shuffle.take(attak.count)
      end
      puts '****'
      puts media_urls.map(&:id)
      puts message_texts.map(&:id)

      initial_text = "#{sender_name.upcase} has sent you a #{attak.name.upcase}!!!"
      opt_out_text = "(To never receive another text from us visit http://textattak.com/optout)"
      final_text = "\n\nGet #{sender_name.upcase} back!!! More attaks at http://textattak.com\n#{note}"

      recipient_numbers.each do |recipient_number|
        # Send warning
        send_message(recipient_number, initial_text, "", from_number)
        # Send unsubscribe link
        send_message(recipient_number, opt_out_text, "", from_number)

        # Send attak
        message_success = []
        arr = (0..attak.count - 1).to_a
        arr.each do |i|
          puts '&&&&&&&&', i, '&&&&&&&&'
          message = message_texts[i].message
          puts message_texts[i].id, ' - ', media_urls[i].id
          puts message_texts[i].message, ' - ', media_urls[i].image_url
          message += final_text if arr.last == i # Send link on last message
          message_success << send_message(recipient_number, message, 
                media_urls[i].image_url, from_number)
        end
      end

      # Send back a simple text response that the message was sent
      puts "***************** Message sent! SID: #{variant_id} *****************"
    end
  
    def validate_recipient(phone, order = nil, line_item = nil)
      # TODO Shopify id field not in use
      phone = validate_number(phone)
      user = User.where(phone: phone).first_or_create
      if user.opt_out == true
        fulfill_order(order, line_item) unless order.nil? || line_item.nil?
        raise 'User has opted out' 
        user = nil
      end
      user
    end

    def validate_number(phone)
      # TODO actually validate number
      phone = phone.tr('^0-9','')
      raise 'Invalid Number' if phone.length != 10
      phone
    end

    def send_message(to, text, media_url, from)
      message_params = {}
      message_params[:to] = to
      message_params[:from] = from
      message_params[:body] = text unless text.empty?
      message_params[:media_url] = media_url unless media_url.empty?
      puts '@@@@@', message_params
      sent = 
        begin
          @twilio.account.messages.create(message_params)
          true
        rescue
          false
        end
      sent
    end

    def fulfill_order(order, line_item) # TODO move to Order helpers
      begin
        f = ShopifyAPI::Fulfillment.new(:order_id => order.id, :line_items =>[ {"id" => line_item.id} ] )
        f.prefix_options = { :order_id => order.id }
        f.save
        puts "***************** Line Item Fulfilled! ID: #{line_item.id} *****************"
      rescue
        puts 'Fulfillment failure ID: #{line_item.id}'
      end
    end
  end
  helpers MessageHelpers
end
