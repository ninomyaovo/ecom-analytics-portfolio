-- ===============================================
-- Where to run: Tableau Desktop → Data Source → New Custom SQL
-- Use these if you don't want to create views in BigQuery.
-- ===============================================

-- Daily orders & revenue
SELECT
  DATE(o.created_at) AS order_date,
  COUNT(DISTINCT o.order_id) AS orders,
  SUM(oi.sale_price) AS revenue
FROM `bigquery-public-data.thelook_ecommerce.orders`  AS o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  ON o.order_id = oi.order_id
WHERE o.status NOT IN ('Cancelled','Returned')
GROUP BY order_date
ORDER BY order_date;

-- Category GMV & margin (overall)
SELECT
  p.category,
  SUM(oi.sale_price) AS gmv,
  SUM(oi.sale_price - p.cost) AS margin,
  SAFE_DIVIDE(SUM(oi.sale_price - p.cost), NULLIF(SUM(oi.sale_price),0)) AS margin_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products`     AS p
  ON oi.product_id = p.id
GROUP BY p.category
ORDER BY gmv DESC;

-- Category GMV & margin by day (date-aware)
SELECT
  DATE(o.created_at) AS order_date,
  p.category,
  SUM(oi.sale_price) AS gmv,
  SUM(oi.sale_price - p.cost) AS margin,
  SAFE_DIVIDE(SUM(oi.sale_price - p.cost), NULLIF(SUM(oi.sale_price),0)) AS margin_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.orders`      AS o
  ON o.order_id = oi.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products`    AS p
  ON oi.product_id = p.id
WHERE o.status NOT IN ('Cancelled','Returned')
GROUP BY order_date, p.category
ORDER BY order_date, p.category;
