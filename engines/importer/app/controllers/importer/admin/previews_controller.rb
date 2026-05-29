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

        if @preview.save
          @preview.add_uploads(params[:files])
          redirect_to main_app.admin_importer_preview_path(@preview)
        else
          render :new
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

      def preview_params
        params.fetch(:preview, {}).permit(:source)
      end
    end
  end
end
