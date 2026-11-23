-- SQL Stock Market Analysis
-- Final Submission
-- Database: stock_market_analysis

CREATE DATABASE IF NOT EXISTS stock_market_analysis;

USE stock_market_analysis;

-- ============================================================
-- PART 1: BASIC DATA CHECKS
-- ============================================================

-- 1. Number of trading days and date range for Bajaj Auto

SELECT
    COUNT(*) AS trading_days,
    MIN(STR_TO_DATE(`Date`, '%d-%M-%Y')) AS first_day,
    MAX(STR_TO_DATE(`Date`, '%d-%M-%Y')) AS last_day
FROM bajaj_auto;


-- 2. Eicher Motors - five highest closing prices

SELECT
    `Date`,
    `Close Price`
FROM eicher_motors
ORDER BY `Close Price` DESC
LIMIT 5;


-- 3. TCS average closing price year by year

SELECT
    YEAR(STR_TO_DATE(`Date`, '%d-%M-%Y')) AS year,
    ROUND(AVG(`Close Price`), 2) AS avg_close
FROM tcs
GROUP BY YEAR(STR_TO_DATE(`Date`, '%d-%M-%Y'))
ORDER BY year;


-- 4. Missing deliverable quantities across all stocks

SELECT 'Bajaj Auto' AS stock, `Date` AS trade_date
FROM bajaj_auto
WHERE `Deliverable Quantity` IS NULL

UNION ALL

SELECT 'Eicher Motors', `Date`
FROM eicher_motors
WHERE `Deliverable Quantity` IS NULL

UNION ALL

SELECT 'Hero Motocorp', `Date`
FROM hero_motocorp
WHERE `Deliverable Quantity` IS NULL

UNION ALL

SELECT 'Infosys', `Date`
FROM infosys
WHERE `Deliverable Quantity` IS NULL

UNION ALL

SELECT 'TCS', `Date`
FROM tcs
WHERE `Deliverable Quantity` IS NULL

UNION ALL

SELECT 'TVS Motors', `Date`
FROM tvs_motors
WHERE `Deliverable Quantity` IS NULL;

-- ============================================================
-- PART 2: MOVING AVERAGES - BAJAJ AUTO
-- ============================================================

DROP TABLE IF EXISTS bajaj1;

CREATE TABLE bajaj1 AS
SELECT
    trade_date,
    close_price,

    CASE
        WHEN rn >= 20 THEN
            ROUND(
                AVG(close_price) OVER (
                    ORDER BY trade_date
                    ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
                ),
                2
            )
    END AS ma20,

    CASE
        WHEN rn >= 50 THEN
            ROUND(
                AVG(close_price) OVER (
                    ORDER BY trade_date
                    ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
                ),
                2
            )
    END AS ma50

FROM
(
    SELECT
        STR_TO_DATE(`Date`, '%d-%M-%Y') AS trade_date,
        `Close Price` AS close_price,
        ROW_NUMBER() OVER (
            ORDER BY STR_TO_DATE(`Date`, '%d-%M-%Y')
        ) AS rn
    FROM bajaj_auto
) AS numbered;


-- Check Bajaj Auto moving averages

SELECT *
FROM bajaj1
ORDER BY trade_date
LIMIT 55;

-- ============================================================
-- PART 3: BAJAJ AUTO BUY/SELL SIGNALS
-- ============================================================

DROP TABLE IF EXISTS bajaj2;

CREATE TABLE bajaj2 AS
WITH lagged AS
(
    SELECT
        trade_date,
        close_price,
        ma20,
        ma50,

        LAG(ma20) OVER (
            ORDER BY trade_date
        ) AS prev_ma20,

        LAG(ma50) OVER (
            ORDER BY trade_date
        ) AS prev_ma50

    FROM bajaj1
)

SELECT
    trade_date,
    close_price,
    ma20,
    ma50,

    CASE
        WHEN ma20 IS NULL
          OR ma50 IS NULL
          OR prev_ma20 IS NULL
          OR prev_ma50 IS NULL
        THEN 'Hold'

        WHEN ma20 > ma50
          AND prev_ma20 <= prev_ma50
        THEN 'Buy'

        WHEN ma20 < ma50
          AND prev_ma20 >= prev_ma50
        THEN 'Sell'

        ELSE 'Hold'
    END AS `signal`

FROM lagged;


-- Check signal counts

