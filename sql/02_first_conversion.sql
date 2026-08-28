-- ============================================================
-- THE LAST-TOUCH TRAP
-- 02 - FIRST CONVERSION POPULATION
-- ============================================================

USE lasttouchattribution;


-- ============================================================
-- 1. INSPECT MULTIPLE CONVERSIONS
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS conversion_count,
    MIN(converted_at) AS first_conversion_at,
    MAX(converted_at) AS last_conversion_at
FROM conversions
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY conversion_count DESC;


-- ============================================================
-- 2. CREATE CLEAN FIRST-CONVERSION TABLE
-- ============================================================

DROP TABLE IF EXISTS first_conversions;

CREATE TABLE first_conversions (
    customer_id VARCHAR(20) NOT NULL,
    converted_at DATETIME NOT NULL,
    plan VARCHAR(50),
    amount_usd DECIMAL(10,2),

    PRIMARY KEY (customer_id),

    INDEX idx_first_conversion_time (converted_at)
);


-- ============================================================
-- 3. KEEP ONLY EACH CUSTOMER'S FIRST CONVERSION
-- ============================================================

INSERT INTO first_conversions (
    customer_id,
    converted_at,
    plan,
    amount_usd
)
SELECT
    c.customer_id,
    c.converted_at,
    c.plan,
    c.amount_usd
FROM conversions c
INNER JOIN (
    SELECT
        customer_id,
        MIN(converted_at) AS first_conversion_at
    FROM conversions
    GROUP BY customer_id
) first_c
    ON c.customer_id = first_c.customer_id
   AND c.converted_at = first_c.first_conversion_at;


-- ============================================================
-- 4. VERIFY FIRST-CONVERSION TABLE
-- ============================================================

SELECT
    COUNT(*) AS first_conversion_rows
FROM first_conversions;


SELECT
    COUNT(DISTINCT customer_id) AS unique_first_conversion_customers
FROM first_conversions;


-- ============================================================
-- 5. VERIFY THAT EACH CUSTOMER NOW APPEARS ONCE
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS row_count
FROM first_conversions
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 6. COMPARE RAW VS CLEAN POPULATION
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM conversions) AS raw_conversion_rows,

    (SELECT COUNT(DISTINCT customer_id)
     FROM conversions) AS raw_unique_customers,

    (SELECT COUNT(*) FROM first_conversions)
        AS first_conversion_rows,

    (SELECT COUNT(DISTINCT customer_id)
     FROM first_conversions)
        AS first_conversion_customers;


-- ============================================================
-- 7. Q2 2026 FIRST CONVERSIONS
-- ============================================================

SELECT
    COUNT(*) AS q2_first_conversions,
    COUNT(DISTINCT customer_id) AS q2_unique_customers
FROM first_conversions
WHERE converted_at >= '2026-04-01 00:00:00'
  AND converted_at < '2026-07-01 00:00:00';


-- ============================================================
-- 8. FIRST CONVERSIONS OUTSIDE Q2
-- ============================================================

SELECT
    COUNT(*) AS first_conversions_outside_q2
FROM first_conversions
WHERE converted_at < '2026-04-01 00:00:00'
   OR converted_at >= '2026-07-01 00:00:00';


-- ============================================================
-- 9. Q2 CONVERSION DISTRIBUTION BY MONTH
-- ============================================================

SELECT
    DATE_FORMAT(converted_at, '%Y-%m') AS conversion_month,
    COUNT(*) AS conversions
FROM first_conversions
WHERE converted_at >= '2026-04-01 00:00:00'
  AND converted_at < '2026-07-01 00:00:00'
GROUP BY DATE_FORMAT(converted_at, '%Y-%m')
ORDER BY conversion_month;


-- ============================================================
-- 10. Q2 CONVERSION DISTRIBUTION BY PLAN
-- ============================================================

SELECT
    plan,
    COUNT(*) AS conversions,
    SUM(amount_usd) AS total_revenue
FROM first_conversions
WHERE converted_at >= '2026-04-01 00:00:00'
  AND converted_at < '2026-07-01 00:00:00'
GROUP BY plan
ORDER BY conversions DESC;
