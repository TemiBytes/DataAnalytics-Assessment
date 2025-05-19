/* Account Inactivity Alert */

-- Objective: find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) 
 
WITH plan_types AS (
	SELECT
		p.id AS plan_id, -- unique identifier of the plan
		p.owner_id AS owner_id, -- owner of the plan 
		-- determine the type of plan
		CASE
			WHEN p.is_regular_savings = 1 THEN 'Savings' -- if its a regualar savings plan
			WHEN p.is_a_fund = 1 THEN 'Investment' -- if its an investment fund plan
			ELSE 'Other'
		END AS `type`
	FROM plans_plan p
    WHERE(p.is_regular_savings = 1 OR p.is_a_fund = 1) -- savings or investment plan
		AND p.is_archived = 0 -- removes archived plans
		AND p.is_deleted = 0 -- removes deleted plans
)
-- query to join with savings account to find last_transaction date
SELECT 
	pt.plan_id, -- plan Id
    pt.owner_id, -- owner of the plan
    pt.type, -- type of plan (savings or investment)
    MAX(s.transaction_date) AS last_transaction_date,   -- Most recent transaction date for this plan
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days    -- Calculate the number of days since the last transaction
FROM 
	plan_types as pt
JOIN -- using an inner join assuming an account is active only if it has had at least one confirmed transaction
	savings_savingsaccount s on s.plan_id = pt.plan_id AND s.confirmed_amount > 0 -- only counts confirmed inflow transaction
-- group by unique plan and its type
GROUP BY 
	pt.plan_id, 
    pt.owner_id, 
    pt.type
-- show only plans with no transaction in the last 365 days
HAVING
	inactivity_days > 365
ORDER BY
	inactivity_days DESC;
     