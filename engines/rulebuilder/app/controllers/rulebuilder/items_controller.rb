require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class ItemsController < ApplicationController

    # GET /items
    def index
      if (current_user.is_free?) && (@type.include?"Resident")
        @sub = "#{current_user.resident.resident_items.count} / #{Quota.limit(current_user, @type)}"
      end
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /items/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /items/new
    def new
      @item = klass.new
      @item.resident_id = current_user.resident.id
      @item.build_gallery_image_join if @item.gallery_image_join.nil?

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /items/1/edit
    def edit
      @item.build_gallery_image_join if @item.gallery_image_join.nil?

      respond_to do |format|
        format.html
        format.js
      end
    end

    # POST /items
    def create
      @item = klass.new (item_params)
      @item.resident_id = current_user.resident.id
      @item.build_gallery_image_join if @item.gallery_image_join.nil?

      respond_to do |format|
        if @item.save
          format.html { redirect_to edit_polymorphic_path(@item), notice: @item.name + ' was successfully created.' }
          format.json { render json: @item, status: :created, location: @item }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @item.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /items/1
    def update
      respond_to do |format|
        if @item.update(item_params)
          format.html { redirect_to edit_polymorphic_path(@item) }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@item.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.json { render json: @item.errors, status: :unprocessable_item }
          format.js
        end
      end
    end

    # GET /items/1/:options
    def options
    end

    # DELETE /items/1
    def destroy
      respond_to do |format|
        if @item.update(item_params)
          @item.destroy
          format.html { redirect_to polymorphic_path(@type.tableize) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private

      def klass
        klass = "Rulebuilder::#{@type}".constantize
      end

      # Only allow a trusted parameter "white list" through.
      def item_params
        params.require(@type.underscore.to_sym).permit(
          :parent_id,
          :resident_id,
          :name,
          :publisher,
          :source,
          :is_3pp,
          :short_description,
          :full_description,
          :core_rules,
          :category,
          :weight,
          :quantity,
          :equipped,
          :proficient,
          :tag_list,
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end

  end
end
