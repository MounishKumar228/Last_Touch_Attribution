-- ============================================================
-- THE LAST-TOUCH TRAP
-- 04 - LAST-TOUCH ATTRIBUTION
-- ============================================================

USE lasttouchattribution;


-- ============================================================
-- 1. CREATE LAST-TOUCH TABLE
-- ============================================================

DROP TABLE IF EXISTS last_touch_attribution;

CREATE TABLE last_touch_attribution (
    customer_id VARCHAR(20) NOT NULL,
    converted_at DATETIME NOT NULL,

    touch_ts DATETIME NOT NULL,
    channel VARCHAR(50) NOT NULL,
    campaign VARCHAR(100),
    device VARCHAR(20),

    days_before_conversion DECIMAL(10,4),

    PRIMARY KEY (customer_id),

    INDEX idx_last_touch_channel (channel),
    INDEX idx_last_touch_conversion (converted_at)
);


-- ============================================================
-- 2. RANK ELIGIBLE TOUCHES
--
-- ROW_NUMBER assigns exactly one last touch per customer.
--
-- Latest touch_ts = last touch.
-- channel/campaign are used as deterministic tie-breakers.
-- ============================================================

INSERT INTO last_touch_attribution (
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device,
    days_before_conversion
)

SELECT
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device,
    days_before_conversion

FROM (
    SELECT
        et.*,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY
                touch_ts DESC,
                channel ASC,
                campaign ASC,
                device ASC,
                eligible_touch_row_id DESC
        ) AS rn

    FROM eligible_touches et
) ranked

WHERE rn = 1;


-- ============================================================
-- 3. VERIFY ONE LAST TOUCH PER CUSTOMER
-- ============================================================

SELECT
    COUNT(*) AS last_touch_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM last_touch_attribution;


-- ============================================================
-- 4. CHECK FOR DUPLICATE CUSTOMERS
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS row_count
FROM last_touch_attribution
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. LAST-TOUCH ATTRIBUTION BY CHANNEL
-- ============================================================

SELECT
    channel,
    COUNT(*) AS attributed_conversions,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM last_touch_attribution),
        2
    ) AS attribution_share_pct

FROM last_touch_attribution

GROUP BY channel

ORDER BY attributed_conversions DESC;


-- ============================================================
-- 6. PAID SOCIAL LAST-TOUCH RESULT
-- ============================================================

SELECT
    COUNT(*) AS paid_social_last_touch_conversions,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM last_touch_attribution),
        2
    ) AS paid_social_last_touch_pct

FROM last_touch_attribution

WHERE LOWER(TRIM(channel)) = 'paid social';


-- ============================================================
-- 7. NUMBER OF Q2 CONVERSIONS
-- ============================================================

SELECT
    COUNT(*) AS total_q2_first_conversions
FROM last_touch_attribution;


-- ============================================================
-- 8. LAST-TOUCH ATTRIBUTION BY MONTH
-- ============================================================

SELECT
    DATE_FORMAT(converted_at, '%Y-%m') AS conversion_month,
    channel,
    COUNT(*) AS attributed_conversions,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY DATE_FORMAT(converted_at, '%Y-%m')
        ),
        2
    ) AS attribution_share_pct

FROM last_touch_attribution

GROUP BY
    DATE_FORMAT(converted_at, '%Y-%m'),
    channel

ORDER BY
    conversion_month,
    attributed_conversions DESC;


-- ============================================================
-- 9. LAST-TOUCH ATTRIBUTION BY DEVICE
-- ============================================================

SELECT
    LOWER(TRIM(device)) AS device,
    channel,
    COUNT(*) AS attributed_conversions

FROM last_touch_attribution

GROUP BY
    LOWER(TRIM(device)),
    channel

ORDER BY
    device,
    attributed_conversions DESC;


-- ============================================================
-- 10. PAID SOCIAL LAST TOUCH BY DEVICE
-- ============================================================

SELECT
    LOWER(TRIM(device)) AS device,

    COUNT(*) AS paid_social_last_touch_conversions,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY LOWER(TRIM(device))
        ),
        2
    ) AS paid_social_share_pct

FROM last_touch_attribution

WHERE LOWER(TRIM(channel)) = 'paid social'

GROUP BY LOWER(TRIM(device))

ORDER BY device;


-- ============================================================
-- 11. LAST TOUCH TIMING
-- ============================================================

SELECT
    channel,

    ROUND(
        AVG(days_before_conversion),
        2
    ) AS avg_days_before_conversion,

    ROUND(
        MIN(days_before_conversion),
        2
    ) AS min_days_before_conversion,

    ROUND(
        MAX(days_before_conversion),
        2
    ) AS max_days_before_conversion

FROM last_touch_attribution

GROUP BY channel

ORDER BY avg_days_before_conversion;


-- ============================================================
-- 12. SAMPLE LAST-TOUCH JOURNEYS
-- ============================================================

SELECT
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device,
    days_before_conversion

FROM last_touch_attribution

ORDER BY converted_at, customer_id

LIMIT 100;
