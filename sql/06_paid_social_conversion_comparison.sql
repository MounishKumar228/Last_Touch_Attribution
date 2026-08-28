-- ============================================================
-- THE LAST-TOUCH TRAP
-- 06 - PAID SOCIAL CONVERSION COMPARISON
-- ============================================================

USE last_touch_trap;


-- ============================================================
-- 1. BUILD UNIQUE CUSTOMER POPULATION
-- ============================================================

DROP TABLE IF EXISTS customer_paid_social_exposure;

CREATE TABLE customer_paid_social_exposure (
    customer_id VARCHAR(20) NOT NULL,
    converted_flag TINYINT NOT NULL,
    paid_social_exposed TINYINT NOT NULL,

    PRIMARY KEY (customer_id)
);


INSERT INTO customer_paid_social_exposure (
    customer_id,
    converted_flag,
    paid_social_exposed
)

SELECT
    c.customer_id,

    CASE
        WHEN fc.customer_id IS NOT NULL THEN 1
        ELSE 0
    END AS converted_flag,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM touches t
            WHERE t.customer_id = c.customer_id
              AND LOWER(TRIM(t.channel)) = 'paid_social'
        )
        THEN 1
        ELSE 0
    END AS paid_social_exposed

FROM (
    SELECT DISTINCT customer_id
    FROM touches
) c

LEFT JOIN first_conversions fc
    ON c.customer_id = fc.customer_id
    AND fc.converted_at >= '2026-04-01 00:00:00'
    AND fc.converted_at < '2026-07-01 00:00:00';


-- ============================================================
-- 2. OVERALL CONVERSION RATE
-- ============================================================

SELECT
    COUNT(*) AS total_customers,

    SUM(converted_flag) AS converters,

    ROUND(
        SUM(converted_flag) * 100.0 / COUNT(*),
        2
    ) AS overall_conversion_rate_pct

FROM customer_paid_social_exposure;


-- ============================================================
-- 3. CONVERSION RATE BY PAID SOCIAL EXPOSURE
-- ============================================================

SELECT
    CASE
        WHEN paid_social_exposed = 1
        THEN 'Paid Social Exposed'
        ELSE 'No Paid Social Exposure'
    END AS paid_social_group,

    COUNT(*) AS customers,

    SUM(converted_flag) AS converters,

    ROUND(
        SUM(converted_flag) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate_pct

FROM customer_paid_social_exposure

GROUP BY paid_social_exposed

ORDER BY paid_social_exposed DESC;


-- ============================================================
-- 4. CONVERSION RATE DIFFERENCE
-- ============================================================

SELECT

    MAX(
        CASE
            WHEN paid_social_exposed = 1
            THEN conversion_rate
        END
    ) AS paid_social_exposed_rate,

    MAX(
        CASE
            WHEN paid_social_exposed = 0
            THEN conversion_rate
        END
    ) AS non_exposed_rate,

    MAX(
        CASE
            WHEN paid_social_exposed = 1
            THEN conversion_rate
        END
    )
    -
    MAX(
        CASE
            WHEN paid_social_exposed = 0
            THEN conversion_rate
        END
    ) AS rate_difference

FROM (
    SELECT
        paid_social_exposed,

        SUM(converted_flag) * 1.0 /
        COUNT(*) AS conversion_rate

    FROM customer_paid_social_exposure

    GROUP BY paid_social_exposed
) x;


-- ============================================================
-- 5. PAID SOCIAL EXPOSURE AMONG CONVERTERS
-- ============================================================

SELECT

    SUM(
        CASE
            WHEN converted_flag = 1
             AND paid_social_exposed = 1
            THEN 1
            ELSE 0
        END
    ) AS converted_with_paid_social,

    SUM(
        CASE
            WHEN converted_flag = 1
             AND paid_social_exposed = 0
            THEN 1
            ELSE 0
        END
    ) AS converted_without_paid_social,

    ROUND(
        SUM(
            CASE
                WHEN converted_flag = 1
                 AND paid_social_exposed = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        SUM(converted_flag),
        2
    ) AS pct_converters_exposed_to_paid_social

FROM customer_paid_social_exposure;


-- ============================================================
-- 6. PAID SOCIAL EXPOSURE AMONG NON-CONVERTERS
-- ============================================================

SELECT

    SUM(
        CASE
            WHEN converted_flag = 0
             AND paid_social_exposed = 1
            THEN 1
            ELSE 0
        END
    ) AS non_converters_with_paid_social,

    SUM(
        CASE
            WHEN converted_flag = 0
             AND paid_social_exposed = 0
            THEN 1
            ELSE 0
        END
    ) AS non_converters_without_paid_social,

    ROUND(
        SUM(
            CASE
                WHEN converted_flag = 0
                 AND paid_social_exposed = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        COUNT(*),
        2
    ) AS pct_non_converters_exposed_to_paid_social

FROM customer_paid_social_exposure

WHERE converted_flag = 0;


-- ============================================================
-- 7. PAID SOCIAL TOUCH FREQUENCY
-- ============================================================

SELECT

    CASE
        WHEN ps_touch_count = 1 THEN '1 touch'
        WHEN ps_touch_count = 2 THEN '2 touches'
        WHEN ps_touch_count = 3 THEN '3 touches'
        WHEN ps_touch_count >= 4 THEN '4+ touches'
    END AS paid_social_touch_frequency,

    COUNT(*) AS customers,

    SUM(converted_flag) AS converters,

    ROUND(
        SUM(converted_flag) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate_pct

FROM (
    SELECT
        c.customer_id,
        c.converted_flag,

        (
            SELECT COUNT(*)
            FROM touches t
            WHERE t.customer_id = c.customer_id
              AND LOWER(TRIM(t.channel)) = 'paid_social'
        ) AS ps_touch_count

    FROM customer_paid_social_exposure c

    WHERE paid_social_exposed = 1
) x

GROUP BY
    CASE
        WHEN ps_touch_count = 1 THEN '1 touch'
        WHEN ps_touch_count = 2 THEN '2 touches'
        WHEN ps_touch_count = 3 THEN '3 touches'
        WHEN ps_touch_count >= 4 THEN '4+ touches'
    END

ORDER BY
    MIN(ps_touch_count);


-- ============================================================
-- 8. FINAL SUMMARY
-- ============================================================

SELECT

    (SELECT COUNT(*)
     FROM first_conversions
     WHERE converted_at >= '2026-04-01 00:00:00'
       AND converted_at < '2026-07-01 00:00:00')
     AS q2_first_conversions,

    (SELECT COUNT(*)
     FROM paid_social_roles)
     AS conversions_with_paid_social,

    (SELECT COUNT(*)
     FROM last_touch_attribution
     WHERE LOWER(TRIM(channel)) = 'paid_social')
     AS paid_social_last_touch_conversions,

    ROUND(
        (SELECT COUNT(*)
         FROM paid_social_roles) * 100.0
        /
        (SELECT COUNT(*)
         FROM first_conversions
         WHERE converted_at >= '2026-04-01 00:00:00'
           AND converted_at < '2026-07-01 00:00:00'),
        2
    ) AS paid_social_journey_presence_pct,

    ROUND(
        (SELECT COUNT(*)
         FROM last_touch_attribution
         WHERE LOWER(TRIM(channel)) = 'paid_social') * 100.0
        /
        (SELECT COUNT(*)
         FROM last_touch_attribution),
        2
    ) AS paid_social_last_touch_pct;
