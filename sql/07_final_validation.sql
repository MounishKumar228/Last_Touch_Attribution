-- 1. First-conversion deduplication
SELECT
    COUNT(*) AS first_conversions,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM first_conversions;
-- Expected: 5939 | 5939

-- 2. Check duplicate first conversions
SELECT
    customer_id,
    COUNT(*) AS conversion_count
FROM first_conversions
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- 3. Check eligible 30-day touches
SELECT
    COUNT(*) AS eligible_touches,
    COUNT(DISTINCT customer_id) AS customers_with_eligible_touches
FROM eligible_touches;

-- 4. Check last-touch attribution
SELECT
    COUNT(*) AS attributed_conversions,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM last_touch_attribution;
-- Expected: 5939 | 5939

-- 5. Check Paid Social reconciliation
SELECT
    COUNT(*) AS paid_social_last_touch,
    
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM last_touch_attribution),
        2
    ) AS paid_social_last_touch_pct

FROM last_touch_attribution

WHERE LOWER(TRIM(channel)) = 'paid_social';
-- Expected: 173 | 2.91

-- 6. Check Paid Social journey presence
SELECT
    COUNT(*) AS paid_social_journey_customers,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM first_conversions),
        2
    ) AS journey_presence_pct

FROM paid_social_roles;

-- 7. Check the statistical result
/*
Exposed conversion rate       15.62%
Unexposed conversion rate     14.40%
Difference                     1.22 pp (15.62[paid social exposed] - 14.40[no paid social exposure])
z-score                        3.29
*/
