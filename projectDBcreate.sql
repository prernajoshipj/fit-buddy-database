-- Employee Table
CREATE TABLE S24_S003_T9_Employee (
    EID VARCHAR2(20) PRIMARY KEY,
    FName VARCHAR2(25),
    LName VARCHAR2(25),
    DOB DATE,
    DOJ DATE,
    Gender VARCHAR2(10),
    RelevantExperience INT,
    City VARCHAR(50)
);

-- Customer Table
CREATE TABLE S24_S003_T9_Customer (
    Username VARCHAR2(20) PRIMARY KEY,
    Password VARCHAR2(50),
    FName VARCHAR2(25),
    LName VARCHAR2(25),
    DOB DATE,
    MSDate DATE,--Membership Start Date
    MEDate DATE,--Membership End Date
    Gender VARCHAR2(10),
    Height DECIMAL(5,2),
    Weight DECIMAL(5,2),
    City VARCHAR(50),
    IsDietOnline VARCHAR(3),
    IsWorkoutOnline VARCHAR(3),
    DietType VARCHAR2(25),
    WorkoutType VARCHAR2(25),
    ActivityLevel VARCHAR2(25),
    Goal VARCHAR2(75)
);

-- Customer Phone Table
CREATE TABLE S24_S003_T9_Customer_Phone (
    Username VARCHAR2(20),
    Phone VARCHAR2(20),
    PRIMARY KEY (Username, Phone),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username)
);

-- Customer Email Table
CREATE TABLE S24_S003_T9_Customer_Email (
    Username VARCHAR2(20),
    Email VARCHAR2(255),
    PRIMARY KEY (Username, Email),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username)
);

-- Employee Phone Table
CREATE TABLE S24_S003_T9_Employee_Phone (
    EID VARCHAR2(20),
    Phone VARCHAR2(20),
    PRIMARY KEY (EID, Phone),
    FOREIGN KEY (EID) REFERENCES S24_S003_T9_Employee(EID)
);

-- Employee Email Table
CREATE TABLE S24_S003_T9_Employee_Email (
    EID VARCHAR2(20),
    Email VARCHAR2(255),
    PRIMARY KEY (EID, Email),
    FOREIGN KEY (EID) REFERENCES S24_S003_T9_Employee(EID)
);

-- Nutritionist Table
CREATE TABLE S24_S003_T9_Nutritionist (
    NID INT PRIMARY KEY,
    EID VARCHAR2(20),
    Degree VARCHAR2(255),
    FOREIGN KEY (EID) REFERENCES S24_S003_T9_Employee(EID)
);

-- Trainer Table
CREATE TABLE S24_S003_T9_Trainer (
    TID INT PRIMARY KEY,
    EID VARCHAR2(20),
    FOREIGN KEY (EID) REFERENCES S24_S003_T9_Employee(EID)
);

-- Employee Supervises Table 
CREATE TABLE S24_S003_T9_Employee_Supervises (
    SupervisorID VARCHAR2(20),
    SubordinateID VARCHAR2(20),
    PRIMARY KEY (SupervisorID, SubordinateID),
    FOREIGN KEY (SupervisorID) REFERENCES S24_S003_T9_Employee(EID),
    FOREIGN KEY (SubordinateID) REFERENCES S24_S003_T9_Employee(EID)
);

-- Assign Nutritionist Table
CREATE TABLE S24_S003_T9_Assign_Nutritionist (
    NID INT,
    Username VARCHAR2(20),
    PRIMARY KEY (NID, Username),
    FOREIGN KEY (NID) REFERENCES S24_S003_T9_Nutritionist(NID),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username)
);

-- Assign Trainer Table 
CREATE TABLE S24_S003_T9_Assign_Trainer (
    TID INT,
    Username VARCHAR2(20),
    PRIMARY KEY (TID, Username),
    FOREIGN KEY (TID) REFERENCES S24_S003_T9_Trainer(TID),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username)
);

-- Customer Health Conditions Table 
CREATE TABLE S24_S003_T9_Customer_HealthConditions (
    Username VARCHAR2(20),
    Type VARCHAR2(25),
    Description VARCHAR2(255),
    PRIMARY KEY (Username, Type, Description),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username)
);

-- Customer Log Table 
CREATE TABLE S24_S003_T9_CustomerLogs (
    Username VARCHAR2(20),
    LogID INT PRIMARY KEY,
    LogDate DATE,
    WaterIntake INT,
    StepsWalked INT,
    IsDietFollowed VARCHAR(3),
    IsWorkoutFollowed VARCHAR(3),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username)
);

-- Plan Table 
CREATE TABLE S24_S003_T9_Plan (
    PlanID INT PRIMARY KEY,
    Type VARCHAR2(25),
    Price DECIMAL(6,2),
    Duration INT,
    IsNutritionistIncluded VARCHAR(3),
    IsTrainerIncluded VARCHAR(3)
);

-- Customer Enrolls Table 
CREATE TABLE S24_S003_T9_Customer_Enrolls (
    Username VARCHAR2(20),
    PlanID INT,
	ESDate DATE,
    EEDate DATE,
    PRIMARY KEY (Username, PlanID, ESDate),
    FOREIGN KEY (Username) REFERENCES S24_S003_T9_Customer(Username),
    FOREIGN KEY (PlanID) REFERENCES S24_S003_T9_Plan(PlanID)
);
commit;