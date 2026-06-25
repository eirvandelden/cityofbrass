class UsersController < ApplicationController

  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.search(params[:search]).order_status.order_email.page(params[:page]).per(20)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)
    @user.skip_confirmation!
    if @user.save
      redirect_to users_path, notice: t(".created", email: @user.email)
    else
      render :new
    end
  end

  def edit
  end

  def update
    email_updated = (@user.email == user_params[:email]) ? false : true
    @user.skip_confirmation_notification!
    respond_to do |format|
      if @user.update(user_params)
        @user.confirm if email_updated
        format.js { flash.now[:notice] = "#{@user.email} has been updated." }
      else
        format.js
      end
    end
  end

  private
    def set_user
      @user = User.includes(:resident).find(params[:id])
      @resident = @user.resident
    end

    def user_params
      params.require(:user).permit(:email, :status, :stripe_customer_token)
    end

    def create_user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :status, :locale)
    end

end
