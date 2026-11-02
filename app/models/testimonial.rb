class Testimonial < ApplicationRecord
  acts_as_tenant :barangay
  belongs_to :user

  after_create :send_new_testimonial_notification

  RATING = [ 1, 2, 3, 4, 5 ]
  enum :status, [ :hidden, :visible ]

  validates :data, :rating, presence: true

  private

  def send_new_testimonial_notification
    ActsAsTenant.without_tenant do
      super_admins = User.where(role: [ "super_admin", "platform_staff" ])
      if super_admins.any?
        NewTestimonialNotifier.with(record: self, testimonial: self).deliver_later(super_admins)
      end
    end
  end
end
