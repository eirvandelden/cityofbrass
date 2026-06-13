require "test_helper"
require "open3"
require "tmpdir"

class BinDevTest < ActiveSupport::TestCase
  test "bin/dev starts sidekiq and rails with app redis defaults" do
    script = Rails.root.join("bin/dev")
    contents = script.read

    assert_predicate script, :exist?
    assert_predicate script, :executable?
    assert_includes contents, 'export REDIS_URL="${REDIS_URL:-redis://localhost:6379/1}"'
    assert_includes contents, 'export PORT="${PORT:-3000}"'
    assert_includes contents, "bundle exec sidekiq -c 8 -q imports -q default -q mailers -q paperclip &"
    assert_includes contents, 'trap \'status=$?; cleanup; exit "$status"\' EXIT'
    assert_includes contents, 'bin/rails server "$@" &'
    assert_includes contents, 'wait "$rails_pid"'
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

  test "root procfile worker handles importer jobs" do
    procfile = Rails.root.join("Procfile").read

    assert_includes procfile, "worker: bundle exec sidekiq -c 8 -q imports -q default -q mailers -q paperclip"
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

  test "bin/dev stops sidekiq when rails server exits" do
    sidekiq_pid = nil

    Dir.mktmpdir do |dir|
      install_bin_dev(dir)
      install_bundle_stub(dir)
      install_rails_stub(dir)

      _, stderr, status = Open3.capture3(bin_dev_env(dir), "#{dir}/bin/dev", chdir: dir)
      sidekiq_pid = File.read("#{dir}/sidekiq.pid").to_i

      assert status.success?, stderr
      assert_not process_alive?(sidekiq_pid), "expected sidekiq process #{sidekiq_pid} to stop"
    ensure
      Process.kill("TERM", sidekiq_pid) if sidekiq_pid && process_alive?(sidekiq_pid)
    end
  end

  private

  def install_bin_dev(dir)
    FileUtils.mkdir_p("#{dir}/bin")
    FileUtils.cp Rails.root.join("bin/dev"), "#{dir}/bin/dev"
    FileUtils.chmod 0o755, "#{dir}/bin/dev"
  end

  def install_bundle_stub(dir)
    File.write("#{dir}/bin/bundle", <<~SH)
      #!/usr/bin/env sh
      exec >/dev/null 2>/dev/null
      echo "$$" > "$TEST_SIDEKIQ_PID_FILE"
      trap 'exit 0' TERM INT
      while true; do sleep 1; done
    SH
    FileUtils.chmod 0o755, "#{dir}/bin/bundle"
  end

  def install_rails_stub(dir)
    File.write("#{dir}/bin/rails", <<~SH)
      #!/usr/bin/env sh
      exit 0
    SH
    FileUtils.chmod 0o755, "#{dir}/bin/rails"
  end

  def bin_dev_env(dir)
    {
      "PATH" => "#{dir}/bin:#{ENV.fetch("PATH")}",
      "TEST_SIDEKIQ_PID_FILE" => "#{dir}/sidekiq.pid"
    }
  end

  def process_alive?(pid)
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH
    false
  end
end
