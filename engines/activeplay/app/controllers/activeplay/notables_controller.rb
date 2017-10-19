require_dependency "activeplay/application_controller"

module Activeplay
  class NotablesController < ApplicationController
    before_action :set_virtual_table
    before_action :check_parent_authorization
    before_action :set_notable,  only: [:show, :edit, :update, :destroy]
    before_action :set_entities, only: [:new, :create]

    # GET /notables
    def index
      @notables = @virtual_table.notables
    end

    # GET /notables/1
    def show
    end

    # GET /notables/new
    def new
      sort_order = 0
      sort_order = @virtual_table.notables.order_sort_order.last.sort_order.to_i+1 unless @virtual_table.notables.order_sort_order.last.nil?

      @notable = @virtual_table.notables.new
      @notable.sort_order = sort_order
    end

    # GET /notables/1/edit
    def edit
    end

    # POST /notables
    def create
      @notable = @virtual_table.notables.new(notable_params)

      respond_to do |format|
        if @notable.save
          set_notables

          format.html { redirect_to notable_path(@virtual_table, @notable), notice: 'notable was successfully added.' }
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
          set_notables

          format.html { redirect_to notable_path(@virtual_table, @notable), notice: "#{@notable.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@notable.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @notable.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @virtual_table.update(entity_params)
          set_notables

          format.html { redirect_to notable_path(@virtual_table, @notable), notice: "Encounter was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "Encounter has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @virtual_table.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /notables/1
    def destroy
      @notable.destroy
      set_notables

      respond_to do |format|
        format.html { redirect_to notables_path(@virtual_table) }
        format.json { head :no_content }
        format.js
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_virtual_table
        @virtual_table = VirtualTable.joins(:user).includes([:campaign]).find_by_id(params[:virtual_table_id])
      end

      def check_parent_authorization
        unless @virtual_table.can_edit?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def set_notable
        @notable = @virtual_table.notables.find(params[:id])
      end

      def set_entities
        @entities = ""
        @entities = current_user.resident.resident_npcs.where(core_rules: @virtual_table.campaign.core_rules).order_name                       if params[:entity_type] == "resident_npc"
        @entities = current_user.resident.resident_creatures.where(core_rules: @virtual_table.campaign.core_rules).order_name                  if params[:entity_type] == "resident_creature"
        @entities = Entitybuilder::StockNpc.where(core_rules: @virtual_table.campaign.core_rules).where(privacy: "Residents").order_name       if params[:entity_type] == "stock_npc"
        @entities = Entitybuilder::StockCreature.where(core_rules: @virtual_table.campaign.core_rules).where(privacy: "Residents").order_name  if params[:entity_type] == "stock_creature"
      end

      def set_notables
        @virtual_table_notables = @virtual_table.notables.joins(:entity).order_sort_order
        if(@virtual_table.user == current_user)
          @isGM = true;
        end
      end

      # Only allow a trusted parameter "white list" through.
      def notable_params
        params.require(:notable).permit(
            :name,
            :sort_order,
            :virtual_table_id,
            :entity_id
          )
      end

      def entity_params
        params.require(:virtual_table).permit(
          notables_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end
