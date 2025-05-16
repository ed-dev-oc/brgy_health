class UserMailer < ApplicationMailer
  def admin_require_verify_email(user)
    @user = user
    mail(to: user.email, subject: "Registration Submitted – Awaiting Admin Approval")
  end

  def admin_validated_email(user)
    @user = user
    mail(to: user.email, subject: "Registration Approved – Welcome to brgyhealth.top")
  end
end
