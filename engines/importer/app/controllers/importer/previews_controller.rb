module Importer
  class PreviewsController < ApplicationController
    def new
      @preview = Preview.new(mode: Preview::RESIDENT_CONTENT, source: Preview::GAME_MASTER_5_XML)
    end

    def create
      @preview = Preview.new(preview_params)
      @preview.mode = Preview::RESIDENT_CONTENT
      @preview.source = Preview::GAME_MASTER_5_XML
      @preview.status = "parsing"
      @preview.resident = current_user.resident

      if @preview.save
        @preview.add_uploads(params[:files])
        redirect_to preview_path(@preview)
      else
        render :new
      end
    end

    def show
      @preview = current_user.resident.importer_previews.find(params[:id])
    end

    def update
      @preview = current_user.resident.importer_previews.find(params[:id])
      if @preview.update(preview_params)
        redirect_to preview_path(@preview)
      else
        render :show
      end
    end

    def destroy
      current_user.resident.importer_previews.find(params[:id]).destroy
      redirect_to new_preview_path
    end

    private

    def preview_params
      params.fetch(:preview, {}).permit(:source)
    end
  end
end
