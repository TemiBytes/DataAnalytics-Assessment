/* High Value Customers With Multiple Products */
 
 -- Objective: Identify customers with at least one funded savings plan and one funded investment plan, sorted by total deposits
 
 -- CTE to aggregate funded savings plan per customer
 WITH savings AS (
	SELECT
		s.owner_id, -- unique id of customer that saved
        COUNT(DISTINCT s.id) AS savings_count, -- total number of distinct savings transactions
        SUM(s.confirmed_amount) AS total_savings_deposit -- total savings amount deposited by customer in kobo
	FROM
		savings_savingsaccount s
	-- join to get only records associated with a regular savings plan 
	JOIN
		plans_plan p ON p.id = s.plan_id
        WHERE p.is_regular_savings = 1 
	GROUP BY s.owner_id
 ),
 
 -- CTE to aggregate funded investment plan per customer
 investments AS (
	SELECT 
		p.owner_id, -- unique id of customer that saved
        COUNT(DISTINCT p.id) AS investment_count, -- total number of distinct investment transactions
        SUM(p.amount) AS total_investment_deposit  -- total investment amount by customer in kobo
	FROM
		plans_plan p
	WHERE p.is_a_fund = 1 -- filter for only investment plans
    GROUP BY p.owner_id
    )
    
    
    -- final query to join user information with the savings and investment data
    SELECT
		u.id AS owner_id, -- unique identifier of the user
        CONCAT(u.first_name , ' ', u.last_name) AS name, -- full name of customer
        s.savings_count AS savings_count, -- count of funded savings transactions
        i.investment_count AS investment_count, -- count of investment plans
        FORMAT((IFNULL(s.total_savings_deposit,0) + IFNULL(i.total_investment_deposit,0))/100,2) AS total_deposits -- added deposit amounts, then converted from kobo to naira 
	FROM 
		users_customuser u
	-- only include users with funded savings and funded investments
	JOIN 
		savings s ON s.owner_id = u.id
	JOIN
		investments i ON i.owner_id = u.id
	ORDER BY 
		(IFNULL(s.total_savings_deposit,0) + IFNULL(i.total_investment_deposit,0)) DESC; -- sort from highest to lowest
	