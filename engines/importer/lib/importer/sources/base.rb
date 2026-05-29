module Importer
  module Sources
    class Base
      def detect?(_io)
        false
      end
    end
  end
end
