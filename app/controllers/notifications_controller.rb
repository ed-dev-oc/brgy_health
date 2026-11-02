class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = preload_notification_records(notifications_scope.newest_first)
  end

  def mark_all_as_read
    current_user.notifications.mark_as_read
    @notifications = preload_notification_records(notifications_scope.newest_first)
  end

  def read
    @notifications = preload_notification_records(notifications_scope.read.newest_first)
  end

  def unread
    @notifications = preload_notification_records(notifications_scope.unread.newest_first)
  end

  def status
    @notifications = preload_notification_records(notifications_scope.unread.newest_first)
  end

  private

  def notifications_scope
    current_user.notifications.includes(event: :record)
  end

  def preload_notification_records(notifications)
    records = notifications.map(&:event).compact.map(&:record).compact
    users = records.select { |r| r.is_a?(User) }
    appts = records.select { |r| r.is_a?(Appointment) }

    ActiveRecord::Associations::Preloader.new(records: users, associations: :barangay).call if users.any?
    ActiveRecord::Associations::Preloader.new(records: appts, associations: [ :patient, :announcement ]).call if appts.any?

    notifications
  end
end
