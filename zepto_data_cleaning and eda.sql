drop table if exists zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

--data exploration

--count of rows
select count(*) from zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

--null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

--product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

--duplicate sku_ids
SELECT
    sku_id,
    COUNT(*)
FROM zepto
GROUP BY sku_id
HAVING COUNT(*) > 1;


--check invalid prices
SELECT *
FROM zepto
WHERE mrp < discountedSellingPrice;

--check negetive values
SELECT *
FROM zepto
WHERE mrp < 0
   OR discountedSellingPrice < 0
   OR availableQuantity < 0
   OR weightInGms < 0;


--products missing weights
SELECT *
FROM zepto
WHERE weightInGms = 0
   OR weightInGms IS NULL;





 
--data cleaning

--products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- Check products with invalid prices
SELECT *
FROM zepto
WHERE mrp <= 0
   OR discountedSellingPrice <= 0;

-- Remove products with invalid prices
DELETE FROM zepto
WHERE mrp <= 0
   OR discountedSellingPrice <= 0;

--convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

-- Verify updated prices
SELECT
    mrp,
    discountedSellingPrice
FROM zepto
LIMIT 10;

-- Check for duplicate product records
SELECT
    sku_id,
    COUNT(*)
FROM zepto
GROUP BY sku_id
HAVING COUNT(*) > 1;

-- Check for leading or trailing spaces in product names
SELECT *
FROM zepto
WHERE name <> TRIM(name);

-- Remove leading and trailing spaces from product names
UPDATE zepto
SET name = TRIM(name);

-- Check for leading or trailing spaces in category names
SELECT *
FROM zepto
WHERE category <> TRIM(category);

-- Remove leading and trailing spaces from category names
UPDATE zepto
SET category = TRIM(category);


-- Standardize category names
UPDATE zepto
SET category = INITCAP(category);

-- Verify products having discount greater than MRP
SELECT *
FROM zepto
WHERE discountedSellingPrice > mrp;


-- Verify invalid discount percentage
SELECT *
FROM zepto
WHERE discountPercent < 0
   OR discountPercent > 100;

-- Verify negative inventory values
SELECT *
FROM zepto
WHERE availableQuantity < 0
   OR weightInGms < 0;

-- Final preview of cleaned dataset
SELECT *
FROM zepto
LIMIT 10;



-- Exploratory Data Analysis (EDA)

-- 1. Total number of products in each category
SELECT
    category,
    COUNT(*) AS total_products
FROM zepto
GROUP BY category
ORDER BY total_products DESC;

-- 2. Average, Minimum and Maximum MRP by category
SELECT
    category,
    ROUND(AVG(mrp),2) AS avg_mrp,
    MIN(mrp) AS min_mrp,
    MAX(mrp) AS max_mrp
FROM zepto
GROUP BY category
ORDER BY avg_mrp DESC;

-- 3. Average selling price by category
SELECT
    category,
    ROUND(AVG(discountedSellingPrice),2) AS avg_selling_price
FROM zepto
GROUP BY category
ORDER BY avg_selling_price DESC;

-- 4. Average discount offered by each category
SELECT
    category,
    ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC;

-- 5. Products available vs out of stock
SELECT
    outOfStock,
    COUNT(*) AS total_products
FROM zepto
GROUP BY outOfStock;

-- 6. Number of products receiving different discount ranges
SELECT
CASE
    WHEN discountPercent < 10 THEN '0-10%'
    WHEN discountPercent < 20 THEN '10-20%'
    WHEN discountPercent < 30 THEN '20-30%'
    WHEN discountPercent < 40 THEN '30-40%'
    ELSE '40%+'
END AS discount_range,
COUNT(*) AS total_products
FROM zepto
GROUP BY discount_range
ORDER BY discount_range;

-- 7. Total available inventory by category
SELECT
    category,
    SUM(availableQuantity) AS total_inventory
FROM zepto
GROUP BY category
ORDER BY total_inventory DESC;

-- 8. Average product weight by category
SELECT
    category,
    ROUND(AVG(weightInGms),2) AS avg_weight
FROM zepto
GROUP BY category
ORDER BY avg_weight DESC;

-- 9. Top 10 most expensive products
SELECT
    name,
    category,
    discountedSellingPrice
FROM zepto
ORDER BY discountedSellingPrice DESC
LIMIT 10;

-- 10. Top 10 cheapest products
SELECT
    name,
    category,
    discountedSellingPrice
FROM zepto
ORDER BY discountedSellingPrice
LIMIT 10;





--data analysis/buisness insight queries 

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

--Q2.What are the Products with High MRP but Out of Stock

SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;

--Q3.Calculate Estimated Revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

