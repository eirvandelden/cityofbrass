require 'test_helper'

module Entitybuilder
  class KnownSpellTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      known_spell = KnownSpell.new
      assert_not known_spell.valid?
      assert_equal [:spell_id], known_spell.errors.keys
    end

  end
end
