class HealthProgram < ApplicationRecord
  acts_as_tenant(:barangay)
  has_many :announcements, foreign_key: :health_program_id
  enum :status, [ :active, :inactive ]

  validates :name, :description, presence: true
  validates_uniqueness_to_tenant :name

  # Advanced SQL Technique: Common Table Expression (CTE - WITH ... AS)
  # Aggregates multi-table program operational metrics and computes completion rates
  def self.program_performance_summary(barangay_id)
    sql = <<-SQL
      WITH program_base AS (
        SELECT 
          hp.id AS health_program_id,
          hp.name AS program_name,
          hp.status AS program_status,
          COUNT(DISTINCT ann.id) AS announcements_count,
          COUNT(DISTINCT appt.id) AS total_appointments,
          COUNT(DISTINCT CASE WHEN appt.status = 2 THEN appt.id END) AS completed_appointments,
          COUNT(DISTINCT CASE WHEN appt.status = 1 THEN appt.id END) AS approved_appointments,
          COUNT(DISTINCT CASE WHEN appt.status = 0 THEN appt.id END) AS pending_appointments,
          COUNT(DISTINCT CASE WHEN appt.status = 4 THEN appt.id END) AS cancelled_appointments
        FROM health_programs hp
        LEFT JOIN announcements ann 
          ON ann.health_program_id = hp.id AND ann.barangay_id = :barangay_id
        LEFT JOIN appointments appt 
          ON appt.announcement_id = ann.id AND appt.barangay_id = :barangay_id
        WHERE hp.barangay_id = :barangay_id
        GROUP BY hp.id, hp.name, hp.status
      ),
      program_metrics AS (
        SELECT 
          health_program_id,
          program_name,
          program_status,
          announcements_count,
          total_appointments,
          completed_appointments,
          approved_appointments,
          pending_appointments,
          cancelled_appointments,
          CASE 
            WHEN total_appointments > 0 
            THEN ROUND((completed_appointments::numeric / total_appointments::numeric) * 100, 1)
            ELSE 0.0
          END AS completion_rate
        FROM program_base
      )
      SELECT * 
      FROM program_metrics
      ORDER BY total_appointments DESC, announcements_count DESC, program_name ASC;
    SQL

    sanitized = sanitize_sql_array([sql, { barangay_id: barangay_id }])
    connection.select_all(sanitized).to_a
  end
end