-- Q9. Find the categories with the highest inventory value.
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS inventory_value
FROM zepto
GROUP BY category
ORDER BY inventory_value DESC;

-- Q10. Find the top 10 products contributing the highest inventory value.
SELECT
    name,
    category,
    discountedSellingPrice,
    availableQuantity,
    (discountedSellingPrice * availableQuantity) AS inventory_value
FROM zepto
ORDER BY inventory_value DESC
LIMIT 10;

-- Q11. Find categories having the highest number of out-of-stock products.
SELECT
    category,
    COUNT(*) AS out_of_stock_products
FROM zepto
WHERE outOfStock = TRUE
GROUP BY category
ORDER BY out_of_stock_products DESC;

-- Q12. Find the top 10 products offering the highest savings.
SELECT
    name,
    category,
    mrp,
    discountedSellingPrice,
    (mrp - discountedSellingPrice) AS savings
FROM zepto
ORDER BY savings DESC
LIMIT 10;

-- Q13. Calculate average savings offered in each category.
SELECT
    category,
    ROUND(AVG(mrp - discountedSellingPrice),2) AS average_savings
FROM zepto
GROUP BY category
ORDER BY average_savings DESC;

-- Q14. Find the distribution of products across weight categories.
SELECT
    CASE
        WHEN weightInGms < 1000 THEN 'Low'
        WHEN weightInGms < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category,
    COUNT(*) AS total_products
FROM zepto
GROUP BY weight_category
ORDER BY total_products DESC;

-- Q15. Find categories with the highest average selling price.
SELECT
    category,
    ROUND(AVG(discountedSellingPrice),2) AS average_selling_price
FROM zepto
GROUP BY category
ORDER BY average_selling_price DESC;


-- Advanced SQL Analysis

-- Q1. Rank products based on discount percentage within each category.
SELECT
    category,
    name,
    discountPercent,
    RANK() OVER(PARTITION BY category ORDER BY discountPercent DESC) AS discount_rank
FROM zepto;

-- Q2. Find the top 3 most expensive products in each category.
SELECT *
FROM (
    SELECT
        category,
        name,
        discountedSellingPrice,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY discountedSellingPrice DESC) AS rn
    FROM zepto
) t
WHERE rn <= 3;

-- Q3. Find products priced above the average selling price of their category.
WITH category_avg AS (
    SELECT
        category,
        AVG(discountedSellingPrice) AS avg_price
    FROM zepto
    GROUP BY category
)
SELECT
    z.name,
    z.category,
    z.discountedSellingPrice
FROM zepto z
JOIN category_avg c
ON z.category = c.category
WHERE z.discountedSellingPrice > c.avg_price
ORDER BY z.category;

-- Q4. Rank categories based on estimated inventory value.
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS inventory_value,
    DENSE_RANK() OVER(
        ORDER BY SUM(discountedSellingPrice * availableQuantity) DESC
    ) AS category_rank
FROM zepto
GROUP BY category;

-- Q5. Find the product having the maximum discount in every category.
SELECT *
FROM (
    SELECT
        category,
        name,
        discountPercent,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY discountPercent DESC) AS rn
    FROM zepto
) t
WHERE rn = 1;

-- Q6. Find products whose selling price is above the overall average.
SELECT
    name,
    category,
    discountedSellingPrice
FROM zepto
WHERE discountedSellingPrice >
(
    SELECT AVG(discountedSellingPrice)
    FROM zepto
)
ORDER BY discountedSellingPrice DESC;

-- Q7. Create a view for premium products.
CREATE VIEW premium_products AS
SELECT
    name,
    category,
    mrp,
    discountedSellingPrice
FROM zepto
WHERE mrp >= 500;

-- View the premium products.
SELECT *
FROM premium_products;

-- Q8. Create a view for products offering more than 40% discount.
CREATE VIEW high_discount_products AS
SELECT
    name,
    category,
    discountPercent
FROM zepto
WHERE discountPercent >= 40;

-- View the high discount products.
SELECT *
FROM high_discount_products;

-- Q9. Find categories contributing more than the average inventory value.
WITH inventory AS (
    SELECT
        category,
        SUM(discountedSellingPrice * availableQuantity) AS inventory_value
    FROM zepto
    GROUP BY category
)
SELECT *
FROM inventory
WHERE inventory_value >
(
    SELECT AVG(inventory_value)
    FROM inventory
);

-- Q10. Find the second most expensive product in each category.
SELECT *
FROM (
    SELECT
        category,
        name,
        discountedSellingPrice,
        DENSE_RANK() OVER(
            PARTITION BY category
            ORDER BY discountedSellingPrice DESC
        ) AS rnk
    FROM zepto
) t
WHERE rnk = 2;

