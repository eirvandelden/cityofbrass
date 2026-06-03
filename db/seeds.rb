# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require Rails.root.join("lib/support/core_faq_bootstrap")

Support::CoreFaqBootstrap.call

user = User.new(
  email: "user@example.com",
  password: "password1",
  password_confirmation: "password1"
)
user.skip_confirmation!
user.save!

admin = Admin.new(
  email: "user@example.com",
  password: "password1",
  password_confirmation: "password1"
)
admin.save!

%w[db:seed:draw_steel:all db:seed:5e:all db:seed:pf2e:all].each do |task_name|
  Rake::Task[task_name].reenable
  Rake::Task[task_name].invoke
end
