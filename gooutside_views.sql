-- ==========================================
-- OVERALL VIEW
-- ==========================================
CREATE OR REPLACE TABLE `goutside.gooutside_full_view` AS

SELECT
    ds.Date AS date,

    EXTRACT(YEAR FROM ds.Date) AS year,

    ds.`Retailer code` AS retailer_code,
    r.`Retailer name` AS retailer_name,
    r.Type AS retailer_type,
    r.Country AS country,

    ds.`Product number` AS product_number,
    p.Product AS product,
    p.`Product brand` AS product_brand,
    p.`Product type` AS product_type,
    p.`Product line` AS product_line,
    p.`Unit cost` AS unit_cost,

    ds.`Order method code` AS order_method_code,
    m.`Order method type` AS order_method_type,

    ds.Quantity AS quantity,
    ds.`Unit price` AS unit_price,
    ds.`Unit sale price` AS unit_sale_price,

    -- revenue
    ds.Quantity * ds.`Unit sale price` AS revenue,

    -- cost
    ds.Quantity * p.`Unit cost` AS cost,

    -- profit
    (ds.Quantity * ds.`Unit sale price`)
    - (ds.Quantity * p.`Unit cost`) AS profit

FROM `goutside.daily_sales` ds

LEFT JOIN `goutside.retailers` r
    ON ds.`Retailer code` = r.`Retailer code`

LEFT JOIN `goutside.products` p
    ON ds.`Product number` = p.`Product number`

LEFT JOIN `goutside.methods` m
    ON ds.`Order method code` = m.`Order method code`;
    
-- ==========================================
-- FINANCE VIEW
-- ==========================================
CREATE OR REPLACE VIEW `gooutside-da-052.GoOutside.finance_view` AS
SELECT 
  DATE_TRUNC(s.date, MONTH) AS sales_month,
  EXTRACT(YEAR FROM s.date) AS sales_year,
  EXTRACT(MONTH FROM s.date) AS calendar_month,
  m.`order method type` AS order_method,
  p.`product line` AS product_line,
  round(SUM(s.quantity),2) AS total_units_sold,
  round(SUM(s.quantity * s.`unit sale price`),2) AS gross_revenue,
  round(SUM(s.quantity * p.`unit cost`),2) AS total_cost,
  round(SUM(s.quantity * (s.`unit sale price` - p.`unit cost`)),2) AS net_profit,
  SUM(s.quantity * (p.`unit price` - s.`unit sale price`)) AS total_discount_loss,
  round(SAFE_DIVIDE(
    SUM(s.quantity * (s.`unit sale price` - p.`unit cost`)), 
    SUM(s.quantity * s.`unit sale price`)
  ),2) AS profit_margin_percentage
FROM `project-4daa4f9a-fadd-406b-ad8.goutside.daily_sales` s
JOIN `project-4daa4f9a-fadd-406b-ad8.goutside.methods` m 
  using(`order method code`)
JOIN `project-4daa4f9a-fadd-406b-ad8.goutside.products` p 
  using(`product number`)
GROUP BY 1, 2,3,4,5
ORDER BY sales_month DESC, net_profit DESC;

-- ==========================================
-- PARTNERSHIPS VIEW - basic
-- ==========================================
CREATE OR REPLACE VIEW `goutside.partnerships_view` AS
SELECT
    ds.Date,
    EXTRACT(YEAR FROM ds.Date) AS year,
    r.Country,
    r.`Retailer code`,
    TRIM(REGEXP_REPLACE(r.`Retailer name`, r'[\r\n\t]', ' '))
  AS retailer_name,
    r.Type AS retailer_type,
    ds.Quantity,
    ds.`Unit sale price`,
    ds.Quantity * ds.`Unit sale price` AS revenue
FROM `goutside.daily_sales` ds
LEFT JOIN `goutside.retailers` r
    ON ds.`Retailer code` = r.`Retailer code`;
    
-- ==========================================
-- PARTNERSHIPS VIEW - with calculated fields (e.g. market share)
-- ==========================================
CREATE OR REPLACE VIEW `goutside.partnerships_full_view` AS

WITH retailer_sales AS (
  SELECT
      r.Country,
      r.`Retailer code`,
      r.`Retailer name`,
      r.Type AS retailer_type,
      SUM(ds.Quantity) AS total_units_sold,
      ROUND(SUM(ds.Quantity * ds.`Unit sale price`),2) AS retailer_revenue
  FROM `goutside.daily_sales` ds
  LEFT JOIN `goutside.retailers` r
    ON ds.`Retailer code` = r.`Retailer code`
  GROUP BY
      r.Country,
      r.`Retailer code`,
      r.`Retailer name`,
      r.Type
),
ranked_retailers AS (
  SELECT
      *,
      retailer_revenue /
      SUM(retailer_revenue) OVER (
        PARTITION BY Country
      ) AS market_share,

      ROW_NUMBER() OVER (
        PARTITION BY Country
        ORDER BY retailer_revenue DESC
      ) AS retailer_rank
  FROM retailer_sales
),

country_summary AS (
  SELECT
      Country,
      COUNT(*) AS retailer_count,
      SUM(CASE
          WHEN retailer_rank <= 3
          THEN market_share
          ELSE 0
        END
      ) AS top3_share
  FROM ranked_retailers
  GROUP BY Country
)
SELECT
    rr.Country,
    rr.`Retailer code`,
    rr.`Retailer name`,
    rr.retailer_type,
    rr.total_units_sold,
    rr.retailer_revenue,
    
    -- Market share variables
    ROUND(rr.market_share * 100, 2) AS market_share_pct,
    cs.retailer_count,
    ROUND(cs.top3_share * 100, 2) AS top3_share_pct,
   
     -- Market classification variable
    CASE
      WHEN cs.top3_share > 0.60
        THEN 'Concentrated'
      ELSE 'Competitive'
    END AS market_type,
    
    -- Target Revenue and No. of Retailers variables
    CASE
      WHEN cs.top3_share > 0.60
        THEN ROUND(rr.retailer_revenue * 1.10, 2)
      ELSE rr.retailer_revenue
    END AS target_revenue,

    CASE
      WHEN cs.top3_share <= 0.60
        THEN CEIL(cs.retailer_count * 1.15)
      ELSE cs.retailer_count
    END AS target_retailers

FROM ranked_retailers rr

LEFT JOIN country_summary cs
  ON rr.Country = cs.Country

ORDER BY
    Country,
    retailer_revenue DESC;
-- ==========================================
-- MARKETING VIEW
-- ==========================================
CREATE OR REPLACE VIEW `goutside.marketing_view` AS

SELECT
    EXTRACT(YEAR FROM ds.Date) AS year,
    r.Country,
    p.`Product line`,
    p.`Product type`,
    p.`Product brand`,
    SUM(ds.Quantity) AS units_sold,
    ROUND(
      SUM(ds.Quantity * ds.`Unit sale price`),
      2
    ) AS revenue

FROM `goutside.daily_sales` ds

JOIN `goutside.products` p
  ON ds.`Product number` = p.`Product number`

JOIN `goutside.retailers` r
  ON ds.`Retailer code` = r.`Retailer code`

GROUP BY
    year,
    Country,
    `Product line`,
    `Product type`,
    `Product brand`;