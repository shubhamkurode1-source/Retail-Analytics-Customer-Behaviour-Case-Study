use casestudy;
show tables ;
describe saletransaction ;
describe customerprofiles;
describe productinventory ;

-- Result Set 1: Find duplicate TransactionIDs
select * from saletransaction;
select ï»¿TransactionID, 
count(*) as count 
from saletransaction
group by ï»¿TransactionID
having count(*) >1;
-- Create a table with unique records
create table saletransaction_duplicate as
select distinct *
from  saletransaction;

-- Drop the original table
DROP TABLE saletransaction;

-- Rename the new table
ALTER TABLE saletransaction_duplicate
RENAME TO saletransaction;

-- Result Set 2: Display the final table
SELECT *
FROM saletransaction;

-- Result Set 1: Identify price discrepancies
SELECT *
FROM saletransaction;
select * from productinventory;
select s.ï»¿TransactionID,
s.Price as saleprice ,
p.Price as invt_price
from saletransaction s join productinventory p
on p.ï»¿ProductID = s.ProductID
where s.Price <> p.Price


-- Update incorrect prices
SET SQL_SAFE_UPDATES = 0;

update saletransaction s  join  productinventory p
on p.ï»¿ProductID = s.ProductID
set s.Price =p.Price
where s.Price <> p.Price;

-- Result Set 2: Verify the updated table
SELECT *
FROM saletransaction;

#Identify null from customer_profile  location and replace with null
describe customerprofiles;
SELECT * FROM customerprofiles;
SELECT COUNT(*) AS count
FROM customerprofiles
WHERE Location IS NULL
   OR TRIM(Location) = '';
-- Update NULL values
UPDATE customerprofiles
SET Location = 'Unknown'
WHERE Location IS NULL
   OR TRIM(Location) = '';
   
-- Result Set 2
SELECT ï»¿CustomerID,
       Age,
       Gender,
       Location,
       JoinDate
FROM customerprofiles;


# Write a SQL query to clean the DATE column in the dataset.
-- Create a new table
DROP TABLE IF EXISTS saletransaction_updated;
SELECT *
FROM saletransaction;
create  table saletransaction_updated as 
select ï»¿TransactionID,CustomerID,ProductID,
QuantityPurchased,TransactionDate,Price,
STR_TO_DATE(TransactionDate, '%d/%m/%y') as TransactionDate_updated
from saletransaction;
-- Drop the original table
drop table  saletransaction;
-- Rename the new table
alter table saletransaction_updated rename to saletransaction;

-- Display the final table
select * from saletransaction;

# summarize the total sales _and quantities sold per product _by the company.
select * from saletransaction;
select ProductID,
sum(QuantityPurchased) as totalunit_sold ,
sum(QuantityPurchased *Price) as totalsale 
from saletransaction
group by ProductID
order by totalsale desc;

#count the number of transactions per customer to understand purchase frequency.
select * from saletransaction;
select CustomerID, count(*) as count_of_transaction 
from saletransaction
group by CustomerID
order by count(*) desc ;

#evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.
select * from saletransaction;
select * from productinventory;

select p.Category,
sum(s.QuantityPurchased) as total_quantity,
sum(s.QuantityPurchased*s.Price) as  total_sale 
from saletransaction s join productinventory p
on s.ProductID = p.ï»¿ProductID
group by p.Category
order by sum(s.QuantityPurchased*s.Price) desc;

# top 10 products with the highest total sales revenue from the sales transactions.
select * from saletransaction;
select ProductID,
sum(QuantityPurchased*Price) as total_sale 
from saletransaction
group by ProductID
order by total_sale desc
limit 10;

#find the ten products with the least amount of units sold from the sales transactions
select  ProductID, 
sum(QuantityPurchased) as totalunitsold
from saletransaction
group by ProductID
having sum(QuantityPurchased)>1
order by totalunitsold asc 
limit 10;

# sales trend to understand the revenue pattern of the company.

select * from saletransaction;
select TransactionDate_updated as datetrans, 
count(ï»¿TransactionID) as transaction_count,
sum(QuantityPurchased) as total_unit_sold,
round(sum(QuantityPurchased * Price),2) as total_sale 
from saletransaction
group by datetrans
order by datetrans desc ;

#month on month growth rate of sales of the company
select * from saletransaction;
with Previous_sale as (select month(TransactionDate_updated) as month ,
sum(QuantityPurchased * Price) as total_sale, 
lag(sum(QuantityPurchased * Price))
over(order by month(TransactionDate_updated)) as previous_month_sale 
from saletransaction
group by month)
select month,total_sale,previous_month_sale,
round((total_sale-previous_month_sale) /previous_month_sale *100,2) as MOM_GROWTH
from Previous_sale
group by month;

#y high-frequency customers
select CustomerID,
count(*) as number_of_transaction,
round(sum(QuantityPurchased *Price),2) as total_spend 
from saletransaction
group by CustomerID
having count(*)>10 and round(sum(QuantityPurchased *Price),2)>1000
order by round(sum(QuantityPurchased *Price),2) desc ;

#identify occasional or low-frequency customers

select CustomerID,
count(*) as number_of_transaction,
round(sum(QuantityPurchased *Price),2) as total_spend 
from saletransaction
group by CustomerID
having count(*)<=2
order by number_of_transaction asc ,total_spend desc
;

# total number of purchases made by each customer against each productID 
select CustomerID,ProductID,
count(*) as time_purchased
from saletransaction
group by CustomerID,ProductID
order by time_purchased desc;

# duration between the first and the last purchase of the customer

select CustomerID,
 min(TransactionDate_updated) as First_purchase,
 max(TransactionDate_updated) as last_purchase,
 datediff(max(TransactionDate_updated), min(TransactionDate_updated)) as Daysbetweenpurchase
 from saletransaction
 group by CustomerID
 order by Daysbetweenpurchase desc;
 
 #segment customers based on the total quantity of products purchased and count customers in each segment
 
with cx_seg as (select CustomerID,
 sum(QuantityPurchased) as sum_of_quantity,
 case 
 when sum(QuantityPurchased) between 1 and 10 then 'Low'
 when sum(QuantityPurchased)between 11 and 30 then 'mid'
 else  'high'
 end as customer_segments 
 from saletransaction
 group by CustomerID)
 select customer_segments, count(*) as total_quanity_of_product_purchased
 from cx_seg 
 group by customer_segments;
 
