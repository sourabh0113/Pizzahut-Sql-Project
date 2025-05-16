create database pizzahut;
use pizzahut;
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;



# Basic:
# 1.Retrieve the total number of orders placed.
SELECT COUNT(order_id) FROM ORDERS;

# 2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id;

# 3.Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;


# 4.Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

# 5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

# Intermediate:

# 1.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


# 2.Determine the distribution of orders by hour of the day.
select hour(order_time),count(order_id) as order_count from orders
group by hour(order_time) ;

# 3.Join relevant tables to find the category-wise distribution of pizzas.
select category ,count(name) from pizza_types
group by category;

# 4.Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_pizza_per_day from (select orders.order_date, 
sum(order_details.quantity) as quantity from orders join
order_details on orders.order_id = order_details.order_id group by 
orders.order_date) as order_quantity;

# 5.Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity * pizzas.price) 
as revenue from pizza_types join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.name order by revenue desc limit 3;

# Advanced:
# 1.Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) /
(SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
FROM
    order_details 
        JOIN
    pizzas  ON pizzas.pizza_id = order_details.pizza_id ) * 100,2) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.category order by revenue desc;

# 2.Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cum_revenue 
from
(select orders.order_date,
SUM(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas on
order_details.pizza_id = pizzas.pizza_id join 
orders on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


# 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from 
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category,pizza_types.name,
SUM(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.category,pizza_types.name) as a) as b
where rn <=3;
