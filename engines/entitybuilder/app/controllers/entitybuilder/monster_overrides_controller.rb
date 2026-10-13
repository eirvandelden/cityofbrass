require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class MonsterOverridesController < ApplicationController
    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :check_monster_buildable
    before_action :check_target

    # DELETE /creatures/1/monster_build/overrides/armor_class
    def destroy
      @parent_object.reset_monster_value(params[:id])
      redirect_to edit_polymorphic_path([ @parent_object, :monster_build ]),
                  notice: t("entitybuilder.monster_overrides.destroy.reset")
    end

    private
      def check_target
        render_not_found unless MonsterTarget.all.map { |target| target.key.to_s }.include?(params[:id])
      end
  end
end
