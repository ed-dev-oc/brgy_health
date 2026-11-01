class DeliveryMethods::NotificationBroadcast < ApplicationDeliveryMethod
  # Specify the config options your delivery method requires in its config block
  required_options # :foo, :bar

  def deliver
    broadcaster = record || recipient
    return unless broadcaster

    broadcaster.broadcast_prepend_later_to recipient.notification_channel,
      target: "notifications_list",
      partial: "notifications/notification",
      locals: { notification: notification }

    broadcaster.broadcast_replace_later_to recipient.notification_channel,
      target: "notification_status_frame",
      partial: "notifications/notification_status",
      locals: { notifications: recipient.notifications.unread.to_a }
  end
end
