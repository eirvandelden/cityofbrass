require_dependency "support/application_controller"

module Support
  class FaqsController < ApplicationController

    before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :destroy]
    before_action :set_topics,          only: [:new, :create, :edit, :update, :destroy, :index]
    before_action :set_faq,             only: [:show, :edit, :update, :destroy]

    # GET /faqs
    # GET /faqs.json
    def index
      @faqs = Faq.all
      @faqs = @faqs.sort_by{ |f| [f.topic.downcase, f.question.downcase] }
    end

    # GET /faqs/1
    # GET /faqs/1.json
    def show
    end

    # GET /faqs/new
    def new
      @faq = Faq.new
    end

    # GET /faqs/1/edit
    def edit
    end

    # POST /faqs
    # POST /faqs.json
    def create
      @faq = Faq.new(faq_params)

      respond_to do |format|
        if @faq.save
          format.html { redirect_to @faq, notice: 'Faq was successfully created' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /faqs/1
    # PATCH/PUT /faqs/1.json
    def update
      respond_to do |format|
        if @faq.update(faq_params)
          format.html { redirect_to @faq, notice: 'Faq was successfully updated.' }
        else
          format.html { render action: 'edit' }
        end
      end
    end

    # DELETE /faqs/1
    # DELETE /faqs/1.json
    def destroy
      @faq.destroy
      respond_to do |format|
        format.html { redirect_to faqs_url }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_topics
        @topics = Faq.pluck(:topic).uniq.sort

      end

      def set_faq
        @faq = Faq.find_by_id(params[:id])
        if @faq.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def faq_params
        params.require(:faq).permit(:topic, :new_topic, :question, :answer, :active)
      end
  end
end
