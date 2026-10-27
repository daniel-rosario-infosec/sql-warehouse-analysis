-- 1. Products at or below their reorder level
SELECT ProductName, UnitsInStock, ReorderLevel
FROM Product
WHERE UnitsInStock <= ReorderLevel AND Discontinued = 0
ORDER BY UnitsInStock;

-- 2. Average days from order to shipment, by shipping company
SELECT s.CompanyName,
       COUNT(*) AS orders,
       ROUND(AVG(julianday(o.ShippedDate) - julianday(o.OrderDate)), 1) AS avg_days_to_ship
FROM "Order" o
JOIN Shipper s ON s.Id = o.ShipVia
WHERE o.ShippedDate IS NOT NULL AND o.ShippedDate <> ''
GROUP BY s.CompanyName
ORDER BY avg_days_to_ship;

-- 3. Share of orders shipped after the required date
SELECT COUNT(*) AS shipped_orders,
       SUM(CASE WHEN ShippedDate > RequiredDate THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN ShippedDate > RequiredDate THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM "Order"
WHERE ShippedDate IS NOT NULL AND ShippedDate <> '';

-- 4. Revenue by product category
SELECT c.CategoryName,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM OrderDetail od
JOIN Product p ON p.Id = od.ProductId
JOIN Category c ON c.Id = p.CategoryId
GROUP BY c.CategoryName
ORDER BY revenue DESC;

-- 5. Top 10 customers by revenue
SELECT cu.CompanyName,
       COUNT(DISTINCT o.Id) AS orders,
       ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS revenue
FROM Customer cu
JOIN "Order" o ON o.CustomerId = cu.Id
JOIN OrderDetail od ON od.OrderId = o.Id
GROUP BY cu.CompanyName
ORDER BY revenue DESC
LIMIT 10;
