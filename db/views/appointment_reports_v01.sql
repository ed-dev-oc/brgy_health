SELECT 
  -- Window functions for sequencing
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
  
  -- Patient information (separate fields)
  patient.id AS patient_id,
  patient.first_name AS patient_first_name,
  patient.middle_name AS patient_middle_name,
  patient.last_name AS patient_last_name,
  patient.suffix AS patient_suffix,
  patient.email AS patient_email,
  patient.phone_number AS patient_phone_number,

  -- Health worker information (separate fields)
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
FROM 
  appointments a
LEFT JOIN users patient ON a.patient_id = patient.id
LEFT JOIN users health_worker ON a.health_worker_id = health_worker.id
LEFT JOIN barangays b ON a.barangay_id = b.id
LEFT JOIN announcements ann ON a.announcement_id = ann.id