require "test_helper"

class DockerfileAssetsTest < ActiveSupport::TestCase
  test "docker build installs javascript dependencies before precompiling assets" do
    dockerfile = Rails.root.join("Dockerfile").read
    install_position = dockerfile.index("npm ci")
    precompile_position = dockerfile.index("assets:precompile")

    assert install_position, "Dockerfile must install npm dependencies"
    assert precompile_position, "Dockerfile must precompile assets"
    assert install_position < precompile_position, "npm ci must run before assets:precompile"
  end
end
