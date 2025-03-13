show databases;
CREATE DATABASE walmart_db;

USE walmart_db;

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
    COUNT(*)
FROM walmart
GROUP BY payment_method;

SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

-- Business Problems
-- Q1. Find diffierent payment method and number of transactions, number of qty sold

SELECT 
	payment_method,
    COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q2. Identify the highest-rated category in each branch, displaying the branch, category AVG ratnig 


SELECT *  
FROM (  
    SELECT branch, category, AVG(rating) AS avg_rating,  
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank`  
    FROM walmart  
    GROUP BY branch, category  
) AS ranked_walmart  -- Added alias for the subquery
WHERE `rank` = 1;  -- Correct column reference


-- Q3. Identify the busiest day for each brach based in the number of transactions

SELECT *
FROM (
    SELECT 
        branch, 
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, day_name
) ranked_data
WHERE `rank` = 1;

-- Q5, Determine the average, minimum, maximum and average rating of category for each city.
-- List the city, avg_rating, min_rating and max_rating.

SELECT 
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
FROM walmart
GROUP BY city, category;


-- Q6. Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit 
FROM walmart
GROUP BY category;

-- Q7. Determine the most common payment method for each Branch.
-- Display Branch and the preferred_payment_method.

WITH cte AS (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE `rank` = 1;


-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_value
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank_value = 1;


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;




