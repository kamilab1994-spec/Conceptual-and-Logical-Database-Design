-- Student 1 individual SQL evidence: advanced queries, procedure, trigger and transaction
USE nhs_group_db;

-- Q1: Aggregate function - number of appointments and completed appointments by clinic
SELECT c.clinic_name,
       COUNT(a.appointment_id) AS total_appointments,
       SUM(a.status = 'Completed') AS completed_appointments
FROM clinics c
LEFT JOIN appointments a ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_name
ORDER BY total_appointments DESC;

-- Q2: Multi-table JOIN - complete patient appointment and medication history
SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       a.appointment_date, a.appointment_time,
       CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
       s.specialty_name, m.medication_name, pr.dosage_instruction
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN specialties s ON d.specialty_id = s.specialty_id
LEFT JOIN prescriptions pr ON a.appointment_id = pr.appointment_id
LEFT JOIN medications m ON pr.medication_id = m.medication_id
ORDER BY p.patient_id, a.appointment_date;

-- Q3: LEFT JOIN - patients who have no completed appointment
SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       a.appointment_id, a.status
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id AND a.status = 'Completed'
WHERE a.appointment_id IS NULL;

-- Q4: MySQL full outer join equivalent using UNION
SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, a.appointment_id
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
UNION
SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, a.appointment_id
FROM patients p
RIGHT JOIN appointments a ON p.patient_id = a.patient_id;

-- Q5: Stored procedure - patient medication history
DROP PROCEDURE IF EXISTS GetPatientMedicationHistory;
DELIMITER //
CREATE PROCEDURE GetPatientMedicationHistory(IN in_patient_id INT)
BEGIN
    SELECT p.nhs_number, CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
           m.medication_name, m.strength, pr.dosage_instruction, pr.start_date, pr.end_date
    FROM patients p
    JOIN prescriptions pr ON p.patient_id = pr.patient_id
    JOIN medications m ON pr.medication_id = m.medication_id
    WHERE p.patient_id = in_patient_id
    ORDER BY pr.start_date DESC;
END //
DELIMITER ;
CALL GetPatientMedicationHistory(1);

-- Q6: Trigger - reject duplicate appointment slots before insert
DROP TRIGGER IF EXISTS trg_prevent_duplicate_doctor_slot;
DELIMITER //
CREATE TRIGGER trg_prevent_duplicate_doctor_slot
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM appointments
        WHERE doctor_id = NEW.doctor_id
          AND appointment_date = NEW.appointment_date
          AND appointment_time = NEW.appointment_time
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor already has an appointment at this time';
    END IF;
END //
DELIMITER ;

-- Q7: Transaction - safely complete appointment and create medical record
START TRANSACTION;
UPDATE appointments
SET status = 'Completed', notes = CONCAT(COALESCE(notes,''), ' | Completed by Student 1 transaction')
WHERE appointment_id = 5;
INSERT INTO medical_records (appointment_id, patient_id, doctor_id, diagnosis, treatment_plan, record_hash)
SELECT appointment_id, patient_id, doctor_id,
       'Neurology assessment completed',
       'Follow-up arranged and advice documented',
       SHA2(CONCAT(appointment_id, '|Neurology assessment completed|Follow-up arranged'), 256)
FROM appointments
WHERE appointment_id = 5
  AND NOT EXISTS (SELECT 1 FROM medical_records WHERE appointment_id = 5);
COMMIT;
