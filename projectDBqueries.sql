set pagesize 1000;
set linesize 1000;

--=================================================================================================================================================================
-- 1) Sustainability of diet and exercise – From the customer log we can get the information on which type of diet or exercise is more sustainable and can be implemented in our lifestyle.
-- Calculate the percentage of times each diet type was followed.
SELECT 
    DietType,
    COUNT(*) AS TotalEntries,
    ROUND((COUNT(CASE WHEN IsDietFollowed = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2) AS PercentageFollowed
FROM 
    S24_S003_T9_CUSTOMERLOGS L
JOIN 
    S24_S003_T9_Customer C ON L.Username = C.Username
GROUP BY 
    DietType
HAVING 
    ROUND((COUNT(CASE WHEN IsDietFollowed = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2) >= ALL 
    (SELECT 
        ROUND((COUNT(CASE WHEN IsDietFollowed = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2) AS PercentageFollowed
    FROM 
        S24_S003_T9_CUSTOMERLOGS L
    JOIN 
        S24_S003_T9_Customer C ON L.Username = C.Username
    GROUP BY 
        DietType);

-- Calculate the percentage of times each workout type was followed.
SELECT 
    WorkoutType,
    COUNT(*) AS TotalEntries,
    ROUND((COUNT(CASE WHEN IsWorkoutFollowed = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2) AS PercentageFollowed
FROM 
    S24_S003_T9_CustomerLogs L
JOIN 
    S24_S003_T9_Customer C ON L.Username = C.Username
GROUP BY 
    WorkoutType
HAVING 
    ROUND((COUNT(CASE WHEN IsWorkoutFollowed = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2) >= ALL 
    (SELECT 
        ROUND((COUNT(CASE WHEN IsWorkoutFollowed = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2) AS PercentageFollowed
    FROM 
        S24_S003_T9_CustomerLogs L
    JOIN 
        S24_S003_T9_Customer C ON L.Username = C.Username
    GROUP BY 
        WorkoutType);
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 2) Based on Customers assigned to the employees we can figure out which types of Nutritionists/Trainers are more in demand, this can help in hiring.
-- Count the number of customers assigned to each Nutritionist and find the nutritionist who have maximum customer enrollment.
SELECT N.NID, 
       E.FName AS NutritionistFirstName,
       E.LName AS NutritionistLastName,
       COUNT(AN.Username) AS NumberOfCustomers
FROM S24_S003_T9_Nutritionist N
JOIN S24_S003_T9_Employee E ON N.EID = E.EID
LEFT JOIN S24_S003_T9_Assign_Nutritionist AN ON N.NID = AN.NID
GROUP BY N.NID, E.FName, E.LName
HAVING
    COUNT(AN.Username) >= (
        SELECT MAX(COUNT(AN.Username)) AS NumberOfCustomers
        FROM S24_S003_T9_Nutritionist N
        JOIN S24_S003_T9_Employee E ON N.EID = E.EID
        LEFT JOIN S24_S003_T9_Assign_Nutritionist AN ON N.NID = AN.NID
        GROUP BY N.NID, E.FName, E.LName);

-- Count the number of customers assigned to each Trainer and find the trainer who have maximum customer enrollment.
SELECT T.TID,
       E.FName AS TrainerFirstName,
       E.LName AS TrainerLastName,
       COUNT(AT.Username) AS NumberOfCustomers
FROM S24_S003_T9_Trainer T
JOIN S24_S003_T9_Employee E ON T.EID = E.EID
LEFT JOIN S24_S003_T9_Assign_Trainer AT ON T.TID = AT.TID
GROUP BY T.TID, E.FName, E.LName
HAVING
    COUNT(AT.Username) >= (SELECT MAX(COUNT(AT.Username)) AS NumberOfCustomers
        FROM S24_S003_T9_Trainer T
        JOIN S24_S003_T9_Employee E ON T.EID = E.EID
        LEFT JOIN S24_S003_T9_Assign_Trainer AT ON T.TID = AT.TID
        GROUP BY T.TID, E.FName, E.LName);
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 3) We provide three plans; based on enrollment, we can determine which is the most popular plan and work to improve it.
SELECT
    E.PlanID,
    P.Type AS PlanName,
    COUNT(*) AS EnrollmentCount
FROM
    S24_S003_T9_Customer_Enrolls E
JOIN
    S24_S003_T9_Plan P ON E.PlanID = P.PlanID
GROUP BY
    E.PlanID, P.Type
ORDER BY
    EnrollmentCount DESC
FETCH FIRST 1 ROW ONLY;
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 4) Based on the customers' location, we can see if there is more demand for online or in-person trainers and nutritionists. This will help us in making the hiring decisions.
SELECT
    C.City,
    ROUND((SUM(CASE WHEN C.IsWorkoutOnline = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS OnlineTrainersDemand,
    ROUND((SUM(CASE WHEN C.IsDietOnline = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS OnlineNutritionistsDemand,
    COUNT(*) AS TotalCustomers
FROM
    S24_S003_T9_Customer C
GROUP BY
    C.City
ORDER BY
    C.City;
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 5) Based on customer’s nutritionist’s/trainer’s gender preference, we can determine the customer gender to employee gender ratio and can make relevant hiring decisions.
WITH TrainerGenderPreference AS (
    SELECT c.Username, c.IsWorkoutOnline, c.Gender AS CustomerGender,
           e.Gender AS EmployeeGender
    FROM S24_S003_T9_Customer c
    INNER JOIN S24_S003_T9_Customer_Enrolls ce ON c.Username = ce.Username
    INNER JOIN S24_S003_T9_Plan p ON ce.PlanID = p.PlanID
    LEFT JOIN S24_S003_T9_Assign_Nutritionist an ON c.Username = an.Username
    LEFT JOIN S24_S003_T9_Nutritionist n ON an.NID = n.NID
    LEFT JOIN S24_S003_T9_Employee e ON n.EID = e.EID
    WHERE p.IsTrainerIncluded = 'Yes' 
),
GenderRatio AS (
    SELECT 
        EmployeeGender,
        COUNT(DISTINCT Username) AS CustomerCount
    FROM TrainerGenderPreference
    WHERE IsWorkoutOnline = 'Yes'
    GROUP BY EmployeeGender
)
SELECT 
    EmployeeGender,
    CustomerCount,
    CustomerCount / SUM(CustomerCount) OVER () AS GenderRatio
FROM GenderRatio
WHERE EmployeeGender IS NOT NULL;

--=================================================================================================================================================================



--=================================================================================================================================================================
-- 6) Divide the customers based on age and then check which age group is following the routine daily. This will help us in posting advertisements and providing offers/discounts.
WITH Age_Groups AS ( 
    SELECT Username, 
           CASE  
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, DOB) / 12) BETWEEN 18 AND 25 THEN '18-25' 
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, DOB) / 12) BETWEEN 26 AND 35 THEN '26-35' 
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, DOB) / 12) BETWEEN 36 AND 45 THEN '36-45' 
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, DOB) / 12) BETWEEN 46 AND 55 THEN '46-55' 
               ELSE '55+'  
           END AS Age_Group 
    FROM S24_S003_T9_Customer 
), 
Routine_Adherence AS ( 
    SELECT cl.Username, 
           CASE  
               WHEN cl.IsDietFollowed = 'Yes' AND cl.IsWorkoutFollowed = 'Yes' THEN 'Both' 
               WHEN cl.IsDietFollowed = 'Yes' THEN 'Diet' 
               WHEN cl.IsWorkoutFollowed = 'Yes' THEN 'Workout' 
               ELSE 'None'  
           END AS Routine_Adherence 
    FROM S24_S003_T9_CustomerLogs cl
) 
SELECT ag.Age_Group, 
       ra.Routine_Adherence, 
       COUNT(ra.Username) AS Num_Customers 
FROM Age_Groups ag 
JOIN Routine_Adherence ra ON ag.Username = ra.Username 
GROUP BY ag.Age_Group, ra.Routine_Adherence 
ORDER BY ag.Age_Group, ra.Routine_Adherence;
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 7) Based on user log, we can analyze which users pertaining to weight loss goal are skipping the workouts more. This data can be used to advertise slimming devices like toning belts.
SELECT c.Username, 
       c.FName, 
       c.LName, 
       COUNT(cl.Username) AS Skipped_Workouts 
FROM S24_S003_T9_Customer c 
JOIN S24_S003_T9_CUSTOMERLOGS cl ON c.Username = cl.Username 
WHERE c.Goal LIKE '%Lose Weight%' 
  AND cl.IsWorkoutFollowed = 'No' 
GROUP BY c.Username, c.FName, c.LName 
ORDER BY Skipped_Workouts DESC;
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 8) Based on the date of user enrollment or renewal, we can advertise the plans accordingly at that time of the year.
SELECT TO_CHAR(TRUNC(ESDate, 'MM'), 'Month') AS Enrollment_Month, COUNT(Username) AS Num_Enrollments 
FROM S24_S003_T9_Customer_Enrolls 
GROUP BY TO_CHAR(TRUNC(ESDate, 'MM'), 'Month') 
HAVING COUNT(Username) >= ANY (
SELECT COUNT(Username)/12
FROM S24_S003_T9_Customer_Enrolls
)
ORDER BY TO_DATE(Enrollment_Month, 'Month');
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 9) Based on the renewed enrollments, we can analyze the most in-demand plans and the same can be modified to increase the revenue as well as the user engagement.
SELECT 
    PlanID,
    COUNT(*) AS TotalEnrollments
FROM 
    (
    SELECT 
        Username,
        PlanID,
        MAX(EEDate) AS LatestEndDate
    FROM 
        S24_S003_T9_Customer_Enrolls
    GROUP BY 
        Username, PlanID
    ) RenewalData
GROUP BY 
    PlanID
ORDER BY 
    TotalEnrollments DESC;
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 10) Based on the health conditions it can be analyzed which diet & training is preferred by which age group. The same can be used to recommend for the new customers.
set pagesize 1000;
set linesize 1000;
column Age_Group FORMAT A10;
column Health_Condition_Type FORMAT A15;
column Health_Condition_Description FORMAT A25;
column DietType FORMAT A20;
column WorkoutType FORMAT A20;

WITH Customer_Age_Group AS (
    SELECT
        c.Username,
        c.DOB,
        CASE
            WHEN MONTHS_BETWEEN(SYSDATE, c.DOB) / 12 BETWEEN 18 AND 30 THEN '18-30'
            WHEN MONTHS_BETWEEN(SYSDATE, c.DOB) / 12 BETWEEN 31 AND 45 THEN '31-45'
            WHEN MONTHS_BETWEEN(SYSDATE, c.DOB) / 12 BETWEEN 46 AND 60 THEN '46-60'
            ELSE 'Above 60'
        END AS Age_Group
    FROM
        S24_S003_T9_Customer c
),
Health_Condition_Preferences AS (
    SELECT
        cag.Username,
        cag.Age_Group,
        chc.Type AS Health_Condition_Type,
        chc.Description AS Health_Condition_Description,
        c.DietType,
        c.WorkoutType
    FROM
        Customer_Age_Group cag
    JOIN
        S24_S003_T9_Customer_HealthConditions chc ON cag.Username = chc.Username
    JOIN
        S24_S003_T9_Customer c ON cag.Username = c.Username
    JOIN
        S24_S003_T9_Customer_Enrolls ce ON c.Username = ce.Username
    JOIN
        S24_S003_T9_Plan cp ON ce.PlanID = cp.PlanID
)
SELECT
    Age_Group,
    Health_Condition_Type,
    Health_Condition_Description,
    DietType,
    WorkoutType,
    COUNT(Username) AS Customer_Count
FROM
    Health_Condition_Preferences
GROUP BY
    Age_Group,
    Health_Condition_Type,
    Health_Condition_Description,
    DietType,
    WorkoutType
ORDER BY
    Age_Group,
    Health_Condition_Type,
    Health_Condition_Description;
	
--=================================================================================================================================================================



--*******************************
--NEWLY IDENTIFIED BUSINESS GOALS
--*******************************


--=================================================================================================================================================================
-- 11) Find customers who have enrolled in all available plans
-- Query Using Division 
SELECT Username
FROM S24_S003_T9_Customer C
WHERE NOT EXISTS (
    SELECT P.PlanID
    FROM S24_S003_T9_Plan P
    WHERE NOT EXISTS (
        SELECT *
        FROM S24_S003_T9_Customer_Enrolls CE
        WHERE CE.Username = C.Username
        AND CE.PlanID = P.PlanID
    )
);
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 12) Calculate the average relevant experience of employees within each city, and then compare each employee's relevant experience to the city's average.
-- Query Using Over
column City FORMAT A15;
SELECT
    EID,
    FName,
    LName,
    City,
    RelevantExperience,
    AVG(RelevantExperience) OVER (PARTITION BY City) AS AvgExperienceInCity,
    CASE
        WHEN RelevantExperience > AVG(RelevantExperience) OVER (PARTITION BY City) THEN 'Above Average'
        WHEN RelevantExperience < AVG(RelevantExperience) OVER (PARTITION BY City) THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS ExperienceComparison
FROM S24_S003_T9_Employee;
	
--=================================================================================================================================================================



--=================================================================================================================================================================
-- 13) Find the total sales for different categories, including subtotals and a grand total, by grouping them based on city and plan type.
-- Query Using Roll up
SELECT 
    c.City,
    p.Type,
    SUM(p.Price) AS Sales
FROM 
    S24_S003_T9_Plan p
JOIN 
    S24_S003_T9_Customer_Enrolls ce ON p.PlanID = ce.PlanID
JOIN 
    S24_S003_T9_Customer c ON c.Username = ce.Username
GROUP BY 
    ROLLUP(c.City, p.Type);

-- Query Using Cube
SELECT 
    c.city, 
    p.type, 
    SUM(price) AS sales
FROM 
    S24_S003_T9_Plan p
JOIN 
    S24_S003_T9_Customer_Enrolls ce ON p.planID = ce.planID
JOIN 
    S24_S003_T9_Customer c ON c.Username = ce.Username
GROUP BY 
    CUBE(c.city, p.type);
	
--=================================================================================================================================================================