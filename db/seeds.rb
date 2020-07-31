# frozen_string_literal: false

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.new(
    :email => 'user@example.com',
    :password => 'password1',
    :password_confirmation => 'password1'
  )
user.skip_confirmation!
user.save!

admin = Admin.new(
    :email => 'user@example.com',
    :password => 'password1',
    :password_confirmation => 'password1'
  )
admin.save!
