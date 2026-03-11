DROP DATABASE IF EXISTS SmartCareDB;
CREATE DATABASE SmartCareDB;
USE SmartCareDB;

- =========================
-- 1) TABLES
-- =========================
DROP TABLE IF EXISTS Patients;

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10) NOT NULL
        CHECK (Gender IN ('Male', 'Female', 'Other')),
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(120) NOT NULL UNIQUE,
    Address VARCHAR(200) NOT NULL
);

DROP TABLE IF EXISTS Doctors;

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(80) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(120) NOT NULL UNIQUE,
    AvailabilityStatus VARCHAR(15) NOT NULL
        CONSTRAINT CK_Doctors_Availability
        CHECK (AvailabilityStatus IN ('Available','Unavailable'))
        DEFAULT 'Available'
);

DROP TABLE IF EXISTS Appointments;
GO

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,

    Status VARCHAR(15) NOT NULL
        CONSTRAINT CK_Appointments_Status
        CHECK (Status IN ('Scheduled','Completed','Cancelled','No-Show'))
        CONSTRAINT DF_Appointments_Status
        DEFAULT 'Scheduled',

    CONSTRAINT FK_Appointments_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Appointments_Doctors
        FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
        ON DELETE NO ACTION
);

DROP TABLE IF EXISTS VisitSummary;
GO

CREATE TABLE VisitSummary (
    VisitID INT PRIMARY KEY,
    AppointmentID INT NOT NULL UNIQUE,
    Symptoms VARCHAR(255) NOT NULL,
    Diagnosis VARCHAR(255) NOT NULL,
    Prescription VARCHAR(255) NULL,
    Notes VARCHAR(255) NULL,

    CONSTRAINT FK_VisitSummary_Appointments
        FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
        ON DELETE NO ACTION
);

- Helpful index (not required but good practice)
CREATE INDEX idx_appt_doctor_dt_time ON Appointments(DoctorID, AppointmentDate, AppointmentTime);

-- =========================
-- 2) TRIGGER (Prevent double-booking per doctor/date/time)
-- =========================
-- SQL Server trigger to prevent double-booking (same Doctor + Date + Time)
CREATE TRIGGER trg_prevent_double_booking
ON Appointments
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if any row being inserted conflicts with existing appointments
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Appointments a
          ON a.DoctorID = i.DoctorID
         AND a.AppointmentDate = i.AppointmentDate
         AND a.AppointmentTime = i.AppointmentTime
        WHERE a.Status <> 'Cancelled'
          AND i.Status <> 'Cancelled'
    )
    BEGIN
        RAISERROR('Double booking not allowed: Doctor already has an appointment at this date/time.', 16, 1);
        RETURN;
    END;

    -- If no conflict, insert the rows
    INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
    SELECT AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status
    FROM inserted;
END;


-- =========================
-- 3) INSERT DATA (30+ EACH TABLE)
-- =========================

