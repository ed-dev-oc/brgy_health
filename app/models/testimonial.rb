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
      super_admins = User.where(role: "super_admin")
      if super_admins.any?
        UserMailer.new_testimonial_email(self, super_admins.first).deliver_later
        NewTestimonialNotifier.with(testimonial: self).deliver_later(super_admins)
      end
    end
  end
end
