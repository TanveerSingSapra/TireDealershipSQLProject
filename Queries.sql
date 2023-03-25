# MOD Final Project Group 12
# Authors: Rahul Passi, Vaishakh Prakash, Naveen Shaji, Tanveer Singh Sapra, Ziyue Tang

# Analysis on Erroneous Data
# Phone number and name mis-entry check
SELECT employee_transactions.EmployeeID,employee_transactions.EmployeeName,Total_Transactions,Misentries,(Misentries/Total_Transactions) AS Error_Ratio
FROM
	(SELECT EmployeeID,EmployeeName, COUNT(*) AS Total_Transactions
	FROM
		(SELECT transaction.EmployeeID,EmployeeName
		FROM transaction
		LEFT JOIN employees
		ON transaction.EmployeeID=employees.EmployeeID) AS total_transactions
	GROUP BY 1,2) employee_transactions
LEFT JOIN
(SELECT EmployeeID,EmployeeName,COUNT(*) AS Misentries
FROM
	(SELECT Phone, CAST(Phone AS FLOAT) AS Phone_Check,Name,transaction.EmployeeID,EmployeeName
	FROM transaction
	LEFT JOIN employees
	ON transaction.EmployeeID=employees.EmployeeID
	) AS phone_name_entries
WHERE Phone_Check=0
OR Name LIKE 'N.A'
GROUP BY 1,2) AS employee_mistakes
ON Employee_Transactions.EmployeeID=employee_mistakes.EmployeeID;

# Missing Make or Model
SELECT Make,Model,COUNT(*) AS MissingCount
FROM vehicles
WHERE Make LIKE 'NA'
OR Model LIKE 'NA'
GROUP BY 1,2;

# Analysis on Business and Employee Performance
# Monthly Sales
SELECT MONTH(Date) AS sale_month,SUM(AmountSold) AS sold_amount
FROM transaction
GROUP BY 1;

# Daywise Sales
SELECT CASE WHEN sale_day=0 THEN 'Monday'
			WHEN sale_day=1 THEN 'Tuesday'
			WHEN sale_day=2 THEN 'Wednesday'
   			WHEN sale_day=3 THEN 'Thursday'
   			WHEN sale_day=4 THEN 'Friday'
            WHEN sale_day=5 THEN 'Saturday'
            ELSE 'Sunday' END AS day_of_sale,sold_amount
FROM
(
SELECT WEEKDAY(Date) AS sale_day,SUM(AmountSold) AS sold_amount
FROM transaction
GROUP BY 1
)daily_sales;

# Product Wise Sales
SELECT product,SUM(AmountSold) AS sold_amount
FROM transaction
GROUP BY 1
LIMIT 10;

# Product Current Stock
SELECT product,SUM(Currentstock) AS stock_amount
FROM inventory
GROUP BY 1
LIMIT 10;

# Sales vs Inventory Management (Top 10 sold vs Top 20 in stock)
SELECT *
FROM (SELECT product,SUM(AmountSold) AS sold_amount
FROM transaction
GROUP BY 1
LIMIT 10) AS SOLD
LEFT JOIN
(SELECT product
FROM inventory
GROUP BY 1
LIMIT 20) AS STOCK
ON SOLD.product=STOCK.product;

# Employee Efficiency
SELECT EmployeeName,transactions
FROM
(
SELECT EmployeeID,COUNT(*) AS transactions
FROM transaction
GROUP BY 1
)employee_transaction_counter
LEFT JOIN
(
SELECT *
FROM employees
)employee_table
ON employee_transaction_counter.employeeID=employee_table.employeeID;

# Bridgestone Certification Usefulness
SELECT BridgestoneCertified,AVG(transactions) AS transactions
FROM
(
SELECT EmployeeID,COUNT(*) AS transactions
FROM transaction
GROUP BY 1
)employee_transaction_counter
LEFT JOIN
(
SELECT *
FROM employees
)employee_table
ON employee_transaction_counter.employeeID=employee_table.employeeID
GROUP BY 1;

# Average Ratings across Employees
select EmployeeName, AVG(Rating) as AverageRating from
(select * from
(SELECT CustomerName, EmployeeID
FROM (select transaction.VehicleNO, name, EmployeeID from transaction) bs
 inner join 
 vehicles 
on bs.VehicleNO=vehicles.VehicleNo)bt
inner join reviews
on bt.CustomerName=reviews.Author)bv
inner join employees
on employees.EmployeeID=bv.EmployeeID
group by EmployeeName;

# Average Ratings across Certified Employees
select BridgestoneCertified, AVG(Rating) as AverageRating from
(select * from
(SELECT CustomerName, EmployeeID
FROM (select transaction.VehicleNO, name, EmployeeID from transaction) bs
 inner join 
 vehicles 
on bs.VehicleNO=vehicles.VehicleNo)bt
inner join reviews
on bt.CustomerName=reviews.Author)bv
inner join employees
on employees.EmployeeID=bv.EmployeeID
group by BridgestoneCertified;