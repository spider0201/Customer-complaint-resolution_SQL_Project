-- 1, Truy vấn thông tin khách hàng phàn nàn
select customerNumber,
 customerName,
 contactLastName,
 contactFirstName,
 phone
from customers
where phone = '+49 69 66 90 2555'

-- 2, Truy vấn ra thông tin đơn hàng
select orderNumber, 
		orderDate,
        shippedDate
from orders
where orderDate = '2003-01-09' and customerNumber = 128

-- 3. Truy vấn nhân viên đã chăm sóc khách hàng của đơn hàng này.
select e.employeeNumber,
		e.lastName,
        e.firstName,
        e.officeCode,
        e.reportsTo,
        e.jobTitle
 from employees as e
join customers as c on c.salesRepEmployeeNumber = e.employeeNumber
where c.customerNumber = 128

-- 4. Truy vấn thông tin sản phẩm bị phàn nàn.
SELECT productCode,
productName,
productLine,
buyPrice,
MSRP
FROM products 
WHERE productName LIKE '%1928 Mercedes-Benz%';
-- 5. Kiểm tra kho hàng còn sản phẩm đó không
select quantityInStock 
from products	
where productCode = 'S18_2795';
-- 6. Đưa ra những dòng sản phẩm có cùng mức giá, chênh lệch giá nhỏ để tư vấn.(Nhỏ hơn 5 đô)
SELECT productCode,
productName,
productLine,
MSRP
FROM products 
WHERE abs(MSRP - 168.75) < 5
-- 7. Đưa ra những dòng xe có cùng một số đặc điểm với xe trước.

select productName,
productVendor,
productDescription
from products
where productLine = 'Vintage Cars' and productScale = '1:18'

-- 8. Truy vấn sản phẩm mới mà khách hàng yêu cầu theo đặc điểm.

select * from products
where productDescription  regexp 'white|black'
and productDescription like '%opening hood%'

-- 9. Tìm 1 nhân viên đã có kinh nghiệm để tư vấn cho khách hàng.
SELECT COUNT(salesRepEmployeeNumber) AS 'COUNT',
       salesRepEmployeeNumber
FROM customers
GROUP BY salesRepEmployeeNumber
ORDER BY COUNT DESC
LIMIT 1;
-- 10. Hiển thị những khách hàng đã mua sản phẩm này để tiến hành khảo sát chất lượng. 
select * from customers
where customerName in
	(select customerName from orders 
		where orderNumber in(
			select orderNumber from orderdetails
            where productCode = 'S18_2795'
            )
	)


select * from customers as c
join orders as o on o.customerNumber = c.customerNumber
join orderdetails as od on od.orderNumber = o.orderNumber
where od.productCode = 'S18_2795'

-- 11. Hiển thị top 5 khách hàng có tổng giá trị đơn hàng lớn nhất.
select c.customerNumber,
	c.customerName,
    sum(od.quantityOrdered*od.priceEach) as Tonggiatridonhang
 from customers as c
join orders as o on o.customerNumber = c.customerNumber
join orderdetails as od on od.orderNumber = o.orderNumber
group by c.customerNumber
order by Tonggiatridonhang desc
limit 5

-- Hiển thị top 5 sản phẩm có tỷ lệ doanh số cao nhất
select productCode ,
sum(priceEach*quantityOrdered)*100/sum(sum(priceEach*quantityOrdered)) over() percentage
from orderdetails
group by productCode
order by percentage desc
limit 5;
-- 13. Kiểm tra giao vận đã đúng thời gian yêu cầu chưa, hiển thị đơn hàng giao trễ.
select 
	orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    datediff(shippedDate,requiredDate) as LastShippedDate
from orders
where datediff(shippedDate,requiredDate) < 0;

-- 14. Đưa các các sản phẩm không có mặt trong bất kỳ một đơn hàng nào.
select * from products
where productCode not in (
	select productCode from orderDetails
)

-- 15. Đưa ra các sản phẩm có số lượng trong kho lớn hơn trung bình số lượng trong kho của các sản phẩm cùng loại.
SELECT p.productCode, 
       p.productName, 
       p.quantityInStock,
       pl.avgQuantityInStock AS tonkhotrungbinh
FROM products AS p
JOIN (
    SELECT productLine, 
           AVG(quantityInStock) AS avgQuantityInStock
    FROM products
    GROUP BY productLine
) AS pl
ON p.productLine = pl.productLine
WHERE p.quantityInStock > pl.avgQuantityInStock
ORDER BY p.quantityInStock DESC;

-- 16(*). Thống kê tổng số lượng sản phẩm trong kho theo từng dòng sản phẩm của từng nhà cung ứng
select productLine, productVendor, sum(quantityInStock)
from products
group by productVendor,productLine
with rollup

-- 17(*). Thống kê ra mỗi sản phẩm được đặt hàng lần cuối vào thời gian nào và khách hàng đã đặt hàng
select * from 
	(select 
		customerNumber,
        orderDate,
        Max(orderDate) over (Partition by productCode) as max_date, productCode
	from (select 
			customerNumber,
            orderDate,
            productCode
		from orderdetails
        inner join orders
        using (orderNumber)
        ) t
	) t2
where orderDate = max_date
















