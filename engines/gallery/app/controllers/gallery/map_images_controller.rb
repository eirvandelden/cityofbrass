# frozen_string_literal: false

require_dependency "gallery/application_controller"

module Gallery
  class MapImagesController < ImagesController

    before_action :set_type
    before_action :check_authorization, only: [:new, :create, :edit, :update, :destroy]
    before_action :set_image,           only: [:show, :edit, :update, :destroy, :swoosh]
    before_action :set_images,          only: [:index]
    before_action :set_pkr,             only: [:pkr]

    private
      def set_type
        @type = 'MapImage'
      end

      def set_images
        @images = MapImage.order_name.page(params[:page]).per(48)
      end

      def set_pkr
        @images = MapImage.order_name.page(params[:page]).per(12)
      end

      def set_image
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @image = klass.find_by_id(params_id)

        if @image.nil?
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
