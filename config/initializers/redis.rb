uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Sidekiq.configure_server do |config|
  config.redis = { :url => uri}
end

Sidekiq.configure_client do |config|
  config.redis = { :url => uri }
end