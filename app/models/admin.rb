class Admin < ApplicationRecord
  include Authenticatable

  validates :email, presence: true, uniqueness: true
end
