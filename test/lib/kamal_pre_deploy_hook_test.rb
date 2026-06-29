require "test_helper"

class KamalPreDeployHookTest < Minitest::Test
  def test_runs_migrations_once_from_the_new_web_image
    hook = Rails.root.join(".kamal/hooks/pre-deploy").read

    assert_includes hook, 'kamal app exec --version "$KAMAL_VERSION" --primary --roles web "bin/rails db:migrate"'
    assert_equal false, hook.include?("--reuse")
  end
end
