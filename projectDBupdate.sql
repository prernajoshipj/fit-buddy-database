-- Update price of the plan
UPDATE S24_S003_T9_Plan
SET Price = 30
WHERE PlanID = 1;
 
-- Update weight and goal of the customer
UPDATE S24_S003_T9_Customer
SET Weight = 70.5, Goal = 'Lose weight'
WHERE Username = 'user058';
 
UPDATE S24_S003_T9_Customer
SET Weight = 68.5, Goal = 'Lose weight'
WHERE Username = 'user063';
 
UPDATE S24_S003_T9_Customer
SET Weight = 65.5, Goal = 'Lose weight'
WHERE Username = 'user064';
 
UPDATE S24_S003_T9_Customer
SET Weight = 58.5, Goal = 'Lose weight'
WHERE Username = 'user065';
 
UPDATE S24_S003_T9_Customer
SET Weight = 71.5, Goal = 'Lose weight'
WHERE Username = 'user071';

-- Change plan for the customer
UPDATE S24_S003_T9_Customer_Enrolls
SET PlanID = 3
WHERE Username IN ('user001','user005','user006','user011','user014');

commit;