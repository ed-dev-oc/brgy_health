# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def admin_require_verify_email
    UserMailer.admin_require_verify_email(User.admin.first)
  end
end
