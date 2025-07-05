-- Create the database
CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- Users table (for authentication)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('patient', 'doctor', 'nurse', 'admin') NOT NULL,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    INDEX idx_role (role),
    INDEX idx_status (status)
);

-- Patients table
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    address TEXT,
    phone VARCHAR(20),
    emergency_contact VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    insurance_provider VARCHAR(100),
    insurance_policy_number VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_name (first_name, last_name),
    INDEX idx_dob (dob)
);

-- Staff table (base for all staff)
CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    department ENUM('cardiology', 'neurology', 'pediatrics', 'surgery', 'radiology', 'pharmacy', 'administration') NOT NULL,
    position ENUM('doctor', 'nurse', 'technician', 'administrator', 'other') NOT NULL,
    status ENUM('active', 'on_leave', 'terminated') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_department (department),
    INDEX idx_position (position)
);

-- Doctors table (extends Staff)
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT UNIQUE,
    specialization VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    consultation_fee DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE CASCADE,
    INDEX idx_specialization (specialization)
);

-- Appointments table
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    duration_minutes INT DEFAULT 30,
    status ENUM('scheduled', 'completed', 'cancelled', 'no_show') DEFAULT 'scheduled',
    reason VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    INDEX idx_appointment_date (appointment_date),
    INDEX idx_status (status)
);

-- MedicalRecords table
CREATE TABLE MedicalRecords (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATETIME NOT NULL,
    diagnosis TEXT,
    treatment TEXT,
    follow_up_date DATE,
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    INDEX idx_visit_date (visit_date)
);

-- Prescriptions table
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    refills INT DEFAULT 0,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    FOREIGN KEY (record_id) REFERENCES MedicalRecords(record_id) ON DELETE CASCADE,
    INDEX idx_medication (medication_name)
);

-- Billing table
CREATE TABLE Billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    total_amount DECIMAL(10, 2) NOT NULL,
    paid_amount DECIMAL(10, 2) DEFAULT 0.00,
    balance DECIMAL(10, 2) GENERATED ALWAYS AS (total_amount - paid_amount) STORED,
    due_date DATE,
    status ENUM('pending', 'partially_paid', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_date DATETIME,
    payment_method ENUM('cash', 'credit_card', 'insurance', 'bank_transfer', 'other'),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);

-- Inventory table
CREATE TABLE Inventory (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category ENUM('medicine', 'equipment', 'supplies') NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    unit_of_measure VARCHAR(20) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    supplier VARCHAR(100),
    expiry_date DATE,
    reorder_level INT DEFAULT 10,
    last_restocked DATE,
    INDEX idx_category (category),
    INDEX idx_expiry (expiry_date)
);

-- Notifications table
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('appointment', 'billing', 'prescription', 'system', 'other') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, is_read),
    INDEX idx_created_at (created_at)
);