-- ---- Patients (30) ----
INSERT INTO Patients (PatientID, FullName, DateOfBirth, Gender, Phone, Email, Address) VALUES
(1,'Aarav Patel','1996-03-12','Male','313-555-1001','aarav.patel@smartcare.com','Southfield, MI'),
(2,'Ananya Reddy','1998-07-21','Female','313-555-1002','ananya.reddy@smartcare.com','Detroit, MI'),
(3,'Vikram Sharma','1992-11-05','Male','313-555-1003','vikram.sharma@smartcare.com','Troy, MI'),
(4,'Meera Iyer','1995-01-14','Female','313-555-1004','meera.iyer@smartcare.com','Novi, MI'),
(5,'Rohan Gupta','1990-09-30','Male','313-555-1005','rohan.gupta@smartcare.com','Farmington Hills, MI'),
(6,'Sneha Nair','1997-05-18','Female','313-555-1006','sneha.nair@smartcare.com','Livonia, MI'),
(7,'Kiran Kumar','1994-08-09','Male','313-555-1007','kiran.kumar@smartcare.com','Royal Oak, MI'),
(8,'Priya Singh','1999-12-27','Female','313-555-1008','priya.singh@smartcare.com','Ferndale, MI'),
(9,'Arjun Menon','1993-02-03','Male','313-555-1009','arjun.menon@smartcare.com','Warren, MI'),
(10,'Divya Rao','1996-06-16','Female','313-555-1010','divya.rao@smartcare.com','Sterling Heights, MI'),
(11,'Neha Joshi','1991-04-25','Female','313-555-1011','neha.joshi@smartcare.com','Madison Heights, MI'),
(12,'Sanjay Verma','1989-10-10','Male','313-555-1012','sanjay.verma@smartcare.com','Clawson, MI'),
(13,'Pooja Kulkarni','1997-09-02','Female','313-555-1013','pooja.kulkarni@smartcare.com','Pontiac, MI'),
(14,'Aditya Jain','1995-12-19','Male','313-555-1014','aditya.jain@smartcare.com','Bloomfield Hills, MI'),
(15,'Ishita Kapoor','1998-03-07','Female','313-555-1015','ishita.kapoor@smartcare.com','Auburn Hills, MI'),
(16,'Rahul Bansal','1992-01-29','Male','313-555-1016','rahul.bansal@smartcare.com','Rochester, MI'),
(17,'Nikhil Chawla','1990-07-11','Male','313-555-1017','nikhil.chawla@smartcare.com','Dearborn, MI'),
(18,'Swati Mishra','1994-11-23','Female','313-555-1018','swati.mishra@smartcare.com','Allen Park, MI'),
(19,'Manish Yadav','1993-05-04','Male','313-555-1019','manish.yadav@smartcare.com','Taylor, MI'),
(20,'Kavya Pillai','1999-08-31','Female','313-555-1020','kavya.pillai@smartcare.com','Westland, MI'),
(21,'Suresh Naidu','1988-02-14','Male','313-555-1021','suresh.naidu@smartcare.com','Canton, MI'),
(22,'Lakshmi Devi','1991-06-08','Female','313-555-1022','lakshmi.devi@smartcare.com','Plymouth, MI'),
(23,'Harsha Vardhan','1996-10-26','Male','313-555-1023','harsha.vardhan@smartcare.com','Waterford, MI'),
(24,'Bhavana Das','1997-04-01','Female','313-555-1024','bhavana.das@smartcare.com','Redford, MI'),
(25,'Sai Teja','1995-09-17','Male','313-555-1025','sai.teja@smartcare.com','Inkster, MI'),
(26,'Anil Kumar','1987-12-05','Male','313-555-1026','anil.kumar@smartcare.com','Ypsilanti, MI'),
(27,'Jyothi S','1998-01-09','Female','313-555-1027','jyothi.s@smartcare.com','Ann Arbor, MI'),
(28,'Mohan Rao','1990-03-20','Male','313-555-1028','mohan.rao@smartcare.com','Hamtramck, MI'),
(29,'Shreya Bose','1996-07-30','Female','313-555-1029','shreya.bose@smartcare.com','Grosse Pointe, MI'),
(30,'Tarun Malhotra','1992-09-12','Male','313-555-1030','tarun.malhotra@smartcare.com','Oak Park, MI');

-- ---- Appointments (30) ----

USE smart1;
GO

