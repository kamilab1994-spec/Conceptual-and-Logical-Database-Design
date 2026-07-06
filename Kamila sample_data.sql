-- CPU4-103 NHS Group Database: sample DML
USE nhs_group_db;

INSERT INTO specialties (specialty_name) VALUES
('Cardiology'),('General Practice'),('Dermatology'),('Neurology'),('Paediatrics'),
('Orthopaedics'),('Respiratory Medicine'),('Endocrinology'),('Gastroenterology'),('Mental Health');

INSERT INTO clinics (clinic_name, clinic_address, phone) VALUES
('Clinic A','10 Main St, London','02070000001'),('Clinic B','22 River Rd, London','02070000002'),
('Clinic C','84 Park Lane, Manchester','01610000003'),('Clinic D','41 King St, Leeds','01130000004'),
('Clinic E','7 Hospital Way, Bristol','01170000005'),('Clinic F','16 Queens Rd, Birmingham','01210000006'),
('Clinic G','3 Station Rd, Liverpool','01510000007'),('Clinic H','93 Green Ave, Oxford','01865000008'),
('Clinic I','55 High St, York','01904000009'),('Clinic J','9 Bridge Rd, Cambridge','01223000010');

INSERT INTO doctors (specialty_id, clinic_id, first_name, last_name, email, phone) VALUES
(1,1,'Helen','Adams','helen.adams@nhs.example','07100000001'),(2,2,'Peter','Brown','peter.brown@nhs.example','07100000002'),
(3,3,'Sara','Patel','sara.patel@nhs.example','07100000003'),(4,4,'Omar','Khan','omar.khan@nhs.example','07100000004'),
(5,5,'Emily','Evans','emily.evans@nhs.example','07100000005'),(6,6,'James','Wilson','james.wilson@nhs.example','07100000006'),
(7,7,'Grace','Taylor','grace.taylor@nhs.example','07100000007'),(8,8,'Noah','Martin','noah.martin@nhs.example','07100000008'),
(9,9,'Chloe','Lewis','chloe.lewis@nhs.example','07100000009'),(10,10,'Liam','Walker','liam.walker@nhs.example','07100000010');

INSERT INTO patients (nhs_number, first_name, last_name, dob, address, phone, email, password_hash) VALUES
('NHS000001','John','Smith','1980-04-12','123 Hill Rd','07900000001','john.smith@example.com',SHA2('TempPass001!',256)),
('NHS000002','Mary','Jones','1975-09-21','456 Lake Ave','07900000002','mary.jones@example.com',SHA2('TempPass002!',256)),
('NHS000003','Aisha','Ali','1992-02-05','4 Market St','07900000003','aisha.ali@example.com',SHA2('TempPass003!',256)),
('NHS000004','Robert','Green','1968-12-19','91 Church Rd','07900000004','robert.green@example.com',SHA2('TempPass004!',256)),
('NHS000005','Priya','Shah','1988-07-30','8 Orchard Way','07900000005','priya.shah@example.com',SHA2('TempPass005!',256)),
('NHS000006','David','White','2001-01-11','71 Mill Lane','07900000006','david.white@example.com',SHA2('TempPass006!',256)),
('NHS000007','Fatima','Hussain','1996-06-15','29 North Rd','07900000007','fatima.hussain@example.com',SHA2('TempPass007!',256)),
('NHS000008','George','Hall','1959-10-02','18 West St','07900000008','george.hall@example.com',SHA2('TempPass008!',256)),
('NHS000009','Olivia','Young','2015-03-27','65 East Ave','07900000009','olivia.young@example.com',SHA2('TempPass009!',256)),
('NHS000010','Daniel','King','1983-11-09','37 South Rd','07900000010','daniel.king@example.com',SHA2('TempPass010!',256));

INSERT INTO medications (medication_name, strength, form) VALUES
('Aspirin','75mg','tablet'),('Bisoprolol','2.5mg','tablet'),('Paracetamol','500mg','tablet'),('Amoxicillin','500mg','capsule'),
('Salbutamol','100mcg','inhaler'),('Metformin','500mg','tablet'),('Omeprazole','20mg','capsule'),('Ibuprofen','200mg','tablet'),
('Cetirizine','10mg','tablet'),('Sertraline','50mg','tablet');

INSERT INTO appointments (patient_id, doctor_id, clinic_id, appointment_date, appointment_time, status, notes) VALUES
(1,1,1,'2024-05-01','10:00:00','Completed','Follow-up in 2 weeks'),
(2,2,2,'2024-05-03','09:00:00','Completed','First visit'),
(1,1,1,'2024-05-10','11:30:00','Completed','Blood pressure check'),
(3,3,3,'2024-05-12','14:00:00','Completed','Skin rash review'),
(4,4,4,'2024-05-13','10:30:00','Booked','Neurology assessment'),
(5,5,5,'2024-05-14','13:15:00','Booked','Child health consultation'),
(6,6,6,'2024-05-15','08:45:00','Cancelled','Knee pain appointment'),
(7,7,7,'2024-05-16','15:20:00','Booked','Asthma review'),
(8,8,8,'2024-05-17','16:10:00','Booked','Diabetes review'),
(9,9,9,'2024-05-18','09:40:00','Booked','Stomach pain'),
(10,10,10,'2024-05-19','12:00:00','Booked','Mental health support'),
(2,2,2,'2024-05-20','10:15:00','Booked','Medication review');

INSERT INTO prescriptions (appointment_id, patient_id, doctor_id, medication_id, dosage_instruction, start_date, end_date) VALUES
(1,1,1,1,'One tablet daily','2024-05-01','2024-08-01'),
(1,1,1,2,'One tablet each morning','2024-05-01','2024-08-01'),
(2,2,2,3,'Two tablets up to four times daily if required','2024-05-03','2024-05-10'),
(3,1,1,1,'Continue one tablet daily','2024-05-10','2024-08-10'),
(4,3,3,9,'One tablet daily for allergy symptoms','2024-05-12','2024-06-12'),
(5,4,4,8,'One tablet up to three times daily with food','2024-05-13','2024-05-20'),
(6,5,5,4,'One capsule three times daily','2024-05-14','2024-05-21'),
(7,6,6,8,'One tablet as needed for pain','2024-05-15','2024-05-22'),
(8,7,7,5,'Two puffs when breathless','2024-05-16',NULL),
(9,8,8,6,'One tablet twice daily with meals','2024-05-17',NULL),
(10,9,9,7,'One capsule daily before food','2024-05-18','2024-06-18'),
(11,10,10,10,'One tablet daily','2024-05-19',NULL);

INSERT INTO medical_records (appointment_id, patient_id, doctor_id, diagnosis, treatment_plan, record_hash) VALUES
(1,1,1,'Hypertension review','Continue aspirin and beta blocker; return in two weeks',SHA2('1|Hypertension review|Continue aspirin and beta blocker',256)),
(2,2,2,'Minor viral illness','Symptomatic relief and safety-netting advice',SHA2('2|Minor viral illness|Symptomatic relief',256)),
(3,1,1,'Blood pressure check','Continue monitoring and lifestyle advice',SHA2('3|Blood pressure check|Continue monitoring',256)),
(4,3,3,'Allergic rash','Antihistamine and review if symptoms persist',SHA2('4|Allergic rash|Antihistamine',256));
