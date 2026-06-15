module Importer
  class PreviewsController < ApplicationController
    helper Importer::ImportsHelper

    def new
      @preview = Preview.new(mode: Preview::RESIDENT_CONTENT, source: Preview::GAME_MASTER_5_XML)
    end

    def create
      @preview = Preview.new(preview_params)
      @preview.mode = Preview::RESIDENT_CONTENT
      @preview.source = Preview::GAME_MASTER_5_XML
      @preview.status = "parsing"
      @preview.resident = current_user.resident

      if persist_preview_uploads
        redirect_to preview_path(@preview)
      else
        render :new, status: :unprocessable_entity
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
