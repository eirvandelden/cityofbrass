# frozen_string_literal: false
class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM_EMAIL']
  layout 'mailer'
end
