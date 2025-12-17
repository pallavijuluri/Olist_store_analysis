-- 1ST QUERY
-- Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
create database  olist_store_analysis;

use olist_store_analysis;
select * from orders_data_set;
select * from payment_dataset;

select k1.day_end,
	concat(round(k1.total_payment/(select sum(payment_value) from  payment_dataset)*100,2)
    , '%') as per_payment_values
    from 
    (select ord.day_end,sum(pmt.payment_value) as total_payment
    from payment_dataset as pmt
    join
(select  distinct order_id,
case
when weekday(str_to_date(order_purchase_timestamp,'%d-%m-%Y')) in (5,6) then "Weekend"
    else "Weekday"
    end as Day_end
    from orders_data_set) as ord 
    on ord.order_id=pmt.order_id
    group by ord.day_end) as k1;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2nd QUERY
-- Number of Orders with review score 5 and payment type as credit card.

select count(distinct p.order_id ) as number_of_orders
from payment_dataset p
join
review_dataset r on p.order_id = r.order_id 
where 
r.review_score=5
and p.payment_type='credit_card';

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3rd QUERY
-- Average number of days taken for order_delivered_customer_date for pet_shop

select * from orders_data_set ;
select*from orders_item_data_set;
select * from product_data_set ;
select avg(datediff(str_to_date(order_delivered_customer_date,'%d-%m-%Y'),str_to_date(order_purchase_timestamp,'%d-%m-%Y'))) as avg_delivery_days
 from orders_data_set od 
join orders_item_data_set oid on od.order_id = oid.order_id
join product_data_set p on p.product_id = oid.product_id
where p.product_category_name = 'pet_shop'
and od.order_delivered_customer_date is not null;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4th QUERY
-- Average price and payment values from customers of sao paulo city

select* from customer_dataset;
select* from orders_item_data_set;
select 
round(avg(i.price))as average_price,
round(avg(p.payment_value)) as average_payment
from customer_dataset c
join orders_data_set o on c.customer_id = o.customer_id
join orders_item_data_set i on o.order_id=i.order_id
join payment_dataset p on o.order_id = p.order_id
where c.customer_city ='sao paulo';

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5th QUERY
-- TOP 5 PRODCT CATEGORIES BY REVENUE.

select* from orders_item_data_set;
select* from product_names_dataset;
select pcn.product_category_name_english,
sum(oi.price + oi.freight_value) as total_revenue
from orders_item_data_set as oi
join product_data_set as p on oi.product_id = p.product_id
join  product_names_dataset as pcn on p.product_category_name = pcn.product_category_name
group by pcn.product_category_name_english
order by total_revenue desc
limit 5;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6th QUERY
--  Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select
round(avg(datediff( str_to_date(order_delivered_customer_date,'%d-%m-%Y'),str_to_date(order_purchase_timestamp,'%d-%m-%Y'))),0) as avg_shipping_days,review_score
from orders_data_set o
join review_dataset r on o.order_id=r.order_id
where order_delivered_customer_date is not null
and order_purchase_timestamp is not null
group by review_score ;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7th 	QUERY
-- Calculate the percentage of late orders
SELECT
    
  round((SUM(CASE WHEN str_to_date( order_delivered_customer_date,'%d-%m-%Y') >
  str_to_date( order_estimated_delivery_date,'%d-%m-%Y') THEN 1 ELSE 0 END) * 100.0) / COUNT(order_id),'%') AS percentage_late_orders
FROM orders_data_set
    
WHERE
    order_status = 'delivered'; 
