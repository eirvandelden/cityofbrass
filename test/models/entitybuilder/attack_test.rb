# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class AttackTest < ActiveSupport::TestCase

    test "attack should have the necessary required validators" do
      attack = Attack.new(name: "AttackTest")
      assert_not attack.valid?
      assert_equal [:attack_type], attack.errors.keys
    end

  end
end
