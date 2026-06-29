require "minitest/autorun"
require "pathname"

class SchemaIntegrityTest < Minitest::Test
  def test_schema_has_no_dump_failures
    schema = Pathname.new(__dir__).join("../../db/schema.rb").read

    assert_includes schema, 'create_table "entitybuilder_currencies"'
    assert_includes schema, 'create_table "rulebuilder_items"'
    assert_equal false, schema.include?("Could not dump table")
  end
end
