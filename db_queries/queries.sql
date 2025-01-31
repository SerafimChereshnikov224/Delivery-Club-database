SELECT u.id, u.full_name, COUNT(o.id) AS order_count
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name
ORDER BY order_count DESC
LIMIT 100;

SELECT r.id, r.name, AVG(r.rating) AS average_rating, COUNT(d.id) AS dish_count
FROM restaurants r
LEFT JOIN dishes d ON r.id = d.restaurant_id
GROUP BY r.id, r.name
ORDER BY average_rating DESC;

SELECT c.id, c.full_name, COUNT(o.id) AS order_count
FROM couriers c
LEFT JOIN orders o ON c.id = o.courier_id
GROUP BY c.id, c.full_name
ORDER BY order_count DESC;

SELECT p.id, p.name, COUNT(up.id) AS usage_count, 
       COALESCE(p.discount_in_rubles, 0) AS discount_in_rubles, 
       COALESCE(p.discount_in_percent, 0) AS discount_in_percent
FROM promocodes p
LEFT JOIN user_promocode up ON p.id = up.promocode_id
GROUP BY p.id, p.name, p.discount_in_rubles, p.discount_in_percent
ORDER BY usage_count DESC;

/* middle */


SELECT u.id, u.full_name, AVG(o.total_amount) AS average_order_amount
FROM users u
JOIN user_promocode up ON u.id = up.user_id
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name;   /* dont work */

SELECT c.id, c.full_name, COUNT(o.id) AS order_count
FROM couriers c
JOIN orders o ON c.id = o.courier_id
GROUP BY c.id, c.full_name
HAVING SUM(o.total_amount) > 10000;    /* dont work */

SELECT r.id, r.name, COUNT(DISTINCT d.id) AS unique_dish_count, AVG(r.rating) AS average_rating
FROM restaurants r
LEFT JOIN dishes d ON r.id = d.restaurant_id
GROUP BY r.id, r.name
ORDER BY unique_dish_count DESC;


SELECT p.id, p.name, COUNT(up.id) AS usage_count, 
       COALESCE(p.discount_in_rubles, 0) AS discount_in_rubles, 
       COALESCE(p.discount_in_percent, 0) AS discount_in_percent
FROM promocodes p
LEFT JOIN user_promocode up ON p.id = up.promocode_id
WHERE p.creation_date >= NOW() - INTERVAL '30 days'
GROUP BY p.id, p.name, p.discount_in_rubles, p.discount_in_percent;

/* hard */

WITH user_order_stats AS (
    SELECT 
        u.id AS user_id,
        COUNT(o.id) AS total_orders,
        COUNT(DISTINCT o.courier_id) AS distinct_couriers,
        COUNT(DISTINCT o.payment_method_id) AS distinct_payment_methods,
        COUNT(o.id) FILTER (WHERE o.order_status = 'canceled') AS canceled_orders,
        COUNT(DISTINCT a.city) AS distinct_cities,
        MAX(o.creation_date) - MIN(o.creation_date) AS order_time_span
    FROM 
        users u
    JOIN 
        orders o ON u.id = o.user_id
    LEFT JOIN 
        addresses a ON u.id = a.user_id
    GROUP BY 
        u.id
)
SELECT 
    user_id,
    total_orders,
    distinct_couriers,
    distinct_payment_methods,
    canceled_orders,
    distinct_cities,
    order_time_span,
    CASE 
        WHEN total_orders > 20 AND distinct_cities > 5 AND canceled_orders > 5 THEN 'Potential Bot'
        ELSE 'Normal User' 
    END AS user_type 
FROM 
    user_order_stats
WHERE 
    CASE 
        WHEN total_orders > 2000 AND distinct_cities > 5 AND canceled_orders > 100 THEN 'Potential Bot'
        ELSE 'Normal User' 
    END = 'Potential Bot';













WITH RECURSIVE user_orders AS (
    SELECT 
        user_id, 
        creation_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY creation_date) AS order_seq
    FROM 
        orders
),
order_intervals AS (
    SELECT 
        u1.user_id,
        u1.creation_date AS order_date,
        u2.creation_date AS next_order_date,
        EXTRACT(EPOCH FROM (u2.creation_date - u1.creation_date)) / 60 AS interval_minutes
    FROM 
        user_orders u1
    JOIN 
        user_orders u2 ON u1.user_id = u2.user_id AND u1.order_seq + 1 = u2.order_seq
)
SELECT 
    user_id,
    COUNT(order_date) AS total_orders,
    COUNT(next_order_date) AS consecutive_orders,
    AVG(interval_minutes) AS average_interval_minutes
