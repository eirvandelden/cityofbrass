#module Entitybuilder
#  class ApplicationController < ActionController::Base
#  end
#end
class Entitybuilder::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_status

  private
    def set_parent_type
      @parent_type = parent_type
    end

    def parent_type
      params.each do |key, value|
        if key.include?"character_id" or key.include?"creature_id" or key.include?"npc_id"
          return key.gsub('_id', '')
        end
      end
    end

    def parent_klass
      "Entitybuilder::#{@parent_type.camelize}".constantize
    end

    def set_parent_object
      @parent_object = parent_klass.find_by_id(params["#{parent_type}_id"])
      if @parent_object.nil?
        render template: 'errors/404', layout: 'layouts/application', status: 404
      end
    end

    def check_parent_authorization
      unless @parent_object.can_edit?(current_user, admin_signed_in?, @parent_type)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end
    end

    def can_show
      unless @parent_object.can_show?(current_user, admin_signed_in?, @type)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end
    end

    def can_sheet
      unless @parent_object.can_sheet?(current_user, admin_signed_in?, @type)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end
    end

    def can_edit
      unless @parent_object.can_edit?(current_user, admin_signed_in?, @type)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end
    end
end
