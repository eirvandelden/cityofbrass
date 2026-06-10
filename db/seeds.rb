# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require Rails.root.join("lib/support/core_faq_bootstrap")

Support::CoreFaqBootstrap.call

if Rails.env.development? || Rails.env.test?
  user = User.find_or_initialize_by(email: "user@example.com")

  if user.new_record?
    user.password = "password1"
    user.password_confirmation = "password1"
    user.skip_confirmation!
    user.save!
  end

  admin = Admin.find_or_initialize_by(email: "user@example.com")

  if admin.new_record?
    admin.password = "password1"
    admin.password_confirmation = "password1"
    admin.save!
  end
end

%w[db:seed:draw_steel:all db:seed:5e:all db:seed:pf2e:all].each do |task_name|
  Rake::Task[task_name].reenable
  Rake::Task[task_name].invoke
end
