/**********************************************************/
/**********    DATA PREPARATION AND UNDERSDANDING  ********/
/**********************************************************/

--Q1
select count(*) as total_no_of_rows, 'customer' as table_name from customer
union
SELECT COUNT(*) as total_no_of_rows, 'transactions' as table_name from Transactions
union
select count(*) as total_no_of_rows, 'prod_cat_info' as table_name from prod_cat_info

--Q2
select COUNT(*) as No_of_returns from Transactions where total_amt < 0

--Q3
/* I HAVE CONVERTED THE DATES BEFORE IMPORTING THE DATA */

--Q4
select datediff(year,min(tran_date),max(tran_date)) as [time_range_in_years],
datediff(month,min(tran_date),max(tran_date)) as [time_range_in_months],
datediff(day,min(tran_date),max(tran_date)) as [time_range_in_days]
from transactions

--Q5
select prod_cat as product_category,prod_subcat as product_sub_category from prod_cat_info
where prod_subcat = 'diy'


/**********************************************************/
/********************* DATA ANALYSIS **********************/
/**********************************************************/

--Q1
select top 1 count(transaction_id) as totalcount,Store_type from Transactions
group by Store_type order by totalcount desc

--Q2
select count(*) as total ,'male' as tablename from customer where gender = 'm'
union
select count(*) as total,'female' as tablename from customer where gender = 'f'

--Q3
select top 1 count(*) as number_of_customers,city_code from Customer group by city_code 
order by number_of_customers desc

--Q4
select count(*) as no_of_subcategories from prod_cat_info where prod_cat = 'books'

--Q5
select max(qty) as maximum_quantity_of_products_ever_ordered from Transactions

--Q6
select round(SUM(total_amt),2) as total_amount , prod_cat_info.prod_cat from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where prod_cat_info.prod_cat in ('books','electronics')
group by prod_cat_info.prod_cat

--Q7
select count(distinct cust_id) as no_of_customers from transactions 
where cust_id in (select cust_id from Transactions where Qty > 0
group by cust_id having count(transaction_id)>10)

--Q8
select round(sum(Transactions.total_amt),2) as combined_revenue from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where prod_cat_info.prod_cat in ('electronics','clothing') and  Transactions.Store_type = 'flagship store'

--Q9
select round(sum(Transactions.total_amt),2) as total_revenue ,prod_cat_info.prod_subcat as 'electronics' from Transactions 
join Customer on Transactions.cust_id = Customer.customer_Id 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where Customer.Gender = 'm' and prod_cat_info.prod_cat='electronics' group by prod_cat_info.prod_subcat

--Q10
select top 5 
round((SUM(Transactions.total_amt)*100)/(select sum(total_amt) from Transactions),2) as [sales_percentage], 
round((SUM(case when transactions.Qty < 0 then total_amt else 0 end)*100)/(select sum(total_amt) from Transactions),2)*(-1) as [return_percentage], 
prod_cat_info.prod_subcat from Transactions 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
group by prod_cat_info.prod_subcat order by SUM(total_amt) desc

--Q11
select round(sum(total_amt),2) as total_revenue from Transactions
join Customer on Transactions.cust_id = Customer.customer_Id 
where (DATEDIFF(year,customer.dob,GETDATE()) between 25 and 35 ) 
and ( datediff(day,tran_date,(select max(tran_date) from transactions))<=30)

--Q12
select top 1 round(sum(transactions.total_amt),2) as return_value,prod_cat_info.prod_cat
from Transactions 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where Transactions.total_amt < 0  and tran_date>(select dateadd(month,-3,max(tran_date)) from Transactions)
group by  prod_cat_info.prod_cat
order by sum(transactions.total_amt) asc

--Q13
select top 1 round(sum(total_amt),2) as sales_amount,sum(Qty) as quantity,store_type
from Transactions group by Store_type order by sum(total_amt) desc

--Q14
select prod_cat_info.prod_cat from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
group by transactions.prod_cat_code,prod_cat_info.prod_cat
having AVG(total_amt)>(select AVG(total_amt) from Transactions)

--Q15
select round(sum(Transactions.total_amt),2)as total_revenue,round(avg(transactions.total_amt),2)as average_revenue,prod_cat_info.prod_subcat,
prod_cat_info.prod_cat from Transactions 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where Transactions.prod_cat_code in (select top 5 prod_cat_code from Transactions group by prod_cat_code order by COUNT(qty)desc)
group by  prod_cat_info.prod_cat,prod_cat_info.prod_subcat
order by prod_cat_info.prod_cat, prod_cat_info.prod_subcat
