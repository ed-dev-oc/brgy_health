class Testimonial < ApplicationRecord
  acts_as_tenant :barangay
  belongs_to :user

  RATING = [ 1, 2, 3, 4, 5 ]
  enum :status, [ :hidden, :visible ]

  validates :data, :rating, presence: true
end