-- Create Doctors rows 1..30 if missing (does not duplicate)
MERGE Doctors AS target
USING (VALUES
(1,'Dr. Olivia Carter','Family Medicine','248-555-2001','olivia.carter@smartcare.com','Available'),
(2,'Dr. Ethan Nguyen','Internal Medicine','248-555-2002','ethan.nguyen@smartcare.com','Available'),
(3,'Dr. Sophia Martinez','Pediatrics','248-555-2003','sophia.martinez@smartcare.com','Available'),
(4,'Dr. Liam Johnson','Dermatology','248-555-2004','liam.johnson@smartcare.com','Available'),
(5,'Dr. Ava Williams','Cardiology','248-555-2005','ava.williams@smartcare.com','Unavailable'),
(6,'Dr. Noah Brown','Orthopedics','248-555-2006','noah.brown@smartcare.com','Available'),
(7,'Dr. Mia Davis','Neurology','248-555-2007','mia.davis@smartcare.com','Available'),
(8,'Dr. Lucas Miller','Endocrinology','248-555-2008','lucas.miller@smartcare.com','Available'),
(9,'Dr. Isabella Wilson','Gynecology','248-555-2009','isabella.wilson@smartcare.com','Available'),
(10,'Dr. Mason Moore','ENT','248-555-2010','mason.moore@smartcare.com','Available'),

(11,'Dr. Harper Taylor','Psychiatry','248-555-2011','harper.taylor@smartcare.com','Unavailable'),
(12,'Dr. Elijah Anderson','Gastroenterology','248-555-2012','elijah.anderson@smartcare.com','Available'),
(13,'Dr. Amelia Thomas','Pulmonology','248-555-2013','amelia.thomas@smartcare.com','Available'),
(14,'Dr. James Jackson','Ophthalmology','248-555-2014','james.jackson@smartcare.com','Available'),
(15,'Dr. Charlotte White','Rheumatology','248-555-2015','charlotte.white@smartcare.com','Available'),
(16,'Dr. Benjamin Harris','Urology','248-555-2016','benjamin.harris@smartcare.com','Available'),
(17,'Dr. Evelyn Martin','Oncology','248-555-2017','evelyn.martin@smartcare.com','Unavailable'),
(18,'Dr. Henry Thompson','Nephrology','248-555-2018','henry.thompson@smartcare.com','Available'),
(19,'Dr. Abigail Garcia','Allergy & Immunology','248-555-2019','abigail.garcia@smartcare.com','Available'),
(20,'Dr. Daniel Rodriguez','Sports Medicine','248-555-2020','daniel.rodriguez@smartcare.com','Available'),

(21,'Dr. Emily Lewis','Family Medicine','248-555-2021','emily.lewis@smartcare.com','Available'),
(22,'Dr. Michael Lee','Internal Medicine','248-555-2022','michael.lee@smartcare.com','Available'),
(23,'Dr. Grace Walker','Pediatrics','248-555-2023','grace.walker@smartcare.com','Available'),
(24,'Dr. Sebastian Hall','Dermatology','248-555-2024','sebastian.hall@smartcare.com','Unavailable'),
(25,'Dr. Lily Allen','Cardiology','248-555-2025','lily.allen@smartcare.com','Available'),
(26,'Dr. Jack Young','Orthopedics','248-555-2026','jack.young@smartcare.com','Available'),
(27,'Dr. Chloe King','Neurology','248-555-2027','chloe.king@smartcare.com','Available'),
(28,'Dr. Owen Wright','Endocrinology','248-555-2028','owen.wright@smartcare.com','Available'),
(29,'Dr. Zoey Scott','Gynecology','248-555-2029','zoey.scott@smartcare.com','Available'),
(30,'Dr. Samuel Green','ENT','248-555-2030','samuel.green@smartcare.com','Available')
) AS src(DoctorID, FullName, Specialty, Phone, Email, AvailabilityStatus)
ON target.DoctorID = src.DoctorID
WHEN NOT MATCHED THEN
  INSERT (DoctorID, FullName, Specialty, Phone, Email, AvailabilityStatus)
  VALUES (src.DoctorID, src.FullName, src.Specialty, src.Phone, src.Email, src.AvailabilityStatus);

  -- ---- VisitSummary (30) ----
