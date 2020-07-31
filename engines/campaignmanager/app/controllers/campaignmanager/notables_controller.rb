require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class NotablesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :set_campaign
    before_action :check_parent_authorization
    before_action :set_notable,  only: [:show, :edit, :update, :destroy]
    before_action :set_entities, only: [:new, :create]

    # GET /notables
    def index
      @notables = @parent_object.notables
    end

    # GET /notables/1
    def show
    end

    # GET /notables/new
    def new
      sort_order = 0
      sort_order = @parent_object.notables.order_sort_order.last.sort_order.to_i+1 unless @parent_object.notables.order_sort_order.last.nil?

      @notable = @parent_object.notables.new
      @notable.sort_order = sort_order
    end

    # GET /notables/1/edit
    def edit
    end

    # POST /notables
    def create
      @notable = @parent_object.notables.new(notable_params)

      respond_to do |format|
        if @notable.save
          format.html { redirect_to notable_path(@parent_object, @notable), notice: 'notable was successfully added.' }
          format.json { render json: @notable, status: :created, location: @notable }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @notable.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /notables/1
    def update
      respond_to do |format|
        if @notable.update(notable_params)
          format.html { redirect_to notable_path(@parent_object, @notable), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @notable.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to notable_path(@parent_object, @notable), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /notables/1
    def destroy
      @notable.destroy

      respond_to do |format|
        format.html { redirect_to notables_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private
      def parent_type
        #return the last match
        parent_type = "campaign"
        params.each do |key, value|
          if key.include?"_id"
            parent_type = key.gsub('_id', '')
          end
        end
        return parent_type
      end

      def set_campaign
        if parent_type.include?"campaign"
          @campaign = @parent_object
        else
          @campaign = @parent_object.campaign
        end
      end

      def set_notable
        @notable = @parent_object.notables.find(params[:id])
      end

      def set_entities
        @entities = ""
        @entities = current_user.resident.resident_npcs.where(core_rules: @campaign.core_rules).order_name                       if params[:entity_type] == "resident_npc"
        @entities = current_user.resident.resident_creatures.where(core_rules: @campaign.core_rules).order_name                  if params[:entity_type] == "resident_creature"
        @entities = Entitybuilder::StockNpc.where(core_rules: @campaign.core_rules).where(privacy: "Residents").order_name       if params[:entity_type] == "stock_npc"
        @entities = Entitybuilder::StockCreature.where(core_rules: @campaign.core_rules).where(privacy: "Residents").order_name  if params[:entity_type] == "stock_creature"
        @entities = @campaign.characters.order_name                                                                               if params[:entity_type] == "player_character"
      end

      # Only allow a trusted parameter "white list" through.
      def notable_params
        params.require(:notable).permit(
            :notableable_id,
            :notableable_type,
            :entity_id,
            :name,
            :sort_order
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          notables_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end
