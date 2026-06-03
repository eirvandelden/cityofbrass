module Importer
  module Sources
    class GameMaster5Xml
      class PcNameParser
        # Parse "Elf (Wood) Monk 2" → { race: "Elf (Wood)", class_name: "Monk", level: 2 }
        # Parse "Half-Orc Barbarian 5" → { race: "Half-Orc", class_name: "Barbarian", level: 5 }
        # Returns nil for unparseable strings
        def self.parse(name_string)
          new(name_string).parse
        end

        def initialize(name_string)
          @name_string = name_string.to_s.strip
        end

        def parse
          # Match: optional parenthesized qualifier, then class name, then level
          # Pattern: "Word (optional qualifier) ClassName Level"
          match = @name_string.match(/\A(.+?)\s+(\w+)\s+(\d+)\z/)
          return nil unless match

          { race: match[1].strip, class_name: match[2], level: match[3].to_i }
        end
      end
    end
  end
end
