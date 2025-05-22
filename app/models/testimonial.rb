class Testimonial < ApplicationRecord
  acts_as_tenant :barangay
  belongs_to :user

  after_create :send_new_testimonial_email

  RATING = [1, 2, 3, 4, 5]
  enum :status, [:hidden, :visible]

  validates :data, :rating, presence: true

  private

  def send_new_testimonial_email
    super_admin = User.find_by(role: :super_admin)
    return unless super_admin

    TestimonialMailer.new_testimonial(self, super_admin).deliver_later
  end
end
