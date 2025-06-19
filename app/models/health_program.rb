class HealthProgram < ApplicationRecord
  acts_as_tenant(:barangay)
  has_many :announcements, foreign_key: :health_program_id
  has_many :activity_logs, as: :loggable, dependent: :destroy
  validates :name, :description, presence: true
  enum :status, [ :active, :inactive ]

  validates :name, :description, presence: true
  validates_uniqueness_to_tenant :name

  def generate_change_log_description
    return unless saved_changes.any?

    messages = []

    saved_changes.except(:updated_at).each do |attr, (old_val, new_val)|
      case attr
      when "status"
        messages << "Status changed from <strong>#{old_val}</strong> to <strong>#{new_val}</strong>"
      when "name"
        messages << "Name updated from <code>#{old_val}</code> to <code>#{new_val}</code>"
      when "description"
        messages << "Description updated"
      end
    end

    messages.join("<br>").html_safe

  end
end
