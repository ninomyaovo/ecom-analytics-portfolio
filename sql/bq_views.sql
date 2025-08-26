-- ===============================================
-- Where to run: Google BigQuery Console → Query editor
-- Prereqs: Create a dataset named `portfolio` in US region.
-- Replace YOUR_PROJECT_ID with your actual project ID.
-- ===============================================

-- View 1: Daily Orders & Revenue
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.portfolio.v_daily_revenue` AS
SELECT
  DATE(o.created_at) AS order_date,
  COUNT(DISTINCT o.order_id) AS orders,
  SUM(oi.sale_price) AS revenue
FROM `bigquery-public-data.thelook_ecommerce.orders` AS o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  ON o.order_id = oi.order_id
WHERE o.status NOT IN ('Cancelled','Returned')
GROUP BY order_date
ORDER BY order_date;

-- View 2: Category GMV & Margin (overall)
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.portfolio.v_category_margin` AS
SELECT
  p.category,
  SUM(oi.sale_price) AS gmv,
  SUM(oi.sale_price - p.cost) AS margin,
  SAFE_DIVIDE(SUM(oi.sale_price - p.cost), NULLIF(SUM(oi.sale_price),0)) AS margin_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
GROUP BY p.category
ORDER BY gmv DESC;

-- View 3: Category GMV & Margin by day (enables date filtering in Tableau)
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.portfolio.v_category_margin_daily` AS
SELECT
  DATE(o.created_at) AS order_date,
  p.category,
  SUM(oi.sale_price) AS gmv,
  SUM(oi.sale_price - p.cost) AS margin,
  SAFE_DIVIDE(SUM(oi.sale_price - p.cost), NULLIF(SUM(oi.sale_price),0)) AS margin_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
  ON o.order_id = oi.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE o.status NOT IN ('Cancelled','Returned')
GROUP BY order_date, p.category
ORDER BY order_date, p.category;
