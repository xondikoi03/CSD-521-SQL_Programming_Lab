-- Hospital Management System: --

-- In a hospital, there are doctors working 
-- in different departments who treat many patients
-- based on appointments. Patients get admitted to 
-- hospital in a room based on health status. 
-- The rooms for patients can be of type ICU, specialroom, generalward.
-- (use of appropriate constraints is required)

CREATE DATABASE HMS_DB;
USE HMS_DB;

-- DROP TABLES IF THEY EXIST:
DROP TABLE IF EXISTS Admission;
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Department;

-- DEPARTMENT TABLE:
CREATE TABLE Department(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    dept_head VARCHAR(50) NOT NULL
)

-- DOCTOR TABLE:
CREATE TABLE Doctor(
    doc_id INT PRIMARY KEY,
    doc_name VARCHAR(50) NOT NULL,
    doc_email VARCHAR(50) NOT NULL UNIQUE,
    doc_phone VARCHAR(15) NOT NULL UNIQUE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
)

-- PATIENT TABLE:
CREATE TABLE Patient(
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50) NOT NULL,
    patient_email VARCHAR(50) NOT NULL UNIQUE,
    patient_phone VARCHAR(15) NOT NULL UNIQUE,
    patient_address VARCHAR(100) NOT NULL,
    patient_gender VARCHAR(10),
    patient_health_status VARCHAR(255) DEFAULT 'stable',
    CONSTRAINT chk_patient_gender
        CHECK (patient_gender IN ('male', 'female', 'other')),
    patient_blood_group VARCHAR(5)
    CONSTRAINT chk_patient_blood_group
        CHECK (patient_blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    patient_dob DATE NOT NULL
)

-- ROOM TABLE:
CREATE TABLE Room(
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(20) 
    CONSTRAINT chk_room_type 
        CHECK (room_type IN ('ICU', 'specialroom', 'generalward')),
    room_status VARCHAR(20)
    CONSTRAINT chk_room_status
        CHECK (room_status IN ('available', 'occupied'))
)

-- APPOINTMENT TABLE:
CREATE TABLE Appointment(
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE, 
    doc_id INT,
    FOREIGN KEY (doc_id) REFERENCES Doctor(doc_id) ON DELETE RESTRICT, 
    appointment_datetime DATETIME NOT NULL,
    appointment_status VARCHAR(20),
    CONSTRAINT chk_appointment_status
        CHECK (appointment_status IN ('scheduled', 'completed', 'cancelled'))
)

-- ADMISSION TABLE:
CREATE TABLE Admission(
    admission_id INT PRIMARY KEY,
    patient_id INT,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    room_id INT,
    FOREIGN KEY (room_id) REFERENCES Room(room_id) ON DELETE RESTRICT,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_status VARCHAR(20)
    CONSTRAINT chk_admission_status
        CHECK (admission_status IN ('admitted', 'discharged', 'transferred'))
)

-- INSERT SAMPLE DATA INTO DEPARTMENT TABLE:
INSERT INTO Department(dept_id, dept_name, dept_head) VALUES
(1, 'Cardiology', 'Dr. Shankar Tiwari'),
(2, 'Neurology', 'Dr. Sunita Sharma'),
(3, 'Orthopedics', 'Dr. Phillips Williams'),
(4, 'Pediatrics', 'Dr. Anjali Mehta'),
(5, 'Oncology', 'Dr. Rajesh Kumar');

-- INSERT SAMPLE DATA INTO DOCTOR TABLE:
INSERT INTO Doctor(doc_id, doc_name, doc_email, doc_phone, dept_id) VALUES
(1, 'Dr. Aarti Singh', 'aarti.singh@gmail.com', '123-456-7890', 1),
(2, 'Dr. Ravi Patel', 'ravi.patel@gmail.com', '234-567-8901', 2),
(3, 'Dr. Priya Sharma', 'priya.sharma@gmail.com', '345-678-9012', 3),
(4, 'Dr. Anil Kumar', 'anil.kumar@gmail.com', '456-789-0123', 4),
(5, 'Dr. Meera Joshi', 'meera.joshi@gmail.com', '567-890-1234', 5);

-- INSERT SAMPLE DATA INTO PATIENT TABLE:
INSERT INTO Patient(patient_id, patient_name, patient_email, patient_phone, patient_address, patient_gender, patient_health_status, patient_blood_group, patient_dob) VALUES
(1, 'Rahul Verma', 'rahul.verma@gmail.com', '123-456-7890', 'Shivaji Nagar, Pune', 'male', 'stable', 'O+', '1990-01-01'),
(2, 'Priya Sharma', 'priya.sharma@gmail.com', '234-567-8901', 'MG Road, Bangalore', 'female', 'stable', 'A+', '1985-05-15'),
(3, 'Raj Kumar', 'raj.kumar@gmail.com', '345-678-9012', 'DLF Place, Gurgaon', 'male', 'improving', 'B-', '1992-08-20'),
(4, 'Sneha Gupta', 'sneha.gupta@gmail.com', '456-789-0123', 'Indiranagar, Bangalore', 'female', 'stable', 'AB+', '1988-12-10'),
(5, 'Vikram Singh', 'vikram.singh@gmail.com', '567-890-1234', 'Sector 12, Noida', 'male', 'stable', 'O-', '1995-03-25'),
(6, 'Anjali Mehta', 'anjali.mehta@gmail.com', '678-901-2345', 'Sector 12, Noida', 'female', 'stable', 'A-', '1990-06-30');

-- INSERT SAMPLE DATA INTO ROOM TABLE:
INSERT INTO Room(room_id, room_number, room_type, room_status) VALUES
(1, '101', 'ICU', 'available'),
(2, '102', 'specialroom', 'occupied'),
(3, '103', 'generalward', 'available'),
(4, '104', 'ICU', 'occupied'),
(5, '105', 'specialroom', 'available'),
(6, '106', 'generalward', 'available');

-- INSERT SAMPLE DATA INTO APPOINTMENT TABLE:
INSERT INTO Appointment(appointment_id, patient_id, doc_id, appointment_datetime, appointment_status) VALUES
(1, 1, 1, '2026-06-01 10:00:00', 'scheduled'),
(2, 2, 2, '2026-06-02 11:00:00', 'completed'),
(3, 3, 3, '2026-06-03 12:00:00', 'cancelled'),
(4, 4, 4, '2026-06-04 13:00:00', 'scheduled'),
(5, 5, 5, '2026-06-05 14:00:00', 'completed'),
(6, 6, 1, '2026-06-06 15:00:00', 'scheduled');  

-- INSERT SAMPLE DATA INTO ADMISSION TABLE:
INSERT INTO Admission(admission_id, patient_id, room_id, admission_date, discharge_date, admission_status) VALUES
(1, 1, 1, '2026-06-01', NULL, 'admitted'),
(2, 2, 2, '2026-06-02', '2026-06-05', 'discharged'),
(3, 3, 3, '2026-06-03', NULL, 'admitted'),
(4, 4, 4, '2026-06-04', NULL, 'admitted'),
(5, 5, 5, '2026-06-05', NULL, 'admitted'),
(6, 6, 6, '2026-06-06', '2026-06-10', 'discharged');

-- DISPLAY TABLES:
SELECT * FROM Admission;
