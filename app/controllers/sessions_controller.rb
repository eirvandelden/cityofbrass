class SessionsController < Devise::SessionsController
  def create
    params[resource_name][:remember_me] = "1"
    super
  end
end
