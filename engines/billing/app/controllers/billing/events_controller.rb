# frozen_string_literal: false

require_dependency "billing/application_controller"

module Billing
  class EventsController < ApplicationController

    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_event, only: [:show, :edit, :update, :destroy]

    # GET /events
    def index
      @events = Event.search(params[:search]).order_event_date.page(params[:page]).per(20)
    end

    # GET /events/1
    def show
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event
        @event = Event.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_params
        params.require(:event).permit(:user_id, :stripe_event_token, :event_date, :event_type, :event_data)
      end
  end
end
