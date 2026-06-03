require "test_helper"
require "rake"

class SeedsTest < ActiveSupport::TestCase
  setup do
    define_seed_task "db:seed:draw_steel:all"
    define_seed_task "db:seed:5e:all"
    define_seed_task "db:seed:pf2e:all"
  end

  test "sample accounts are skipped outside local environments" do
    production = ActiveSupport::StringInquirer.new("production")

    assert_no_changes -> { User.where(email: "user@example.com").count } do
      assert_no_changes -> { Admin.where(email: "user@example.com").count } do
        with_rails_env(production) { load Rails.root.join("db/seeds.rb") }
      end
    end
  end

  private

  def define_seed_task(task_name)
    Rake::Task.define_task(task_name) unless Rake::Task.task_defined?(task_name)
  end

  def with_rails_env(environment)
    original_environment = Rails.method(:env)
    Rails.define_singleton_method(:env) { environment }
    yield
  ensure
    Rails.define_singleton_method(:env, original_environment)
  end
end
