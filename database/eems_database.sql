-- =====================================================
-- EEMS (Employee Expense Management System) Database
-- PostgreSQL Schema with Inheritance Structure
-- =====================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS MEDICAL_CLAIM CASCADE;
DROP TABLE IF EXISTS TRAVEL_CLAIM CASCADE;
DROP TABLE IF EXISTS OVERTIME_CLAIM CASCADE;
DROP TABLE IF EXISTS SUBMISSION CASCADE;
DROP TABLE IF EXISTS EMPLOYEE CASCADE;
DROP TABLE IF EXISTS DEPARTMENT CASCADE;

-- =====================================================
-- 1. DEPARTMENT TABLE
-- =====================================================
CREATE TABLE DEPARTMENT (
    DEPTID VARCHAR(10) PRIMARY KEY,
    DEPTNAME VARCHAR(100) NOT NULL
);

-- Insert sample departments
INSERT INTO DEPARTMENT (DEPTID, DEPTNAME) VALUES
('D01', 'Production'),
('D02', 'Finance'),
('D03', 'Operation'),
('D04', 'Marketing');

-- =====================================================
-- 2. EMPLOYEE TABLE
-- =====================================================
CREATE TABLE EMPLOYEE (
    EMPLOYEEID VARCHAR(20) PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(100) UNIQUE NOT NULL,
    PASSWORD VARCHAR(100) NOT NULL,
    PHONE VARCHAR(20),
    ROLE VARCHAR(20) NOT NULL CHECK (ROLE IN ('Employee', 'Manager')),
    DEPTID VARCHAR(10),
    CONSTRAINT FK_EMPLOYEE_DEPT FOREIGN KEY (DEPTID) REFERENCES DEPARTMENT(DEPTID)
);

-- Insert sample employees
INSERT INTO EMPLOYEE (EMPLOYEEID, NAME, EMAIL, PASSWORD, PHONE, ROLE, DEPTID) VALUES
-- Managers
('M001', 'Ahmad bin Ali', 'ahmad.ali@eems.com', 'password123', '012-3456789', 'Manager', 'D01'),
('M002', 'Siti Nurhaliza', 'siti.nur@eems.com', 'password123', '012-9876543', 'Manager', 'D02'),
('M003', 'Lee Wei Ming', 'lee.wei@eems.com', 'password123', '013-1234567', 'Manager', 'D03'),
('M004', 'Raj Kumar', 'raj.kumar@eems.com', 'password123', '014-7654321', 'Manager', 'D04'),

-- Employees in Production (D01)
('E001', 'Nurul Aina', 'nurul.aina@eems.com', 'password123', '011-2345678', 'Employee', 'D01'),
('E002', 'Muhammad Hafiz', 'hafiz.m@eems.com', 'password123', '012-3456780', 'Employee', 'D01'),
('E003', 'Tan Mei Ling', 'tan.mei@eems.com', 'password123', '013-4567890', 'Employee', 'D01'),

-- Employees in Finance (D02)
('E004', 'Wong Kar Wai', 'wong.kar@eems.com', 'password123', '014-5678901', 'Employee', 'D02'),
('E005', 'Fatimah Zahra', 'fatimah.z@eems.com', 'password123', '015-6789012', 'Employee', 'D02'),

-- Employees in Operation (D03)
('E006', 'Kumar Rajan', 'kumar.r@eems.com', 'password123', '016-7890123', 'Employee', 'D03'),
('E007', 'Lim Siew Hui', 'lim.siew@eems.com', 'password123', '017-8901234', 'Employee', 'D03'),

-- Employees in Marketing (D04)
('E008', 'Aziz Rahman', 'aziz.rahman@eems.com', 'password123', '018-9012345', 'Employee', 'D04'),
('E009', 'Chen Li Na', 'chen.li@eems.com', 'password123', '019-0123456', 'Employee', 'D04');

