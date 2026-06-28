require "test_helper"
require "yaml"

class CiWorkflowTest < ActiveSupport::TestCase
  test "test job installs JavaScript dependencies before Rails tests" do
    steps = ci_workflow.fetch("jobs").fetch("test").fetch("steps")
    step_names = steps.filter_map { |step| step["name"] }

    install_index = step_names.index("Install JavaScript dependencies")
    test_index = step_names.index("Run tests")

    assert install_index, "Test job must install JavaScript dependencies for Sprockets assets"
    assert install_index < test_index
  end

  private

    def ci_workflow
      YAML.safe_load(Rails.root.join(".github/workflows/ci.yml").read)
    end
end
