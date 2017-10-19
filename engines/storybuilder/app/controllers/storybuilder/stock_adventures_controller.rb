require_dependency "storybuilder/application_controller"

module Storybuilder
  class StockAdventuresController < AdventuresController

    before_action :set_type
    before_action :check_authorization,     only: [:new, :create, :edit, :update, :destroy, :options]

    before_action :set_adventure,           only: [:edit, :update, :destroy, :options]
    before_action :set_parent_options,      only: [:new, :create, :edit, :update]
    before_action :set_adventure_for_show,  only: [:show, :campaign]
    before_action :set_campaign,            only: [:campaign]
    before_action :set_adventures,          only: [:index]

    before_action :can_show,                only: [:show]

    private
      def params_id
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
      end

      def set_type
        @type = 'StockAdventure'
      end

      def set_adventures
        if admin_signed_in?
          if params[:order] == "wizard"
            @adventures = klass.short.order("updated_at DESC")
          else
            @adventures = klass.search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.order(:name).page(params[:page])
          end
        else

          if params[:order] == "wizard"
            @adventures = klass.where(privacy: "Residents").short.order("updated_at DESC")
          else
            @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('SB Stock Adventures')
          #  @adventures = klass.where(privacy: "Residents").search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.order(:name).page(params[:page])
          end
        end

        @index_image = 'sb_stock.jpg'
      end

      def set_adventure
        @adventure = klass.find_by_id(params_id)
        if @adventure.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @adventure
      end

      def set_parent_options
        @parent_options = klass.order_name
      end

      def set_adventure_for_show
        @adventure = klass.includes([:features, :sections, :menu_item_join, :entities]).find_by_id(params_id)
        if @adventure.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_campaign
        @type = ""

        @campaign = Campaignmanager::Campaign.find_by_id(params[:campaign_id]) unless params[:campaign_id].nil?
        if @campaign.nil? || !@campaign.can_show?(current_user, admin_signed_in?, @campaign.type)
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @resident = @campaign.resident
      end

  end
end
