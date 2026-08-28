-- ============================================================
-- THE LAST-TOUCH TRAP
-- 05 - MULTI-TOUCH ANALYSIS
-- ============================================================

USE lasttouchattribution;


-- ============================================================
-- 1. CHANNEL PRESENCE IN CONVERTING JOURNEYS
--
-- A customer is counted once for each channel they touched
-- during their eligible 30-day pre-conversion journey.
-- ============================================================

SELECT
    channel,

    COUNT(DISTINCT customer_id) AS converting_customers_touched,

    ROUND(
        COUNT(DISTINCT customer_id) * 100.0 /
        (SELECT COUNT(*) FROM first_conversions
         WHERE converted_at >= '2026-04-01 00:00:00'
           AND converted_at < '2026-07-01 00:00:00'),
        2
    ) AS journey_presence_pct

FROM eligible_touches

GROUP BY channel

ORDER BY converting_customers_touched DESC;


-- ============================================================
-- 2. PAID SOCIAL JOURNEY PRESENCE
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS paid_social_converting_customers,

    ROUND(
        COUNT(DISTINCT customer_id) * 100.0 /
        (SELECT COUNT(*) FROM first_conversions
         WHERE converted_at >= '2026-04-01 00:00:00'
           AND converted_at < '2026-07-01 00:00:00'),
        2
    ) AS paid_social_journey_presence_pct

FROM eligible_touches

WHERE LOWER(TRIM(channel)) = 'paid_social';


-- ============================================================
-- 3. FIRST-TOUCH CHANNEL
--
-- Find the earliest eligible touch for each customer.
-- ============================================================

DROP TABLE IF EXISTS first_touch_attribution;

CREATE TABLE first_touch_attribution (
    customer_id VARCHAR(20) NOT NULL,
    converted_at DATETIME NOT NULL,

    touch_ts DATETIME NOT NULL,
    channel VARCHAR(50) NOT NULL,
    campaign VARCHAR(100),
    device VARCHAR(20),

    PRIMARY KEY (customer_id),

    INDEX idx_first_touch_channel (channel)
);


INSERT INTO first_touch_attribution (
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device
)

SELECT
    customer_id,
    converted_at,
    touch_ts,
    channel,
    campaign,
    device

FROM (
    SELECT
        et.*,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY
                touch_ts ASC,
                channel ASC,
                campaign ASC,
                device ASC,
                eligible_touch_row_id ASC
        ) AS rn

    FROM eligible_touches et
) ranked

WHERE rn = 1;


-- ============================================================
-- 4. FIRST-TOUCH ATTRIBUTION BY CHANNEL
-- ============================================================

SELECT
    channel,

    COUNT(*) AS first_touch_conversions,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM first_touch_attribution),
        2
    ) AS first_touch_share_pct

FROM first_touch_attribution

GROUP BY channel

ORDER BY first_touch_conversions DESC;


-- ============================================================
-- 5. PAID SOCIAL FIRST-TOUCH RESULT
-- ============================================================

SELECT
    COUNT(*) AS paid_social_first_touch_conversions,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM first_touch_attribution),
        2
    ) AS paid_social_first_touch_pct

FROM first_touch_attribution

WHERE LOWER(TRIM(channel)) = 'paid_social';


-- ============================================================
-- 6. CLASSIFY PAID SOCIAL ROLE IN EACH JOURNEY
--
-- FIRST TOUCH
-- LAST TOUCH
-- ASSISTING TOUCH
-- ============================================================

DROP TABLE IF EXISTS paid_social_roles;

CREATE TABLE paid_social_roles (
    customer_id VARCHAR(20) NOT NULL,
    converted_at DATETIME NOT NULL,

    paid_social_touch_count INT NOT NULL,

    first_touch_channel VARCHAR(50),
    last_touch_channel VARCHAR(50),

    paid_social_role VARCHAR(30),

    PRIMARY KEY (customer_id)
);


INSERT INTO paid_social_roles (
    customer_id,
    converted_at,
    paid_social_touch_count,
    first_touch_channel,
    last_touch_channel,
    paid_social_role
)

