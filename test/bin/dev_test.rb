require "test_helper"

class BinDevTest < ActiveSupport::TestCase
  test "bin/dev starts the development procfile with app redis defaults" do
    script = Rails.root.join("bin/dev")

    assert_predicate script, :exist?
    assert_predicate script, :executable?
    assert_includes script.read, 'export REDIS_URL="${REDIS_URL:-redis://localhost:6379/1}"'
    assert_includes script.read, 'export PORT="${PORT:-3000}"'
    assert_includes script.read, 'exec foreman start -f Procfile.dev "$@"'
  end

  test "development procfile starts rails and sidekiq" do
    procfile = Rails.root.join("Procfile.dev").read

    assert_includes procfile, "web: bin/rails server"
    assert_includes procfile, "worker: bundle exec sidekiq -c 8 -q default -q mailers -q paperclip"
  end
end
