-- ============================================================
-- THE LAST-TOUCH TRAP
-- 01 - DATA QUALITY AND DUPLICATE ANALYSIS
-- ============================================================

USE lasttouchattribution;


-- ============================================================
-- 1. BASIC ROW COUNTS
-- ============================================================

SELECT
    COUNT(*) AS total_touch_rows
FROM touches;


SELECT
    COUNT(*) AS total_conversion_rows
FROM conversions;


-- ============================================================
-- 2. UNIQUE CUSTOMER COUNTS
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS unique_touch_customers
FROM touches;


SELECT
    COUNT(DISTINCT customer_id) AS unique_conversion_customers
FROM conversions;


-- ============================================================
-- 3. CUSTOMERS WITH MULTIPLE TOUCHES
-- ============================================================

  SELECT
      customer_id,
      COUNT(*) AS touch_count
  FROM touches
  GROUP BY customer_id
  HAVING COUNT(*) > 1
  ORDER BY touch_count DESC;


-- ============================================================
-- 4. NUMBER OF CUSTOMERS WITH MULTIPLE TOUCHES
-- ============================================================

SELECT
    COUNT(*) AS customers_with_multiple_touches
FROM (
    SELECT
        customer_id
    FROM touches
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) t;


-- ============================================================
-- 5. CHECK FOR EXACT DUPLICATE TOUCH ROWS
-- ============================================================

SELECT
    customer_id,
    touch_ts,
    channel,
    campaign,
    device,
    COUNT(*) AS duplicate_count
FROM touches
GROUP BY
    customer_id,
    touch_ts,
    channel,
    campaign,
    device
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 6. CUSTOMERS WITH MULTIPLE CONVERSIONS
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS conversion_count
FROM conversions
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY conversion_count DESC;


-- ============================================================
-- 7. NUMBER OF CUSTOMERS WITH MULTIPLE CONVERSIONS
-- ============================================================

SELECT
    COUNT(*) AS customers_with_multiple_conversions
FROM (
    SELECT
        customer_id
    FROM conversions
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) c;


-- ============================================================
-- 8. EXACT DUPLICATE CONVERSION ROWS
-- ============================================================

SELECT
    customer_id,
    converted_at,
    plan,
    amount_usd,
    COUNT(*) AS duplicate_count
FROM conversions
GROUP BY
    customer_id,
    converted_at,
    plan,
    amount_usd
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 9. TOUCH DATE RANGE
-- ============================================================

SELECT
    MIN(touch_ts) AS earliest_touch,
    MAX(touch_ts) AS latest_touch
FROM touches;


-- ============================================================
-- 10. CONVERSION DATE RANGE
-- ============================================================

SELECT
    MIN(converted_at) AS earliest_conversion,
    MAX(converted_at) AS latest_conversion
FROM conversions;


-- ============================================================
-- 11. CHANNEL DISTRIBUTION
-- ============================================================

SELECT
    channel,
    COUNT(*) AS touch_count,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM touches
GROUP BY channel
ORDER BY touch_count DESC;


-- ============================================================
-- 12. DEVICE DISTRIBUTION
-- ============================================================

SELECT
    LOWER(TRIM(device)) AS device,
    COUNT(*) AS touch_count,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM touches
GROUP BY LOWER(TRIM(device))
ORDER BY touch_count DESC;


-- ============================================================
-- 13. MISSING VALUES IN TOUCH DATA
-- ============================================================

SELECT
    SUM(customer_id IS NULL OR customer_id = '') AS missing_customer_id,
    SUM(touch_ts IS NULL) AS missing_touch_ts,
    SUM(channel IS NULL OR channel = '') AS missing_channel,
    SUM(campaign IS NULL OR campaign = '') AS missing_campaign,
    SUM(device IS NULL OR device = '') AS missing_device
FROM touches;


-- ============================================================
-- 14. MISSING VALUES IN CONVERSION DATA
-- ============================================================

SELECT
    SUM(customer_id IS NULL OR customer_id = '') AS missing_customer_id,
    SUM(converted_at IS NULL) AS missing_conversion_time,
    SUM(plan IS NULL OR plan = '') AS missing_plan,
    SUM(amount_usd IS NULL) AS missing_amount
FROM conversions;


-- ============================================================
-- 15. Q2 2026 CONVERSIONS
-- ============================================================

SELECT
    COUNT(*) AS q2_conversion_rows,
    COUNT(DISTINCT customer_id) AS q2_unique_customers
FROM conversions
WHERE converted_at >= '2026-04-01 00:00:00'
  AND converted_at < '2026-07-01 00:00:00';


-- ============================================================
-- 16. CONVERSIONS OUTSIDE Q2
-- ============================================================

SELECT
    COUNT(*) AS conversions_outside_q2
FROM conversions
WHERE converted_at < '2026-04-01 00:00:00'
   OR converted_at >= '2026-07-01 00:00:00';


-- ============================================================
-- 17. CUSTOMERS PRESENT IN TOUCHES BUT NEVER CONVERTED
-- ============================================================

SELECT
    COUNT(DISTINCT t.customer_id) AS touched_but_never_converted
FROM touches t
LEFT JOIN conversions c
    ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 18. CONVERTED CUSTOMERS WHO ALSO HAVE TOUCHES
-- ============================================================

SELECT
    COUNT(DISTINCT c.customer_id) AS converted_customers_with_touches
FROM conversions c
INNER JOIN touches t
    ON c.customer_id = t.customer_id;


-- ============================================================
-- 19. DATA QUALITY SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM touches) AS total_touch_rows,
    (SELECT COUNT(DISTINCT customer_id) FROM touches) AS unique_touch_customers,
    (SELECT COUNT(*) FROM conversions) AS total_conversion_rows,
    (SELECT COUNT(DISTINCT customer_id) FROM conversions) AS unique_conversion_customers,
    (
        SELECT COUNT(*)
        FROM (
            SELECT customer_id
            FROM conversions
            GROUP BY customer_id
            HAVING COUNT(*) > 1
        ) x
    ) AS customers_with_multiple_conversions;