FROM 
    order_intervals
GROUP BY 
    user_id
ORDER BY 
    total_orders DESC;



SELECT 
    c.id AS courier_id,
    c.full_name,
    COUNT(o.id) AS total_deliveries,
    AVG(EXTRACT(EPOCH FROM (o.creation_date - c.registration_date)) / 60) AS average_delivery_time
FROM 
    couriers c
LEFT JOIN 
    orders o ON c.id = o.courier_id
GROUP BY 
    c.id
ORDER BY 
    total_deliveries DESC, average_delivery_time ASC;





WITH average_times AS (
    SELECT 
        a.city,
        AVG(EXTRACT(EPOCH FROM (o.creation_date - c.registration_date)) / 60) AS average_delivery_time
    FROM 
        orders o
    JOIN 
        couriers c ON o.courier_id = c.id
    JOIN 
        addresses a ON o.user_id = a.user_id
    GROUP BY 
        a.city
    HAVING 
        AVG(EXTRACT(EPOCH FROM (o.creation_date - c.registration_date)) / 60) >= 0
),
ranked_times AS (
    SELECT 
        city,
        average_delivery_time,
        ROW_NUMBER() OVER (PARTITION BY average_delivery_time ORDER BY city) AS rn
    FROM 
        average_times
)

SELECT 
    city,
    average_delivery_time
FROM 
    ranked_times
WHERE 
    rn = 1
ORDER BY 
    average_delivery_time ASC;


WITH user_orders AS (
    SELECT 
        user_id,
        COUNT(*) AS total_orders,
        COUNT(DISTINCT order_number) AS unique_orders
    FROM 
        orders
    GROUP BY 
        user_id
),
favorite_restaurant AS (
    SELECT 
        o.user_id,
        d.restaurant_id,
        COUNT(d.id) AS dish_count
    FROM 
        orders o
    JOIN 
        order_dish od ON o.id = od.order_id
    JOIN 
        dishes d ON od.dish_id = d.id
    GROUP BY 
        o.user_id, d.restaurant_id
),
favorite_store AS (
    SELECT 
        o.user_id,
        p.store_id,
        COUNT(p.id) AS product_count
    FROM 
        orders o
    JOIN 
        order_product op ON o.id = op.order_id
    JOIN 
        products p ON op.product_id = p.id
    GROUP BY 
        o.user_id, p.store_id
),
favorite_dish AS (
    SELECT 
        o.user_id,
        d.id AS dish_id,
        COUNT(d.id) AS count
    FROM 
        orders o
    JOIN 
        order_dish od ON o.id = od.order_id
    JOIN 
        dishes d ON od.dish_id = d.id
    GROUP BY 
        o.user_id, d.id
),
favorite_product AS (
    SELECT 
        o.user_id,
        p.id AS product_id,
        COUNT(p.id) AS count
    FROM 
        orders o
    JOIN 
        order_product op ON o.id = op.order_id
    JOIN 
        products p ON op.product_id = p.id
    GROUP BY 
        o.user_id, p.id
)

SELECT 
    u.id AS user_id,
    u.full_name,
    /*COALESCE(TO_CHAR((CAST(r.repeated_order_count AS FLOAT) / NULLIF(uo.total_orders, 0)) * 100, 'FM999999999.00'), '0.00') AS repeat_order_percentage,*/
    (SELECT restaurant_id FROM favorite_restaurant WHERE user_id = u.id ORDER BY dish_count DESC LIMIT 1) AS favorite_restaurant_id,
    (SELECT store_id FROM favorite_store WHERE user_id = u.id ORDER BY product_count DESC LIMIT 1) AS favorite_store_id,
    (SELECT dish_id FROM favorite_dish WHERE user_id = u.id ORDER BY count DESC LIMIT 1) AS favorite_dish_id,
    (SELECT product_id FROM favorite_product WHERE user_id = u.id ORDER BY count DESC LIMIT 1) AS favorite_product_id
FROM 
    users u
JOIN 
    user_orders uo ON u.id = uo.user_id
ORDER BY 
    u.id;




