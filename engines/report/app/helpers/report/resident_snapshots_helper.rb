module Report
  module ResidentSnapshotsHelper

    def report_resident_count(status)
      return Resident.joins(:user).where("users.status in (?)", status).count
    end

    def report_resident_affiliate_accepted_count(status)
      return (Affiliation.joins(:resident_user).where("users.status in (?)", status).where("affiliations.status = 'accepted'").count/2)
    end

    def report_resident_affiliate_pending_count(status)
      return Affiliation.joins(:resident_user).where("users.status in (?)", status).where("affiliations.status = 'pending'").count
    end

    def report_resident_affiliate_blocked_count(status)
      return Affiliation.joins(:resident_user).where("users.status in (?)", status).where("affiliations.status = 'blocked'").count
    end

    def report_resident_message_count(status)
      return Message.joins(:sender_user).where("users.status in (?)", status).count
    end

  end
end
