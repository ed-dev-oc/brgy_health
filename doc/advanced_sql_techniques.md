# Advanced SQL Techniques Implementation & Architecture (`brgy_health`)

> **Reference Assignment Specification:** [`doc/requirements/assignment.jpg`](requirements/assignment.jpg)  
> **Requirement:** Implement at least **4** of the following Advanced SQL Techniques:
> - Stored Procedures
> - Triggers
> - Views
> - Window Functions
> - Common Table Expressions (CTEs)
> - Transactions (with commit/rollback)
> - Indexing and Query Optimization (must show performance benefit)

---

## 1. Summary of All Implemented Techniques

All **7 out of 7** Advanced SQL techniques are implemented in the `brgy_health` codebase:

| # | Advanced SQL Technique | Status | Core Implementation Files |
| :- | :--- | :--- | :--- |
| 1 | **Views** | **Applied** | [`db/views/appointment_reports_v01.sql`](../db/views/appointment_reports_v01.sql), [`db/migrate/20250625093919_create_appointment_reports.rb`](../db/migrate/20250625093919_create_appointment_reports.rb), [`app/models/appointment_report.rb`](../app/models/appointment_report.rb) |
| 2 | **Window Functions** | **Applied** | [`db/views/appointment_reports_v01.sql`](../db/views/appointment_reports_v01.sql) (`ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)`) |
| 3 | **Stored Procedures** | **Applied** | [`db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb`](../db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb), [`app/models/appointment.rb`](../app/models/appointment.rb) |
| 4 | **Triggers** | **Applied** | [`db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb`](../db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb), [`app/models/appointment_status_log.rb`](../app/models/appointment_status_log.rb) |
| 5 | **Common Table Expressions (CTEs)** | **Applied** | [`app/models/health_program.rb`](../app/models/health_program.rb) (`HealthProgram.program_performance_summary`), [`app/controllers/admin/dashboard_controller.rb`](../app/controllers/admin/dashboard_controller.rb), [`app/views/admin/dashboard/index.html.erb`](../app/views/admin/dashboard/index.html.erb) |
| 6 | **Transactions (with commit/rollback)** | **Applied** | [`app/controllers/admin/appointments_controller.rb`](../app/controllers/admin/appointments_controller.rb) (`follow_up_check_up`, `flag_as_approved`), [`app/models/user.rb`](../app/models/user.rb) |
| 7 | **Indexing and Query Optimization** | **Applied** | Indexes across `db/migrate/*`, N+1 eager loading, and [`lib/tasks/sql_benchmark.rake`](../lib/tasks/sql_benchmark.rake) (`bin/rails sql:benchmark` showing `EXPLAIN (ANALYZE, BUFFERS)`) |

---

## 2. Detailed Technical Breakdown & Code Artifacts

