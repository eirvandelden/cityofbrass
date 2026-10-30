class PasswordsMailer < ApplicationMailer
  def reset(account, edit_url)
    @account = account
    @edit_url = edit_url
    I18n.with_locale(account.try(:locale) || I18n.default_locale) do
      mail to: account.email, subject: t("passwords_mailer.reset.subject")
    end
  end
end
