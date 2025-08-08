# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      # Allow any origin in development for external access
      origins '*'
    else
      # Restrict origins in production
      origins "localhost:3000", "127.0.0.1:3000"
    end

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
  
  # Additional rule for common development ports and IPs
  if Rails.env.development?
    allow do
      origins /\Ahttp:\/\/.*:300[0-9]\z/, /\Ahttp:\/\/.*:3001\z/
      
      resource "*",
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true
    end
  end
end
