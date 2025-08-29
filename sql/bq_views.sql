-- 1. KPIs for the last 12 months
DECLARE start_date DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 11 MONTH);
DECLARE end_date   DATE DEFAULT DATE_ADD(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 MONTH);

WITH base AS (
  SELECT
    DATE(o.created_at) AS order_date,
    o.order_id,
    oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.orders`  o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status NOT IN ('Cancelled','Returned')
    AND DATE(o.created_at) >= start_date
    AND DATE(o.created_at) <  end_date
)
SELECT
  SUM(sale_price)                        AS revenue,
  COUNT(DISTINCT order_id)               AS orders,
  SAFE_DIVIDE(SUM(sale_price), COUNT(DISTINCT order_id)) AS aov
FROM base;

-- 2. Month-over-Month revenue change (latest month vs previous)
DECLARE start_date DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 11 MONTH);
DECLARE end_date   DATE DEFAULT DATE_ADD(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 MONTH);

WITH monthly AS (
  SELECT
    DATE_TRUNC(DATE(o.created_at), MONTH) AS month,
    SUM(oi.sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status NOT IN ('Cancelled','Returned')
    AND DATE(o.created_at) >= start_date
    AND DATE(o.created_at) <  end_date
  GROUP BY 1
),
cmp AS (
  SELECT
    m.month,
    m.revenue AS revenue_this_month,
    LAG(m.revenue) OVER (ORDER BY m.month) AS revenue_prev_month
  FROM monthly m
)
SELECT
  month,
  revenue_this_month,
  revenue_prev_month,
  SAFE_DIVIDE(revenue_this_month - revenue_prev_month, revenue_prev_month) AS mom_pct
FROM cmp
ORDER BY month DESC
LIMIT 1;

-- 3. Category mix & margin for the last 12 months
DECLARE start_date DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 11 MONTH);
DECLARE end_date   DATE DEFAULT DATE_ADD(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 MONTH);

WITH cat AS (
  SELECT
    p.category,
    SUM(oi.sale_price)                             AS gmv,
    SUM(oi.sale_price - p.cost)                    AS margin,
    SAFE_DIVIDE(SUM(oi.sale_price - p.cost), NULLIF(SUM(oi.sale_price),0)) AS margin_pct
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.orders`      o ON o.order_id = oi.order_id
  JOIN `bigquery-public-data.thelook_ecommerce.products`    p ON p.id = oi.product_id
  WHERE o.status NOT IN ('Cancelled','Returned')
    AND DATE(o.created_at) >= start_date
    AND DATE(o.created_at) <  end_date
  GROUP BY 1
)
SELECT
  category,
  gmv,
  margin,
  margin_pct,
  SAFE_DIVIDE(gmv, SUM(gmv) OVER ()) AS gmv_share
FROM cat
ORDER BY gmv DESC
LIMIT 10;

-- 4. Last full month vs previous: Orders, AOV, and their MoM%
DECLARE last_m_start DATE DEFAULT DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 MONTH);
DECLARE last_m_end   DATE DEFAULT DATE_TRUNC(CURRENT_DATE(), MONTH);
DECLARE prev_m_start DATE DEFAULT DATE_SUB(last_m_start, INTERVAL 1 MONTH);
DECLARE prev_m_end   DATE DEFAULT last_m_start;

WITH base AS (
  SELECT DATE(o.created_at) d, o.order_id, oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi USING(order_id)
  WHERE o.status NOT IN ('Cancelled','Returned')
),
agg AS (
  SELECT
    COUNT(DISTINCT IF(d>=last_m_start AND d<last_m_end, order_id, NULL)) AS ord_this,
    SUM(         IF(d>=last_m_start AND d<last_m_end, sale_price, NULL)) AS rev_this,
    COUNT(DISTINCT IF(d>=prev_m_start AND d<prev_m_end, order_id, NULL)) AS ord_prev,
    SUM(         IF(d>=prev_m_start AND d<prev_m_end, sale_price, NULL)) AS rev_prev
  FROM base
)
SELECT
  ord_this, ord_prev,
  SAFE_DIVIDE(rev_this, ord_this) AS aov_this,
  SAFE_DIVIDE(rev_prev, ord_prev) AS aov_prev,
  SAFE_DIVIDE(ord_this - ord_prev, ord_prev) AS orders_mom_pct,
  SAFE_DIVIDE(SAFE_DIVIDE(rev_this, ord_this) - SAFE_DIVIDE(rev_prev, ord_prev),
              SAFE_DIVIDE(rev_prev, ord_prev)) AS aov_mom_pct
FROM agg;


