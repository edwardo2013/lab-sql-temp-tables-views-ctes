USE sakila;

SELECT
MIN(movies_made)
FROM
(SELECT
first_name,
last_name,
COUNT(*) as movies_made
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
WHERE first_name REGEXP '^[A-M]'
GROUP BY first_name,last_name
HAVING COUNT(*)>=20
ORDER BY COUNT(*) DESC
LIMIT 5 OFFSET 1)
 AS table_1; 
 
 
WITH table_1 AS
(SELECT
first_name,
last_name,
COUNT(*) as movies_made
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
WHERE first_name REGEXP '^[A-M]'
GROUP BY first_name,last_name
HAVING COUNT(*)>=20
ORDER BY COUNT(*) DESC
LIMIT 5 OFFSET 1)

SELECT 
MIN(movies_made)
FROM table_1
; 

CREATE TEMPORARY TABLE table_1 AS
(SELECT
first_name,
last_name,
COUNT(*) as movies_made
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
WHERE first_name REGEXP '^[A-M]'
GROUP BY first_name,last_name
HAVING COUNT(*)>=20
ORDER BY COUNT(*) DESC
LIMIT 5 OFFSET 1);

SELECT 
MIN(movies_made)
FROM table_1
; 

CREATE VIEW table_1_view AS
(SELECT
first_name,
last_name,
COUNT(*) as movies_made
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
WHERE first_name REGEXP '^[A-M]'
GROUP BY first_name,last_name
HAVING COUNT(*)>=20
ORDER BY COUNT(*) DESC
LIMIT 5 OFFSET 1);

SELECT 
MIN(movies_made)
FROM table_1_view
; 
-- LAB solution
-- STEP 1 First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, 
-- and total number of rentals (rental_count).
CREATE VIEW rental_summary AS
SELECT
customer.customer_id,
CONCAT(first_name,' ',last_name) AS name,
email AS email_address,
COUNT(rental_id) rental_count
FROM customer
JOIN rental ON customer.customer_id=rental.customer_id
GROUP BY customer.customer_id,
CONCAT(first_name,' ',last_name),
email ;

select * from rental_summary;

-- STEP 2 Next, create a Temporary Table that calculates the total amount paid
-- by each customer (total_paid).
--  The Temporary Table should use the rental summary view created in Step 1
-- to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid_table AS
(SELECT 
rental_summary.customer_id,
name,
SUM(amount) total_paid
FROM 
rental_summary
JOIN payment ON rental_summary.customer_id=payment.customer_id
GROUP BY rental_summary.customer_id, name);
/*
Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary 
Temporary Table created in Step 2. The CTE should include the customer's name, 
email address, rental count, and total amount paid.

Next, using the CTE, create the query to generate the final customer summary report,
 which should include: customer name, email, rental_count, total_paid and 
 average_payment_per_rental, this last column is a derived column from total_paid 
 and rental_count.
*/
WITH customer_summary_report AS
(SELECT
rental_summary.customer_id,
rental_summary.name,
rental_summary.email_address,
rental_summary.rental_count,
total_paid_table.total_paid,
total_paid_table.total_paid/rental_summary.rental_count AS average_payment_per_rental
FROM rental_summary
JOIN total_paid_table ON rental_summary.customer_id= total_paid_table.customer_id)
SELECT 
*
FROM customer_summary_report
;

