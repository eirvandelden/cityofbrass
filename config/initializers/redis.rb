# frozen_string_literal: false

if ENV["REDISCLOUD_URL"]
  $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
end
if ENV["REDISCLOUD_WHITE_URL"]
  $redis = Redis.new(:url => ENV["REDISCLOUD_WHITE_URL"])
end
if ENV["REDIS_URL"]
  $redis = Redis.new(:url => ENV["REDIS_URL"])
end
