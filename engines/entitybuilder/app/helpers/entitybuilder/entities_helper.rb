# frozen_string_literal: false

module Entitybuilder
  module EntitiesHelper

    include AttackCardHelper
    include AttackProfileHelper

    def eb_icon_for(type)
      icons = [
        ['fa fa-paw','StockCreature'],
        ['fa fa-male','StockNpc'],

        ['fa fa-paw','ProprietaryCreature'],
        ['fa fa-male','ProprietaryNpc'],

        ['fa fa-shield','ResidentCharacter'],
        ['fa fa-paw','ResidentCreature'],
        ['fa fa-male','ResidentNpc']
      ]

      return icons.rassoc(type).first
    end

    # Used by both Card and Profile Helper
    def format_range(type, distance)
      return distance.present? ? " #{type.gsub("Melee", "Reach").gsub("Special", "")} #{distance}" : ""
    end

    def format_dice_activeplay(display, name, roll)
      return "<a onclick=\"ApCore.$emit('evt-sendDice', {label: '#{name_scrubber(name).gsub(/'/, "\\\\'")}', dice: '#{roll}'});\">#{display}</a>"
    end

    # ROLL THEM BONES 2 <== DICE ROLLER POPBOX FOR ENTITIES
    def format_dice_popup(display, dice, bonus)
       builder =  "<span class='popbox'>"
       builder << "  <a class='openbox' onclick=\"roll_them_bones2('#{dice}', '#{bonus}');\">#{display}</a>"
       builder << "</span>"
       return builder
    end

    def card_name_shortner(name)
      case name
      when "Armor Class"
          return "AC"
      when "Defense"
          return "Def"
      when "Hit Points"
          return "HP"
      when "Initiative"
          return "Init"
      when "Speed"
          return "Spd"
      when "Fate Points"
          return "FP"
      else
          return name[0..3]
      end
    end

  end
end
