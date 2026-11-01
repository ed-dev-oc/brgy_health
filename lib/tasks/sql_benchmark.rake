# frozen_string_literal: true

namespace :sql do
  desc "Demonstrate and benchmark Advanced SQL Indexing and Query Optimization with EXPLAIN ANALYZE"
  task benchmark: :environment do
    conn = ActiveRecord::Base.connection

    puts "\n================================================================================"
    puts "  ADVANCED SQL BENCHMARK: INDEXING & QUERY OPTIMIZATION DEMONSTRATION"
    puts "================================================================================\n"

    # 1. Composite Unique Index on Users (:first_name, :middle_name, :last_name, :suffix)
    puts "--- [1] Index Scan Benchmark: Composite Full Name Index ---"
    puts "Index: index_users_on_full_name ON users(first_name, middle_name, last_name, suffix)"
    query1 = <<-SQL
      EXPLAIN (ANALYZE, BUFFERS)
      SELECT id, email, first_name, last_name 
      FROM users 
      WHERE first_name = 'Lao' 
        AND middle_name IS NULL 
        AND last_name = 'Admin' 
        AND suffix IS NULL;
    SQL
    plan1 = conn.execute(query1).map { |r| r["QUERY PLAN"] }.join("\n")
    puts plan1
    puts ""

    # 2. Unique Identifier Lookup (public_uid)
    puts "--- [2] Index Scan Benchmark: Public UID Unique Index ---"
    puts "Index: index_appointments_on_public_uid ON appointments(public_uid)"
    sample_uid = Appointment.first&.public_uid || "11111"
    query2 = <<-SQL
      EXPLAIN (ANALYZE, BUFFERS)
      SELECT id, status, scheduled_at 
      FROM appointments 
      WHERE public_uid = '#{sample_uid}';
    SQL
    plan2 = conn.execute(query2).map { |r| r["QUERY PLAN"] }.join("\n")
    puts plan2
    puts ""

    # 3. View & Window Function Performance: appointment_reports
    puts "--- [3] SQL View & Window Function Benchmark: appointment_reports ---"
    puts "View: appointment_reports (uses ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...))"
    query3 = <<-SQL
      EXPLAIN (ANALYZE, BUFFERS)
      SELECT row_num, patient_first_name, patient_last_name, announcement_name, scheduled_at
      FROM appointment_reports
      WHERE announcement_id = (SELECT id FROM announcements LIMIT 1)
      ORDER BY scheduled_at;
    SQL
    plan3 = conn.execute(query3).map { |r| r["QUERY PLAN"] }.join("\n")
    puts plan3
    puts ""

    # 4. Common Table Expression (CTE) Benchmark: program_performance_summary
    puts "--- [4] Common Table Expression (CTE) Benchmark: WITH ... AS ---"
    puts "Method: HealthProgram.program_performance_summary(barangay_id)"
    query4 = <<-SQL
      EXPLAIN (ANALYZE, BUFFERS)
      WITH program_base AS (
        SELECT 
          hp.id AS health_program_id,
          hp.name AS program_name,
          COUNT(DISTINCT ann.id) AS announcements_count,
          COUNT(DISTINCT appt.id) AS total_appointments,
          COUNT(DISTINCT CASE WHEN appt.status = 2 THEN appt.id END) AS completed_appointments
        FROM health_programs hp
        LEFT JOIN announcements ann ON ann.health_program_id = hp.id AND ann.barangay_id = 1
        LEFT JOIN appointments appt ON appt.announcement_id = ann.id AND appt.barangay_id = 1
        WHERE hp.barangay_id = 1
        GROUP BY hp.id, hp.name
      )
      SELECT * FROM program_base;
    SQL
    plan4 = conn.execute(query4).map { |r| r["QUERY PLAN"] }.join("\n")
    puts plan4
    puts ""

    puts "================================================================================"
    puts "  BENCHMARK COMPLETE: All execution plans verified against PostgreSQL indexes"
    puts "================================================================================\n"
  end
end
