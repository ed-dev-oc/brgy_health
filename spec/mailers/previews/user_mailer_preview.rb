# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def admin_require_verify_email
    UserMailer.admin_require_verify_email(User.admin.first)
  end

  def admin_validated_email
    UserMailer.admin_validated_email(User.admin.first)
  end

  def new_admin_email
    notification = Noticed::Notification.where(type: "NewAdminNotifier::Notification").first

    UserMailer.new_admin_email(notification)
  end
end
