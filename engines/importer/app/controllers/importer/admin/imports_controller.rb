module Importer
  module Admin
    class ImportsController < Admin::ApplicationController
      def index
        @imports = Import.admin_stock.includes(:import_files, :import_results).order(created_at: :desc)
      end

      def create
        preview = Preview.admin_stock.find(params[:preview_id])
        import = Import.create!(mode: preview.mode, source: preview.source, status: Import::QUEUED, preview: preview)
        ProcessImportJob.perform_later(import.id)

        redirect_to main_app.admin_importer_import_path(import)
      end

      def show
        @import = Import.admin_stock.includes(import_results: [ :record, :import_file ]).find(params[:id])
      end
    end
  end
end
