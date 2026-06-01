require "test_helper"
require "fileutils"
require "tmpdir"

class DockerEntrypointTest < ActiveSupport::TestCase
  test "creates the storage db directory before exec" do
    Dir.mktmpdir do |dir|
      storage_root = File.join(dir, "storage")
      sentinel = File.join(dir, "sentinel")

      system(
        {
          "RAILS_STORAGE_PATH" => storage_root,
          "SENTINEL" => sentinel
        },
        Rails.root.join("bin/docker-entrypoint").to_s,
        "sh",
        "-c",
        "test -d \"$RAILS_STORAGE_PATH/db\" && touch \"$SENTINEL\""
      )

      assert Dir.exist?(File.join(storage_root, "db"))
      assert File.exist?(sentinel)
    end
  end
end
