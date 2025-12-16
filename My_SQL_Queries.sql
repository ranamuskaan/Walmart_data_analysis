CREATE DATABASE walmart_db;
SELECT COUNT(*) FROM walmart;
SELECT * FROM walmart;

-- To count what is the count for each payment method
SELECT
	payment_method,
    COUNT(*)
from walmart
group by payment_method;

-- to count total no. of distinct branches 
SELECT
    COUNT(DISTINCT Branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

-- Business Problems

-- Q1. What are the different payment methods, and how many transactions and items were sold with each method?
SELECT
	payment_method,
    COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Q2. Which category received the highest average rating in each branch?
SELECT *
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
    FROM walmart
    GROUP BY branch, category
) AS ranked_data
WHERE ranking = 1;

-- Q3. What is the busiest day of the week for each branch based on transaction volume?
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranking = 1;

-- Q4. Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5. What are the average, minimum, and maximum ratings for each category in each city?
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6. Calculate the total profit for each category
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE ranking = 1;

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

-- Q10: Identify the top 3 categories by total sales revenue
SELECT 
    category,
    SUM(total) AS total_revenue
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 3;

-- Q11: Find the average transaction value for each branch
SELECT 
    branch,
    ROUND(AVG(total), 2) AS avg_transaction_value
FROM walmart
GROUP BY branch;

-- Q12: Identify the city with the highest number of transactions
SELECT 
    city,
    COUNT(*) AS no_transactions
FROM walmart
GROUP BY city
ORDER BY no_transactions DESC
LIMIT 1;

-- Q13: Determine which product category generates the highest average profit per transaction
SELECT 
    category,
    ROUND(AVG(unit_price * quantity * profit_margin), 2) AS avg_profit
FROM walmart
GROUP BY category
ORDER BY avg_profit DESC;

-- Q14: Find the month with the highest total sales revenue
SELECT 
    MONTHNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS month_name,
    SUM(total) AS total_revenue
FROM walmart
GROUP BY month_name
ORDER BY total_revenue DESC
LIMIT 1;





