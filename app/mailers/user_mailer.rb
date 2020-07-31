# frozen_string_literal: false

class UserMailer < ApplicationMailer
  def user_trial_warning(user)
    @user = user
    @url = "https://#{ENV['DEFAULT_BASE_URL']}/billing"

    mail(to: @user.email, subject: "Remember, your City of Brass trial ends in 3 days!")
  end

  def user_trial_end(user)
    @user = user
    @url = "https://#{ENV['DEFAULT_BASE_URL']}/billing"

    mail(to: @user.email, subject: "Your City of Brass trial period has ended.")
  end

end
