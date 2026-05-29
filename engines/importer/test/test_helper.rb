require File.expand_path("../../../test/test_helper", __dir__)

module ImporterFixtureFiles
  def importer_fixture_file(name)
    Importer::Engine.root.join("test/fixtures/files/importer/#{name}")
  end
end

class ActiveSupport::TestCase
  include ImporterFixtureFiles
end

class ActionDispatch::IntegrationTest
  include ImporterFixtureFiles
end
