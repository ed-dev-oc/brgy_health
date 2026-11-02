class AnnouncementCompletedJob < ApplicationJob
  queue_as :default

  def perform
    ActsAsTenant.without_tenant do
      announcements = Announcement.active.where("end_date < ?", Time.now)

      announcements.find_each(batch_size: 100) do |announcement|
        announcement.completed!
      end
    end
  end
end
