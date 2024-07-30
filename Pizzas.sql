select * from order_details
/*Retrieve the total number of orders placed.*/
	
select count(distinct order_id) as no_orders from orders

/*Calculate the total revenue generated from pizza sales.*/
	
select sum(od.quantity*p.price) as total_revenue from order_details as od
join pizza as p on p.pizza_id=od.pizza_id
	
/*Identify the highest-priced pizza.*/
	
select pt.name, max(p.price) as price from pizza_types as pt
join pizza as p on p.pizza_type_id=pt.pizza_type_id group by pt.name order by price desc

/*Identify the most common pizza size ordered.*/
	
select p.size, count(od.pizza_id) from order_details as od
join pizza as p on p.pizza_id=od.pizza_id group by p.size order by count(od.pizza_id) desc limit 1

/*List the top 5 most ordered pizza types along with their quantities.*/
select * from order_details
select * from pizza	
select * from pizza_types

select pt.name, pt.pizza_type_id, sum(od.quantity) from pizza_types as pt
join pizza as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id 
group by pt.pizza_type_id,pt.name order by sum(od.quantity) desc limit 5

/* Join the necessary tables to find the total quantity of each pizza category ordered */
select pt.category, sum(od.quantity) from pizza_types as pt
join pizza as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id 
group by  pt.category order by sum(od.quantity) desc 

/*Determine the distribution of orders by hour of the day.*/

select * from orders

select EXTRACT(HOUR FROM to_timestamp(time, 'hh24:mi:ss')) AS hour, count(order_id) from orders 
group by hour

/*Join relevant tables to find the category-wise distribution of pizzas.*/

select category, count(name) from pizza_types group by category
/* pizza sold by category and and pizza wize*/	

select p.category,p.name,sum(od.quantity), 
dense_rank()over(partition by p.category order by sum(od.quantity) desc ) as rownum from pizza_types as p
join pizza as pz on pz.pizza_type_id=p.pizza_type_id
join order_details as od on od.pizza_id=pz.pizza_id group by p.category,p.name order by category


/*Group the orders by date and calculate the average number of pizzas ordered per day.*/

/*1.buy using cte*/
	
with avg as (
	select o.date, Round(sum(od.quantity)) as total_orders_day  from orders as o
	join order_details as od on od.order_id=o.order_id group by o.date 
)
select Round(avg(total_orders_day)) from avg

/*2.buy using sub query*/  

select round(avg(avrg_quantity.total_orders_day)) as avrgorders from 
(select o.date, Round(sum(od.quantity)) as total_orders_day  from orders as o
	join order_details as od on od.order_id=o.order_id group by o.date 
) as  avrg_quantity 

/*Determine the top 3 most ordered pizza types based on revenue*/

select pt.pizza_type_id,pt.name,sum(od.quantity*p.price) as revenue from pizza_types as pt
join pizza as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id group by pt.pizza_type_id,pt.name order by revenue desc limit 3

/*Calculate the percentage contribution of each pizza type to total revenue.*/

select pt.category,(sum(od.quantity*p.price)) /(select round(sum(od.quantity*p.price)) as total_revenue from order_details as od
join pizza as p on p.pizza_id=od.pizza_id) *100 as revenue
	from pizza_types as pt
join pizza as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id group by pt.category order by revenue desc 

/*Analyze the cumulative revenue generated over time.*/

select date, sum(revenue)over (order by date)from
	(select o.date, sum(p.price*od.quantity) as revenue from order_details as od
join pizza as p on od.pizza_id=p.pizza_id
join orders as o on od.order_id=o.order_id
group by o.date) 

/*Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
with top3 as(
select pt.category ,
	pt.pizza_type_id, 
	pt.name,sum(od.quantity*p.price) as revenue,
rank()over (partition by pt.category order by sum(od.quantity*p.price) desc ) 
	from order_details as od
join pizza as p on p.pizza_id=od.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id group by pt.category,pt.pizza_type_id,
	pt.name order by pt.category
)
select * from top3 where rank<=3





	


