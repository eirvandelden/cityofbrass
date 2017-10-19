require_dependency "gallery/application_controller"

module Gallery
  class ResidentImagesController < ImagesController

    before_action :set_type
    before_action :set_image,  only: [:show, :edit, :update, :destroy, :swoosh]
    before_action :set_images, only: [:index]
    before_action :set_pkr,    only: [:pkr]
    before_action :can_show,   only: [:show]
    before_action :can_edit, except: [:index, :show, :new, :create, :pkr, :swoosh]

    before_action :check_quota, only: [:new, :create]

    private
      def set_type
        @type = 'ResidentImage'
      end

      def set_images
        @images = current_user.resident.send("#{@type.tableize}").order_name.page(params[:page]).per(48)

        if @images.blank?
          @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Image Index')
        end
      end

      def set_pkr
        @images = current_user.resident.send("#{@type.tableize}").order_name.page(params[:page]).per(12)
      end

      def set_image
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @image = klass.joins(:user).find_by_id(params_id)

        if @image.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def can_show
        unless @image.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @image.can_edit?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

  end
end
