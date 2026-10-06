require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset mail goes to the account with the edit link" do
    mail = PasswordsMailer.reset(users(:dan), "https://example.com/users/passwords/abc/edit")

    assert_equal [ users(:dan).email ], mail.to
    assert_match "https://example.com/users/passwords/abc/edit", mail.body.to_s
  end

  test "subject is translated" do
    users(:dan).update!(locale: "nl")

    assert_equal "Instructies om je wachtwoord opnieuw in te stellen",
                 PasswordsMailer.reset(users(:dan), "https://example.com").subject
  end
end
