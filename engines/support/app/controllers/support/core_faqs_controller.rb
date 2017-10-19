require_dependency "support/application_controller"

module Support
  class CoreFaqsController < ApplicationController
    before_action :authenticate_admin!, except: [:show]
    before_action :set_core_faq, only: [:show, :edit, :update, :destroy]

    def index
      @core_faqs = CoreFaq.order_core_item.page(params[:page]).per(100)
    end

    def new
      @core_faq = CoreFaq.new
    end

    def show
    end

    def edit
    end

    def create
      @core_faq = CoreFaq.new(core_faq_params)
      respond_to do |format|
        if @core_faq.save
          format.js { flash.now[:notice] = "#{@core_faq.core_item} has been added." }
        else
          format.js
        end
      end
    end

    def update
      respond_to do |format|
        if @core_faq.update(core_faq_params)
          format.js { flash.now[:notice] = "#{@core_faq.core_item} has been updated." }
        else
          format.js
        end
      end
    end

    def destroy
      respond_to do |format|
        if @core_faq.destroy
          format.js { flash.now[:notice] = "#{@core_faq.core_item} has been removed." }
        else
          format.js
        end
      end
    end

    private
      def set_core_faq
        @core_faq = CoreFaq.find(params[:id])
      end

      def core_faq_params
        params.require(:core_faq).permit(:faq_id, :core_item, :active)
      end
  end
end
