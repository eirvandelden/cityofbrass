require "test_helper"

class SetupTest < ActiveSupport::TestCase
  test "a failed JavaScript install stops the setup" do
    assert_match(/system!\s*\(?["']yarn install/, Rails.root.join("bin/setup").read,
      "bin/setup must stop when installing JavaScript dependencies fails")
  end

  test "installs JavaScript dependencies before preparing the database" do
    setup_script = Rails.root.join("bin/setup").read
    install_position = setup_script.index("yarn install")
    prepare_position = setup_script.index("bin/rails db:prepare")

    assert install_position, "bin/setup must install JavaScript dependencies"
    assert prepare_position, "bin/setup must prepare the database"
    assert install_position < prepare_position, "bin/setup must install JavaScript dependencies before database setup"
  end
end
