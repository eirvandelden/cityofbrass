require "test_helper"
require "bundler"

class EngineGemfileTest < ActiveSupport::TestCase
  def test_ruby_34_engines_include_drb
    missing = ruby_34_engine_gemfiles.reject do |gemfile|
      dependency_names(gemfile).include?("drb")
    end

    assert_empty missing.map { |gemfile| engine_name(gemfile) }
  end

  def test_sqlite_uses_ruby_platform
    missing = sqlite_gemfiles.reject do |gemfile|
      sqlite_dependency(gemfile).force_ruby_platform
    end

    assert_empty missing.map { |gemfile| gemfile.relative_path_from(Rails.root).to_s }
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
    dependencies(gemfile).map(&:name)
  end

  def sqlite_gemfiles
    Dir[Rails.root.join("{Gemfile,engines/*/Gemfile}")].filter_map do |gemfile|
      Pathname(gemfile) if dependency_names(gemfile).include?("sqlite3")
    end
  end

  def sqlite_dependency(gemfile)
    dependencies(gemfile).find { |dependency| dependency.name == "sqlite3" }
  end

  def dependencies(gemfile)
    Bundler::Dsl.evaluate(gemfile.to_s, nil, {}).dependencies
  end

  def engine_name(gemfile)
    Pathname(gemfile).dirname.basename.to_s
  end
end
