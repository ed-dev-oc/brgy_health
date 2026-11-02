class AddAdvancedSqlStoredProceduresAndTriggers < ActiveRecord::Migration[8.0]
  def up
    # 1. Create table for tracking appointment status transitions via Trigger
    create_table :appointment_status_logs do |t|
      t.bigint :appointment_id, null: false
      t.integer :old_status
      t.integer :new_status
      t.datetime :changed_at, null: false
      t.string :action_type, default: "UPDATE"
      t.index :appointment_id
      t.index :changed_at
    end

    add_foreign_key :appointment_status_logs, :appointments, column: :appointment_id, on_delete: :cascade

    # 2. Advanced SQL Technique: Database Trigger (Function + Trigger)
    execute <<-SQL
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

      DROP TRIGGER IF EXISTS trg_appointment_status_transition ON appointments;

      CREATE TRIGGER trg_appointment_status_transition
      AFTER UPDATE OF status ON appointments
      FOR EACH ROW
      EXECUTE FUNCTION audit_appointment_status_transition();
    SQL

    # 3. Advanced SQL Technique: Stored Procedure (CREATE PROCEDURE)
    execute <<-SQL
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
    SQL
  end

  def down
    execute <<-SQL
      DROP PROCEDURE IF EXISTS cancel_expired_pending_appointments(BIGINT, TIMESTAMP);
      DROP TRIGGER IF EXISTS trg_appointment_status_transition ON appointments;
      DROP FUNCTION IF EXISTS audit_appointment_status_transition();
    SQL

    drop_table :appointment_status_logs, if_exists: true
  end
end
