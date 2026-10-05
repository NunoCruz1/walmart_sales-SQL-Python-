SELECT * FROM walmart;

SELECT
	COUNT(distinct branch)
FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- Business Problems
-- Q.1 Find different payment method and number of transactions, number of qty sold

SELECT
	payment_method,
    COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category AVG_Rating

SELECT *
FROM
(	SELECT
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC)as ranking
	FROM walmart
	GROUP BY 1, 2
) AS ranking
WHERE ranking = 1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions
-- Report: Multiple days across different branches

SELECT *
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (
            PARTITION BY branch 
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranking = 1;

-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
-- Report: Report: 1º Credit Card, 2º Ewallet, 3º Cash

SELECT
	payment_method,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.5 Determine the average, minimum, and maximum rating of category for each city. List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart
GROUP BY city, category;

-- Q.6 What is the total profit for each category, ranked from highest to lowest?

SELECT 
    category,
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category
ORDER BY profit DESC;

-- Q.7 What is the most frequently used payment method in each branch?

WITH cte
AS
	(SELECT
		branch,
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranking
	FROM walmart
	GROUP BY branch, payment_method
	)
SELECT *
FROM cte
WHERE ranking = 1;

-- Q.8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS transactions
FROM walmart
GROUP BY 1;

-- Q.9 Which branches experienced the largest decrease in revenue compared to the previous year?

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
