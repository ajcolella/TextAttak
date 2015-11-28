require './app/app'
require 'sinatra/base'
require 'sinatra/activerecord/rake'
require './app/base'
require 'open-uri'

include Sinatra::MessageHelpers
include Sinatra::TwitterHelpers
include Sinatra::AuthHelpers

desc "Twitter Scheduler"
task :tweet do
  # Run once an hour. 09:00, 13:00, 20:00 on odd days. 11:00, 16:00, 21:00, even days
  if ([9, 13, 20].include?(DateTime.now.hour) && !DateTime.now.day.odd?) || ([11, 16, 21].include?(DateTime.now.hour) && DateTime.now.day.odd?)
    init_twitter_keys
    tag = ' #' + ['textbomb', 'funny', 'joke', 'collegehumor', 'stoopidtexts', 'prank', 'pranktext'].sample.to_str
    attak = Attak.all.sample
    image = Image.where(attak_id: attak.id).map(&:image_url).sample
    text = Text.where(attak_id: attak.id).map(&:message).sample + ' #' + attak.name.delete(' ') + tag
    byebug
    #TODO hastags from shopify product tags
    begin
      uri = URI.parse(image)
      media = uri.open
      media.instance_eval("def original_filename; '#{File.basename(uri.path)}'; end")
      @twitter.update_with_media(text, media)
    rescue
      puts 'Invalid credentials'
    end
  end
end

desc "Send Final Text"
task :final_text do

  init_api_keys
  # 1. schedule final text every 10 minutes. heroku scheduler
  # 2. redis queue of all pending texts. schedule ever 30 secs
  # ShopifyAPI::Order.find(:all, params: {status: 'closed'})
  puts 'Scheduled Run'
end