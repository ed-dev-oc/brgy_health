class UserCredentialChangedNotifier < ApplicationNotifier
  deliver_by :notification_broadcast, class: "DeliveryMethods::NotificationBroadcast"
  deliver_by :web_push, class: "DeliveryMethods::WebPush"
  deliver_by :email, mailer: "UserMailer", method: :credential_changed

  required_param :changed_attributes

  notification_methods do
    def message
      changes = params[:changed_attributes].map(&:humanize).join(", ")
      "Your profile information has been updated: #{changes}."
    end

    def url
      Rails.application.routes.url_helpers.edit_profile_path(recipient)
    end
  end
end
