require "test_helper"
require "bundler"

class GemfileLockAdvisoriesTest < ActiveSupport::TestCase
  test "jwt is at or above 3.2.0 and below 4" do
    assert_locked_between "jwt", "3.2.0", "4"
  end

  test "bcrypt is at or above 3.1.22 and below 3.2" do
    assert_locked_between "bcrypt", "3.1.22", "3.2"
  end

  test "msgpack is at or above 1.8.2 and below 2" do
    assert_locked_between "msgpack", "1.8.2", "2"
  end

  private

  def assert_locked_between(name, floor, ceiling)
    version = locked_version(name)

    assert_operator version, :>=, Gem::Version.new(floor)
    assert_operator version, :<, Gem::Version.new(ceiling)
  end

  def locked_version(name)
    spec = lockfile.specs.find { |candidate| candidate.name == name }

    spec.version
  end

  def lockfile
    Bundler::LockfileParser.new(Rails.root.join("Gemfile.lock").read)
  end
end
