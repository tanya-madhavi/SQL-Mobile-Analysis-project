--SQL Advance Case Study


--Q1--BEGIN 
Select Distinct l.State 
from dbo.FACT_TRANSACTIONS F
JOIN DBO.DIM_DATE D on 
f.date = d.date
join dbo.DIM_LOCATION l on
f.idLocation = l.idLocation
where d.year >= 2005;





--Q1--END

--Q2--BEGIN
select top 1 l.state,
sum(f.quantity) as totalsamsungsales 
from dbo.fact_transactions f 
join dbo.dim_model m on 
f.idmodel = m.idmodel 
join dbo.dim_manufacturer man on
m.idmanufacturer = man.idmanufacturer 
join dbo.dim_location l on 
f.idlocation = l.idlocation 
where man.Manufacturer_Name like 'samsung' 
group by l.state 
order by totalsamsungsales desc;










--Q2--END

--Q3--BEGIN      
select m.model_name,l.zipcode,l.state,
count(*) as numoftrans 
from dbo.fact_transactions f 
join dbo.dim_model m on
f.idmodel = m.idmodel 
join dbo.dim_location l on 
f.idlocation = l.idlocation
group by m.model_name,l.zipcode,l.state 
order by m.model_name,l.state;	










--Q3--END

--Q4--BEGIN
select unit_price,model_name 
from dbo.dim_model
where unit_price = (select min(unit_price)from dbo.dim_model);






--Q4--END

--Q5--BEGIN
WITH top5_manufacturers AS (
    SELECT TOP 5 m.idmanufacturer
    FROM dbo.fact_transactions f
    JOIN dbo.dim_model m ON f.idmodel = m.idmodel
    GROUP BY m.idmanufacturer
    ORDER BY SUM(f.quantity) DESC
)
SELECT m.model_name, AVG(m.unit_price) AS avg_price
FROM dbo.dim_model m
JOIN top5_manufacturers t5 ON m.idmanufacturer = t5.idmanufacturer
GROUP BY m.model_name
ORDER BY avg_price;














--Q5--END

--Q6--BEGIN
select c.Customer_Name,avg(f.TotalPrice) as avgp from
dbo.fact_transactions f 
join dbo.dim_Customer c on 
f.idcustomer = c.idcustomer 
join dbo.dim_Date d on
f.date = d.date 
where d.year = 2009 
group by c.Customer_Name 
having avg(f.TotalPrice) >500;











--Q6--END
	
--Q7--BEGIN  
WITH data AS (
    SELECT 
        f.idmodel,
        d.year,
        SUM(f.quantity) AS total_qty,
        RANK() OVER (PARTITION BY d.year ORDER BY SUM(f.quantity) DESC) AS rnk
    FROM fact_transactions f
    JOIN Dim_Date d ON f.date = d.date
    WHERE d.year IN (2008, 2009, 2010)
    GROUP BY f.idmodel, d.year
)
SELECT m.model_Name
FROM data d
JOIN Dim_model m ON d.idmodel = m.idmodel
WHERE d.rnk <= 5
GROUP BY m.model_Name
HAVING COUNT(DISTINCT d.year) = 3;	
	
















--Q7--END	
--Q8--BEGIN
WITH data AS (
    SELECT 
        man.manufacturer_Name,
        d.year,
        SUM(f.quantity) AS total_sales,
        RANK() OVER (PARTITION BY d.year ORDER BY SUM(f.quantity) DESC) AS rnk
    FROM fact_transactions f
    JOIN Dim_model m
        ON f.idmodel = m.idmodel
    JOIN Dim_manufacturer man
        ON m.idmanufacturer = man.idmanufacturer
    JOIN Dim_Date d
        ON f.date = d.date
    WHERE d.year IN (2009, 2010)
    GROUP BY man.manufacturer_Name, d.year
)
SELECT manufacturer_Name, year, total_sales
FROM data
WHERE rnk = 2;


















--Q8--END
--Q9--BEGIN
SELECT DISTINCT man.manufacturer_Name
FROM fact_transactions f
JOIN Dim_model m ON f.idmodel = m.idmodel
JOIN Dim_manufacturer man ON m.idmanufacturer = man.idmanufacturer
JOIN Dim_Date d ON f.date = d.date
WHERE d.year = 2010

EXCEPT

SELECT DISTINCT man.manufacturer_Name
FROM fact_transactions f
JOIN Dim_model m ON f.idmodel = m.idmodel
JOIN Dim_manufacturer man ON m.idmanufacturer = man.idmanufacturer
JOIN Dim_Date d ON f.date = d.date
WHERE d.year = 2009;	

















--Q9--END

--Q10--BEGIN
	WITH customer_year_stats AS (
    SELECT 
        c.idcustomer,
        c.Customer_Name,
        d.year,
        AVG(f.TotalPrice) AS avg_spend,
        AVG(f.quantity) AS avg_quantity,
        SUM(f.TotalPrice) AS total_spend
    FROM dbo.fact_transactions f
    JOIN dbo.dim_customer c ON f.idcustomer = c.idcustomer
    JOIN dbo.dim_date d ON f.date = d.date
    GROUP BY c.idcustomer, c.Customer_Name, d.year
),
top_customers AS (
    SELECT TOP 100 idcustomer
    FROM (
        SELECT idcustomer, SUM(total_spend) AS overall_spend
        FROM customer_year_stats
        GROUP BY idcustomer
    ) t
    ORDER BY overall_spend DESC
)
SELECT 
    cys.idcustomer,
    cys.Customer_Name,
    cys.year,
    cys.avg_spend,
    cys.avg_quantity,
    (cys.avg_spend - LAG(cys.avg_spend) OVER (PARTITION BY cys.idcustomer ORDER BY cys.year)) 
        * 100.0 / LAG(cys.avg_spend) OVER (PARTITION BY cys.idcustomer ORDER BY cys.year) AS pct_change_spend
FROM customer_year_stats cys
JOIN top_customers tc ON cys.idcustomer = tc.idcustomer
ORDER BY cys.idcustomer, cys.year;


















--Q10--END
	