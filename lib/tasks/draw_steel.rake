namespace :db do
  namespace :seed do
    namespace :draw_steel do
      SEED_DIR = Rails.root.join("db", "seeds", "draw-steel") unless defined?(SEED_DIR)
      DRAW_STEEL_SEED_TASKS = %w[ancestries classes kits careers complications conditions abilities].freeze unless
        defined?(DRAW_STEEL_SEED_TASKS)

      desc "Seed Draw Steel Ancestries"
      task ancestries: :environment do
        CoreRules::Seeder.seed_rules(SEED_DIR, "ancestries.json")
      end

      desc "Seed Draw Steel Classes"
      task classes: :environment do
        CoreRules::Seeder.seed_rules(SEED_DIR, "classes.json")
      end

      desc "Seed Draw Steel Kits"
      task kits: :environment do
        CoreRules::Seeder.seed_rules(SEED_DIR, "kits.json")
      end

      desc "Seed Draw Steel Careers"
      task careers: :environment do
        CoreRules::Seeder.seed_rules(SEED_DIR, "careers.json")
      end

      desc "Seed Draw Steel Complications"
      task complications: :environment do
        CoreRules::Seeder.seed_rules(SEED_DIR, "complications.json")
      end

      desc "Seed Draw Steel Conditions"
      task conditions: :environment do
        CoreRules::Seeder.seed_rules(SEED_DIR, "conditions.json")
      end

      desc "Seed Draw Steel Abilities (StockSpells)"
      task abilities: :environment do
        CoreRules::Seeder.seed_spells(SEED_DIR, "abilities.json")
      end

      desc "Seed everything for Draw Steel"
      task all: :environment do
        invoke_seed_tasks(DRAW_STEEL_SEED_TASKS)
        puts "Draw Steel seed does not seed stock creatures; no Draw Steel creature dataset is present."
      end

      def invoke_seed_tasks(task_names)
        task_names.each do |task_name|
          task = Rake::Task["db:seed:draw_steel:#{task_name}"]
          task.reenable
          task.invoke
        end
      end
    end
  end
end
