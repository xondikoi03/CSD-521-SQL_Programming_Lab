-- Hospital Management System: --

-- In a hospital, there are doctors working 
-- in different departments who treat many patients
-- based on appointments. Patients get admitted to 
-- hospital in a room based on health status. 
-- The rooms for patients can be of type ICU, specialroom, generalward.
-- (use of appropriate constraints is required)

CREATE DATABASE HMS_DB;
USE HMS_DB;

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
    patient_dob DATE NOT NULL
)

-- ROOM TABLE:
