# frozen_string_literal: false

require_dependency "report/application_controller"

module Report
  class RulebuilderSnapshotsController < ApplicationController

    # GET /entity_snapshots
    def index

      @paid_counts = User.find_by_sql("
        SELECT
          core_rules,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentRule' ) THEN 1 ELSE 0 END) AS rules,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentItem' ) THEN 1 ELSE 0 END) AS items,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentSpell' ) THEN 1 ELSE 0 END) AS spells,
          count(*) as total
        FROM
        (
          SELECT type, core_rules, resident_id FROM rulebuilder_rules where type = 'Rulebuilder::ResidentRule'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_items where type = 'Rulebuilder::ResidentItem'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_spells where type = 'Rulebuilder::ResidentSpell'
        )x
        INNER JOIN residents on residents.id = resident_id
        INNER JOIN users on users.id = user_id AND status in ('active')
        GROUP BY
          core_rules
        ORDER BY
          core_rules
      ")

      @paid_totals = User.find_by_sql("
        SELECT
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentRule' ) THEN 1 ELSE 0 END) AS rules,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentItem' ) THEN 1 ELSE 0 END) AS items,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentSpell' ) THEN 1 ELSE 0 END) AS spells,
          count(*) as total
        FROM
        (
          SELECT type, core_rules, resident_id FROM rulebuilder_rules where type = 'Rulebuilder::ResidentRule'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_items where type = 'Rulebuilder::ResidentItem'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_spells where type = 'Rulebuilder::ResidentSpell'
        )x
        INNER JOIN residents on residents.id = resident_id
        INNER JOIN users on users.id = user_id AND status in ('active')
      ").first

      @free_counts = User.find_by_sql("
        SELECT
          core_rules,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentRule' ) THEN 1 ELSE 0 END) AS rules,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentItem' ) THEN 1 ELSE 0 END) AS items,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentSpell' ) THEN 1 ELSE 0 END) AS spells,
          count(*) as total
        FROM
        (
          SELECT type, core_rules, resident_id FROM rulebuilder_rules where type = 'Rulebuilder::ResidentRule'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_items where type = 'Rulebuilder::ResidentItem'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_spells where type = 'Rulebuilder::ResidentSpell'
        )x
        INNER JOIN residents on residents.id = resident_id
        INNER JOIN users on users.id = user_id AND status in ('free')
        GROUP BY
          core_rules
        ORDER BY
          core_rules
      ")

      @free_totals = User.find_by_sql("
        SELECT
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentRule' ) THEN 1 ELSE 0 END) AS rules,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentItem' ) THEN 1 ELSE 0 END) AS items,
          SUM(CASE WHEN (type = 'Rulebuilder::ResidentSpell' ) THEN 1 ELSE 0 END) AS spells,
          count(*) as total
        FROM
        (
          SELECT type, core_rules, resident_id FROM rulebuilder_rules where type = 'Rulebuilder::ResidentRule'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_items where type = 'Rulebuilder::ResidentItem'
          UNION ALL
          SELECT type, core_rules, resident_id FROM rulebuilder_spells where type = 'Rulebuilder::ResidentSpell'
        )x
        INNER JOIN residents on residents.id = resident_id
        INNER JOIN users on users.id = user_id AND status in ('free')
      ").first

      @stock_counts = User.find_by_sql("
        SELECT
          core_rules,
          SUM(CASE WHEN (type = 'Rulebuilder::StockRule' ) THEN 1 ELSE 0 END) AS rules,
          SUM(CASE WHEN (type = 'Rulebuilder::StockItem' ) THEN 1 ELSE 0 END) AS items,
          SUM(CASE WHEN (type = 'Rulebuilder::StockSpell' ) THEN 1 ELSE 0 END) AS spells,
          count(*) as total
        FROM
        (
          SELECT type, core_rules FROM rulebuilder_rules where type = 'Rulebuilder::StockRule'
          UNION ALL
          SELECT type, core_rules FROM rulebuilder_items where type = 'Rulebuilder::StockItem'
          UNION ALL
          SELECT type, core_rules FROM rulebuilder_spells where type = 'Rulebuilder::StockSpell'
        )x
        GROUP BY
          core_rules
        ORDER BY
          core_rules
      ")

      @stock_totals = User.find_by_sql("
        SELECT
          SUM(CASE WHEN (type = 'Rulebuilder::StockRule' ) THEN 1 ELSE 0 END) AS rules,
          SUM(CASE WHEN (type = 'Rulebuilder::StockItem' ) THEN 1 ELSE 0 END) AS items,
          SUM(CASE WHEN (type = 'Rulebuilder::StockSpell' ) THEN 1 ELSE 0 END) AS spells,
          count(*) as total
        FROM
        (
          SELECT type, core_rules FROM rulebuilder_rules where type = 'Rulebuilder::StockRule'
          UNION ALL
          SELECT type, core_rules FROM rulebuilder_items where type = 'Rulebuilder::StockItem'
          UNION ALL
          SELECT type, core_rules FROM rulebuilder_spells where type = 'Rulebuilder::StockSpell'
        )x
      ").first

    end

    private
      # Only allow a trusted parameter "white list" through.
      def rulebuilder_snapshot_params
        params[:rulebuilder_snapshot]
      end
  end
end
