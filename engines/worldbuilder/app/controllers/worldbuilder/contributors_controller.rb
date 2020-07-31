# frozen_string_literal: false

require_dependency "worldbuilder/application_controller"

module Worldbuilder
  class ContributorsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_district
    before_action :check_authorization
    before_action :set_contributor, only: [:show, :edit, :update, :destroy]

    # GET /contributors
    def index
      @contributors = @district.contributors.includes([:affiliate_user]).page(params[:page])
    end

    # GET /contributors/new
    def new
      @contributor = @district.contributors.new
      @aff_list = @district.resident.affiliations.where("status = 'accepted'").collect {|a| [a.affiliate.name, a.id]}.sort
    end

    # POST /contributors
    def create
      @contributor = @district.contributors.create(contributor_params)
      @aff_list = @district.resident.affiliations.where("status = 'accepted'").collect {|a| [a.affiliate.name, a.id]}.sort

      respond_to do |format|
        if @contributor.save
          format.js
        else
          format.js
        end
      end
    end

    # DELETE /contributors/1
    def destroy
      @contributor.destroy
    end

    private
      def set_district
        @district = District.joins(:user).find_by_id(params[:district_id]) unless params[:district_id].nil?
        if @district.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_contributor
        @contributor = @district.contributors.find(params[:id])
      end

      def check_authorization
        unless @district.is_owner?(current_user)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Only allow a trusted parameter "white list" through.
      def contributor_params
        params.require(:contributor).permit(:district_id, :affiliation_id)
      end
  end
end
