--------## Tables----------
CREATE TABLE burger_names(
   burger_id   INTEGER  NOT NULL PRIMARY KEY 
  ,burger_name VARCHAR(10) NOT NULL
);

INSERT INTO burger_names(burger_id,burger_name) VALUES (1,'Meatlovers');
INSERT INTO burger_names(burger_id,burger_name) VALUES (2,'Vegetarian');

--------------------------
CREATE TABLE runner_orders(
   order_id     INTEGER  NOT NULL PRIMARY KEY 
  ,runner_id    INTEGER  NOT NULL
  ,pickup_time  timestamp
  ,distance     numeric
  ,duration     numeric
  ,cancellation VARCHAR(23)
);

INSERT INTO runner_orders VALUES (1,1,'2021-01-01 18:15:34','20','32',NULL);
INSERT INTO runner_orders VALUES (2,1,'2021-01-01 19:10:54','20','27',NULL);
INSERT INTO runner_orders VALUES (3,1,'2021-01-03 00:12:37','13.4','20',NULL);
INSERT INTO runner_orders VALUES (4,2,'2021-01-04 13:53:03','23.4','40',NULL);
INSERT INTO runner_orders VALUES (5,3,'2021-01-08 21:10:57','10','15',NULL);
INSERT INTO runner_orders VALUES (6,3,NULL,NULL,NULL,'Restaurant Cancellation');
INSERT INTO runner_orders VALUES (7,2,'2021-01-08 21:30:45','25','25',NULL);
INSERT INTO runner_orders VALUES (8,2,'2021-01-10 00:15:02','23.4','15',NULL);
INSERT INTO runner_orders VALUES (9,2,NULL,NULL,NULL,'Customer Cancellation');
INSERT INTO runner_orders VALUES (10,1,'2021-01-11 18:50:20','10','10',NULL);

-----------------------
CREATE TABLE burger_runner(
   runner_id   INTEGER  NOT NULL PRIMARY KEY 
  ,registration_date date NOT NULL
);

INSERT INTO burger_runner VALUES (1,'2021-01-01');
INSERT INTO burger_runner VALUES (2,'2021-01-03');
INSERT INTO burger_runner VALUES (3,'2021-01-08');
INSERT INTO burger_runner VALUES (4,'2021-01-15');

-------------
CREATE TABLE customer_orders(
   order_id    INTEGER  NOT NULL 
  ,customer_id INTEGER  NOT NULL
  ,burger_id    INTEGER  NOT NULL
  ,exclusions  VARCHAR(4)
  ,extras      VARCHAR(4)
  ,order_time  timestamp NOT NULL
);


INSERT INTO customer_orders VALUES (1,101,1,NULL,NULL,'2021-01-01 18:05:02');
INSERT INTO customer_orders VALUES (2,101,1,NULL,NULL,'2021-01-01 19:00:52');
INSERT INTO customer_orders VALUES (3,102,1,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (3,102,2,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,2,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (5,104,1,NULL,'1','2021-01-08 21:00:29');
INSERT INTO customer_orders VALUES (6,101,2,NULL,NULL,'2021-01-08 21:03:13');
INSERT INTO customer_orders VALUES (7,105,2,NULL,'1','2021-01-08 21:20:29');
INSERT INTO customer_orders VALUES (8,102,1,NULL,NULL,'2021-01-09 23:54:33');
INSERT INTO customer_orders VALUES (9,103,1,'4','1, 5','2021-01-10 11:22:59');
INSERT INTO customer_orders VALUES (10,104,1,NULL,NULL,'2021-01-11 18:34:49');
INSERT INTO customer_orders VALUES (10,104,1,'2, 6','1, 4','2021-01-11 18:34:49');

----------------------------------------------------------------------------------------
---------------------------------------------------------------
select * from burger_names;
select * from runner_orders;
select * from customer_orders;
select * from burger_runner;

-----------------------Questions---------------------------------------
--Q1 How many burgers were ordered?
Ans-  we have to calculate total count of orders ,we will use order_id column from runner_orders table

select count(*) as total_orders from runner_orders

-----------------------------------------------------------------------
--Q2 How many unique customer orders were made?
Ans - we have to find count of unique order_id from cutomer table

select count(distinct order_id) from customer_orders           --- count of unique orders = 10

select count(distinct customer_id) from customer_orders        ---count of unique customers = 5
-----------------------------------------------------------------------
--Q3 How many successful orders were delivered by each runner?
Ans-  successful orders means orders having cancellation = null

select runner_id, count(*) as total_successful_orders
from runner_orders
where cancellation is null
group by runner_id
-------------------------------------------------------------------------
--Q4.How many of each type of burger was delivered?
Ans- 
--query for count of succcessful delievered
select bn.burger_name,count(*) as total_burger_delivered
from customer_orders co
join burger_names bn on co.burger_id = bn.burger_id
join runner_orders ro on co.order_id = ro.order_id
where ro.cancellation is null
group by bn.burger_name

--query for count of succcessful ordered
select bn.burger_name,count(*) as total_
from customer_orders co join burger_names bn on co.burger_id = bn.burger_id
group by bn.burger_name

--------------------------------------------------------------------
--Q5 How many Vegetarian and Meatlovers were ordered by each customer?
--Ans- we have to group on each customer id with count of each type of burger

select co.customer_id,bn.burger_name,count(*) as total_
from customer_orders co join burger_names bn on co.burger_id = bn.burger_id
group by co.customer_id,bn.burger_name
order by customer_id ,burger_name

-------------------------------------------------------------------------
--Q6 What was the maximum number of burgers delivered in a single order?
Ans- 

with cte as(
select co.order_id, count(co.burger_id) as total_
from customer_orders co 
join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.order_id
order by co.order_id
)
select max(total_) as max_burger_delivered 
from cte

--------------------------------------------------------------------------
--Q7 For each customer, how many delivered burgers had at least 1 change and how many had no changes?
Ans-

select co.customer_id,
   sum(
	   case
       when co.exclusions = ' ' or co.extras = ' ' then 1
	   else 0
	   end
	   )
    as no_change,
   sum( 
	   case
       when co.exclusions != ' ' or co.extras != ' ' then 1
	   else 0
	   end
      ) as at_least_1_change
from customer_orders co 
join runner_orders ro on co.order_id = ro.order_id
where ro.distance is not null
group by co.customer_id
ORDER BY co.customer_id;

-------------------------------------------------------------------------
--Q8 What was the total volume of burgers ordered for each hour of the day?
--Ans- we have to find grouping of order count on hourly basis

select extract(hours from order_time)as hrs_,count(order_id) as total_hourly_order
from customer_orders
group by hrs_
order by total_hourly_order desc;

------------------------------------------------------------------------------
--Q9 How many runners signed up for each 1 week period? 
Ans-

select extract(week from registration_date) as signed_week,count(runner_id)
from burger_runner
group by 1
order by 1

-----------------------------------------------------------------------
--Q 10 What was the average distance travelled for each customer?
Ans-

select co.customer_id , sum(ro.distance) as avg_dist
from customer_orders co
join runner_orders ro on co.order_id = ro.order_id
WHERE ro.duration != 0
group by co.customer_id
order by co.customer_id

