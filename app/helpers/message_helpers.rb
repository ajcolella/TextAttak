require 'sinatra/base'

module Sinatra
  module MessageHelpers

    def validate_user(order)
      user = User.first_or_create(shopify_id: order.user_id)
      raise 'TODO Invalid User' if user.nil?
      raise 'TODO check relationship between to and send users' if false
      user
    end

    def validate_recipient(phone)
      begin
        user = User.first(phone: phone)
      rescue
        'TODO User has opted out'
      end
      user
    end

    def send_attak(type, to_user, from_number)

      puts order_id
      puts params
      
      message = params[:message]


      message = to_number.each do |number|
        10.times.each do 
          send_message(number, message_text, media_url, from_number)
        end
      end

      # Send back a simple text response that the message was sent
      "Message sent! SID: #{message.sid}"
    end
  end

  def send_message(to, text, image_url, from)
    message = @twilio.account.messages.create(
      :to => to,
      :body => text,
      :media_url => image_url,
      :from => from
    )
    message.id
  end

  helpers MessageHelpers
end
