module App
  class Application < Rails::Application
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*',
        :headers => :any,
        :expose => ['X-User-Authentication-Token', 'X-User-Id'],
        :methods => [:get, :post, :options, :patch, :delete]
      end
    end
  end
end