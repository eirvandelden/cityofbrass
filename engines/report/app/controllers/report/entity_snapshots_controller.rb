require_dependency "report/application_controller"

module Report
  class EntitySnapshotsController < ApplicationController

    # GET /entity_snapshots
    def index

      @paid_counts = Entitybuilder::Entity.find_by_sql("
        SELECT
        	core_rules,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCharacter' ) THEN 1 ELSE 0 END) AS characters,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCreature' ) THEN 1 ELSE 0 END) AS creatures,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentNpc' ) THEN 1 ELSE 0 END) AS npcs,
        	count(*) as total
        FROM
        	entitybuilder_entities
          INNER JOIN residents on residents.id = resident_id
          INNER JOIN users on users.id = user_id AND status in ('active')
        WHERE
          type like 'Entitybuilder::Resident%'
        GROUP BY
        	core_rules
        ORDER BY
        	core_rules
      ")

      @free_totals = Entitybuilder::Entity.find_by_sql("
        SELECT
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCharacter' ) THEN 1 ELSE 0 END) AS characters,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCreature' ) THEN 1 ELSE 0 END) AS creatures,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentNpc' ) THEN 1 ELSE 0 END) AS npcs,
        	count(*) as total
        FROM
        	entitybuilder_entities
          INNER JOIN residents on residents.id = resident_id
          INNER JOIN users on users.id = user_id AND status in ('free')
        WHERE type like 'Entitybuilder::Resident%'
      ").first

      @free_counts = Entitybuilder::Entity.find_by_sql("
        SELECT
        	core_rules,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCharacter' ) THEN 1 ELSE 0 END) AS characters,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCreature' ) THEN 1 ELSE 0 END) AS creatures,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentNpc' ) THEN 1 ELSE 0 END) AS npcs,
        	count(*) as total
        FROM
        	entitybuilder_entities
          INNER JOIN residents on residents.id = resident_id
          INNER JOIN users on users.id = user_id AND status in ('free')
        WHERE
          type like 'Entitybuilder::Resident%'
        GROUP BY
        	core_rules
        ORDER BY
        	core_rules
      ")

      @paid_totals = Entitybuilder::Entity.find_by_sql("
        SELECT
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCharacter' ) THEN 1 ELSE 0 END) AS characters,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentCreature' ) THEN 1 ELSE 0 END) AS creatures,
        	SUM(CASE WHEN (type = 'Entitybuilder::ResidentNpc' ) THEN 1 ELSE 0 END) AS npcs,
        	count(*) as total
        FROM
        	entitybuilder_entities
          INNER JOIN residents on residents.id = resident_id
          INNER JOIN users on users.id = user_id AND status in ('active')
        WHERE type like 'Entitybuilder::Resident%'
      ").first

      @stock_counts = Entitybuilder::Entity.find_by_sql("
        SELECT
          core_rules,
          SUM(CASE WHEN (type = 'Entitybuilder::StockCharacter' ) THEN 1 ELSE 0 END) AS characters,
          SUM(CASE WHEN (type = 'Entitybuilder::StockCreature' ) THEN 1 ELSE 0 END) AS creatures,
          SUM(CASE WHEN (type = 'Entitybuilder::StockNpc' ) THEN 1 ELSE 0 END) AS npcs,
          count(*) as total
        FROM
          entitybuilder_entities
        WHERE type like 'Entitybuilder::Stock%'
        GROUP BY
          core_rules
        ORDER BY
          core_rules
      ")

      @stock_totals = Entitybuilder::Entity.find_by_sql("
        SELECT
          SUM(CASE WHEN (type = 'Entitybuilder::StockCharacter' ) THEN 1 ELSE 0 END) AS characters,
          SUM(CASE WHEN (type = 'Entitybuilder::StockCreature' ) THEN 1 ELSE 0 END) AS creatures,
          SUM(CASE WHEN (type = 'Entitybuilder::StockNpc' ) THEN 1 ELSE 0 END) AS npcs,
          count(*) as total
        FROM
          entitybuilder_entities
        WHERE type like 'Entitybuilder::Stock%'
      ").first

    end

    private
      # Only allow a trusted parameter "white list" through.
      def entity_snapshot_params
        params[:entity_snapshot]
      end
  end
end
