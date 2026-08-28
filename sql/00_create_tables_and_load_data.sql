-- ============================================================
-- THE LAST-TOUCH TRAP
-- 00 - CREATE TABLES AND LOAD DATA
-- ============================================================

USE lasttouchattribution;


-- ============================================================
-- 1. DROP EXISTING TABLES
-- ============================================================

DROP TABLE IF EXISTS conversions;
DROP TABLE IF EXISTS touches;


-- ============================================================
-- 2. CREATE TOUCHES TABLE
-- ============================================================

CREATE TABLE touches (
    touch_row_id BIGINT AUTO_INCREMENT,

    customer_id VARCHAR(20) NOT NULL,
    touch_ts DATETIME NOT NULL,
    channel VARCHAR(50) NOT NULL,
    campaign VARCHAR(100),
    device VARCHAR(20),

    PRIMARY KEY (touch_row_id),

    INDEX idx_touch_customer (customer_id),
    INDEX idx_touch_timestamp (touch_ts),
    INDEX idx_touch_channel (channel)
);


-- ============================================================
-- 3. CREATE CONVERSIONS TABLE
-- ============================================================

CREATE TABLE conversions (
    conversion_row_id BIGINT AUTO_INCREMENT,

    customer_id VARCHAR(20) NOT NULL,
    converted_at DATETIME NOT NULL,
    plan VARCHAR(50),
    amount_usd DECIMAL(10,2),

    PRIMARY KEY (conversion_row_id),

    INDEX idx_conversion_customer (customer_id),
    INDEX idx_conversion_timestamp (converted_at)
);


-- ============================================================
-- 4. CHECK LOCAL INFILE
-- ============================================================

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;


-- ============================================================
-- 5. LOAD TOUCH DATA
-- ============================================================

LOAD DATA LOCAL INFILE
'C:/Users/nagar/OneDrive/Desktop/Mounish/Datasets/The Last-Touch Trap/touches.csv'

INTO TABLE touches

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\n'

IGNORE 1 ROWS

(
    customer_id,
    touch_ts,
    channel,
    campaign,
    device
);


-- ============================================================
-- 6. LOAD CONVERSION DATA
-- ============================================================

LOAD DATA LOCAL INFILE
'C:/Users/nagar/OneDrive/Desktop/Mounish/Datasets/The Last-Touch Trap/conversions(1).csv'

INTO TABLE conversions

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\n'

IGNORE 1 ROWS

(
    customer_id,
    converted_at,
    plan,
    amount_usd
);


-- ============================================================
-- 7. VERIFY DATA LOAD
-- ============================================================

SELECT
    COUNT(*) AS total_touch_rows
FROM touches;


SELECT
    COUNT(DISTINCT customer_id) AS unique_touch_customers
FROM touches;


SELECT
    COUNT(*) AS total_conversion_rows
FROM conversions;


SELECT
    COUNT(DISTINCT customer_id) AS unique_conversion_customers
FROM conversions;


-- ============================================================
-- 8. PREVIEW DATA
-- ============================================================

SELECT *
FROM touches
LIMIT 10;


SELECT *
FROM conversions
LIMIT 10;
