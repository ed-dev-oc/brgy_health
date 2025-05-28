class DeliveryMethods::NotificationBroadcast < ApplicationDeliveryMethod
  # Specify the config options your delivery method requires in its config block
  required_options # :foo, :bar

  def deliver
    record.broadcast_prepend_later_to recipient.notification_channel,
      target: "notifications_list",
      partial: "notifications/notification",
      locals: { notification: notification }

    record.broadcast_replace_later_to recipient.notification_channel,
      target: "notification_status",
      partial: "notifications/notification_status",
      locals: { notifications: recipient.notifications.unread.to_a }
  end
end
