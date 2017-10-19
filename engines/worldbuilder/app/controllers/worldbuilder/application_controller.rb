class Worldbuilder::ApplicationController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index, :campaign]
  before_action :check_user_status,  except: [:show, :index, :campaign]

  private
    def set_parent_type
      @parent_type = parent_type
    end

    def parent_type
      # return the first match
      params.each do |key, value|
        if key.include?"_id"
          return key.gsub('_id', '')
        end
      end
    end

    def parent_klass
      parent_klass = "Worldbuilder::#{@parent_type.camelize}".constantize
    end

    def set_parent_object
      @parent_object = parent_klass.joins(:user).find_by_slug(params["#{parent_type}_id"])
      if @parent_object.nil?
        render template: 'errors/404', layout: 'layouts/application', status: 404
      end
    end

    def check_parent_authorization
      unless @parent_object.can_edit?(current_user, admin_signed_in?)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end
    end
end
