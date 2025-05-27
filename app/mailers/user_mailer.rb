class UserMailer < ApplicationMailer
  def admin_require_verify_email(user)
    @user = user
    mail(to: user.email, subject: "Registration Submitted – Awaiting Admin Approval")
  end

  def admin_validated_email(user)
    @user = user
    mail(to: user.email, subject: "Registration Approved – Welcome to brgyhealth.top")
  end

  def new_admin_email(notification)
    @user = notification.recipient
    @admin = notification.record

    mail(to: @user.email, subject: "New Admin Registration Requires Your Approval")
  end

  def credential_changed(notification)
    @user = notification.recipient
    @changed_attributes = notification.params[:changed_attributes]

    mail(
      to: @user.email,
      subject: "Your account credentials have been updated"
    )
  end

  def new_testimonial_email(notification)
    @user = notification.recipient
    @testimonial = notification.params[:testimonial]
    mail(to: @user.email, subject: "New Testimonial Submitted")
  end
end
