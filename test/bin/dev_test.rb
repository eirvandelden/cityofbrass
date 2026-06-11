require "test_helper"

class BinDevTest < ActiveSupport::TestCase
  test "bin/dev starts sidekiq and rails with app redis defaults" do
    script = Rails.root.join("bin/dev")
    contents = script.read

    assert_predicate script, :exist?
    assert_predicate script, :executable?
    assert_includes contents, 'export REDIS_URL="${REDIS_URL:-redis://localhost:6379/1}"'
    assert_includes contents, 'export PORT="${PORT:-3000}"'
    assert_includes contents, "bundle exec sidekiq -c 8 -q imports -q default -q mailers -q paperclip &"
    assert_includes contents, 'exec bin/rails server "$@"'
    assert_not_includes contents, "gem install"
  end

  test "development procfile starts rails and sidekiq" do
    procfile = Rails.root.join("Procfile.dev").read

    assert_includes procfile, "web: bin/rails server"
    assert_includes procfile, "worker: bundle exec sidekiq -c 8 -q imports -q default -q mailers -q paperclip"
  end

  test "deployment worker handles importer jobs" do
    deploy_config = Rails.root.join("config/deploy.yml").read

    assert_includes deploy_config, "cmd: bundle exec sidekiq -c 8 -q imports -q default -q mailers -q paperclip"
  end

  test "development redis defaults use the app redis database" do
    sidekiq_initializer = Rails.root.join("config/initializers/sidekiq.rb").read
    redis_initializer = Rails.root.join("config/initializers/redis.rb").read

    assert_includes sidekiq_initializer, 'Rails.env.development? ? "redis://localhost:6379/1" : nil'
    assert_includes redis_initializer, 'Rails.env.development? ? "redis://localhost:6379/1" : nil'
  end

  test "sidekiq scheduler can sleep with installed connection pool" do
    stack = ConnectionPool::TimedStack.new

    assert_raises(ConnectionPool::TimeoutError) { stack.pop(0) }
  end
end
