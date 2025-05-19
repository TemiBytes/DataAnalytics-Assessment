/* Customer Lifetime Value (CLV) Estimation */
 
 -- Objective: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- Account tenure (months since signup)
-- Total transactions
-- FORMULA: Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
-- Order by estimated CLV from highest to lowest

 -- CTE to compute tenure, avg_profit_transaction, and transaction count
 WITH transactions AS (
	 SELECT
		u.id AS customer_id, -- unique ID of the customer
		CONCAT(u.first_name, ' ', u.last_name) AS name, -- Full name
		GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()),1) AS tenure_months, -- months since signup (for tenure months = 0 , greatest ensures they appear as one)
		COUNT(CASE WHEN s.confirmed_amount > 0 THEN s.id END) AS total_transactions, -- total number of savings transactions
		AVG( CASE WHEN s.confirmed_amount > 0 THEN s.confirmed_amount * 0.001 END) AS avg_profit_per_transaction -- Average Profit per transaction at 0.1% rate
	 FROM 
		users_customuser u	
	LEFT JOIN  -- join to give full CLV insight on customers that have transacted.
		savings_savingsaccount s ON s.owner_id = u.id
	GROUP BY 
		u.id, u.first_name, u.last_name
) 
-- final query to summarize results and calculate the Customer Lifetime Value (CLV) Estimation
SELECT 
	t.customer_id,
	t.name,
    t.tenure_months,
    t.total_transactions,
    
    FORMAT(
    IFNULL(((t.total_transactions / t.tenure_months) * 12 * t.avg_profit_per_transaction) / 100, 0),
    2) AS estimated_clv -- CLV formula (then converted Kobo to Naira)
    FROM 
		transactions t
	ORDER BY 
		IFNULL(((t.total_transactions / t.tenure_months) * 12 * t.avg_profit_per_transaction) / 100, 0) DESC; -- ordered by estimated CLV from highest to lowest
	
	
    