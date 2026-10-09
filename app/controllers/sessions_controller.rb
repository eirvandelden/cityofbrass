class SessionsController < ApplicationController
  SCOPES = { "user" => User, "admin" => Admin }.freeze

  before_action :set_scope

  def new
    @account = @model.new
  end

  def create
    account = @model.authenticate_by_credentials(**credentials)
    account ? sign_in_and_redirect(account) : render_failure(t("sessions.create.invalid"))
  rescue Authenticatable::Locked
    render_failure(t("sessions.create.locked"))
  end

  def destroy
    terminate_session(@model.name)
    redirect_to main_app.root_path, notice: t("sessions.destroy.signed_out"), status: :see_other
  end

  private
    def set_scope
      @scope = params.fetch(:scope)
      @model = SCOPES.fetch(@scope)
      @form_url = login_path
      @forgot_password_url = forgot_password_path
    end

    def login_path
      @scope == "admin" ? admin_session_path : user_session_path
    end

    def forgot_password_path
      @scope == "admin" ? new_admin_password_path : new_user_password_path
    end

    def credentials
      params.expect(@scope => [ :email, :password ]).to_h.symbolize_keys
    end

    def sign_in_and_redirect(account)
      return_to = after_authentication_url(account)
      start_new_session_for(account)
      I18n.with_locale(account.try(:locale) || I18n.locale) do
        redirect_to return_to, notice: t("sessions.create.signed_in")
      end
    end

    def render_failure(message)
      @account = @model.new(email: params.dig(@scope, :email))
      flash.now[:alert] = message
      render :new, status: :unprocessable_entity
    end
end
