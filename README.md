# swiggy_sales_analysis

End-to-end sales analysis of food delivery data using SQL, Python, and Power BI — covering revenue trends, cancellation rates, peak demand, and city/cuisine performance.


# Swiggy Sales Analysis — SQL, Python & Power BI

An end-to-end data analysis project on food delivery sales data, covering the full analyst workflow: 
**SQL for business questions → Python for deeper exploration & cleaning → Power BI for a stakeholder-facing dashboard.**


## Overview

This project analyzes ~5,000 food delivery orders across 50 restaurants in 10 Indian cities, answering 15 real business questions around revenue, cancellations, cuisine performance, peak demand, and delivery operations.


## Key Findings

**Revenue:** ~3,972 delivered orders generated ₹27.53L in total revenue, at an average order value of ₹693.
**Top city:** Hyderabad leads with 18.6% of total revenue; the top 3 cities (Hyderabad, Pune, Chennai) drive ~46% of revenue combined.
**Top cuisine:** Continental generates the highest revenue (₹5.08L) and, along with Desserts, carries the highest average order value (~₹710-730).
**Cancellation rate:** ~20% average across all cities (range 17.6%-23.1%) — flagged as the top operational issue worth investigating (payment failures, restaurant unavailability, etc.).
**Peak demand:** Orders peak between 7 PM-11 PM, with 8 PM and 11 PM as the single busiest hours — delivery staffing should be weighted toward this window.
**Delivery performance:** Delivery times are consistent across cities (38.6-40.2 min average), with no city standing out as a bottleneck.
**Payment behavior:** All 5 payment modes are used near-evenly (15.7%-16.5% share each) — no dominant channel.
**Rating vs. spend:** No meaningful correlation found between restaurant rating and average order value — customers don't necessarily spend more at higher-rated restaurants.
**Data quality:** No restaurants had zero delivered orders; all order amounts reconciled correctly against `order_value - discount + delivery_fee`.



## What This Project Demonstrates

- Writing business-question-driven SQL, including joins, aggregations, and window functions (`RANK`, `LAG`)
- Data cleaning: handling duplicates, standardizing text, outlier detection (IQR method), and validation checks
- Exploratory data analysis and visualization in Python
- Building an interactive, stakeholder-ready dashboard in Power BI with slicers and KPI cards
- Cross-validating findings across SQL, Python, and Power BI to ensure consistency