### 2.1. Database Views (`CREATE VIEW`)
Managed via the [`scenic`](https://github.com/scenic-views/scenic) gem (`Gemfile` line 111). Creates a virtual table pre-joining 5 tables (`appointments`, `users` as patient, `users` as health worker, `barangays`, and `announcements`) for clinical roster reports and PDF generation.

- **SQL Definition (`db/views/appointment_reports_v01.sql`):**
  ```sql
  SELECT 
    ROW_NUMBER() OVER (PARTITION BY a.announcement_id ORDER BY a.scheduled_at) AS row_num,
    a.id,
    a.barangay_id,
    a.announcement_id,
    a.public_uid,
    a.scheduled_at,
    a.status,
    a.reason,
    a.notes,
    a.cancel_reason,
    a.reschedule_reason,
    patient.id AS patient_id,
    patient.first_name AS patient_first_name,
    patient.middle_name AS patient_middle_name,
    patient.last_name AS patient_last_name,
    patient.suffix AS patient_suffix,
    patient.email AS patient_email,
    patient.phone_number AS patient_phone_number,
    health_worker.id AS health_worker_id,
    health_worker.first_name AS health_worker_first_name,
    health_worker.middle_name AS health_worker_middle_name,
    health_worker.last_name AS health_worker_last_name,
    health_worker.suffix AS health_worker_suffix,
    health_worker.email AS health_worker_email,
    b.name AS barangay_name,
    ann.name AS announcement_name,
    a.created_at,
    a.updated_at
  FROM appointments a
  LEFT JOIN users patient ON a.patient_id = patient.id
  LEFT JOIN users health_worker ON a.health_worker_id = health_worker.id
  LEFT JOIN barangays b ON a.barangay_id = b.id
  LEFT JOIN announcements ann ON a.announcement_id = ann.id;
  ```
- **ActiveRecord Model:** [`app/models/appointment_report.rb`](../app/models/appointment_report.rb) marked with `def readonly? = true`.
- **Controller & Views:** [`app/controllers/admin/appointment_reports_controller.rb`](../app/controllers/admin/appointment_reports_controller.rb) renders printable rosters and PDFs via Grover.

---

### 2.2. Window Functions (`ROW_NUMBER() OVER (...)`)
Used in [`db/views/appointment_reports_v01.sql`](../db/views/appointment_reports_v01.sql) (line 3) to partition appointments dynamically:
```sql
ROW_NUMBER() OVER (PARTITION BY a.announcement_id ORDER BY a.scheduled_at) AS row_num
```
- **Operational Benefit:** Sequentially indexes patients for each announcement without requiring a separate sequence table or application-level counter loops. Displayed as the queue `#` in [`app/views/admin/appointment_reports/index.html.erb`](../app/views/admin/appointment_reports/index.html.erb).

---

### 2.3. PostgreSQL Stored Procedures (`CREATE OR REPLACE PROCEDURE`)
Added via migration [`db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb`](../db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb).

- **Stored Procedure Definition:**
  ```sql
  CREATE OR REPLACE PROCEDURE cancel_expired_pending_appointments(
    p_barangay_id BIGINT,
    p_cutoff_time TIMESTAMP
  )
  LANGUAGE plpgsql
  AS $$
  BEGIN
    UPDATE appointments a
    SET status = 4, -- cancelled
        cancel_reason = 'Automated Stored Procedure: Schedule expired without clinic confirmation',
        updated_at = NOW()
    FROM announcements ann
    WHERE a.announcement_id = ann.id
      AND a.barangay_id = p_barangay_id
      AND a.status = 0 -- pending
      AND ann.end_date < p_cutoff_time;
  END;
  $$;
  ```
- **Model Wrapper in [`app/models/appointment.rb`](../app/models/appointment.rb):**
  ```ruby
  def self.cancel_expired_pending_via_procedure(barangay_id, cutoff_time = Time.current)
    sanitized = sanitize_sql_array([
      "CALL cancel_expired_pending_appointments(?, ?)",
      barangay_id,
      cutoff_time
    ])
    connection.execute(sanitized)
  end
  ```

---

### 2.4. PostgreSQL Database Triggers (`CREATE TRIGGER` + `CREATE FUNCTION`)
Added in [`db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb`](../db/migrate/20261101211500_add_advanced_sql_stored_procedures_and_triggers.rb) to create an immutable audit trail table `appointment_status_logs`.

- **Trigger Function & Trigger Definition:**
  ```sql
  CREATE OR REPLACE FUNCTION audit_appointment_status_transition()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
  BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
      INSERT INTO appointment_status_logs (
        appointment_id,
        old_status,
        new_status,
        changed_at,
        action_type
      ) VALUES (
        NEW.id,
        OLD.status,
        NEW.status,
        NOW(),
        'STATUS_CHANGE'
      );
    END IF;
    RETURN NEW;
  END;
  $$;

  CREATE TRIGGER trg_appointment_status_transition
  AFTER UPDATE OF status ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION audit_appointment_status_transition();
  ```
- **ActiveRecord Integration:** [`app/models/appointment_status_log.rb`](../app/models/appointment_status_log.rb) and `has_many :appointment_status_logs` in [`app/models/appointment.rb`](../app/models/appointment.rb).
- **Benefit:** Audits every status change at the database level even if updates occur through direct SQL, background workers, or migrations, preventing audit tampering.

---

### 2.5. Common Table Expressions (CTEs - `WITH ... AS`)
Implemented in [`app/models/health_program.rb`](../app/models/health_program.rb) to aggregate multi-tier program statistics (announcement counts, booking totals, status breakdowns) and compute completion rates in a single database pass.

- **CTE Query (`HealthProgram.program_performance_summary`):**
  ```sql
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
  ```
- **User Interface:** Loaded in [`app/controllers/admin/dashboard_controller.rb`](../app/controllers/admin/dashboard_controller.rb) and rendered in [`app/views/admin/dashboard/index.html.erb`](../app/views/admin/dashboard/index.html.erb) under **Health Program Operational Metrics (CTE Powered)** with visual completion rate bars.

---

### 2.6. Transactions (with Commit / Rollback)
Explicit database transactions with `ActiveRecord::Rollback` protect multi-record operations from partial writes:

1. **Follow-Up Consultation Creation ([`app/controllers/admin/appointments_controller.rb`](../app/controllers/admin/appointments_controller.rb)):**
   ```ruby
   def follow_up_check_up
     Appointment.transaction do
       @new_appointment = Appointment.new(follow_up_check_up_params)
       @new_appointment.barangay = current_tenant
       @new_appointment.announcement = @appointment.announcement
       @new_appointment.patient = @appointment.patient
       @new_appointment.follow_up = @appointment
       @appointment.flag_list.add("follow_up_check_up")

       if @new_appointment.save && @appointment.save
         flash.notice = "New follow up was successfully created."
       else
         error_msg = @new_appointment.errors.full_messages.presence || @appointment.errors.full_messages
         flash.alert = "New follow up was not created: #{error_msg.to_sentence}"
         raise ActiveRecord::Rollback
       end
     end
   end
   ```
2. **Atomic Approval & Capacity Waitlisting ([`app/controllers/admin/appointments_controller.rb`](../app/controllers/admin/appointments_controller.rb)):**
   ```ruby
   def flag_as_approved
     success = false
     Appointment.transaction do
       if @appointment.update(status: :approved, health_worker: current_user)
         if @appointment.announcement.appointment_full?
           @appointment.flag_list.add("waitlisted")
           unless @appointment.save
             flash.alert = "Appointment was not accepted: #{@appointment.errors.full_messages.to_sentence}"
             raise ActiveRecord::Rollback
           end
         end
         success = true
       else
         flash.alert = "Appointment was not accepted: #{@appointment.errors.full_messages.to_sentence}"
         raise ActiveRecord::Rollback
       end
     end

     if success
       flash.notice = "Appointment was successfully accepted."
       redirect_back fallback_location: admin_appointments_path
     else
       redirect_back fallback_location: admin_appointments_path, status: :unprocessable_entity
     end
   end
   ```
3. **Transaction Rollback via Callback:** [`User#prevent_super_admin_demotion`](../app/models/user.rb) issues `throw(:abort)` on demotion attempts, triggering an immediate database rollback.

---

### 2.7. Indexing and Query Optimization (Showing Performance Benefit)

#### Key Database Indexes:
- **Composite Unique Index on Full Name:** `index_users_on_full_name ON users(first_name, middle_name, last_name, suffix)`
- **Composite Unique Index on Barangay Slugs:** `index_barangays_on_region_and_province_and_city_and_slug`
- **Composite Unique Index on Subdivisions:** `index_subdivisions_on_name_and_barangay_id`
- **Composite Index on Pages:** `index_pages_on_barangay_id_and_section`
- **Single Unique Indexes:** `users(email)`, `users(phone_number)`, `users(public_uid)`, `announcements(public_uid)`, `appointments(public_uid)`
- **Foreign Key Indexing:** Every foreign key (`barangay_id`, `announcement_id`, `patient_id`, `health_worker_id`, `health_program_id`) is indexed.

#### Performance Benchmark Task:
Run the built-in benchmark task:
```bash
bin/rails sql:benchmark
```

#### Actual `EXPLAIN (ANALYZE, BUFFERS)` Output:
```text
================================================================================
  ADVANCED SQL BENCHMARK: INDEXING & QUERY OPTIMIZATION DEMONSTRATION
================================================================================
--- [1] Index Scan Benchmark: Composite Full Name Index ---
Index: index_users_on_full_name ON users(first_name, middle_name, last_name, suffix)
Index Scan using index_users_on_full_name on users  (cost=0.14..8.17 rows=1 width=104) (actual time=0.101..0.102 rows=1.00 loops=1)
  Index Cond: (((first_name)::text = 'Lao'::text) AND (middle_name IS NULL) AND ((last_name)::text = 'Admin'::text) AND (suffix IS NULL))
  Index Searches: 1
  Buffers: shared hit=2
Planning Time: 0.305 ms
Execution Time: 0.110 ms

--- [3] SQL View & Window Function Benchmark: appointment_reports ---
View: appointment_reports (uses ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...))
Subquery Scan on appointment_reports  (cost=24.63..24.66 rows=1 width=112) (actual time=0.158..0.161 rows=2.00 loops=1)
  ->  WindowAgg  (cost=24.59..24.61 rows=1 width=652) (actual time=0.157..0.159 rows=2.00 loops=1)
        Window: w1 AS (ORDER BY a.scheduled_at ROWS UNBOUNDED PRECEDING)
        ->  Index Scan using index_appointments_on_announcement_id on appointments a
Execution Time: 0.511 ms

--- [4] Common Table Expression (CTE) Benchmark: WITH ... AS ---
Method: HealthProgram.program_performance_summary(barangay_id)
GroupAggregate  (cost=23.68..29.27 rows=3 width=64) (actual time=0.064..0.066 rows=1.00 loops=1)
  ->  Bitmap Index Scan on index_health_programs_on_barangay_id
  ->  Bitmap Index Scan on index_announcements_on_barangay_id
  ->  Index Scan using index_appointments_on_barangay_id on appointments appt
Execution Time: 0.105 ms
================================================================================
```

---

## 3. How to Demonstrate for Assignment Defense

1. **View & Window Function:**
   - Navigate to any announcement with appointments as Barangay Admin:
     `http://lao.lvh.me:3000/admin/announcements/<announcement_id>/appointment_reports`
   - Point out the `row_num` sequence computed dynamically via `ROW_NUMBER() OVER (PARTITION BY announcement_id ORDER BY scheduled_at)` in `db/views/appointment_reports_v01.sql`.
2. **Common Table Expression (CTE):**
   - Navigate to the Barangay Admin Dashboard: `http://lao.lvh.me:3000/admin/dashboard`
   - Scroll to **Health Program Operational Metrics (CTE Powered)**, showing completion rates and program metrics calculated via `WITH program_base AS (...), program_metrics AS (...)`.
3. **Database Trigger:**
   - When an appointment's status is changed (e.g. from Pending to Approved or Completed), PostgreSQL trigger `trg_appointment_status_transition` writes an entry directly into `appointment_status_logs`.
   - Inspect in console: `AppointmentStatusLog.all`.
4. **Stored Procedure:**
   - Execute in Rails runner or psql: `Appointment.cancel_expired_pending_via_procedure(1)`.
   - Demonstrates `CALL cancel_expired_pending_appointments(?, ?)`.
5. **Transactions:**
   - Demonstrate `Admin::AppointmentsController#follow_up_check_up` and `flag_as_approved`, where all changes commit atomically or roll back cleanly with `raise ActiveRecord::Rollback`.
6. **Indexing Performance Benefit:**
   - Execute `bin/rails sql:benchmark` in terminal to display the live `EXPLAIN (ANALYZE, BUFFERS)` execution plans demonstrating index hits (`shared hit=2`, execution time ~`0.11 ms`).
