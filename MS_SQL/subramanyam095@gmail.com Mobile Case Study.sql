--SQL Advance Case Study
create database mobile

use mobile
select * from DIM_DATE

select *
from DIM_MANUFACTURER

--Q1--BEGIN 
	--List all the states in which we have customers who bought cellphones from the 2005 to till today
	select State,count(IDCustomer) as number_of_customers
	from FACT_TRANSACTIONS as t1
	LEFT JOIN DIM_LOCATION as t2 ON t2.IDLocation =t1.IDLocation
	where YEAR(Date) >2005
	group by State

--Q1--END

--Q2--BEGIN
--what state in the US is buying the most samsung cell phones?

select Country,State, sum(Quantity) as qty, COUNT(IDCustomer) as no_customer
	from FACT_TRANSACTIONS as t1
	LEFT JOIN DIM_LOCATION as t2 ON t2.IDLocation =t1.IDLocation
	LEFT JOIN DIM_MODEL as t3 ON t3.IDModel =t1.IDModel
	LEFT JOIN DIM_MANUFACTURER as t4 ON t4.IDManufacturer =t3.IDManufacturer
	where Manufacturer_Name like 'Samsung' and Country ='US'
	group by Country,State

--Q2--END

--Q3--BEGIN      
--Show the number of transections for each model per zip code per state.

select state, zipcode, count(IDCustomer) as Transections
from FACT_TRANSACTIONS as t1
left join DIM_LOCATION as t2 on t2.IDLocation = t1.IDLocation
group by state,ZipCode
order by Transections DESC

--Q3--END

--Q4--BEGIN
--Show the Chepest Cellphone (Output should contain The price also)

 select top 1 Model_Name,min(Unit_price) as Chepest_unit_Price ,min(TotalPrice) price
from FACT_TRANSACTIONS as t1
left join DIM_MODEL as t2 on t2.IDModel = t1.IDModel
group by Model_Name


--Q4--END

--Q5--BEGIN
--Find over the average price for each model in the top5 manufacturers in term of sales quantity and order by average price. 
select top 5 Model_Name,count(Quantity) Total_QTY, avg(TotalPrice) AVG_price
from FACT_TRANSACTIONS as t1
left join DIM_MODEL as t2 on t2.IDModel = t1.IDModel
left join DIM_MANUFACTURER as t3 on t3.IDManufacturer = t2.IDManufacturer
group by Model_Name,Quantity
order by  AVG_price desc

--Q5--END

--Q6--BEGIN
--List the name of customers and the average amount spent in 2009, where the average is higher then 500
select Customer_Name, AVG(TotalPrice) as Avg_amount_Spet ,YEAR
from FACT_TRANSACTIONS as t1
left join DIM_CUSTOMER as t2 on t2.IDCustomer = t1.IDCustomer
left join DIM_DATE as t3 on t3.DATE = t1.Date
where YEAR like '2009' 
group by Customer_Name,YEAR
having AVG(TotalPrice) >500


--Q6--END
	
--Q7--BEGIN  
--List if there is any modeal that was in the top 5 in terms of quantity, Simultaneously in 2008,2009 and 2010.

select * from [dbo].[DIM_MODEL] d right join 
(select idmodel from (SELECT TOP 5 SUM(QUANTITY)[qty],idmodel FROM FACT_TRANSACTIONS WHERE YEAR(DATE)=2008
GROUP BY IDMODEL ORDER BY SUM(QUANTITY)DESC)t3
intersect
select idmodel from (SELECT TOP 5 SUM(QUANTITY)[qty],idmodel FROM FACT_TRANSACTIONS WHERE YEAR(DATE)=2009
GROUP BY IDMODEL ORDER BY SUM(QUANTITY)DESC)t3
intersect
select idmodel from (SELECT TOP 5 SUM(QUANTITY)[qty],idmodel FROM FACT_TRANSACTIONS WHERE YEAR(DATE)=2010
GROUP BY IDMODEL ORDER BY SUM(QUANTITY)DESC)t3) t4 on d.idmodel=t4.IDModel

--Q7--END	

--Q8--BEGIN
--Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer 
-- with the 2nd top sales in the year of 2010.

  with rnk as
 (Select year(date)[Year],m.IDManufacturer,Manufacturer_Name ,rank() over( order by sum(TotalPrice) desc) as [Rank]
 from FACT_TRANSACTIONS f inner join DIM_MODEL m on f.IDModel=m.IDModel 
 inner join DIM_MANUFACTURER ma on m.IDManufacturer=ma.IDManufacturer
 where year(date) ='2009' 
 group by year(date),m.IDManufacturer,Manufacturer_Name
 union all
 Select year(date)[Year], m.IDManufacturer,Manufacturer_Name ,rank() over( order by sum(TotalPrice) desc) as [Rank]
 from FACT_TRANSACTIONS f inner join DIM_MODEL m on f.IDModel=m.IDModel 
 inner join DIM_MANUFACTURER ma on m.IDManufacturer=ma.IDManufacturer
 where year(date) ='2010' 
 group by year(date), m.IDManufacturer,Manufacturer_Name)
 Select year[Year],Manufacturer_Name from rnk
 where [Rank]=2

 --Q8--END

--Q9--BEGIN
--Show the manufacturers that sold cellphones in 2010 but did not in 2009.	
select Manufacturer_Name from DIM_MANUFACTURER as t1
inner join DIM_MODEL as t2 on t2.IDManufacturer = t1.IDManufacturer
inner join FACT_TRANSACTIONS as t3 on t3.IDModel = t2.IDModel
where year(date) =2010 
except
select Manufacturer_Name from DIM_MANUFACTURER as t1
inner join DIM_MODEL as t2 on t2.IDManufacturer = t1.IDManufacturer
inner join FACT_TRANSACTIONS as t3 on t3.IDModel = t2.IDModel
where year(date) = 2009

--Q9--END

--Q10--BEGIN
--Find top 10 customers and their average spend, average quantity by each year. 
--Also find the percentage of change in their spend

 create view a as
 Select top 10 t1.IDCustomer, Customer_Name from DIM_CUSTOMER t1 
 inner join FACT_TRANSACTIONS t6 on t1.IDCustomer=t6.IDCustomer
 group by t1.IDCustomer,Customer_Name
 order by sum(TotalPrice) desc

 create view b as
 (Select Customer_Name,avg(TotalPrice)[Average spend],avg(Quantity)[Average quantity], sum(TotalPrice)[Total Spend],
 lag(sum (TotalPrice)) over(Partition by a.Customer_Name order by year(date))[lag]from FACT_TRANSACTIONS t6 
 inner join a on t6.IDCustomer=a.IDCustomer
 Group by a.Customer_Name,year([date]))

 Select a.Customer_Name, [Average spend],[Average quantity],([Total Spend] - [lag])*100/[lag]
 [Percent change of spend] from a inner join b on   a.Customer_Name=b.Customer_Name  
 
 --Q10--END
	