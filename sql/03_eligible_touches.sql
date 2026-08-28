-- ============================================================
-- THE LAST-TOUCH TRAP
-- 03 - 30-DAY ELIGIBLE TOUCHES
-- ============================================================

USE last_touch_trap;


-- ============================================================
-- 1. CREATE ELIGIBLE TOUCHES TABLE
-- ============================================================

DROP TABLE IF EXISTS eligible_touches;

CREATE TABLE eligible_touches (
    eligible_touch_row_id BIGINT AUTO_INCREMENT,

    customer_id VARCHAR(20) NOT NULL,
    converted_at DATETIME NOT NULL,

    touch_ts DATETIME NOT NULL,
    channel VARCHAR(50) NOT NULL,
    campaign VARCHAR(100),
    device VARCHAR(20),

    days_before_conversion DECIMAL(10,4),

    PRIMARY KEY (eligible_touch_row_id),

    INDEX idx_eligible_customer (customer_id),
    INDEX idx_eligible_conversion (converted_at),
    INDEX idx_eligible_touch_time (touch_ts),
    INDEX idx_eligible_channel (channel)
);


-- ============================================================
-- 2. INSERT TOUCHES WITHIN THE 30-DAY ATTRIBUTION WINDOW
-- ============================================================

INSERT INTO eligible_touches (
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device,
    days_before_conversion
)

SELECT
    fc.customer_id,
    fc.converted_at,

    t.touch_ts,
    t.channel,
    t.campaign,
    t.device,

    TIMESTAMPDIFF(
        SECOND,
        t.touch_ts,
        fc.converted_at
    ) / 86400.0 AS days_before_conversion

FROM first_conversions fc

INNER JOIN touches t
    ON fc.customer_id = t.customer_id

WHERE fc.converted_at >= '2026-04-01 00:00:00'
  AND fc.converted_at < '2026-07-01 00:00:00'

  AND t.touch_ts >= DATE_SUB(
        fc.converted_at,
        INTERVAL 30 DAY
      )

  AND t.touch_ts <= fc.converted_at;


-- ============================================================
-- 3. TOTAL ELIGIBLE TOUCH ROWS
-- ============================================================

SELECT
    COUNT(*) AS eligible_touch_rows
FROM eligible_touches;


-- ============================================================
-- 4. UNIQUE CUSTOMERS WITH AT LEAST ONE ELIGIBLE TOUCH
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS customers_with_eligible_touches
FROM eligible_touches;


-- ============================================================
-- 5. Q2 CONVERTED CUSTOMERS WITH NO ELIGIBLE TOUCH
-- ============================================================

SELECT
    COUNT(*) AS converted_customers_without_eligible_touch
FROM first_conversions fc

LEFT JOIN eligible_touches et
    ON fc.customer_id = et.customer_id

WHERE fc.converted_at >= '2026-04-01 00:00:00'
  AND fc.converted_at < '2026-07-01 00:00:00'

  AND et.customer_id IS NULL;


-- ============================================================
-- 6. NUMBER OF ELIGIBLE TOUCHES PER CUSTOMER
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS eligible_touch_count
FROM eligible_touches
GROUP BY customer_id
ORDER BY eligible_touch_count DESC;


-- ============================================================
-- 7. SUMMARY OF JOURNEY LENGTH
-- ============================================================

SELECT
    MIN(eligible_touch_count) AS minimum_touches,
    MAX(eligible_touch_count) AS maximum_touches,
    ROUND(AVG(eligible_touch_count), 2) AS average_touches
FROM (
    SELECT
        customer_id,
        COUNT(*) AS eligible_touch_count
    FROM eligible_touches
    GROUP BY customer_id
) x;


-- ============================================================
-- 8. CHANNEL DISTRIBUTION OF ELIGIBLE TOUCHES
-- ============================================================

SELECT
    channel,
    COUNT(*) AS eligible_touch_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM eligible_touches
GROUP BY channel
ORDER BY eligible_touch_rows DESC;


-- ============================================================
-- 9. DEVICE DISTRIBUTION
-- ============================================================

SELECT
    LOWER(TRIM(device)) AS device,
    COUNT(*) AS eligible_touch_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM eligible_touches
GROUP BY LOWER(TRIM(device))
ORDER BY eligible_touch_rows DESC;


-- ============================================================
-- 10. CHECK TOUCHES BEFORE THE 30-DAY WINDOW
-- ============================================================

SELECT
    COUNT(*) AS touches_outside_30_day_window
FROM first_conversions fc

INNER JOIN touches t
    ON fc.customer_id = t.customer_id

WHERE fc.converted_at >= '2026-04-01 00:00:00'
  AND fc.converted_at < '2026-07-01 00:00:00'

  AND (
        t.touch_ts < DATE_SUB(
            fc.converted_at,
            INTERVAL 30 DAY
        )
        OR t.touch_ts > fc.converted_at
      );


-- ============================================================
-- 11. VERIFY NO ELIGIBLE TOUCH IS AFTER CONVERSION
-- ============================================================

SELECT
    COUNT(*) AS touches_after_conversion
FROM eligible_touches
WHERE touch_ts > converted_at;


-- ============================================================
-- 12. VERIFY NO ELIGIBLE TOUCH IS MORE THAN 30 DAYS OLD
-- ============================================================

SELECT
    COUNT(*) AS touches_older_than_30_days
FROM eligible_touches
WHERE touch_ts < DATE_SUB(
    converted_at,
    INTERVAL 30 DAY
);


-- ============================================================
-- 13. SAMPLE CUSTOMER JOURNEYS
-- ============================================================

SELECT
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device,
    days_before_conversion
FROM eligible_touches
ORDER BY customer_id, touch_ts
LIMIT 100;
