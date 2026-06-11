development_redis_url = Rails.env.development? ? "redis://localhost:6379/1" : nil
redis_url = ENV["REDIS_URL"] || ENV["REDISCLOUD_URL"] || ENV["REDISCLOUD_WHITE_URL"] || development_redis_url

$redis = Redis.new(url: redis_url) if redis_url
