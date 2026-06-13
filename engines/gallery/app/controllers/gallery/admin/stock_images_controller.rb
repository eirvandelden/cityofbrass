require_dependency "gallery/application_controller"

module Gallery
  module Admin
    class StockImagesController < ImagesController
      before_action :set_type
      before_action :set_route_namespace
      before_action :check_authorization, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
      before_action :set_image,           only: [ :show, :edit, :update, :destroy, :swoosh ]
      before_action :set_images,          only: [ :index ]
      before_action :set_pkr,             only: [ :pkr ]

      def new
        @image = klass.new
        # Note: deliberately does NOT call super, since ImagesController#new sets resident_id
        # which would fail for admin who has no resident. Also gallery_images has no privacy column.
      end

      def create
        @image = klass.new(image_params)

        if @image.save
          redirect_to edit_admin_stock_image_path(@image), notice: 'Image was successfully created.'
        else
          render action: 'new'
        end
      end

      def update
        if @image.update(image_params)
          redirect_to edit_admin_stock_image_path(@image), notice: 'Image was successfully updated.'
        else
          render action: 'edit'
        end
      end

      def destroy
        @image.destroy
        redirect_to admin_stock_images_path, notice: 'Image was successfully deleted.'
      end

      private
        def set_route_namespace
          @route_namespace = :admin
        end

        def set_type
          @type = 'StockImage'
        end

        def set_images
          @images = StockImage.order_name.page(params[:page]).per(48)
        end

        def set_pkr
          @images = StockImage.order_name.page(params[:page]).per(12)
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
end
