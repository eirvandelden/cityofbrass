require_dependency "activeplay/application_controller"

module Activeplay
  class VirtualTablesController < ApplicationController

    before_action :set_virtual_table, only: [:show, :new_token]
    before_action :can_show, only: [:show, :new_token]

    before_action :set_campaign_details, only: [:show]
    before_action :set_token_details, only: [:new_token]

    before_action :set_token, only: [:show, :new_token]

    def show
    end

    def new_token
    end

    def index
      redirect_to main_app.root_path
    end

    private
      def set_virtual_table
        params_id = params[:virtual_table_id] ||= params[:id]
        @virtual_table = VirtualTable.joins(:user).find_by_id(params_id)
        @campaign_characters = Entitybuilder::ResidentCharacter.joins(:user, :campaign_join).includes([:ability_scores, :class_levels, :defenses, :descriptors, :base_values, :modifiers, :movements, :trackables]).where("entitybuilder_campaign_joins.campaign_id = ?", @virtual_table.campaign_id).order_name
      end

      def set_campaign_details
        @game_master = @virtual_table.resident

        #@virtual_table_notables = Entitybuilder::Entity.joins(:cm_notables).includes([:ability_scores, :class_levels, :defenses, :descriptors, :base_values, :modifiers, :movements,:trackables]).where("campaignmanager_notables.notableable_id = ? ", @virtual_table.campaign_id)
        @campaign_notables = @virtual_table.campaign.notables.joins(:entity).order_sort_order

        #@virtual_table_notables = Entitybuilder::Entity.joins(:ap_notables).includes([:ability_scores, :class_levels, :defenses, :descriptors, :base_values, :modifiers, :movements,:trackables]).where("activeplay_notables.virtual_table_id = ? ", @virtual_table.id)
        @virtual_table_notables = @virtual_table.notables.joins(:entity).order_sort_order

        @isGM = false;

        if(@virtual_table.user == current_user)
          @isGM = true;
          @my_character = @campaign_characters.first
          @ap_user_name = "GM"
          @ap_user_color = "#cc0000"
        else
          @my_character = @campaign_characters.detect { |d| d.resident.user == current_user }
          if @my_character.present?
            @parent_object = @my_character
            @notables = @my_character.notables

            @ap_user_name = @my_character.name
            @ap_user_color = "#4e74a5"
            @ap_character_id = @my_character.id
          else
            @ap_user_name = current_user.resident.name
            @ap_user_color = "#c5c5c5"
          end
        end

        if @virtual_table.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_token_details
        if(@virtual_table.user == current_user)
          @my_character = @campaign_characters.first
          @ap_user_name = "GM"
          @ap_user_color = "#cc0000"
        else
          @my_character = @campaign_characters.detect { |d| d.resident.user == current_user }
          if @my_character.present?
            @ap_user_name = @my_character.name
            @ap_user_color = "#4e74a5"
            @ap_character_id = @my_character.id
          else
            @ap_user_name = current_user.resident.name
            @ap_user_color = "#c5c5c5"
          end
        end
      end

      def set_token
        exp = (Time.now + 12.hours).to_i

        payload = {
          name: name_scrubber(@ap_user_name),
          color: @ap_user_color,
          residentId: current_user.resident.id,
          characterId: @ap_character_id,
          campaignId: @virtual_table.campaign_id,
          exp: exp
        }

        hmac_secret = ENV['ACTIVEPLAY_SECRET']
        @token = JWT.encode payload, hmac_secret, 'HS256'
      end

      def can_show
        unless @virtual_table.can_show?(current_user, admin_signed_in?, "Activeplay::Campaign")
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @virtual_table.can_edit?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def name_scrubber(name)
        return name.gsub(/[^0-9A-Za-z \-\(\)\[\]\']/, ' ')
      end

      # Only allow a trusted parameter "white list" through.
      # def virtual_table_params
      #  params.require(:campaign).permit(
      #    :campaign_id
      #  )
      # end

  end
end
