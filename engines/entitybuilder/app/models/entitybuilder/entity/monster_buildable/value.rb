module Entitybuilder
  class Entity
    module MonsterBuildable
      # One builder number as the builder page shows it: stored, calculated, and whether they differ.
      Value = Data.define(:target, :stored, :calculated, :edited) do
        def needs_manual_revision? = edited
      end
    end
  end
end
