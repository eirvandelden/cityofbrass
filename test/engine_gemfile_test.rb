require "test_helper"
require "bundler"

class EngineGemfileTest < ActiveSupport::TestCase
  def test_ruby_34_engines_include_drb
    missing = ruby_34_engine_gemfiles.reject do |gemfile|
      dependency_names(gemfile).include?("drb")
    end

    assert_empty missing.map { |gemfile| engine_name(gemfile) }
  end

  private

  def ruby_34_engine_gemfiles
    Dir[Rails.root.join("engines/*/.ruby-version")].filter_map do |ruby_version|
      Rails.root.join(File.dirname(ruby_version), "Gemfile") if ruby_34_or_newer?(ruby_version)
    end
  end

  def ruby_34_or_newer?(ruby_version)
    Gem::Version.new(File.read(ruby_version).strip) >= Gem::Version.new("3.4.0")
  end

  def dependency_names(gemfile)
    Bundler::Dsl.evaluate(gemfile.to_s, nil, {}).dependencies.map(&:name)
  end

  def engine_name(gemfile)
    Pathname(gemfile).dirname.basename.to_s
  end
end
