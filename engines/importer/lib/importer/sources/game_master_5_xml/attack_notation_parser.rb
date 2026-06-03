module Importer
  module Sources
    class GameMaster5Xml
      class AttackNotationParser
        # Parse "|+3|1d6+1" or "Scimitar|+4|1d6+2" → { name: "Scimitar", bonus: "+4", damage: "1d6+2" }
        # Returns nil for unparseable strings
        def self.parse(notation)
          new(notation).parse
        end

        def initialize(notation)
          @notation = notation.to_s.strip
        end

        def parse
          parts = @notation.split("|")
          return nil if parts.length < 3

          { name: parts[0].strip, bonus: parts[1].strip, damage: parts[2].strip }
        end
      end
    end
  end
end
