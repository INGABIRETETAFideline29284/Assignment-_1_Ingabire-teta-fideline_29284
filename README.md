# Assignment-_1_Ingabire-teta-fideline_29284
# Sunrise Supermarket — PL/SQL/SQL Assignment One

## Student Information

Name: INGABIRE TETA Fideline
Student ID: 29284
Database Management System: MySQL
Tool: MySQL Workbench

1. Business Scenario

Sunrise Supermarket sells different products to customers.

Customers place orders, and each order can contain one or more products. The supermarket stores information about customers, products, orders, and order items.

Management wants to understand:

 Who the customers are.
 What products customers purchase.
 How much each customer spends.
 Which customers spend above the average.
 Customer purchasing frequency.
 How revenue changes over time.

The database contains four main tables:

1. Customers
2. Products
3. Orders
4. Order Items

2. Database Management System

MySQL was selected because it supports all the SQL features required in the assignment, including:

* INNER JOIN
* LEFT JOIN
* Common Table Expressions (CTEs)
* Window functions
* RANK()
* ROW_NUMBER()
* LAG()
* Aggregate functions
* GROUP BY

3. Database Design

 Customers

The `customers` table stores information about customers.

| Column        | Description                           |
| ------------- | ------------------------------------- |
| customer_id   | Primary key identifying each customer |
| customer_name | Customer's name                       |
| email         | Customer's email address              |
| city          | Customer's city                       |

Products

The `products` table stores products sold by Sunrise Supermarket.

| Column       | Description                          |
| ------------ | ------------------------------------ |
| product_id   | Primary key identifying each product |
| product_name | Product name                         |
| category     | Product category                     |
| price        | Product selling price                |

Orders

The `orders` table stores customer orders.

| Column      | Description                        |
| ----------- | ---------------------------------- |
| order_id    | Primary key identifying each order |
| customer_id | Foreign key referencing customers  |
| order_date  | Date on which the order was placed |

 Order Items

The `order_items` table stores the products included in each order.

| Column        | Description                             |
| ------------- | --------------------------------------- |
| order_item_id | Primary key identifying each order item |
| order_id      | Foreign key referencing orders          |
| product_id    | Foreign key referencing products        |
| quantity      | Number of units purchased               |

4. Data Population

The assignment required at least:
5 customers
8 products
3 categories
15 orders
25 order items

Therefore, the database satisfies all minimum requirements.

One customer, Frank Tuyisenge, does not have an order. This was intentional so that the LEFT JOIN query could demonstrate customers without orders.

5. JOIN Queries

JOIN 1 — Orders and Customers

Requirement

List every order with the customer's name, city, and order date.

Query

```sql
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```

Explanation

The INNER JOIN connects the `orders` table to the `customers` table using `customer_id`.

This allows the query to display customer information together with order information.

Business Interpretation

Management can identify who placed each order and the city in which the customer is located.

<img width="246" height="204" alt="join 1" src="https://github.com/user-attachments/assets/389924f9-c770-4c2f-9a82-ca74d2c83b81" />


JOIN 2 — Order Items and Products

Requirement

List every order item with product name, category, price, and quantity.

Query

```sql
SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items AS oi
INNER JOIN products AS p
    ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;
```

Explanation

The query joins `order_items` with `products` using `product_id`.

This makes it possible to display the actual product name, category, price, and quantity.

Business Interpretation

Management can determine which products customers purchase and the quantities purchased.

JOIN 3 — Customers and Orders

Requirement

List all customers and their orders where they exist, including customers with no orders.

Query

```sql
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;
```

Explanation

A LEFT JOIN returns every customer from the `customers` table.

If a customer has no order, the order columns contain NULL.

Frank Tuyisenge therefore appears even though he has not placed an order.

### Business Interpretation

Management can identify customers who have registered but have not purchased any products.

6. CTE Query

Customers Above Average Spending

Requirement

Calculate each customer's total spend using quantity multiplied by price and return customers above average spend.

Query

```sql
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend
    FROM customers AS c
    LEFT JOIN orders AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spend
FROM customer_totals
WHERE total_spend > (
    SELECT AVG(total_spend)
    FROM customer_totals
)
ORDER BY total_spend DESC;
```

Explanation

The CTE named `customer_totals` first calculates total spending for every customer.

The formula is:

```text
Total Spend = Quantity × Product Price
```

The outer query then calculates the average customer spending and returns customers whose spending is above that average.

`COALESCE()` is used to return 0 for customers with no orders.

Result

| Customer        | Total Spend |
| --------------- | ----------: |
| David Habimana  |      40,900 |
| Alice Mukamana  |      39,700 |
| Brian Niyonzima |      34,000 |
| Claudine Uwase  |      30,500 |

The average spending across all customers is approximately **22,116.67**.

Business Interpretation

Management can identify customers who spend above the overall customer average. This information can support customer segmentation and loyalty programs.

7. Window Functions

7.1 Rank Customers by Total Spending

Requirement

Rank customers by total amount spent, highest first.

Query

