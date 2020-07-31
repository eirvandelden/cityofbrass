# frozen_string_literal: false

module Report
  module WorldbuilderSnapshotsHelper

    def report_district_count
      return Worldbuilder::District.count
    end

  end
end
