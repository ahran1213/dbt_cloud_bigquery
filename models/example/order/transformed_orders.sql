
WITH orders AS (

    SELECT
        order_id,
        customer_id,
        customer_name,
        email,
        order_date,
        status,
        total_amount,
        payment_method,
        city
    FROM {{ source('bigquery_source', 'orders') }}  --stagging.orders

),

transformed AS (

    SELECT
        -- Primary key
        order_id,

        -- Customer info
        customer_id,
        customer_name,
        email,

        -- Standardized fields
        UPPER(TRIM(status)) AS status,
        INITCAP(TRIM(payment_method)) AS payment_method,
        INITCAP(TRIM(city)) AS city,

        -- Dates
        order_date,
        DATE(order_date) AS order_date_day,
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        FORMAT_TIMESTAMP('%A', order_date) AS order_day_name,

        -- Metrics
        CAST(total_amount AS NUMERIC) AS total_amount,

        -- Business logic
        CASE
            WHEN UPPER(status) = 'DELIVERED' THEN total_amount
            ELSE 0
        END AS delivered_amount,

        CASE
            WHEN UPPER(status) = 'CANCELLED' THEN 1
            ELSE 0
        END AS is_cancelled,

        CASE
            WHEN UPPER(status) = 'RETURNED' THEN 1
            ELSE 0
        END AS is_returned

    FROM orders

)

SELECT * FROM transformed