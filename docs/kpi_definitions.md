# KPI Definitions

**Revenue**  
Sum of line-item `sale_price` on completed orders (excludes `Cancelled`/`Returned`).

**Orders**  
Count of completed orders.

**Average Order Value (AOV)**  
AOV = Revenue / Orders.  
Interpretation: average dollars per order over the selected period.

**GMV (Gross Merchandise Value)**  
Sum of `sale_price`.

**Margin**  
Margin = Revenue − Cost. (Here, cost is from `products.cost` in TheLook.)

**Margin %**  
Margin % = Margin / Revenue.

**Notes**  
- For % metrics, aggregate **numerator and denominator first**, then divide (avoid averaging percentages directly).  
- Ensure date filters are applied consistently across views.