SELECT
    ps.customer_id,
    ps.converted_at,
    ps.paid_social_touch_count,

    ft.channel AS first_touch_channel,
    lt.channel AS last_touch_channel,

    CASE

        WHEN LOWER(TRIM(ft.channel)) = 'paid_social'
             AND LOWER(TRIM(lt.channel)) = 'paid_social'
        THEN 'First and Last'

        WHEN LOWER(TRIM(ft.channel)) = 'paid_social'
        THEN 'First Touch'

        WHEN LOWER(TRIM(lt.channel)) = 'paid_social'
        THEN 'Last Touch'

        ELSE 'Assisting Touch'

    END AS paid_social_role

FROM (
    SELECT
        customer_id,
        converted_at,
        COUNT(*) AS paid_social_touch_count

    FROM eligible_touches

    WHERE LOWER(TRIM(channel)) = 'paid_social'

    GROUP BY
        customer_id,
        converted_at
) ps

INNER JOIN first_touch_attribution ft
    ON ps.customer_id = ft.customer_id

INNER JOIN last_touch_attribution lt
    ON ps.customer_id = lt.customer_id;


-- ============================================================
-- 7. PAID SOCIAL ROLE DISTRIBUTION
-- ============================================================

SELECT
    paid_social_role,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM paid_social_roles),
        2
    ) AS pct_of_paid_social_journeys

FROM paid_social_roles

GROUP BY paid_social_role

ORDER BY customers DESC;


-- ============================================================
-- 8. PAID SOCIAL ASSISTING CONVERSIONS
-- ============================================================

SELECT
    COUNT(*) AS paid_social_assisted_conversions

FROM paid_social_roles

WHERE paid_social_role = 'Assisting Touch';


-- ============================================================
-- 9. PAID SOCIAL TOTAL JOURNEY CONTRIBUTION
-- ============================================================

SELECT
    COUNT(*) AS conversions_with_paid_social,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM last_touch_attribution),
        2
    ) AS pct_of_all_converting_customers

FROM paid_social_roles;


-- ============================================================
-- 10. COMPARE CHANNEL JOURNEY PRESENCE VS LAST TOUCH
-- ============================================================

SELECT
    ep.channel,

    COUNT(DISTINCT ep.customer_id) AS journey_customers,

    ROUND(
        COUNT(DISTINCT ep.customer_id) * 100.0 /
        (SELECT COUNT(*) FROM last_touch_attribution),
        2
    ) AS journey_presence_pct,

    COALESCE(
        lt.last_touch_customers,
        0
    ) AS last_touch_customers,

    ROUND(
        COALESCE(lt.last_touch_customers, 0) * 100.0 /
        (SELECT COUNT(*) FROM last_touch_attribution),
        2
    ) AS last_touch_pct

FROM eligible_touches ep

LEFT JOIN (
    SELECT
        channel,
        COUNT(*) AS last_touch_customers

    FROM last_touch_attribution

    GROUP BY channel
) lt
    ON LOWER(TRIM(ep.channel)) = LOWER(TRIM(lt.channel))

GROUP BY
    ep.channel,
    lt.last_touch_customers

ORDER BY journey_presence_pct DESC;


-- ============================================================
-- 11. PAID SOCIAL JOURNEY LENGTH
-- ============================================================

SELECT
    ROUND(AVG(journey_touch_count), 2) AS avg_journey_length,
    MIN(journey_touch_count) AS minimum_journey_length,
    MAX(journey_touch_count) AS maximum_journey_length

FROM (
    SELECT
        customer_id,
        COUNT(*) AS journey_touch_count

    FROM eligible_touches

    WHERE customer_id IN (
        SELECT customer_id
        FROM paid_social_roles
    )

    GROUP BY customer_id
) x;


-- ============================================================
-- 12. PAID SOCIAL TOUCH POSITION
--
-- Show where Paid Social occurs in the customer's journey.
-- ============================================================

SELECT
    CASE

        WHEN first_touch_channel = 'paid_social'
             AND last_touch_channel = 'paid_social'
        THEN 'First and Last'

        WHEN first_touch_channel = 'paid_social'
        THEN 'First'

        WHEN last_touch_channel = 'paid_social'
        THEN 'Last'

        ELSE 'Middle / Assisting'

    END AS paid_social_position,

    COUNT(*) AS customers

FROM paid_social_roles

GROUP BY
    CASE

        WHEN first_touch_channel = 'paid_social'
             AND last_touch_channel = 'paid_social'
        THEN 'First and Last'

        WHEN first_touch_channel = 'paid_social'
        THEN 'First'

        WHEN last_touch_channel = 'paid_social'
        THEN 'Last'

        ELSE 'Middle / Assisting'

    END

ORDER BY customers DESC;
