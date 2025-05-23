class Testimonial < ApplicationRecord
  acts_as_tenant :barangay
  belongs_to :user

  after_create :send_new_testimonial_notification

  RATING = [1, 2, 3, 4, 5]
  enum :status, [:hidden, :visible]

  validates :data, :rating, presence: true

  private

  def send_new_testimonial_notification
    super_admins = User.super_admins
    TestimonialMailer.new_testimonial(self, super_admins.first).deliver_later if super_admins.any?
    NewTestimonialNotifier.with(testimonial: self).deliver_later(super_admins)
  end
end
