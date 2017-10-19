require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class CurrenciesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_currency, only: [:show, :edit, :edit_sheet, :update, :update_sheet, :update_card, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /currencies
    def index
      @currencies = @parent_object.currencies

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /currencies/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /currencies/new
    def new
      @currency = @parent_object.currencies.new
      @currency.sort_order = @parent_object.currencies.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /currencies/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    def edit_sheet
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /currencies
    def create
      @currency = @parent_object.currencies.new(currency_params)

      respond_to do |format|
        if @currency.save
          format.html { redirect_to currency_path(@parent_object, @currency), notice: 'currency was successfully added.' }
          format.json { render json: @currency, status: :created, location: @currency }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @currency.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /currencies/1
    def update
      respond_to do |format|
        if @currency.update(currency_params)
          format.html { redirect_to currency_path(@parent_object, @currency), notice: "#{@currency.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@currency.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @currency.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_sheet
      @clickable = @parent_object.can_edit?(current_user, admin_signed_in?, @parent_type)

      respond_to do |format|
        if @currency.update(currency_params)
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@currency.name} has been updated." }
        else
          format.json { render json: @currency.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_card
      @clickable = @parent_object.can_edit?(current_user, admin_signed_in?, @parent_type)

      respond_to do |format|
        if @currency.update(currency_params)
          format.js   { flash.now[:notice] = "#{@currency.name} has been updated." }
        else
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to currency_path(@parent_object, @currency), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /currencies/1
    def destroy
      @currency.destroy

      respond_to do |format|
        format.html { redirect_to currencies_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_currency
        @currency = @parent_object.currencies.find(params[:id])
        @modifier_parent_object = @currency
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Currency Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def currency_params
        params.require(:currency).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :weight,
            :quantity,
            :carried
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          currencies_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end
