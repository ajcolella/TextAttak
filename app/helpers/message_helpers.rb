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
      media_urls = get_media_urls(attak)
      message_texts = get_message_texts(attak)
      
      initial_text = "#{sender_name.upcase} has sent you a #{attak.name.upcase}!!!"
      opt_out_text = "(To never receive another text from us visit http://textattak.com/optout)"
      final_text = "\nGet #{sender_name.upcase} back!!! More attaks at http://textattak.com"

      recipient_numbers.each do |recipient_number|
        # Send warning
        send_message(recipient_number, initial_text, "", from_number)
        # Send unsubscribe link
        send_message(recipient_number, opt_out_text, "", from_number)

        # Send attak
        message_success = []
        puts attak.count, 'count'
        attak.count.times.each do |i|
          message = message_texts[i].message
          message += final_text if attak.count == i # Send link on last message
          puts message, ' m ' 
          message_success << send_message(recipient_number, message, 
                media_urls[i].image_url, from_number)
        end
      end

      # Send back a simple text response that the message was sent
      # puts "***************** Message sent! SID: #{message.sid} *****************"
    end
  
    def validate_recipient(phone)
      user = User.first_or_create(phone: phone)
      if user.opt_out == true
        raise 'TODO User has opted out' 
        user = nil
      end
      user.phone
    end

    def get_media_urls(attak)
      media_urls = Image.where(attak_id: attak) # TODO limit query
      media_urls.shuffle unless attak.ordered
      media_urls[0..attak.count]
    end

    def get_message_texts(attak)
      message_texts = Text.where(attak_id: attak)
      message_texts.shuffle unless attak.ordered
      message_texts[0..attak.count]
    end

    def send_message(to, text, media_url, from)
      message_params = {}
      message_params[:to] = to
      message_params[:from] = from
      message_params[:body] = text unless text.empty?
      message_params[:media_url] = media_url unless media_url.empty?

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
