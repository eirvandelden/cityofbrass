# frozen_string_literal: false

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include DetectFormatVariant

  protect_from_forgery prepend: true, with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :clear_ajax_flash

  helper Activeplay::Engine.helpers
  helper Billing::Engine.helpers
  helper Campaignmanager::Engine.helpers
  helper Entitybuilder::Engine.helpers
  helper Gallery::Engine.helpers
  helper Rulebuilder::Engine.helpers
  helper Storybuilder::Engine.helpers
  helper Worldbuilder::Engine.helpers

  def clear_ajax_flash
    flash.discard if request.xhr?
  end

  def check_user_status
    if current_user.inactive?
      redirect_to main_app.root_path
    end
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:check_field, :terms_of_service])
    end

    def check_quota
      if current_user.is_free?
        type = @type
        if @parent_type.present?
          type = 'Page'
          count = @parent_object.pages.size
        else
          count = current_user.resident.send("#{type.tableize}").size
        end

        # puts '===============QUOTA==============='
        # puts "Parent Type: #{@parent_type}"
        # puts "Type: #{type}"
        # puts "Count: #{count}"

        if Quota.over_limit?(current_user, type, count+1)
          redirect_to billing.subscriptions_path
        end
      end
    end
end
