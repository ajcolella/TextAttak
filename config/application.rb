module App
  class Application < Rails::Application
    config.middleware.insert_before 0, "Rack::Cors" do
      puts '********************************************************'
      allow do
        origins '*'
        resource '*',
        :headers => :any,
        :expose => :any,
        :methods => [:get, :post, :options, :patch, :delete]
      end
    end
  end
end