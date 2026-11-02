class ApplicationMailer < ActionMailer::Base
  default from: (Rails.application.credentials.dig(:yahoo, :email) || "po_e@yahoo.com")
  layout "mailer"
end
