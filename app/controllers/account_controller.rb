class AccountController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_account(account_params)
      redirect_to edit_user_settings_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:email, :locale, :password, :password_confirmation, :current_password)
  end
end
