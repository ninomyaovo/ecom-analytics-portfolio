# E-commerce Analytics Portfolio — BigQuery + Tableau

**TL;DR:** A clean, reproducible analytics project that showcases SQL rigor, KPI design, and executive storytelling using the **TheLook eCommerce** public dataset (BigQuery) and **Tableau**.

## What this project demonstrates
- End-to-end analytics: data → SQL views → BI dashboard → business insights
- Core KPIs: **Revenue, Orders, AOV, Margin%**, Category performance
- Clear **executive memo** with decisions and next steps

## Stack
- **Warehouse:** Google BigQuery (public dataset: `bigquery-public-data.thelook_ecommerce`)
- **BI:** Tableau Desktop (or Tableau Public if you export as .twbx)
- **Repo:** This GitHub project (you)

---

## Reproduce this project

### 1) BigQuery setup
**Where to run:** Google BigQuery Console → **Query editor**

> Replace `YOUR_PROJECT_ID` below with your actual GCP project ID (no spaces). Make sure your dataset is in **US** region.

Run the view pack in `sql/bq_views.sql`. It creates:
- `v_daily_revenue` — daily Orders & Revenue
- `v_category_margin` — category GMV/Margin (overall)
- `v_category_margin_daily` — category GMV/Margin **by day** (enables date filtering in Tableau)

### 2) Tableau setup
**Where to click:** Tableau Desktop → **Connect → Google BigQuery**

- **Billing Project:** your GCP project
- **Project:** your GCP project
- **Dataset:** `portfolio` (or the dataset you used)
- Drag **`v_daily_revenue`** for the trend & KPIs
- Drag **`v_category_margin_daily`** for the category chart (date-aware)
- Alternatively, use the snippets in `sql/tableau_custom_sql.sql` via **New Custom SQL**

### 3) Business insights (how to use this repo)
- Fill in **docs/executive_memo_template.md** with key findings and decisions
- Keep **docs/kpi_definitions.md** as your metric source of truth
- Export your final Tableau workbook to `/tableau/dashboard.twbx` (and add screenshots in `/docs/img/`)

---

## Business questions this answers
1. **Growth**: How are revenue and orders trending? What’s the **AOV**?
2. **Unit economics**: Which categories drive **GMV** and **Margin%**?
3. **Seasonality**: What periods show spikes or dips?
4. **Next actions**: Where should we shift focus—channels, categories, pricing, or bundles?

## KPIs used (see `docs/kpi_definitions.md` for full details)
- **Revenue** — sum of sales (excl. canceled/returned)
- **Orders** — completed orders
- **AOV** — Average Order Value = Revenue / Orders
- **Margin%** — (Revenue − Cost) / Revenue
- **GMV** — Gross Merchandise Value (sum of sale_price before refunds/cancels)

---

## Repo structure
```
ecom-analytics-portfolio/
├─ README.md
├─ docs/
│  ├─ executive_memo_template.md
│  ├─ kpi_definitions.md
│  └─ img/                      # screenshots of your dashboard
├─ sql/
│  ├─ bq_views.sql
│  └─ tableau_custom_sql.sql
├─ tableau/                     # put your .twbx here
├─ .gitignore
└─ LICENSE
```

## License
MIT — see `LICENSE`.
