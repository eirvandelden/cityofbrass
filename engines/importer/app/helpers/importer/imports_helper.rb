module Importer
  module ImportsHelper
    def importer_result_entity(result)
      record_path = importer_result_record_path(result)
      return result.entity_name if record_path.blank?

      link_to result.entity_name, record_path
    end

    private

    def importer_result_record_path(result)
      return if result.record.blank?
      return rulebuilder_import_path(result.record) if result.record.is_a?(Rulebuilder::Rule)
      return rulebuilder_import_path(result.record) if result.record.is_a?(Rulebuilder::Item)
      return rulebuilder_import_path(result.record) if result.record.is_a?(Rulebuilder::Spell)
      return entitybuilder_import_path(result.record) if stock_entitybuilder_record?(result.record)

      path = tcob_path(result.record)
      path if path.is_a?(String) && path.present?
    end

    def rulebuilder_import_path(record)
      scope, resource = record.class.name.demodulize.underscore.split("_", 2)
      return if scope.blank? || resource.blank?

      "/rb/#{scope}/#{resource.pluralize}/#{record.id}"
    end

    def entitybuilder_import_path(record)
      scope, resource = record.class.name.demodulize.underscore.split("_", 2)
      return if scope.blank? || resource.blank?

      "/eb/#{scope}/#{resource.pluralize}/#{record.id}"
    end

    def stock_entitybuilder_record?(record)
      record.is_a?(Entitybuilder::Entity) && record.class.name.demodulize.start_with?("Stock")
    end
  end
end
