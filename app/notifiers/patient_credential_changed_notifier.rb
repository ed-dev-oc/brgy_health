# app/notifications/patient_credential_changed_notifier.rb
class PatientCredentialChangedNotifier < ApplicationNotifier
  deliver_by :notification_broadcast, class: "DeliveryMethods::NotificationBroadcast"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"
  deliver_by :email, mailer: "UserMailer", method: :credential_changed

  required_param :changed_attributes

  notification_methods do
    def message
      changed = params[:changed_attributes].join(" and ")
      "Your #{changed} #{changed.length > 1 ? 'were' : 'was'} updated successfully."
    end

    def url
      Rails.application.routes.url_helpers.edit_user_registration_path
    end
  end
end
