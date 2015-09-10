require 'sinatra/base'

module Sinatra
  module TwitterHelpers

    def init_twitter_keys
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_KEY']
        config.consumer_secret     = ENV['TWITTER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
      end
    end

  end
  helpers TwitterHelpers
end