SELECT
    `signal`,
    COUNT(*) AS days
FROM bajaj2
GROUP BY `signal`
ORDER BY `signal`;


-- Check signal on 2018-06-21

SELECT
    `signal`
FROM bajaj2
WHERE trade_date = '2018-06-21';

-- ============================================================
-- PART 4: BUY/SELL SIGNALS FOR ALL SIX STOCKS
-- ============================================================

WITH prices AS
(
    SELECT 'Bajaj Auto' AS stock,
           STR_TO_DATE(`Date`, '%d-%M-%Y') AS trade_date,
           `Close Price` AS close_price
    FROM bajaj_auto

    UNION ALL

    SELECT 'Eicher Motors',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM eicher_motors

    UNION ALL

    SELECT 'Hero Motocorp',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM hero_motocorp

    UNION ALL

    SELECT 'Infosys',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM infosys

    UNION ALL

    SELECT 'TCS',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM tcs

    UNION ALL

    SELECT 'TVS Motors',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM tvs_motors
),
numbered AS
(
    SELECT
        stock,
        trade_date,
        close_price,
        ROW_NUMBER() OVER (
            PARTITION BY stock
            ORDER BY trade_date
        ) AS rn
    FROM prices
),
moving_averages AS
(
    SELECT
        stock,
        trade_date,
        close_price,
        CASE
            WHEN rn >= 20 THEN
                AVG(close_price) OVER (
                    PARTITION BY stock
                    ORDER BY trade_date
                    ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
                )
        END AS ma20,
        CASE
            WHEN rn >= 50 THEN
                AVG(close_price) OVER (
                    PARTITION BY stock
                    ORDER BY trade_date
                    ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
                )
        END AS ma50
    FROM numbered
),
lagged AS
(
    SELECT
        stock,
        trade_date,
        close_price,
        ma20,
        ma50,
        LAG(ma20) OVER (
            PARTITION BY stock
            ORDER BY trade_date
        ) AS prev_ma20,
        LAG(ma50) OVER (
            PARTITION BY stock
            ORDER BY trade_date
        ) AS prev_ma50
    FROM moving_averages
),
signals AS
(
    SELECT
        stock,
        trade_date,
        CASE
            WHEN ma20 IS NULL
              OR ma50 IS NULL
              OR prev_ma20 IS NULL
              OR prev_ma50 IS NULL
            THEN 'Hold'

            WHEN ma20 > ma50
              AND prev_ma20 <= prev_ma50
            THEN 'Buy'

            WHEN ma20 < ma50
              AND prev_ma20 >= prev_ma50
            THEN 'Sell'

            ELSE 'Hold'
        END AS `signal`
    FROM lagged
),
latest AS
(
    SELECT
        stock,
        trade_date,
        `signal`,
        ROW_NUMBER() OVER (
            PARTITION BY stock
            ORDER BY trade_date DESC
        ) AS rn
    FROM signals
    WHERE `signal` <> 'Hold'
)
SELECT
    s.stock,
    SUM(s.`signal` = 'Buy') AS buys,
    SUM(s.`signal` = 'Sell') AS sells,
    l.trade_date AS last_signal_date,
    l.`signal` AS last_signal
FROM signals s
LEFT JOIN latest l
    ON s.stock = l.stock
   AND l.rn = 1
GROUP BY
    s.stock,
    l.trade_date,
    l.`signal`
ORDER BY s.stock;

-- ============================================================
-- PART 5: FIRST VS LAST CLOSING PRICE
-- ============================================================

WITH prices AS
(
    SELECT
        'Bajaj Auto' AS stock,
        STR_TO_DATE(`Date`, '%d-%M-%Y') AS trade_date,
        `Close Price` AS close_price
    FROM bajaj_auto

    UNION ALL
    SELECT
        'Eicher Motors',
        STR_TO_DATE(`Date`, '%d-%M-%Y'),
        `Close Price`
    FROM eicher_motors

    UNION ALL
    SELECT
        'Hero Motocorp',
        STR_TO_DATE(`Date`, '%d-%M-%Y'),
        `Close Price`
    FROM hero_motocorp

    UNION ALL
    SELECT
        'Infosys',
        STR_TO_DATE(`Date`, '%d-%M-%Y'),
        `Close Price`
    FROM infosys

    UNION ALL
    SELECT
        'TCS',
        STR_TO_DATE(`Date`, '%d-%M-%Y'),
        `Close Price`
    FROM tcs

    UNION ALL
    SELECT
        'TVS Motors',
        STR_TO_DATE(`Date`, '%d-%M-%Y'),
        `Close Price`
    FROM tvs_motors
),

