create schema bank;
use bank;
select * from bank_analysis limit 3;
 select count(*) from bank_analysis;
 -- there is 10000 records in data 
CREATE VIEW risk_analysis AS
SELECT
    Customer_ID,
    Credit_Score,
    Credit_Utilization_Ratio,
    Debt_To_Income_Ratio,
    Number_of_Late_Payments,
    Defaulted,
    Annual_Income,
    Employment_Status
FROM bank_analysis;
 select * from risk_analysis limit 3;
 CREATE VIEW customer_segmentation AS
SELECT
    Customer_ID,
    Annual_Income,
    CLV,
    Total_Spend_Last_Year,
    Total_Transactions,
    Avg_Transaction_Amount,
    Tenure_in_Years
FROM bank_analysis;
CREATE VIEW fraud_analysis AS
SELECT
    Customer_ID,
    Fraud_Transactions,
    Unique_Transaction_Cities,
    Credit_Utilization_Ratio,
    Max_Transaction_Amount,
    Total_Transactions
FROM bank_analysis;

CREATE VIEW customer_risk_profile AS
SELECT
    Customer_ID,
    Age,
    Gender,
    Employment_Status,
    Annual_Income,
    Credit_Score,
    Credit_Utilization_Ratio,
    Debt_To_Income_Ratio,
    Number_of_Late_Payments,
    Total_Spend_Last_Year,
    CLV,
    Fraud_Transactions,
    Defaulted
FROM bank_analysis;

select * from risk_analysis limit 3;
-- Average Credit Score by Default Status
select Defaulted ,round(avg(Credit_Score),0) as `Avg Credit Score`
from risk_analysis group by Defaulted;
--  Non-default customers have slightly higher average credit scores compared to defaulted customers.
-- High Risk Customers
select * from risk_analysis where
Credit_Score<600
and Credit_Utilization_Ratio> 0.7
and Number_of_Late_Payments>=2;

-- Defaul rate by Employement status
select Employment_Status , count(*) as `Total Customers`,
sum(Defaulted) as `Defaulted Customers`,
round(avg(Defaulted)*100,2) as `Rate Of Default`
from risk_analysis
group by Employment_Status
order by round(avg(Defaulted)*100,2) desc ;
-- Employed customers show the highest default rate at 35%, followed by self-employed and unemployed customers.
-- Recommendation:
-- Employment status alone should not be used for credit approval; banks should also evaluate repayment behavior and credit utilization.
 select * from customer_segmentation limit 3;
-- Top 10 % high value cusatomers
with ten as ( select Customer_ID,CLV,Total_Spend_Last_Year from  customer_segmentation
)
select * from(select *,ntile(10) over(order by CLV desc) as grp from ten)t
where grp=1;
 select max(Total_Spend_Last_Year) from customer_segmentation;
 -- Customer Category Segmentation
select Customer_ID, Total_Spend_Last_Year,
case
when Total_Spend_Last_Year< 10000 then "Low Value"
when Total_Spend_Last_Year< 20000 then "Medium Value"
else "High Value" end as `Customer Category`
 from customer_segmentation;
 select * from fraud_analysis limit 3;
 -- Customers with Fraud activities
 select * from fraud_analysis
 where Fraud_Transactions > 0
 order by Fraud_Transactions desc;
 -- Suspicious Customers
 select *  from fraud_analysis
 where Unique_Transaction_Cities >15 and Fraud_Transactions>0;
 select * from customer_risk_profile limit 3;
 -- Average Spend By Gender
 select Gender, round(avg(Total_Spend_Last_Year),0) as`Avg Spend` 
 from customer_risk_profile
 group by Gender ;
 -- Male customers have slightly higher average spending compared to female customers.
 -- Average Income By Employement
 select Employment_Status, round(avg(Annual_Income),0) as`Average Income`
 from customer_risk_profile
 group by  Employment_Status;
 -- Self-employed customers have slightly higher average income compared to employed and unemployed customers.
 
 -- High CLV + Low Risk Customers
 SELECT *
FROM customer_risk_profile
WHERE Credit_Score > 700
AND Number_of_Late_Payments = 0
AND Defaulted = 0
ORDER BY CLV DESC;
-- Defult rate by credit score category
select
case
    when Credit_Score < 600 then 'Poor'
    when Credit_Score < 700 then 'Average'
    else 'Good'
end as Credit_Category,

count(*) as Total_Customers,
sum(Defaulted) as Default_Customers,
round(avg(Defaulted)*100,2) as Default_Rate

from risk_analysis
group by Credit_Category
order by Default_Rate desc;
-- Customers in the poor credit score category have the highest default rate among all credit groups.
-- Recommendation:
-- Banks should apply stricter credit checks and lower credit limits for low credit score customers.
-- Top spendind gender
select Gender,round(sum(Total_Spend_Last_Year),0) as `Spending`
from customer_risk_profile
group by gender
order by round(sum(Total_Spend_Last_Year),0) desc;
-- Male customers have slightly higher average spending compared to female customers.
-- Recommendation:
-- Banks can design targeted reward programs and personalized offers based on customer spending behavior.
-- Fraud Rate Analysis
select
Fraud_Transactions,
COUNT(*) as Customers
from fraud_analysis
group by Fraud_Transactions
order by Fraud_Transactions desc;
-- 24 % customers have one time fraud transaction
-- Recommendation:
-- Banks should strengthen fraud detection systems for customers showing unusual transaction behavior across multiple cities.
-- Average Spend by Age Group
select
case
   when Age < 30 then'Young Adults'
    when Age < 50 then 'Middle Age'
    else 'Senior Customers'
end as Age_Group,

round(avg(Total_Spend_Last_Year),0) as Avg_Spend

from customer_risk_profile
group by Age_Group;
-- Young adult customers show slightly higher average spending compared to other age groups.