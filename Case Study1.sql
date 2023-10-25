--ADDED DATA INTO SALES TABLE
INSERT INTO sales VALUES
('A','2021-01-01',1),
('A','2021-01-01',2),
('A','2021-01-07',2),
('A','2021-01-10',3),
('A','2021-01-11',3),
('A','2021-01-11',3),
('B','2021-01-01',2),
('B','2021-01-02',2),
('B','2021-01-04',1),
('B','2021-01-11',1),
('B','2021-01-16',3),
('B','2021-02-01',3),
('C','2021-01-01',3),
('C','2021-01-01',3),
('C','2021-01-07',3)

--ADDED DATA INTO MENU TABLE
INSERT INTO MENU VALUES 
(1,'sushi',10),
(2,'curry',15),
(3,'ramen',12)

--ADDED DATA INTO MEMBERS TABLE
INSERT INTO members VALUES
('A','2021-01-07'),
('B','2021-01-09')
--Question1
SELECT
	customer_id,SUM(PRICE) As "total_amount_spent"
FROM sales
JOIN menu
ON sales.product_id=menu.product_id
GROUP BY customer_id
ORDER BY customer_id
--Question2
SELECT
	customer_id,
	count(distinct(S.order_date)) As "Total_vISITED_dayS"
FROM sales S
JOIN menu M
ON S.product_id=M.product_id
GROUP BY customer_id
ORDER BY customer_id
--Question3
WITH first_order_item AS (
SELECT
	S.customer_id,
	M.product_name,
	order_date,
	dense_rank() over(partition by customer_id order by S.order_date ) As "rank"
FROM sales S
INNER JOIN menu M
ON S.product_id=M.product_id
) 
SELECT 
	customer_id,
	product_name,
	order_date
FROM first_order_item
WHERE rank=1
GROUP BY customer_id,product_name,order_date
--Question4
SELECT
	TOP 1
	product_name,
	count(*) As "Most Purchased"
FROM sales S
LEFT JOIN menu M ON s.product_id=m.product_id
GROUP BY product_name
ORDER BY [Most Purchased] DESC

--Question5
WITH MPI AS(
SELECT
	customer_id,
	product_name,
	dense_rank() OVER(partition by 	customer_id order by count(S.product_id) desc) As "Most_popular_item" 
FROM sales S
JOIN menu M
ON S.product_id=M.product_id
GROUP BY customer_id,product_name
)
SELECT
	customer_id,
	product_name
FROM MPI
WHERE [Most_popular_item]=1

--Question6
WITH after_member AS(
SELECT
	MB.customer_id,
	M.product_name,
	DENSE_RANK() OVER(PARTITION BY S.customer_id order by order_date) AS "rank"
FROM sales S
JOIN members MB
ON MB.CUSTOMER_ID=S.customer_id
JOIN menu M
ON M.product_id=S.product_id
AND S.order_date>=MB.JOIN_DATE
)
SELECT
	AF.CUSTOMER_ID,
	AF.product_name
FROM after_member AF
WHERE rank=1

----Question7
WITH before_member AS(
SELECT
	s.customer_id,
	s.product_id,
	DENSE_RANK() OVER(PARTITION BY S.customer_id order by order_date desc) AS "rank"
FROM sales S
JOIN members MB
ON MB.CUSTOMER_ID=S.customer_id
WHERE S.order_date<MB.JOIN_DATE
)
SELECT
	BF.CUSTOMER_ID,
	M.product_name
FROM before_member BF
JOIN menu M
ON M.product_id=BF.product_id
WHERE rank=1

--Question8
SELECT
	s.customer_id,
	COUNT(DISTINCT(S.product_id)) AS "TOTAL ITEMS",
	SUM(PRICE) AS "TOTAL AMOUNT"
FROM sales S
JOIN menu M
ON M.product_id=S.product_id
JOIN members MB
ON S.customer_id=MB.CUSTOMER_ID
WHERE S.order_date<MB.JOIN_DATE
GROUP BY S.customer_id

--Question9
SELECT customer_id, SUM(points) AS points_total
FROM (
  SELECT 
    s.customer_id,
    (
      CASE
        WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
        ELSE m.price * 10
      END
    ) AS points
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
) AS cus_points
GROUP BY customer_id
ORDER BY customer_id;

--Question10
WITH dates_cte AS (
  SELECT 
    m.customer_id, 
    m.join_date, 
    DATEADD(DAY, 6, m.join_date) AS valid_date
  FROM members AS m
)
SELECT 
  s.customer_id, 
  SUM(
    CASE
      WHEN mn.product_name = 'sushi' THEN 2 * 10 * mn.price
      WHEN s.order_date BETWEEN dc.join_date AND dc.valid_date THEN 2 * 10 * mn.price
      ELSE 10 * mn.price
    END
  ) AS points
FROM sales AS s
JOIN dates_cte AS dc
  ON s.customer_id = dc.customer_id
  AND s.order_date <'2021-02-01'
JOIN menu AS mn
  ON s.product_id = mn.product_id
GROUP BY s.customer_id;

--Bonus Questions
SELECT 
	s.customer_id,
	s.order_date,
	m.product_id,
	m.price,
	CASE
	WHEN mb.JOIN_DATE<=s.order_date THEN 'Y'
	ELSE 'N'
	END AS "Member"
FROM sales S
LEFT JOIN menu M
ON S.product_id=M.product_id
LEFT JOIN members MB
ON S.customer_id=MB.customer_id


WITH MEMBER_CTE AS
(SELECT 
	s.customer_id,
	s.order_date,
	m.product_id,
	m.price,
	CASE
	WHEN mb.JOIN_DATE<=s.order_date THEN 'Y'
	ELSE 'N'
	END AS "Member"
FROM sales S
LEFT JOIN menu M
ON S.product_id=M.product_id
LEFT JOIN members MB
ON S.customer_id=MB.customer_id
)
SELECT *,
	CASE
		WHEN Member='N' THEN NULL
		ELSE RANK() OVER(partition by customer_id,member order by order_date)
		END AS "ranking"
FROM MEMBER_CTE 











