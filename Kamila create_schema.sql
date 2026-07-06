-- CPU4-103 NHS Group Database: schema / DDL
-- RDBMS: MySQL 8.x
DROP DATABASE IF EXISTS nhs_group_db;
CREATE DATABASE nhs_group_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE nhs_group_db;

CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE clinics (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL UNIQUE,
    clinic_address VARCHAR(200) NOT NULL,
    phone VARCHAR(30)
) ENGINE=InnoDB;

CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_id INT NOT NULL,
    clinic_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(30),
    CONSTRAINT fk_doctor_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id),
    CONSTRAINT fk_doctor_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
) ENGINE=InnoDB;

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    nhs_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(120) UNIQUE,
    password_hash CHAR(64) NOT NULL
) ENGINE=InnoDB;
DELIMITER //

CREATE TRIGGER trg_patients_dob_insert
BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
    IF NEW.dob >= CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Date of birth must be before today.';
    END IF;
END //

DELIMITER ;

CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_name VARCHAR(100) NOT NULL,
    strength VARCHAR(60),
    form VARCHAR(40),
    UNIQUE (medication_name, strength, form)
) ENGINE=InnoDB;

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Booked','Completed','Cancelled','No-show') NOT NULL DEFAULT 'Booked',
    notes VARCHAR(500),
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    CONSTRAINT fk_appt_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id),
    CONSTRAINT uq_doctor_slot UNIQUE (doctor_id, appointment_date, appointment_time)
) ENGINE=InnoDB;

CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage_instruction VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_presc_appt FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    CONSTRAINT fk_presc_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_presc_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    CONSTRAINT fk_presc_med FOREIGN KEY (medication_id) REFERENCES medications(medication_id),
    CONSTRAINT chk_presc_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis VARCHAR(200),
    treatment_plan VARCHAR(500),
    record_hash CHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_record_appt FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    CONSTRAINT fk_record_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_record_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(80) NOT NULL,
    action_type VARCHAR(30) NOT NULL,
    record_id INT NOT NULL,
    changed_by VARCHAR(80) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
DELIMITER //

CREATE TRIGGER audit_log_set_user
BEFORE INSERT ON audit_log
FOR EACH ROW
BEGIN
    IF NEW.changed_by IS NULL OR NEW.changed_by = '' THEN
        SET NEW.changed_by = CURRENT_USER();
    END IF;
END //

DELIMITER ;
