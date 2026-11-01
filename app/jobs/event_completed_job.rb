class EventCompletedJob < ApplicationJob
  queue_as :default

  def perform
    ActsAsTenant.without_tenant do
      events = Event.active.where("end_date < ?", Time.now)

      events.find_each(batch_size: 100) do |event|
        event.completed!
      end
    end
  end
end