ranked AS
(
    SELECT
        stock,
        trade_date,
        close_price,

        ROW_NUMBER() OVER (
            PARTITION BY stock
            ORDER BY trade_date
        ) AS first_row,

        ROW_NUMBER() OVER (
            PARTITION BY stock
            ORDER BY trade_date DESC
        ) AS last_row

    FROM prices
)

SELECT
    stock,

    MAX(
        CASE WHEN first_row = 1
        THEN close_price END
    ) AS first_close,

    MAX(
        CASE WHEN last_row = 1
        THEN close_price END
    ) AS last_close,

    ROUND(
        100 *
        (
            MAX(CASE WHEN last_row = 1 THEN close_price END)
            -
            MAX(CASE WHEN first_row = 1 THEN close_price END)
        )
        /
        MAX(CASE WHEN first_row = 1 THEN close_price END),
        1
    ) AS pct_change

FROM ranked
GROUP BY stock
ORDER BY pct_change DESC;

-- ============================================================
-- PART 6: WORST ONE-DAY PERCENTAGE FALL
-- ============================================================

WITH prices AS
(
    SELECT 'Bajaj Auto' AS stock,
           STR_TO_DATE(`Date`, '%d-%M-%Y') AS trade_date,
           `Close Price` AS close_price
    FROM bajaj_auto

    UNION ALL
    SELECT 'Eicher Motors',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM eicher_motors

    UNION ALL
    SELECT 'Hero Motocorp',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM hero_motocorp

    UNION ALL
    SELECT 'Infosys',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM infosys

    UNION ALL
    SELECT 'TCS',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM tcs

    UNION ALL
    SELECT 'TVS Motors',
           STR_TO_DATE(`Date`, '%d-%M-%Y'),
           `Close Price`
    FROM tvs_motors
),

daily_change AS
(
    SELECT
        stock,
        trade_date,
        close_price,

        LAG(close_price) OVER (
            PARTITION BY stock
            ORDER BY trade_date
        ) AS previous_close

    FROM prices
),

worst_days AS
(
    SELECT
        stock,
        trade_date,
        close_price,
        previous_close,

        100.0 *
        (close_price - previous_close)
        / previous_close AS pct_change

    FROM daily_change
    WHERE previous_close IS NOT NULL
)

SELECT
    stock,
    trade_date,
    ROUND(close_price, 2) AS close_price,
    ROUND(previous_close, 2) AS previous_close,
    ROUND(pct_change, 2) AS pct_change

FROM worst_days w

WHERE pct_change =
(
    SELECT MIN(w2.pct_change)
    FROM worst_days w2
    WHERE w2.stock = w.stock
)

ORDER BY pct_change ASC;

-- ============================================================
-- PART 7: BONUS-ADJUSTED PRICES
-- ============================================================

WITH adjusted AS
(
    SELECT
        'TCS' AS stock,
        STR_TO_DATE(`Date`, '%d-%M-%Y') AS trade_date,

        CASE
            WHEN STR_TO_DATE(`Date`, '%d-%M-%Y') < '2018-05-31'
            THEN `Close Price` / 2
            ELSE `Close Price`
        END AS adjusted_close

    FROM tcs

    UNION ALL

    SELECT
        'Infosys' AS stock,
        STR_TO_DATE(`Date`, '%d-%M-%Y') AS trade_date,

        CASE
            WHEN STR_TO_DATE(`Date`, '%d-%M-%Y') < '2015-06-15'
            THEN `Close Price` / 2
            ELSE `Close Price`
        END AS adjusted_close

    FROM infosys
)

SELECT
    stock,
    ROUND(
        100 *
        (
            MAX(
                CASE
                    WHEN trade_date =
                        CASE
                            WHEN stock = 'TCS'
                            THEN '2018-07-31'
                            ELSE '2018-07-31'
                        END
                    THEN adjusted_close
                END
            )
            /
            MAX(
                CASE
                    WHEN trade_date = '2015-01-01'
                    THEN adjusted_close
                END
            )
            - 1
        ),
        1
    ) AS adjusted_pct_change

FROM adjusted
GROUP BY stock
ORDER BY stock;

