require "importer/sources/base"

module Importer
  module Sources
    class GameMaster5Xml < Base
      def detect?(io)
        Detector.new(io).kind != "unsupported"
      end
    end
  end
end

require "importer/sources/game_master_5_xml/detector"
require "importer/sources/game_master_5_xml/document"
