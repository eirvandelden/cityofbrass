require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class VersionsController < ApplicationController
    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization

    # GET /creatures/1/versions/new
    def new
      @version = @parent_object.class.new(monster_level: @parent_object.try(:monster_level))
    end

    # POST /creatures/1/versions
    def create
      @version = @parent_object.create_version(**version_params.to_h.symbolize_keys)

      if @version.persisted?
        redirect_to edit_polymorphic_path(@version), notice: t("entitybuilder.versions.created", name: @version.name)
      else
        render :new, status: :unprocessable_entity
      end
    end

    private
      def version_params
        params.require(:version).permit(:version_label, :monster_level)
      end
  end
end
