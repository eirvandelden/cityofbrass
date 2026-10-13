require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class MonsterBuildsController < ApplicationController
    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :check_monster_buildable

    # GET /creatures/1/monster_build/edit
    def edit
    end

    # PATCH /creatures/1/monster_build
    def update
      if @parent_object.rebuild_monster(input_params)
        @parent_object.store_monster_values(value_params)
        redirect_to edit_polymorphic_path([ @parent_object, :monster_build ]),
                    notice: t("entitybuilder.monster_builds.update.saved")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private
      def input_params
        params.require(@parent_type).permit(:monster_level, :monster_role, :monster_group,
                                            :monster_extra_action, monster_defense_bonuses: [])
      end

      def value_params
        params.require(@parent_type).permit(monster_values: MonsterTarget.all.map(&:key)).fetch(:monster_values, {})
      end
  end
end
