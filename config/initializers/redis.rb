if ENV["REDISCLOUD_URL"]
  $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
end
if ENV["REDISCLOUD_WHITE_URL"]
  $redis = Redis.new(:url => ENV["REDISCLOUD_WHITE_URL"])
end
