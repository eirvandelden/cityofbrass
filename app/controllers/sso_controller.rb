require 'single_sign_on'

class SsoController < ApplicationController
  before_action :authenticate_user!


  def symposium
    begin
      secret = ENV["SYMPOSIUM_SSO_SECRET"]
      sso = SingleSignOn.parse(request.query_string, secret)
      sso.email = current_user.email
      sso.name = current_user.resident.name # this is a custom method on the User class
      sso.username = current_user.resident.slug
      sso.external_id = current_user.id
      sso.sso_secret = secret

      redirect_to sso.to_url(ENV["SYMPOSIUM_SSO_URL"]), allow_other_host: true
    rescue => e
      logger.error "User #{current_user.email} was unable to log into Symposium"
      redirect_to root_path
    end
  end
end
