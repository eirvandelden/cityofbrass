module Importer
  class ProcessImportJob < ApplicationJob
    queue_as :imports

    def perform(import_id)
      Import.find(import_id).process!
    end
  end
end
