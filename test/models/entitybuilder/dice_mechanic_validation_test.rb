require "test_helper"

module Entitybuilder
  class DiceMechanicValidationTest < ActiveSupport::TestCase
    MODELS = {
      Skill => :dice,
      AbilityScore => :dice,
      BaseValue => :dice,
      Movement => :dice,
      SavingThrow => :dice,
      Attack => :attack_dice
    }.freeze

    setup do
      @entity = entitybuilder_entities(:resident_character_one)
    end

    test "each dice-mechanic model refuses text around a mechanic on create" do
      each_model do |model, field|
        record = build(model, field, "foo Standard bar")

        assert_not record.valid?, "#{model} should refuse text around a mechanic"
        assert_includes record.errors.attribute_names, field
      end
    end

    test "each dice-mechanic model refuses a changed value with text around a mechanic" do
      each_model do |model, field|
        record = create(model, field, "1d20")
        record.public_send("#{field}=", "Standard ")

        assert_not record.valid?, "#{model} should refuse a changed value with text around it"
      end
    end

    test "each dice-mechanic model saves an unchanged legacy value" do
      each_model do |model, field|
        record = create(model, field, "1d20")
        record.update_column(field, "1d20 Standard")

        record.name = "Renamed"

        assert record.save, "#{model} should save with an unchanged legacy value"
      end
    end

    test "each dice-mechanic model saves a valid replacement for a legacy value" do
      each_model do |model, field|
        record = create(model, field, "1d20")
        record.update_column(field, "1d20 Standard")

        record.public_send("#{field}=", "Fate")

        assert record.save, "#{model} should save a valid replacement"
      end
    end

    test "each dice-mechanic model refuses an overlong value" do
      each_model do |model, field|
        record = build(model, field, "1d20" + "+1d20" * 60)

        assert_not record.valid?, "#{model} should refuse an overlong value"
        assert_includes record.errors.details[field].pluck(:error), :too_long
      end
    end

    private
      def each_model(&block)
        MODELS.each { |model, field| block.call(model, field) }
      end

      def build(model, field, value)
        attributes = { entity: @entity, name: "Dice #{model.name.demodulize}", field => value }
        attributes[:attack_type] = "Melee" if model == Attack
        model.new(attributes)
      end

      def create(model, field, value)
        build(model, field, value).tap(&:save!)
      end
  end
end