-- Note: AppointmentID is UNIQUE here, so one visit summary per appointment.
MERGE Appointments AS target
USING (VALUES
(1, 1, 1,'2025-12-18','09:00:00','Scheduled'),
(2, 2, 2,'2025-12-18','09:30:00','Scheduled'),
(3, 3, 3,'2025-12-18','10:00:00','Scheduled'),
(4, 4, 4,'2025-12-18','10:30:00','Scheduled'),
(5, 5, 5,'2025-12-18','11:00:00','Scheduled'),
(6, 6, 6,'2025-12-18','11:30:00','Scheduled'),
(7, 7, 7,'2025-12-18','13:00:00','Scheduled'),
(8, 8, 8,'2025-12-18','13:30:00','Scheduled'),
(9, 9, 9,'2025-12-18','14:00:00','Scheduled'),
(10,10,10,'2025-12-18','14:30:00','Scheduled'),

(11,11,11,'2025-12-19','09:00:00','Cancelled'),
(12,12,12,'2025-12-19','09:30:00','Scheduled'),
(13,13,13,'2025-12-19','10:00:00','Scheduled'),
(14,14,14,'2025-12-19','10:30:00','Scheduled'),
(15,15,15,'2025-12-19','11:00:00','Scheduled'),
(16,16,16,'2025-12-19','11:30:00','Scheduled'),
(17,17,17,'2025-12-19','13:00:00','Scheduled'),
(18,18,18,'2025-12-19','13:30:00','Scheduled'),
(19,19,19,'2025-12-19','14:00:00','Scheduled'),
(20,20,20,'2025-12-19','14:30:00','Scheduled'),

(21,21,21,'2025-12-20','09:00:00','Completed'),
(22,22,22,'2025-12-20','09:30:00','Completed'),
(23,23,23,'2025-12-20','10:00:00','Completed'),
(24,24,24,'2025-12-20','10:30:00','No-Show'),
(25,25,25,'2025-12-20','11:00:00','Completed'),
(26,26,26,'2025-12-20','11:30:00','Completed'),
(27,27,27,'2025-12-20','13:00:00','Completed'),
(28,28,28,'2025-12-20','13:30:00','Completed'),
(29,29,29,'2025-12-20','14:00:00','Completed'),
(30,30,30,'2025-12-20','14:30:00','Completed')
) AS src(AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
ON target.AppointmentID = src.AppointmentID
WHEN NOT MATCHED THEN
  INSERT (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
  VALUES (src.AppointmentID, src.PatientID, src.DoctorID, src.AppointmentDate, src.AppointmentTime, src.Status);

  - Note: AppointmentID is UNIQUE here, so one visit summary per appointment.
INSERT INTO VisitSummary (VisitID, AppointmentID, Symptoms, Diagnosis, Prescription, Notes) VALUES
(1, 1,'Fever, sore throat','Viral pharyngitis','Warm fluids, rest','Follow up if fever persists'),
(2, 2,'Fatigue, headache','Dehydration','Oral rehydration','Increase water intake'),
(3, 3,'Cough, mild wheeze','Acute bronchitis','Cough syrup PRN','No antibiotics needed'),
(4, 4,'Skin rash, itching','Contact dermatitis','Topical hydrocortisone','Avoid irritant products'),
(5, 5,'Chest discomfort','GERD suspected','PPI 14 days','Diet changes advised'),
(6, 6,'Knee pain after activity','Sprain','NSAID PRN','Rest + ice'),
(7, 7,'Migraine episodes','Migraine','Triptan PRN','Sleep hygiene'),
(8, 8,'Increased thirst','Prediabetes','Lifestyle plan','Recheck labs in 3 months'),
(9, 9,'Pelvic pain','Dysmenorrhea','NSAID','Track symptoms'),
(10,10,'Ear pain','Otitis media','Antibiotic course','Return if no improvement'),

(11,11,'Anxiety, sleep issues','Generalized anxiety','SSRI starter','Referral to therapy'),
(12,12,'Abdominal pain','Gastritis','PPI 10 days','Avoid spicy foods'),
(13,13,'Shortness of breath','Mild asthma','Inhaler','Trigger avoidance'),
(14,14,'Blurred vision','Dry eyes','Artificial tears','Screen breaks'),
(15,15,'Joint stiffness','Early arthritis','NSAID','Light exercise'),
(16,16,'Urinary frequency','UTI','Antibiotic course','Hydration'),
(17,17,'Unexplained weight loss','Further evaluation','Lab work','Oncology referral if needed'),
(18,18,'Swelling ankles','Fluid retention','Diuretic','Monitor BP'),
(19,19,'Sneezing, watery eyes','Seasonal allergies','Antihistamine','Limit allergens'),
(20,20,'Shoulder pain','Tendonitis','NSAID','Physio recommended'),

(21,21,'Sore throat','Strep ruled out','Pain reliever','Rest'),
(22,22,'High BP reading','Hypertension','ACE inhibitor','Monitor at home'),
(23,23,'Child fever','Viral fever','Paracetamol','Watch hydration'),
(24,24,'Acne flare','Acne vulgaris','Topical retinoid','Skincare routine'),
(25,25,'Palpitations','Arrhythmia eval','ECG ordered','Limit caffeine'),
(26,26,'Back pain','Muscle strain','NSAID','Stretching'),
(27,27,'Numbness','Neuropathy eval','B12 test','Follow up results'),
(28,28,'Thyroid symptoms','Hypothyroid','Levothyroxine','Recheck TSH'),
(29,29,'Irregular cycles','PCOS suspected','Metformin','Lifestyle counseling'),
(30,30,'Sinus congestion','Sinusitis','Decongestant','Steam inhalation');

-- =========================
-- 4) VIEW (Reporting page support)
-- =========================
DROP VIEW IF EXISTS vw_UpcomingAppointments;
GO

CREATE VIEW vw_UpcomingAppointments AS
SELECT
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status,
    p.PatientID,
    p.FullName AS PatientName,
    d.DoctorID,
    d.FullName AS DoctorName,
    d.Specialty
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d  ON a.DoctorID  = d.DoctorID
WHERE a.AppointmentDate >= CAST(GETDATE() AS date);

-- =========================
-- 5) TRANSACTION DEMO (START -> COMMIT / ROLLBACK)
-- =========================

