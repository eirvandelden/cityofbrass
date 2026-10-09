# frozen_string_literal: false

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include DetectFormatVariant
  include Authentication

  protect_from_forgery prepend: true, with: :exception

  before_action :set_locale
  after_action :clear_ajax_flash

  helper Activeplay::Engine.helpers
  helper Billing::Engine.helpers
  helper Campaignmanager::Engine.helpers
  helper Entitybuilder::Engine.helpers
  helper Gallery::Engine.helpers
  helper Rulebuilder::Engine.helpers
  helper Storybuilder::Engine.helpers
  helper Worldbuilder::Engine.helpers

  helper_method :stock_content_available?

  def clear_ajax_flash
    flash.discard if request.format.js?
  end

  def check_user_status
    if current_user.inactive?
      redirect_to main_app.root_path
    end
  end

  def stock_content_available?(core_rules)
    admin_signed_in? || CoreRules.stock?(core_rules)
  end

  protected
    def set_locale
      I18n.locale = current_user&.locale || accepted_locale || I18n.default_locale
    end

    def accepted_locale
      accepted_languages.find { |language| I18n.available_locales.include?(language) }
    end

    def accepted_languages
      header = request.headers["Accept-Language"].to_s
      weighted = header.split(",").each_with_index.map { |entry, index| language_weight(entry, index) }
      weighted.compact.sort_by { |_, weight, index| [ -weight, index ] }.map(&:first)
    end

    # Returns nil for a wildcard or for q=0, which means "not acceptable".
    def language_weight(entry, index)
      tag, *params = entry.split(";").map(&:strip)
      return if tag.blank? || tag == "*"

      quality = (params.filter_map { |param| param[/\Aq\s*=\s*(\d(?:\.\d+)?)\z/, 1] }.first || 1).to_f
      [ tag.split("-").first.downcase.to_sym, quality, index ] if quality.positive?
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
