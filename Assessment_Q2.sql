/* Transaction Frequency Analysis */
 
/* Objective: Analyze how frequently customers perform transactions on a monthly basis and classify them into 
high , medium and low frequency */

-- CTE for monthly transactions of each customer
WITH monthly_transactions AS (
	SELECT 
		u.id AS user_id, -- unique identifier for each customer
		DATE_FORMAT(s.transaction_date, '%Y-%m') AS transaction_month, -- a date format ensuring each year-month value is distinct
		COUNT(*) AS monthly_transaction_count -- total confirmed savings transactions by month
	FROM 
		users_customuser u	 -- customer demographic and contact information table
        
	-- join with savings account to access records of deposit transactions
	JOIN 
		savings_savingsaccount s on s.owner_id = u.id
        WHERE s.confirmed_amount > 0 -- consider only valid inflow transactions
	GROUP BY u.id, transaction_month  -- group per customer per month
),

-- CTE to calulate the average monthly transaction for each user
avg_monthly_transaction AS (
	SELECT
		user_id,
        AVG(monthly_transaction_count) AS avg_transactions_per_month -- mean of monthly transaction for each user
	FROM 
		monthly_transactions
	GROUP BY user_id
),

-- CTE to classify users based on their average monthly transaction frequency
category AS (
	SELECT
		user_id,
        CASE
			WHEN avg_transactions_per_month >= 10 THEN 'High Frequency' -- 10 or more transactions per month
            WHEN avg_transactions_per_month >=3 THEN 'Medium Frequency' -- 3 to 9 transactions per month
            ELSE 'Low Frequency' -- less than 3 transactions per month ( 2 or fewer)
		END AS frequency_category,
        avg_transactions_per_month
	FROM
		avg_monthly_transaction
	)
    
    -- Final query to summarize the count and average per frequency group
    SELECT
		frequency_category, -- category e,g High Frequency, Medium Frequency, Low Frequency
        COUNT(*) as customer_count, -- Number of customers in the frequency band
        ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month -- rounded average to one decimal place
	FROM
		category
	GROUP BY frequency_category
    ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency'); -- to ensure logical category order