# frozen_string_literal: false
class Admin < ApplicationRecord
  devise :database_authenticatable,
         :trackable, :rememberable, :recoverable,
         :lockable

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
