module Importer
  module Admin
    class PreviewsController < Admin::ApplicationController
      def new
        @preview = Preview.new(mode: Preview::ADMIN_STOCK, source: Preview::GAME_MASTER_5_XML)
      end

    def create
      @preview = Preview.new(preview_params)
      @preview.mode = Preview::ADMIN_STOCK
      @preview.source = Preview::GAME_MASTER_5_XML
      @preview.status = "parsing"

      if persist_preview_uploads
        redirect_to main_app.admin_importer_preview_path(@preview)
      else
        render :new, status: :unprocessable_entity
      end
    end

      def show
        @preview = Preview.admin_stock.find(params[:id])
      end

      def update
        @preview = Preview.admin_stock.find(params[:id])
        if @preview.update(preview_params)
          redirect_to main_app.admin_importer_preview_path(@preview)
        else
          render :show
        end
      end

      def destroy
        Preview.admin_stock.find(params[:id]).destroy
        redirect_to main_app.new_admin_importer_preview_path
      end

    private

    def persist_preview_uploads
      persisted = false

      Preview.transaction do
        persisted = @preview.save && @preview.add_uploads(params[:files])
        next if persisted

        raise ActiveRecord::Rollback
      end

      persisted
    end

    def preview_params
      params.fetch(:preview, {}).permit(:source)
      end
    end
  end
end
