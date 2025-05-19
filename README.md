Customer Insights Analytics - SQL Asessment

This repository contains SQL solutions designed to evaluate technical proficiency, analytical thinking, and real-world business logic application using SQL.

Each query addresses a specific business scenario using MySQL best practices :

- Data integrity through null handling, filtering, and aggregation safeguards
- with a focus on readibilty, DRY code, accuracy, and performance optimization with Common Table Expressions (CTE) and conditional logics.

--------------------------------

## Per-Question Explanations

## Q1. High Value Customers with Multiple Product

**Objective**: Identify customers with at least one funded savings plan and one funded investment plan, then rank them based on their total deposits.

**Approach**:
- Created two CTEs to compute savings and investment deposits separately:
- Funded savings: filtered using `plans_plan.is_regular_savings = 1`
- Funded investments: filtered using `plans_plan.is_a_fund = 1`
- Joined both with `users_customuser` to return only customers who had **both** types of plans.
- Calculated `total_deposits` as the sum of both plan types and converted from kobo to naira.
- Used `FORMAT` to display total deposits in a more readable, comma-separated format e.g **20,500,900** instead of **20500900** to improve visual clarity.
- Since `FORMAT` returns a string, sorting by the formatted column would be incorrect. To ensure an accurate numeric ordering , I used `ORDER BY` on the deposit sum : `(IFNULL(s.total_savings_deposit,0) + IFNULL(i.total_investment_deposit,0)) DESC` and sorted from highest to lowest.

![High Value Customers](https://drive.google.com/uc?export=view&id=1LHd7rd7phu5dwzilySycYhQr3m8-NQHe)


------------------------------

## Q2. Transaction Frequency Analysis

**Objective**: Analyze how frequently customers perform transactions on a monthly basis and classify them into 
high , medium and low frequency

**Approach**:
- Created three CTES to calculate monthly transactions, average monthly transaction, and frequency category for each customer
- Aggregated customer transaction counts per month using `DATE_FORMAT(s.transaction_date, '%Y-%m')` to normalize by month.
- Classified users using:
  - High Frequency (≥10/month)
  - Medium Frequency (3–9/month)
  - Low Frequency (≤2/month)
- my final output was grouped by frequency category to give me the customer count and average monthly transactions based on each frequency category.
- Used `ORDER BY FIELD(...)` to sort frequency categories in a custom logical order instead of default alphabetical sorting.


**Challenges**

- `Avoiding Inflated Transaction Counts in Frequency Analysis`.

**how I resolved it**: 
- I initally considered counting all rows from the `savings_savingsaccount` but I realized this will skew the frequencies. So i ensured only confirmed transactions were counted, and normalized over unique months using `DATE_FORMAT()`.


![Transaction Frequency Chart](https://drive.google.com/uc?export=view&id=1SJbPfNXHJMH-Mm_V4ZVK0P7xZ-yA28qw)

------------------------------

## Question 3. Account Inactivity Alert

**Objective**: find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) 

**Approach**:
- Defined a CTE to label plan types (`Savings`, `Investment`) 
- filtered only **active** plans based on (`is_archived = 0 AND is_deleted = 0`) which means the accounts have not been archived or deleted.
- Joined the CTE with `savings_savingsaccount` to find last transaction date 
- restricted the results of the join to `confirmed_amount > 0` to ensure we're tracking only successful inflows.
- Used `MAX(transaction_date)` and `DATEDIFF()` to compute inactivity duration.
- Filtered results to show only those plans that haven’t had any inflow for **over a year**.

**Challenges**

- `Defining What Makes an Account “Active” `

**Assumptions**: 
- There were two interperations I defined:
- 1. System-active: plans that are not archived or deleted
- 2. Behaviorally-active: plans with at least one confirmed transaction

- I included the two logic into my query by setting `is_archived = 0`,`is_deleted = 0`. Then I adopted the behavioral-active definition, using an `INNER JOIN` and `confirmed_amount > 0` because I was working under the assumption that an “active” plan must have had **at least one confirmed inflow transaction** in the past.

-If I had used a `LEFT JOIN`, it would have included plans with no transactions at all. However, those rows would have had `NULL` for `transaction_date`, and thus been excluded later by the `HAVING inactivity_days > 365` clause. 

- However, it is important to note that while using both kind of Joins could eventually give the same output based on my query logic, an `INNER JOIN` or just `JOIN` (which also means inner join) was more efficient due to the fewer rows processed, and accurate as it algined with my behavioral definition of active accounts.

---------------------------------

## Question 4. Customer Lifetime Value (CLV) Estimation

**Objective**: Estimate CLV based on transaction history and account tenure.

**Approach**:
- Built a CTE called transactions to calculate:
  - Account tenure in months using (`TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())`)
  - I used `GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()),1) AS tenure_months` to avoid tenure_months = 0
  - Total confirmed transactions per user
  - Average profit per transaction (0.1% of transaction value) using `confirmed_amount` as transaction value
- Applied the CLV formula: `(total_transactions / tenure_months) × 12 × avg_profit_per_transaction`
- Used `FORMAT(..., 2)` to convert the computed CLV from kobo to naira and present it with two decimal places for better financial readability.
- Wrapped the entire CLV formula in IFNULL and FORMAT to handle nulls and ensure proper formatting.
- Ordered by `estimated_clv` from highest to lowest

**Challenges**

- `Handling Zero-Month Tenure in CLV Calculation`
- `Handling Null Values in CLV Calculation`

**how I resolved it**: 
- I used `GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()),1) AS tenure_months`. From a marketing and customer analytics standpoint, assuming a minimum tenure of 1 month for users with tenure = 0 is not only justifiable, it’s actually practically necessary in this context.

- Some customers had NULL values in their transaction count or average profit, which made their CLV come out as NULL. I used `IFNULL(..., 0)` to return 0 instead of NULL, and `FORMAT(..., 2)` to display the CLV cleanly.

![CLV chart](https://drive.google.com/uc?export=view&id=1j8qikSXakm4SLP-VDHt4pp2EC4kTbE9o)







