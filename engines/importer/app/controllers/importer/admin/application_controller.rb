module Importer
  module Admin
    class ApplicationController < ::ApplicationController
      before_action :check_authorization

      private

      def check_authorization
        render template: "errors/403", layout: "layouts/application", status: :forbidden unless admin_signed_in?
      end
    end
  end
end
