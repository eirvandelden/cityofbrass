module Report
  module ApplicationHelper

    def report_menu
      options = [
        {label: 'Dashboard', link: 'dashboards'},
        {label: 'User', link: 'user_snapshots'},
        {label: 'Resident', link: 'resident_snapshots'},
        {label: 'Gallery', link: 'gallery_snapshots'},
        {label: 'Entity', link: 'entity_snapshots'},
        {label: 'Rule Builder', link: 'rulebuilder_snapshots'},
        {label: 'Campaign Mgr', link: 'campaignmanager_snapshots'},
        {label: 'Story Builder', link: 'storybuilder_snapshots'},
        {label: 'World Builder', link: 'worldbuilder_snapshots'}
      ]
    end

    def user_status
      ['active', 'free']
    end

  end
end
