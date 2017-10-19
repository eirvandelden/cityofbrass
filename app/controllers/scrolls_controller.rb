class ScrollsController < ApplicationController

  respond_to :html, :json, :js

  def home
    if user_signed_in?
      if current_user.active?
        if current_user.resident && current_user.resident.slug
        	redirect_to resident_path(current_user.resident.slug)
        else
          redirect_to new_resident_path
        end
      end
    end

    @wb_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Home World Builder')
    @eb_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Home Entity Builder')
    @sb_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Home Story Builder')
    @cm_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Home Campaign Manager')
    @account_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Home Account')
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def license
    license = params[:license]
    logger.info(license)
    if license.present?
      @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item(license)
    end
  end

  def hastur
  end
end
