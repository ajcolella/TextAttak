desc "Twitter Scheduler"
task :tweet => :production do
  init_twitter_keys
  attaks = Attak.all.count
  rand_attak = Random.rand(attaks) + 1
  image = Image.where(attak_id: rand_attak).map(&:image_url).sample
  text = Text.where(attak_id: rand_attak).map(&:message).sample

  begin
    @twitter.update_with_media
  rescue
    "Tweet Failed"
  end
end

desc "Send Final Text"
task :final_text => :production do
  init_api_keys
  # ShopifyAPI::Order.where()
  puts 'Scheduled Run'
end