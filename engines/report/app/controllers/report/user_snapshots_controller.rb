# frozen_string_literal: false

require_dependency "report/application_controller"

module Report
  class UserSnapshotsController < ApplicationController

    # GET /user_snapshots
    def index
      @user_counts = User.find_by_sql("SELECT status, count(*) as total FROM users WHERE status in ('active', 'free') GROUP BY status ORDER BY status")
      @other_counts = User.find_by_sql("SELECT status, count(*) as total FROM users WHERE status not in ('active', 'free') GROUP BY status ORDER BY status")


      @current_login_counts_by_date = User.find_by_sql("
        SELECT
        	date(current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST') as dte,
        	count(*) total
        FROM
        	users
        where
          status in ('active', 'free')
        	AND current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST' > current_date - 7
        group by
        	date(current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST')
        order by
        	date(current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST') desc
        limit 7
      ")

      @current_login_counts_by_week = User.find_by_sql("
        SELECT
          date(date_trunc('week', date(current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST'))) AS dte,
          count(*) total
        FROM
          users
        where
          status in ('active', 'free')
          AND current_sign_in_at > date('2015-05-10')
        group by
          date_trunc('week', date(current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST'))
        order by
          date_trunc('week', date(current_sign_in_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST')) desc
        limit 8
      ")


      @created_at_counts_by_date = User.find_by_sql("
        SELECT
          date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST') as dte,
          count(*) total
        FROM
          users
        where
          created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST' > current_date - 7
        group by
          date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST')
        order by
          date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST') desc
        limit 7
      ")

      @created_at_counts_by_week = User.find_by_sql("
        SELECT
          date(date_trunc('week', date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST'))) AS dte,
          count(*) total
        FROM
          users
        where
          created_at > date('2015-05-10')
        group by
          date_trunc('week', date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST'))
        order by
          date_trunc('week', date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST')) desc
        limit 8
      ")

      @created_at_counts_by_month = User.find_by_sql("
        SELECT
          date(date_trunc('month', date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST'))) AS dte,
          count(*) total
        FROM
          users
        where
          created_at > date('2015-05-10')
        group by
          date_trunc('month', date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST'))
        order by
          date_trunc('month', date(created_at AT TIME ZONE 'UTC' AT TIME ZONE 'EST')) desc
        limit 6
      ")
    end

    private
      # Only allow a trusted parameter "white list" through.
      def user_snapshot_params
        params[:user_snapshot]
      end
  end
end
