-- customer_segmentation_analysis.sql
-- Simulated segmentation query for marketing insights

-- Step 1: Prepare a cleaned customer dataset
WITH cleaned_customers AS (
  SELECT 
    user_id,
    plan_type,
    region,
    start_date,
    end_date,
    DATE_DIFF('2023-08-31', start_date, DAY) AS tenure_days,
    CASE 
      WHEN end_date IS NULL THEN 'Active'
      WHEN end_date BETWEEN '2023-07-01' AND '2023-08-31' THEN 'Churned (Last 2 Months)'
      ELSE 'Inactive'
    END AS status
  FROM telecom_customers
  WHERE start_date <= '2023-08-31'
),

-- Step 2: Segment customers by tenure and plan type
segmented_customers AS (
  SELECT 
    user_id,
    region,
    plan_type,
    status,
    tenure_days,
    CASE 
      WHEN tenure_days < 180 THEN 'New'
      WHEN tenure_days BETWEEN 180 AND 730 THEN 'Established'
      ELSE 'Loyal'
    END AS tenure_segment
  FROM cleaned_customers
),

-- Step 3: Aggregate to get counts by segment
segment_summary AS (
  SELECT 
    region,
    plan_type,
    tenure_segment,
    status,
    COUNT(DISTINCT user_id) AS customer_count
  FROM segmented_customers
  GROUP BY region, plan_type, tenure_segment, status
)

-- Final Output
SELECT *
FROM segment_summary
ORDER BY region, plan_type, tenure_segment, status;
