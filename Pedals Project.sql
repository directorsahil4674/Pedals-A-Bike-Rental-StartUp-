use bikerentalshop;

/*1. Emily would like to know how many bikes the shop owns by category. Can
you get this for her?
Display the category name and the number of bikes the shop owns in
each category (call this column number_of_bikes ). Show only the categories
where the number of bikes is greater than 2 .*/ 

SELECT 
    Category, COUNT(id) AS number_of_bikes
FROM
    bike
GROUP BY Category;
-- HAVING number_of_bikes > 2;  

SELECT 
    customer.name, COUNT(membership.id) AS membership_count
FROM
    customer
        LEFT JOIN
    membership ON customer.id = membership.customer_id
GROUP BY 1
ORDER BY 2 DESC;

/*3. Emily is working on a special offer for the winter months. Can you help her
prepare a list of new rental prices?
For each bike, display its ID, category, old price per hour (call this column
old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), old
price per day (call it old_price_per_day ), and discounted price per day (call it
new_price_per_day ).
Electric bikes should have a 10% discount for hourly rentals and a 20%
discount for daily rentals. Mountain bikes should have a 20% discount for
hourly rentals and a 50% discount for daily rentals. All other bikes should
have a 50% discount for all types of rentals.
Round the new prices to 2 decimal digits.*/  


SELECT 
    id,
    model,
    price_per_hour AS old_price_per_year,
    (CASE
        WHEN model LIKE 'Electric%' THEN price_per_hour - (price_per_hour * 0.1)
        WHEN model LIKE 'Mountain%' THEN price_per_hour - (price_per_hour * 0.2)
        ELSE price_per_hour - (price_per_hour * .5)
    END) AS new_price_per_hour,
    (CASE
        WHEN model LIKE 'Electric%' THEN ROUND(price_per_day - (price_per_day * .20), 2)
        WHEN model LIKE 'Mountain%' THEN ROUND(price_per_day - (price_per_day * .50), 2)
        ELSE ROUND(price_per_day - (price_per_day * .5), 2)
    END) AS new_price_per_day
FROM
    bike;
    
/*4. Emily is looking for counts of the rented bikes and of the available bikes in
each category.
Display the number of available bikes (call this column
available_bikes_count ) and the number of rented bikes (call this column
rented_bikes_count ) by bike category.*/

SELECT 
    category,
    SUM(CASE
        WHEN status LIKE 'available%' THEN 1
        ELSE 0
    END) AS available_bikes_count,
    SUM(CASE
        WHEN status LIKE 'rented%' THEN 1
        ELSE 0
    END) AS rented_bikes_count
FROM
    bike
GROUP BY 1;

/*5. Emily is preparing a sales report. She needs to know the total revenue
from rentals by month, the total by year, and the all-time across all the
years.
Bike rental shop - SQL Case study 5
Display the total revenue from rentals for each month, the total for each
year, and the total across all the years. Do not take memberships into
account. There should be 3 columns: year , month , and revenue .
Sort the results chronologically. Display the year total after all the month
totals for the corresponding year. Show the all-time total as the last row.*/  

SELECT 
    YEAR(start_timestamp) AS year,
    MONTH(start_timestamp) AS month,
    SUM(totaL_paid) AS total_revenue
FROM
    rental
GROUP BY 1 , 2 
UNION ALL SELECT 
    YEAR(start_timestamp) AS year,
    NULL AS month,
    SUM(total_paid) AS total_revenue
FROM
    rental
GROUP BY 1 
UNION ALL SELECT 
    NULL AS year,
    NULL AS month,
    SUM(total_paid) AS total_revenue
FROM
    rental
ORDER BY year , month;

/*SOL.2 => using ROLLUP.*/

SELECT 
    YEAR(start_timestamp) AS year,
    MONTH(start_timestamp) AS month,
    SUM(total_paid) AS total_revenue
FROM
    rental
GROUP BY 1 , 2 WITH ROLLUP
ORDER BY 1 , 2;

/*6. Emily has asked you to get the total revenue from memberships for each
combination of year, month, and membership type.
Display the year, the month, the name of the membership type (call this
column membership_type_name ), and the total revenue (call this column
total_revenue ) for every combination of year, month, and membership type.
Sort the results by year, month, and name of membership type.*/

SELECT 
    YEAR(membership.start_date) AS year,
    MONTH(membership.start_date) AS month,
    membership_type.name,
    SUM(total_paid) AS total_revenue
FROM
    membership_type
        INNER JOIN
    membership ON membership_type.id = membership.membership_type_id
GROUP BY 1 , 2 , 3 WITH ROLLUP
ORDER BY 1 , 2 , 3;
            
/*7. Next, Emily would like data about memberships purchased in 2023, with
subtotals and grand totals for all the different combinations of membership
types and months.
Display the total revenue from memberships purchased in 2023 for each
combination of month and membership type. Generate subtotals and
grand totals for all possible combinations. There should be 3 columns:
membership_type_name , month , and total_revenue .
Sort the results by membership type name alphabetically and then
chronologically by month.*/
  
SELECT 
    membership_type.name,
    MONTH(membership.start_date) AS month,
    SUM(total_paid) AS total_revenue
FROM
    membership_type
        INNER JOIN
    membership ON membership_type.id = membership.membership_type_id
WHERE
    YEAR(membership.start_date) = 2023
GROUP BY 1 , 2
ORDER BY 1 , 2;

SELECT 
    start_timestamp
FROM
    rental; 

/*8. */

with temp_table as (
  SELECT 
  customer_id, 
  COUNT(id) as count_of_rentals, 
  (CASE WHEN COUNT(1) > 10 THEN 'more than 10' 
      WHEN COUNT(1) >=5 AND COUNT(1) <=10 THEN 'between 5 and 10'
      ELSE 'fewer than 5'
      END) AS rental_count_category
FROM rental
GROUP BY 1 
) 

SELECT 
  rental_count_category, 
  COUNT(*) as total_customers
    FROM temp_table
  GROUP BY 1
  ORDER BY 1; 