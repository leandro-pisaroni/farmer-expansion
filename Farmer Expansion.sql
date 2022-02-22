%%sql
postgresql:///groceries

WITH dairy_sales_2020 AS(
    SELECT
        CAST(DATE_PART('month', CAST(fulldate AS DATE)) AS integer) AS month,
        COUNT(*) AS dairy_2020
    FROM purchases_2020
    INNER JOIN categories
    ON purchaseid = purchase_id
    WHERE LOWER(category) IN ('whole milk', 'yogurt', 'domestic eggs')
    GROUP BY month
),
market_sales_2020 AS(
    SELECT
        CAST(DATE_PART('month', CAST(fulldate AS DATE)) AS integer) AS month,
        COUNT(*) AS market_2020
    FROM purchases_2020
    INNER JOIN categories
    ON purchaseid = purchase_id
    GROUP BY month
),
dairy_sales_2019 AS(
    SELECT
        month,
        COUNT(*) AS dairy_2019
    FROM purchases_2019
    INNER JOIN categories
    USING (purchase_id)
    WHERE LOWER(category) IN ('whole milk', 'yogurt', 'domestic eggs')
    GROUP BY month
)
    
SELECT
    CAST(ds20.month AS integer),
    CAST(ds20.dairy_2020 AS integer) AS total_sales,
    ROUND(CAST(ds20.dairy_2020 AS NUMERIC)/ms.market_2020*100,2) AS market_share,
    ROUND((CAST(ds20.dairy_2020 AS NUMERIC) - ds19.dairy_2019)/ds19.dairy_2019*100,2) AS year_change
FROM dairy_sales_2020 AS ds20
INNER JOIN market_sales_2020 AS ms
USING (month)
INNER JOIN dairy_sales_2019 AS ds19
USING (month)
ORDER BY month;
