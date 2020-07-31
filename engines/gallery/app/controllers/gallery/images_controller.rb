# frozen_string_literal: false

require_dependency "gallery/application_controller"

module Gallery
  class ImagesController < ApplicationController

    # GET /images
    def index



      if @type.include?"Resident"
        if current_user.is_free?
          @sub = "#{current_user.resident.resident_images.count} / #{Quota.limit(current_user, @type)}"
        else
          @sub = current_user.resident.resident_images_sum
        end
      end
    end

    # GET /images/1
    def show
    end

    # GET /mine
    def pkr
    end

    # GET /mine
    def swoosh
      respond_to do |format|
        format.html { head :ok }
        format.js
      end
    end

    # GET /images/new
    def new
      @image = klass.new
      @image.resident_id = current_user.resident.id
    end

    # GET /images/1/edit
    def edit
    end

    # POST /images
    def create
      @image = klass.new (image_params)
      @image.resident_id = current_user.resident.id

      if @image.save
        redirect_to @image, notice: 'Image was successfully created.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /images/1
    def update
      if @image.update(image_params)
        redirect_to @image, notice: 'Image was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /images/1
    def destroy
      @image.destroy
      redirect_to polymorphic_path(@type.tableize) , notice: 'Image was successfully deleted.'
    end

    private

      def klass
        return "Gallery::#{@type}".constantize
      end

      # Only allow a trusted parameter "white list" through.
      def image_params
        params.require(@type.underscore.to_sym).permit(:name, :file)
      end

  end
end
