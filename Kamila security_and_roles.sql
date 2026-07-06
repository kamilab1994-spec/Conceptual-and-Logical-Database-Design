-- Individual security, protection and transaction scripts
USE nhs_group_db;

-- Remove old roles if they already exist in the development environment
DROP ROLE IF EXISTS 'nhs_admin', 'nhs_doctor', 'nhs_patient', 'nhs_receptionist';
CREATE ROLE 'nhs_admin', 'nhs_doctor', 'nhs_patient', 'nhs_receptionist';

-- Administrator: full control over the database
GRANT ALL PRIVILEGES ON nhs_group_db.* TO 'nhs_admin';

-- Doctor: read patient and appointment data; update clinical records and prescriptions
GRANT SELECT ON nhs_group_db.patients TO 'nhs_doctor';
GRANT SELECT, UPDATE ON nhs_group_db.appointments TO 'nhs_doctor';
GRANT SELECT, INSERT, UPDATE ON nhs_group_db.medical_records TO 'nhs_doctor';
GRANT SELECT, INSERT, UPDATE ON nhs_group_db.prescriptions TO 'nhs_doctor';
GRANT SELECT ON nhs_group_db.medications TO 'nhs_doctor';

-- Receptionist: manage bookings but no access to medical notes or password hashes
CREATE OR REPLACE VIEW vw_reception_appointments AS
SELECT a.appointment_id, p.patient_id, p.first_name, p.last_name, p.phone,
       d.doctor_id, d.first_name AS doctor_first_name, d.last_name AS doctor_last_name,
       c.clinic_name, a.appointment_date, a.appointment_time, a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN clinics c ON a.clinic_id = c.clinic_id;
GRANT SELECT, INSERT, UPDATE ON nhs_group_db.appointments TO 'nhs_receptionist';
GRANT SELECT ON nhs_group_db.vw_reception_appointments TO 'nhs_receptionist';

-- Patient: limited read access through a view, never direct access to all tables
CREATE OR REPLACE VIEW vw_patient_portal AS
SELECT p.patient_id, p.nhs_number, p.first_name, p.last_name,
       a.appointment_id, a.appointment_date, a.appointment_time, a.status,
       c.clinic_name, CONCAT(d.first_name, ' ', d.last_name) AS doctor_name
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN clinics c ON a.clinic_id = c.clinic_id;
GRANT SELECT ON nhs_group_db.vw_patient_portal TO 'nhs_patient';

-- Example user accounts for testing in MySQL Workbench; edit passwords before live use
DROP USER IF EXISTS 'admin_user'@'localhost', 'doctor_user'@'localhost', 'patient_user'@'localhost', 'reception_user'@'localhost';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'ChangeMe_Admin_001!';
CREATE USER 'doctor_user'@'localhost' IDENTIFIED BY 'ChangeMe_Doctor_001!';
CREATE USER 'patient_user'@'localhost' IDENTIFIED BY 'ChangeMe_Patient_001!';
CREATE USER 'reception_user'@'localhost' IDENTIFIED BY 'ChangeMe_Reception_001!';
GRANT 'nhs_admin' TO 'admin_user'@'localhost';
GRANT 'nhs_doctor' TO 'doctor_user'@'localhost';
GRANT 'nhs_patient' TO 'patient_user'@'localhost';
GRANT 'nhs_receptionist' TO 'reception_user'@'localhost';
SET DEFAULT ROLE ALL TO 'admin_user'@'localhost', 'doctor_user'@'localhost', 'patient_user'@'localhost', 'reception_user'@'localhost';

-- Protection technique: one-way password hashing for sensitive login fields
UPDATE patients
SET password_hash = SHA2(CONCAT(nhs_number, '|', 'temporary-reset-token'), 256)
WHERE patient_id BETWEEN 1 AND 10;

-- Secure coding note: use stored procedures/parameterised calls instead of string-concatenated SQL
-- Example: CALL BookAppointment(?, ?, ?, ?, ?, ?); from an application layer.
FLUSH PRIVILEGES;
