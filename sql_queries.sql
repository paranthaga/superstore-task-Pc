-- 1. Total sales, profit, quantity
SELECT SUM(Sales) AS total_sales, SUM(Profit) AS total_profit, SUM(Quantity) AS total_quantity FROM cleaned_superstore;

-- 2. Monthly sales trend
SELECT DATE_TRUNC('month', "Order Date") AS month, SUM(Sales) AS monthly_sales
FROM cleaned_superstore
GROUP BY 1
ORDER BY 1;

-- 3. YoY sales comparison (yearly totals)
SELECT EXTRACT(year FROM "Order Date") AS year, SUM(Sales) AS total_sales
FROM cleaned_superstore
GROUP BY 1
ORDER BY 1;

-- 4. Top 10 products by sales
SELECT "Product Name", SUM(Sales) AS product_sales
FROM cleaned_superstore
GROUP BY "Product Name"
ORDER BY product_sales DESC
LIMIT 10;

-- 5. Top 10 customers by revenue
SELECT "Customer Name", SUM(Sales) AS customer_revenue
FROM cleaned_superstore
GROUP BY "Customer Name"
ORDER BY customer_revenue DESC
LIMIT 10;

-- 6. Category-wise profit margin (profit / sales)
SELECT Category, SUM(Profit) AS total_profit, SUM(Sales) AS total_sales, 
       CASE WHEN SUM(Sales)=0 THEN NULL ELSE SUM(Profit)/SUM(Sales) END AS profit_margin
FROM cleaned_superstore
GROUP BY Category
ORDER BY profit_margin DESC;

-- 7. Region performance (sales + profit)
SELECT Region, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM cleaned_superstore
GROUP BY Region
ORDER BY total_sales DESC;

-- 8. Discount impact on profitability (aggregate buckets)
SELECT CASE WHEN Discount = 0 THEN '0' WHEN Discount <= 0.1 THEN '<=10%' WHEN Discount <= 0.25 THEN '<=25%' ELSE '>25%' END AS discount_bucket,
       SUM(Sales) AS sales, SUM(Profit) AS profit, COUNT(*) AS orders
FROM cleaned_superstore
GROUP BY 1
ORDER BY 1;

-- 9. Profit loss analysis (items with negative profit)
SELECT "Product Name", SUM(Sales) AS sales, SUM(Profit) AS profit, COUNT(*) AS orders
FROM cleaned_superstore
GROUP BY "Product Name"
HAVING SUM(Profit) < 0
ORDER BY profit ASC
LIMIT 20;

-- 10. Segment contribution % (by sales)
SELECT Segment, SUM(Sales) AS sales, SUM(Sales) / (SELECT SUM(Sales) FROM cleaned_superstore) * 100.0 AS pct_contribution
FROM cleaned_superstore
GROUP BY Segment
ORDER BY sales DESC;

-- 11. Shipping time calculation (Ship Date – Order Date)
SELECT "Order ID", "Order Date", "Ship Date", ("Ship Date" - "Order Date") AS shipping_time_days
FROM cleaned_superstore
WHERE "Ship Date" IS NOT NULL AND "Order Date" IS NOT NULL
ORDER BY shipping_time_days DESC
LIMIT 50;

-- 12. Identify outlier orders (High sales or large loss)
-- Example: Orders with sales greater than 99th percentile OR profit less than 1st percentile
WITH metrics AS (
  SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Sales) AS p99_sales,
         PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY Profit) AS p01_profit
  FROM cleaned_superstore
)
SELECT cs.* FROM cleaned_superstore cs, metrics
WHERE cs.Sales >= metrics.p99_sales OR cs.Profit <= metrics.p01_profit
ORDER BY cs.Sales DESC NULLS LAST;