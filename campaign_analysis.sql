-- Calculate monthly churn rate by region and plan type
WITH active_users AS (
  SELECT user_id, region, plan_type, start_date, end_date
  FROM telecom_customers
  WHERE start_date <= '2023-08-01'
),

churned_users AS (
  SELECT user_id, region, plan_type
  FROM active_users
  WHERE end_date BETWEEN '2023-08-01' AND '2023-08-31'
),

total_users AS (
  SELECT region, plan_type, COUNT(DISTINCT user_id) AS total_customers
  FROM active_users
  GROUP BY region, plan_type
),

churn_rates AS (
  SELECT 
    t.region,
    t.plan_type,
    t.total_customers,
    COUNT(DISTINCT c.user_id) AS churned_customers,
    ROUND(COUNT(DISTINCT c.user_id) * 1.0 / t.total_customers, 3) AS churn_rate
  FROM total_users t
  LEFT JOIN churned_users c
    ON t.region = c.region AND t.plan_type = c.plan_type
  GROUP BY t.region, t.plan_type, t.total_customers
)

SELECT * FROM churn_rates
ORDER BY churn_rate DESC;
