require "test_helper"

class DockerfileAssetsTest < ActiveSupport::TestCase
  test "docker build installs javascript dependencies before precompiling assets" do
    dockerfile = Rails.root.join("Dockerfile").read
    install_position = dockerfile.index("yarn install --frozen-lockfile")
    precompile_position = dockerfile.index("assets:precompile")

    assert install_position, "Dockerfile must install yarn dependencies"
    assert precompile_position, "Dockerfile must precompile assets"
    assert install_position < precompile_position, "yarn install must run before assets:precompile"
  end
end