-- Example COMMIT flow:
BEGIN TRAN;

INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
VALUES (31, 1, 2, '2025-12-21', '09:00:00', 'Scheduled');

INSERT INTO VisitSummary (VisitID, AppointmentID, Symptoms, Diagnosis, Prescription, Notes)
VALUES (31, 31, 'Follow-up check', 'Routine follow-up', NULL, 'Patient stable');

COMMIT;

-- Example ROLLBACK flow (uncomment to test):
BEGIN TRAN;

INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
VALUES (32, 2, 3, '2025-12-21', '09:00:00', 'Scheduled');  -- changed DoctorID to 3

ROLLBACK;

- =========================
-- 6) 3–5 MEANINGFUL JOIN QUERIES
-- =========================

-- Q1: Full appointment list with patient + doctor names
SELECT a.AppointmentID, a.AppointmentDate, a.AppointmentTime, a.Status,
       p.FullName AS PatientName,
       d.FullName AS DoctorName, d.Specialty
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d  ON a.DoctorID  = d.DoctorID
ORDER BY a.AppointmentDate, a.AppointmentTime;

-- Q2: Completed visits with diagnosis details (Appointments + VisitSummary + Patient + Doctor)
SELECT a.AppointmentID, p.FullName AS PatientName, d.FullName AS DoctorName,
       v.Symptoms, v.Diagnosis, v.Prescription
FROM VisitSummary v
JOIN Appointments a ON v.AppointmentID = a.AppointmentID
JOIN Patients p     ON a.PatientID = p.PatientID
JOIN Doctors d      ON a.DoctorID  = d.DoctorID
WHERE a.Status = 'Completed'
ORDER BY a.AppointmentDate;

-- Q3: Doctor schedule for a specific date (change date as needed)
SELECT d.DoctorID, d.FullName, d.Specialty, a.AppointmentTime, a.Status, p.FullName AS PatientName
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID AND a.AppointmentDate = '2025-12-18'
LEFT JOIN Patients p ON a.PatientID = p.PatientID
ORDER BY d.DoctorID, a.AppointmentTime;

-- Q4: Patients who had a No-Show
SELECT p.PatientID, p.FullName, a.AppointmentDate, a.AppointmentTime, d.FullName AS DoctorName
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d  ON a.DoctorID  = d.DoctorID
WHERE a.Status = 'No-Show';

-- Q5: Upcoming appointments using the VIEW
SELECT * FROM vw_UpcomingAppointments;

-- =========================
-- 7) AGGREGATION QUERY (GROUP BY/HAVING)
-- =========================
-- Doctors with 2 or more appointments in the dataset
SELECT d.DoctorID, d.FullName, d.Specialty, COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctors d
JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FullName, d.Specialty
HAVING COUNT(a.AppointmentID) >= 2
ORDER BY TotalAppointments DESC;

USE master;

ALTER DATABASE smart1 SET MULTI_USER WITH ROLLBACK IMMEDIATE;



