module Importer
  class ImportsController < ApplicationController
    helper Importer::ImportsHelper

    def index
      @imports = current_user.resident.importer_imports.includes(:import_files, :import_results)
    end

    def create
      preview = current_user.resident.importer_previews.find(params[:preview_id])
      import = Import.create!(resident: current_user.resident, mode: preview.mode, source: preview.source, status: Import::QUEUED, preview: preview)
      ProcessImportJob.perform_later(import.id)

      redirect_to import_path(import)
    end

    def show
      @import = current_user.resident.importer_imports.includes(import_results: :record).find(params[:id])
    end
  end
end
