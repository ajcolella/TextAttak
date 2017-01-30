require 'sinatra/base'

module Sinatra
  module TwitterHelpers

    def init_twitter_keys(account)
      account_name = account.nil? ? "" : "#{account}_"
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["#{account_name}TWITTER_KEY"]
        config.consumer_secret     = ENV["#{account_name}TWITTER_SECRET"]
        config.access_token        = ENV["#{account_name}TWITTER_ACCESS_TOKEN"]
        config.access_token_secret = ENV["#{account_name}TWITTER_ACCESS_SECRET"]
      end
    end

  end
  helpers TwitterHelpers
end