-- =====================================================
-- 3. SUBMISSION TABLE (Parent Table)
-- =====================================================
-- Contains common fields for all claim types
CREATE TABLE SUBMISSION (
    SUBMISSIONID SERIAL PRIMARY KEY,
    EMPLOYEEID VARCHAR(20) NOT NULL,
    CLAIMTYPE VARCHAR(50) NOT NULL CHECK (CLAIMTYPE IN ('Medical', 'Travel', 'Overtime')),
    SUBMISSIONDATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CLAIM_DESC TEXT,
    STATUS VARCHAR(20) NOT NULL CHECK (STATUS IN ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED')),
    AMOUNT DECIMAL(10,2) NOT NULL,
    DOCUMENT_PATH VARCHAR(255),
    
    CONSTRAINT FK_SUBMISSION_EMP FOREIGN KEY (EMPLOYEEID) REFERENCES EMPLOYEE(EMPLOYEEID)
);

-- =====================================================
-- 4. MEDICAL_CLAIM TABLE (Child Table)
-- =====================================================
-- Contains Medical-specific fields only
CREATE TABLE MEDICAL_CLAIM (
    SUBMISSIONID INTEGER PRIMARY KEY,
    CLINICNAME VARCHAR(100) NOT NULL,
    MRNDOCTOR VARCHAR(50) NOT NULL,
    DIAGNOSIS VARCHAR(100) NOT NULL,
    
    CONSTRAINT FK_MEDICAL_SUBMISSION FOREIGN KEY (SUBMISSIONID) REFERENCES SUBMISSION(SUBMISSIONID) ON DELETE CASCADE
);

-- =====================================================
-- 5. TRAVEL_CLAIM TABLE (Child Table)
-- =====================================================
-- Contains Travel-specific fields only
CREATE TABLE TRAVEL_CLAIM (
    SUBMISSIONID INTEGER PRIMARY KEY,
    DEPARTUREDEST VARCHAR(100) NOT NULL,
    ARRIVALDEST VARCHAR(100) NOT NULL,
    MILEAGE DECIMAL(10,2) NOT NULL,
    RATEPERKM DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT FK_TRAVEL_SUBMISSION FOREIGN KEY (SUBMISSIONID) REFERENCES SUBMISSION(SUBMISSIONID) ON DELETE CASCADE
);

-- =====================================================
-- 6. OVERTIME_CLAIM TABLE (Child Table)
-- =====================================================
-- Contains Overtime-specific fields only
CREATE TABLE OVERTIME_CLAIM (
    SUBMISSIONID INTEGER PRIMARY KEY,
    HOURS INTEGER NOT NULL,
    STARTTIME TIMESTAMP NOT NULL,
    ENDTIME TIMESTAMP NOT NULL,
    RATEPERHOURS DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT FK_OVERTIME_SUBMISSION FOREIGN KEY (SUBMISSIONID) REFERENCES SUBMISSION(SUBMISSIONID) ON DELETE CASCADE
);

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Medical Claims
-- First insert into SUBMISSION, then into MEDICAL_CLAIM
INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E001', 'Medical', '2026-01-15 10:30:00', 'Flu treatment and medication', 'PENDING', 85.50);
INSERT INTO MEDICAL_CLAIM (SUBMISSIONID, CLINICNAME, MRNDOCTOR, DIAGNOSIS) VALUES
(currval('submission_submissionid_seq'), 'Klinik Kesihatan Ayer Keroh', 'DR12345', 'Flu');

INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E004', 'Medical', '2026-01-18 14:20:00', 'Dental checkup and cleaning', 'APPROVED', 150.00);
INSERT INTO MEDICAL_CLAIM (SUBMISSIONID, CLINICNAME, MRNDOCTOR, DIAGNOSIS) VALUES
(currval('submission_submissionid_seq'), 'Dental Care Clinic', 'DR67890', 'Dental');

INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E006', 'Medical', '2026-01-10 09:15:00', 'Fever consultation', 'REJECTED', 60.00);
INSERT INTO MEDICAL_CLAIM (SUBMISSIONID, CLINICNAME, MRNDOCTOR, DIAGNOSIS) VALUES
(currval('submission_submissionid_seq'), 'Poliklinik Melaka', 'DR11223', 'Fever');

-- Travel Claims
INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E002', 'Travel', '2026-01-16 11:00:00', 'Client meeting in KL', 'PENDING', 77.00);
INSERT INTO TRAVEL_CLAIM (SUBMISSIONID, DEPARTUREDEST, ARRIVALDEST, MILEAGE, RATEPERKM) VALUES
(currval('submission_submissionid_seq'), 'Ayer Keroh', 'Kuala Lumpur', 140.00, 0.55);

INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E005', 'Travel', '2026-01-19 16:45:00', 'Bank visit for company matters', 'PENDING', 35.00);
INSERT INTO TRAVEL_CLAIM (SUBMISSIONID, DEPARTUREDEST, ARRIVALDEST, MILEAGE, RATEPERKM) VALUES
(currval('submission_submissionid_seq'), 'Ayer Keroh', 'Selangor', 50.00, 0.70);

INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E008', 'Travel', '2026-01-12 13:30:00', 'Marketing event in Johor', 'APPROVED', 112.50);
INSERT INTO TRAVEL_CLAIM (SUBMISSIONID, DEPARTUREDEST, ARRIVALDEST, MILEAGE, RATEPERKM) VALUES
(currval('submission_submissionid_seq'), 'Ayer Keroh', 'Johor', 250.00, 0.45);

-- Overtime Claims
INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E003', 'Overtime', '2026-01-17 18:00:00', 'Project deadline work', 'PENDING', 60.00);
INSERT INTO OVERTIME_CLAIM (SUBMISSIONID, HOURS, STARTTIME, ENDTIME, RATEPERHOURS) VALUES
(currval('submission_submissionid_seq'), 2, '2026-01-17 18:00:00', '2026-01-17 20:00:00', 15.00);

INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E007', 'Overtime', '2026-01-14 17:30:00', 'System maintenance', 'APPROVED', 120.00);
INSERT INTO OVERTIME_CLAIM (SUBMISSIONID, HOURS, STARTTIME, ENDTIME, RATEPERHOURS) VALUES
(currval('submission_submissionid_seq'), 4, '2026-01-14 18:00:00', '2026-01-14 22:00:00', 15.00);

INSERT INTO SUBMISSION (EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT) VALUES
('E009', 'Overtime', '2026-01-11 19:00:00', 'Campaign preparation', 'DRAFT', 45.00);
INSERT INTO OVERTIME_CLAIM (SUBMISSIONID, HOURS, STARTTIME, ENDTIME, RATEPERHOURS) VALUES
(currval('submission_submissionid_seq'), 3, '2026-01-11 18:00:00', '2026-01-11 21:00:00', 15.00);

-- =====================================================
-- USEFUL QUERIES FOR INHERITANCE STRUCTURE
-- =====================================================

-- View all Medical claims with full details
-- SELECT s.SUBMISSIONID, s.EMPLOYEEID, e.NAME, s.SUBMISSIONDATE, s.STATUS, s.AMOUNT,
--        m.CLINICNAME, m.MRNDOCTOR, m.DIAGNOSIS
-- FROM SUBMISSION s
-- JOIN MEDICAL_CLAIM m ON s.SUBMISSIONID = m.SUBMISSIONID
-- JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID
-- ORDER BY s.SUBMISSIONDATE DESC;

-- View all Travel claims with full details
-- SELECT s.SUBMISSIONID, s.EMPLOYEEID, e.NAME, s.SUBMISSIONDATE, s.STATUS, s.AMOUNT,
--        t.DEPARTUREDEST, t.ARRIVALDEST, t.MILEAGE, t.RATEPERKM
-- FROM SUBMISSION s
-- JOIN TRAVEL_CLAIM t ON s.SUBMISSIONID = t.SUBMISSIONID
-- JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID
-- ORDER BY s.SUBMISSIONDATE DESC;

-- View all Overtime claims with full details
-- SELECT s.SUBMISSIONID, s.EMPLOYEEID, e.NAME, s.SUBMISSIONDATE, s.STATUS, s.AMOUNT,
--        o.HOURS, o.STARTTIME, o.ENDTIME, o.RATEPERHOURS
-- FROM SUBMISSION s
-- JOIN OVERTIME_CLAIM o ON s.SUBMISSIONID = o.SUBMISSIONID
-- JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID
-- ORDER BY s.SUBMISSIONDATE DESC;

-- View ALL claims (union of all types)
-- SELECT s.SUBMISSIONID, s.EMPLOYEEID, e.NAME, s.CLAIMTYPE, s.SUBMISSIONDATE, s.STATUS, s.AMOUNT
-- FROM SUBMISSION s
-- JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID
-- ORDER BY s.SUBMISSIONDATE DESC;

-- =====================================================
-- DATABASE SETUP COMPLETE
-- =====================================================
-- Structure: Inheritance pattern with parent-child tables
-- Total Tables: 6 (DEPARTMENT, EMPLOYEE, SUBMISSION, MEDICAL_CLAIM, TRAVEL_CLAIM, OVERTIME_CLAIM)
-- Total Claims: 9 (3 Medical + 3 Travel + 3 Overtime)
-- =====================================================
