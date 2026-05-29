module Importer
  class ProcessImportJob < ApplicationJob
    queue_as :default

    def perform(import_id)
      Import.find(import_id).process!
    end
  end
end
