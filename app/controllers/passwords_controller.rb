class PasswordsController < ApplicationController
  SCOPES = { "user" => User, "admin" => Admin }.freeze

  before_action :set_scope
  before_action :set_account_by_token, only: %i[edit update]

  def new
    @account = @model.new
    @form_url = passwords_path
  end

  def create
    account = @model.find_by(email: params.dig(@scope, :email).to_s)
    deliver_reset(account) if account
    redirect_to login_path, notice: t("passwords.create.sent")
  end

  def edit; end

  def update
    if @account.reset_password(**new_password)
      start_new_session_for(@account)
      redirect_to main_app.root_path, notice: t("passwords.update.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_scope
      @scope = params.fetch(:scope)
      @model = SCOPES.fetch(@scope)
    end

    def set_account_by_token
      @account = @model.find_by_password_reset_token(params[:token])
      @form_url = password_path(params[:token])
      redirect_to new_password_path, alert: t("passwords.update.expired") unless @account
    end

    def password_path(token)
      @scope == "admin" ? admin_password_path(token) : user_password_path(token)
    end

    def new_password_path
      @scope == "admin" ? new_admin_password_path : new_user_password_path
    end

    def passwords_path
      @scope == "admin" ? admin_passwords_path : user_passwords_path
    end

    def deliver_reset(account)
      PasswordsMailer.reset(account, edit_password_url(account.password_reset_token)).deliver_later
    end

    def edit_password_url(token)
      @scope == "admin" ? edit_admin_password_url(token) : edit_user_password_url(token)
    end

    def login_path
      @scope == "admin" ? new_admin_session_path : new_user_session_path
    end

    def new_password
      params.expect(@scope => [ :password, :password_confirmation ]).to_h.symbolize_keys
    end
end
