# frozen_string_literal: false

require_dependency "storybuilder/application_controller"

module Storybuilder
  class ResidentAdventuresController < AdventuresController

    before_action :set_type
    before_action :set_adventure,           only: [:edit, :update, :destroy, :options]
    before_action :set_parent_options,      only: [:new, :create, :edit, :update]
    before_action :set_adventure_for_show,  only: [:show, :campaign]
    before_action :set_campaign,            only: [:campaign]
    before_action :set_adventures,          only: [:index]

    before_action :can_show,                only: [:show]
    before_action :can_edit,              except: [:index, :show, :campaign, :new, :create]

    before_action :check_quota, only: [:new, :create]

    private
      def params_id
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
      end

      def set_type
        @type = 'ResidentAdventure'
      end

      def set_adventures
        if params[:order] == "wizard"
          @adventures = current_user.resident.send("#{@type.tableize}").short.order("updated_at DESC")
        else
          @adventures = current_user.resident.send("#{@type.tableize}").search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.order(:name).page(params[:page])
        end

        if @adventures.blank?
          @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('SB Adventure Index')
        end

        @index_image = 'sb_resident.jpg'
      end

      def set_adventure
        @adventure = klass.joins(:user).find_by_id(params_id)
        if @adventure.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @adventure
      end

      def set_parent_options
        @parent_options = current_user.resident.resident_adventures.order_name
      end

      def set_adventure_for_show
        @adventure = klass.joins(:user).includes([:features, :sections, :menu_item_join, :entities]).find_by_id(params_id)
        if @adventure.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_campaign
        @type = ""

        @campaign = Campaignmanager::Campaign.find_by_id(params[:campaign_id]) unless params[:campaign_id].nil?
        if @campaign.nil? || !@campaign.can_show?(current_user, admin_signed_in?, 'Campaign')
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @resident = @campaign.resident
      end

  end
end
