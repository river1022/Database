https://repl.it/@JiangHe/Database-Lab-2-Querying-Multiple-Tables-1#main.sql

.header ON
.mode column

CREATE TABLE Item (
  ItemName VARCHAR(30) NOT NULL,
  ItemType CHAR(1) NOT NULL,
  ItemColour VARCHAR(10),
  PRIMARY KEY (ItemName));

CREATE TABLE Employee (
  EmployeeNumber SMALLINT UNSIGNED NOT NULL,
  EmployeeName VARCHAR(10) NOT NULL,
  EmployeeSalary INTEGER UNSIGNED NOT NULL,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES
  Department,
  BossNumber SMALLINT UNSIGNED NOT NULL REFERENCES
  Employee,
  PRIMARY KEY (EmployeeNumber));

CREATE TABLE Department (
  DepartmentName VARCHAR(10) NOT NULL,
  DepartmentFloor SMALLINT UNSIGNED NOT NULL,
  DepartmentPhone SMALLINT UNSIGNED NOT NULL,
  EmployeeNumber SMALLINT UNSIGNED NOT NULL REFERENCES
  Employee,
  PRIMARY KEY (DepartmentName));

CREATE TABLE Sale (
  SaleNumber INTEGER UNSIGNED NOT NULL,
  SaleQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  ItemName VARCHAR(30) NOT NULL REFERENCES Item,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES
  Department,
  PRIMARY KEY (SaleNumber));

CREATE TABLE Supplier (
  SupplierNumber INTEGER UNSIGNED NOT NULL,
  SupplierName VARCHAR(30) NOT NULL,
  PRIMARY KEY (SupplierNumber));

CREATE TABLE Delivery (
  DeliveryNumber INTEGER UNSIGNED NOT NULL,
  DeliveryQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  ItemName VARCHAR(30) NOT NULL REFERENCES Item,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES
  Department,
  SupplierNumber INTEGER UNSIGNED NOT NULL REFERENCES
  Supplier,
  PRIMARY KEY (DeliveryNumber));

.table
.separator "\t"
.import delivery.txt Delivery
.import department.txt Department
.import employee.txt Employee
.import item.txt Item
.import sale.txt Sale
.import supplier.txt Supplier

.print
.print 'Q1-1. List the green items of type C'
SELECT ItemName FROM Item
WHERE ItemType = 'C' AND ItemColour = 'Green';

.print
.print 'Q1-2. What are the names of brown items sold by the Recreation Department'
SELECT Item.ItemName FROM Item, Department, Sale
WHERE Item.ItemName = Sale.ItemName 
AND Department.DepartmentName = Sale.DepartmentName
AND ItemColour = 'Brown'
AND Department.DepartmentName = 'Recreation';

.print
.print 'Q1-3. Which suppliers deliver compasses?'
SELECT DISTINCT SupplierName FROM Supplier, Delivery
WHERE Delivery.ItemName = 'Compass'
AND Supplier.SupplierNumber = Delivery.SupplierNumber;

.print
.print 'Q1-4. What items are delivered to the Books department?'
SELECT DISTINCT Sale.ItemName FROM Department, Sale, Delivery
WHERE Sale.DepartmentName = Department.DepartmentName
AND Department.DepartmentName = Delivery.DepartmentName
AND Sale.DepartmentName = 'Books';

.print
.print 'Q1-5. What are the numbers and names of those employees who earn more than their managers?';
SELECT Worker.EmployeeNumber, Worker.EmployeeName
FROM Employee AS Worker, Employee AS Boss
WHERE Worker.BossNumber = Boss.EmployeeNumber
AND Worker.EmployeeSalary > Boss.EmployeeSalary;

.print
.print 'Q1-6. What are the names of employees who are in the same department as their manager (as an employee), reporting the name of the employee, the department and the manager?';
SELECT Worker.EmployeeName, Worker.DepartmentName, Boss.EmployeeName AS 'Manager'
FROM Employee AS Worker, Employee AS Boss
WHERE Worker.BossNumber = Boss.EmployeeNumber
AND Worker.DepartmentName = Boss.DepartmentName;

.print
.print 'Q1-7. List the departments having an average salary of over £25000.'
SELECT DepartmentName
FROM Employee
GROUP BY DepartmentName
HAVING AVG(EmployeeSalary) > 25000;

.print
.print 'Q1-8. List the name, salary and manager of the employees of the Marketing department who have a salary of over £25000'
SELECT Worker.EmployeeName, Worker.EmployeeSalary, Boss.EmployeeName AS 'Manager'
FROM Employee AS Worker, Employee AS Boss, Department
WHERE Worker.BossNumber = Boss.EmployeeNumber
AND Worker.EmployeeSalary > 25000
AND Worker.DepartmentName = Department.DepartmentName
AND Department.DepartmentName = 'Marketing';

.print
.print 'Q1-9. For each item, give its type, the departments that sell the item and the floor location of these departments.'
SELECT Item.ItemName, ItemType, Department.DepartmentName, DepartmentFloor
FROM Item, Department, Sale
WHERE Item.ItemName = Sale.ItemName
AND Department.DepartmentName = Sale.DepartmentName
ORDER BY Item.ItemName;

.print
.print 'Q1-10. What suppliers deliver a total quantity of items of types 'C' and 'N' that is altogether greater than 100?'
SELECT SupplierName 
FROM Item, Delivery, Supplier
WHERE Item.ItemName = Delivery.ItemName
AND Supplier.SupplierNumber = Delivery.SupplierNumber
AND (ItemType = 'C' OR ItemType = 'N')
GROUP BY SupplierName
HAVING SUM(DeliveryQuantity) > 100;

.print
.print 'Q2-1. Find the suppliers that do not deliver compasses.'
SELECT SupplierName
FROM Supplier
WHERE SupplierNumber NOT IN
(SELECT SupplierNumber FROM Delivery
WHERE ItemName = 'Compass');

.print
.print 'Q2-2. Find the name of the highest-paid employee in the Marketing Department'
SELECT EmployeeName
FROM Employee
WHERE EmployeeSalary = 
(SELECT MAX(EmployeeSalary) FROM Employee
WHERE DepartmentName = 'Marketing');

.print
.print 'Q2-3. Find the names of the suppliers that do not supply compasses or geo-positioning systems'
SELECT SupplierName
FROM Supplier
WHERE SupplierNumber NOT IN
(SELECT SupplierNumber FROM Delivery
WHERE ItemName = 'Compass' OR ItemName = 'Geo positioning system');

.print
.print 'Q2-4. Find the number of employees with a salary under £10000'
SELECT COUNT(*)
FROM Employee
WHERE EmployeeName IN
(SELECT EmployeeName
FROM Employee
WHERE EmployeeSalary < 10000);

.print
.print 'Q2-5. List the departments on the second floor that contain more than one employee'
SELECT DepartmentName
FROM Department
WHERE DepartmentFloor = '2'
AND DepartmentName IN
(SELECT DepartmentName
FROM Employee
GROUP BY DepartmentName
HAVING COUNT(*) > 1)