```sql
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend
    FROM customers AS c
    LEFT JOIN orders AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spend,
    RANK() OVER (
        ORDER BY total_spend DESC
    ) AS spending_rank
FROM customer_totals
ORDER BY spending_rank;
```

Explanation

`RANK()` assigns a ranking according to customer spending.

The customer with the highest spending receives rank 1.

Business Interpretation

Management can use the ranking to understand customer spending levels.

7.2 Number Each Customer's Orders

Requirement

Number each customer's orders in the order placed.

Query

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date
    ) AS customer_order_number
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;
```

Explanation

`PARTITION BY customer_id` separates the orders by customer.

`ROW_NUMBER()` then numbers each customer's orders beginning with 1.

Business Interpretation

This identifies whether an order is a customer's first, second, third, or later purchase.

7.3 Running Total of Revenue

Requirement

Show a running total of revenue over time, ordered by order date.

Query

```sql
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.order_date,
        SUM(oi.quantity * p.price) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    INNER JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY
        o.order_id,
        o.order_date
)
SELECT
    order_id,
    order_date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM order_revenue
ORDER BY order_date, order_id;
```

Explanation

The CTE first calculates the revenue generated by each order.

The window function then adds each order's revenue to the revenue from all previous orders.

Result

The final running total is:

**163,700**

Business Interpretation

Management can monitor cumulative revenue and understand how sales accumulate over time.

7.4 Days Between Customer Orders

Requirement

For each customer with more than one order, show the days between the current and previous order.

Query

```sql
WITH order_history AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.customer_name,
        o.order_date,

        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS previous_order_date,

        COUNT(*) OVER (
            PARTITION BY o.customer_id
        ) AS total_orders

    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF(
        order_date,
        previous_order_date
    ) AS days_since_previous_order
FROM order_history
WHERE total_orders > 1
  AND previous_order_date IS NOT NULL
ORDER BY customer_id, order_date;
```

Explanation

`LAG()` retrieves the previous order date for each customer.

`DATEDIFF()` then calculates the number of days between the current order and the previous order.

Business Interpretation

Management can understand customer purchase frequency and identify how long customers typically wait between purchases.

8. Overall Business Interpretation

The analysis provides Sunrise Supermarket with information that can support customer and sales management.

The dataset shows:

6 registered customers.
5 customers with orders.
1 customer without an order.
8 products across 5 categories.
15 orders.
30 order items.
Total revenue of 163,700.
Customers with spending above the average.
Customer order sequences.
The number of days between repeat purchases.
Cumulative revenue over time.

These results can help Sunrise Supermarket understand customer behavior, monitor sales, identify purchasing patterns, and plan customer-focused marketing activities.

9. Challenges and Resolutions

Challenge 1: Calculating Customer Spending

Customer spending required data from several tables.

Resolution

JOIN operations were used between customers, orders, order_items, and products.

The calculation was:

```text
Quantity × Product Price
```

---

Challenge 2: Including Customers Without Orders

An INNER JOIN would exclude customers who have no orders.

Resolution

A LEFT JOIN was used so that every customer is displayed, including customers with no orders.

Challenge 3: Calculating Average Spending

Customer totals had to be calculated before the average could be calculated.

Resolution

A Common Table Expression called `customer_totals` was used to calculate customer spending first.

The outer query then calculated the average.

Challenge 4: Finding Previous Orders

The previous order date for each customer could not be easily obtained using only GROUP BY.

Resolution

The `LAG()` window function was used with:

```sql
PARTITION BY customer_id
ORDER BY order_date
```

Challenge 5: Calculating Running Revenue

Revenue had to be calculated for each order before cumulative revenue could be calculated.

Resolution

A CTE was used to calculate order revenue first, followed by a window function using `SUM()`.

10. How to Run the Project

1. Install MySQL Server.
2. Install and open MySQL Workbench.
3. Open `01_create_tables.sql`.
4. Execute the script.
5. Open `02_insert_data.sql`.
6. Execute the script.
7. Open `03_queries.sql`.
8. Execute each query.
9. Check the results in the MySQL Workbench result grid.
10. Take screenshots of the query results if screenshots are required by the lecturer.

11. Project Files

```text
assignment_1_your_name-your_id/
│
├── README.md
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   └── 03_queries.sql
│
└── results/
    └── results.md
```

---

12. Minimum Requirements Checklist

| Requirement                | Status         |
| -------------------------- | -------------- |
| At least 5 customers       | Completed — 6  |
| At least 8 products        | Completed — 8  |
| At least 3 categories      | Completed — 5  |
| At least 15 orders         | Completed — 15 |
| At least 25 order items    | Completed — 30 |
| JOIN query 1               | Completed      |
| JOIN query 2               | Completed      |
| LEFT JOIN query            | Completed      |
| CTE query                  | Completed      |
| RANK() query               | Completed      |
| ROW_NUMBER() query         | Completed      |
| Running total query        | Completed      |
| LAG() query                | Completed      |
| Business interpretations   | Completed      |
| Challenges and resolutions | Completed      |
| Results                    | Included       |
| DBMS stated                | MySQL          |
| README included            | Completed      |
