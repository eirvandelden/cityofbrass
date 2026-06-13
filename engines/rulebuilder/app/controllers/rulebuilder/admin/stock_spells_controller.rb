require_dependency "rulebuilder/application_controller"

module Rulebuilder
  module Admin
    class StockSpellsController < SpellsController
      before_action :set_type
      before_action :check_authorization, only: [ :index, :new, :create, :edit, :update, :destroy, :options ]
      before_action :set_spell,           only: [ :show, :edit, :update, :destroy, :options ]
      before_action :set_spells,          only: [ :index ]

      def create
        @spell = klass.new(spell_params)
        @spell.build_gallery_image_join if @spell.gallery_image_join.nil?

        respond_to do |format|
          if @spell.save
            format.html { redirect_to edit_admin_stock_spell_path(@spell), notice: @spell.name + ' was successfully created.' }
            format.json { render json: @spell, status: :created, location: @spell }
            format.js
          else
            format.html { render action: "new" }
            format.json { render json: @spell.errors, status: :unprocessable_entity }
            format.js
          end
        end
      end

      def update
        respond_to do |format|
          if @spell.update(spell_params)
            format.html { redirect_to edit_admin_stock_spell_path(@spell) }
            format.json { head :no_content }
            format.js   { flash.now[:notice] = "#{@spell.name} has been updated." }
          else
            format.html { render action: 'edit' }
            format.json { render json: @spell.errors, status: :unprocessable_entity }
            format.js
          end
        end
      end

      def destroy
        respond_to do |format|
          if @spell.update(spell_params)
            @spell.destroy
            format.html { redirect_to admin_stock_spells_path }
          else
            format.html { render action: 'options' }
          end
        end
      end

      private
        def set_type
          @type = 'StockSpell'
        end

        def set_spells
          @spells = StockSpell.short.order_name.search(params[:search]).core_rules_filter(params[:core_rules_filter]).page(params[:page]).per(100)
        end

        def set_spell
          params_id = params["#{@type.underscore}_id"] ||= params[:id]
          @spell = klass.find_by_id(params_id)

          if @spell.nil?
            render template: 'errors/404', layout: 'layouts/application', status: 404
          end
        end

        def check_authorization
          unless admin_signed_in?
            render template: 'errors/403', layout: 'layouts/application', status: 403
          end
        end
    end
  end
end
