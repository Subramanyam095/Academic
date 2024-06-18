create database retail

use retail

--Q1.What is the total number of rows in each of the 3 tables in the database?

SELECT 'Customer' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Customer UNION 
SELECT 'prod_cat_info' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM prod_cat_info UNION 
SELECT 'Transactions' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Transactions 

--Q2.What is the total number of transactions that have a return?
select * from Transactions
select count(transaction_id)from Transactions where total_amt<0 and Qty<0

--Q3.	As you would have noticed, the dates provided across the datasets are not in a correct format. 
---     As first steps, pls convert the date variables into valid date formats before proceeding ahead.
Alter table Transactions alter column tran_date date

--Q4.	What is the time range of the transaction data available for analysis? 
--- Show the output in number of days, months and years simultaneously in different columns.
select datediff(year,min(tran_date),max(tran_date)) [Year] , datediff(month,min(tran_date), max(tran_date)) [MONTH],
 datediff(day,min(tran_date), max(tran_date) )[Day]
from Transactions

--Q5. Which product category does the sub-category “DIY” belong to?
select prod_cat,prod_subcat 
from prod_cat_info 
where prod_subcat in ('DIY')

--Data Analysis

--Q1.Which channel is most frequently used for transactions?
select top 1 Store_type, count(transaction_id) [Count]
from Transactions
group by store_type 
order by count DESC


--Q2.What is the count of Male and Female customers in the database?

SELECT 'Male' AS Lable, COUNT(Gender) AS Gender FROM Customer where gender='M' UNION 
SELECT 'Female' AS Lable, COUNT(Gender) AS Gender FROM Customer where gender='F' 


--Q3.From which city do we have the maximum number of customers and how many?
select city_code, count(city_code) as [Count] 
from Customer
where city_code is not null Group by city_code

--Q4.How many sub-categories are there under the Books category?
select count(prod_cat)
From  prod_cat_info where prod_cat = 'Books'


--Q5.What is the maximum quantity of products ever ordered?
select top 10 cust_id ,sum(qty) as order_qty  from Transactions
group by cust_id  
order by order_qty DESC


--Q6.What is the net total revenue generated in categories Electronics and Books?
select sum(total_amt) as net_revenu_by_filter 
from Transactions
where prod_cat_code = '3' or prod_cat_code = '5'

--Q7.How many customers have >10 transactions with us, excluding returns?

select cust_id,count(transaction_id) as Num_id
from Transactions
group by cust_id
having count(*) > 10
order by Num_id desc

--Q8.What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

select  SUM(total_amt) as revenue from Transactions
where Store_type = 'Flagship store' and (prod_cat_code = '3' or prod_cat_code = '1')
group by prod_cat_code

--Q9 in fact table we dont have gender details, iam mearging with custmer table to get a gender details
select distinct prod_subcat as Prod_subcat ,SUM(total_amt) AS revenue from Transactions as t1 
inner JOIN prod_cat_info as t2 ON t2.prod_cat_code =t1.prod_cat_code
inner join Customer as t3 on t3.customer_Id= t1.cust_id
where Gender = 'M' and	prod_cat='Electronics'
group by prod_subcat

--Q10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?
    Select t1.prod_subcat,[Percent sales],[Percent returns] from
 (Select top 5 prod_subcat,sum(total_amt) /(select sum(total_amt) from Transactions)*100[Percent sales] 
 from Transactions t 
 inner join prod_cat_info p on t.prod_cat_code = p.prod_cat_code
 group by prod_sub_cat_code, prod_subcat
 order by sum(total_amt) desc)t1
 left join
 (Select top 5 p.prod_subcat,sum(qty)/(Select sum(qty)*0.01 from Transactions where qty<0)[Percent returns]
 from Transactions t2 inner join  prod_cat_info p on t2.prod_cat_code = p.prod_cat_code
 where Qty<0
 group by prod_sub_cat_code, prod_subcat
 order by [Percent returns] desc)t2 on t1.prod_subcat=t2.prod_subcat



--Q11.For all customers aged between 25 to 35 years find what is the net total revenue generated
 ---   by these consumers in last 30 days of transactions from max transaction date available in the data?
select sum(total_amt) as revenue  from Customer t1
inner join Transactions as t3 on t3.cust_id=t1.customer_Id 
WHERE DATEDIFF(year,DOB,getdate()) BETWEEN 25 AND 35
AND tran_date=(dateadd(day,-30,(select max(tran_date) from Transactions)))

--Q12.Which product category has seen the max value of returns in the last 3 months of transaction?
select top 1 prod_cat  from Transactions t1
inner join prod_cat_info t2 on t2.prod_cat_code=t1.prod_cat_code
where tran_date between dateadd(month, -3,(select max(tran_date) from Transactions)) and (select max(tran_date) from transactions)and qty<0
group by prod_cat
order by sum(qty)desc

--Q13.Which store-type sells the maximum products; by value of sales amount and by quantity sold?
select top 1 Store_type, sum(total_amt) as sales , sum(qty) as qty
from Transactions 
group by Store_type
order by qty desc

--Q14.What are the categories for which average revenue is above the overall average.
select prod_cat, AVG(total_amt) as average 
from Transactions t1
inner join prod_cat_info t2 on t2.prod_cat_code=t1.prod_cat_code
group by t1.prod_cat_code,prod_cat
having AVG(total_amt) > (select AVG(total_amt) from Transactions)

--Q15.Find the average and total revenue by each subcategory for the categories which are among 
 --- top 5 categories in terms of quantity sold.

select prod_subcat, avg(total_amt)[average revenue],sum(total_amt)[total revenue] from Transactions t1
inner join prod_cat_info t2 on t1.prod_subcat_code=t2.prod_sub_cat_code
where prod_cat in (select top 5 prod_cat from transactions t1
inner join prod_cat_info t2 on t1.prod_cat_code=t2.prod_cat_code
group by prod_cat
order by sum(qty) desc)
group by prod_subcat
 


