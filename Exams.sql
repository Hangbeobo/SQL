 -- liệt kê danh sách khách hàng có cùng chi nhánh với Nguyễn Tiến Trung
select cust_id,cust_name,br_id
from customer
where (br_id=(select br_id
			   from customer
               where cust_name=N'Trần Đức Quý') and cust_name <> N'Trần Đức Quý')


-- hiển thị danh sách chi nhánh vs tổng tiền giao dịch theo từng năm
select branch.br_id, year(transactions.t_date) , sum(transactions.t_amount)
from branch join customer on branch.br_id=customer.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no = transactions.ac_no
group by branch.br_id, year(transactions.t_date) 
order by year(transactions.t_date)

-- hiện thị danh scahs khách hàng của mỗi chi nhánh và tổng tiền họ có
select customer.cust_id,customer.cust_name, sum(ac_balance)
from customer join account on customer.cust_id=account.cust_id
group by customer.cust_id,customer.cust_name

-- thống kê số lượng giao dịch of chi nhánh đà nẵng năm 2016-2018 theo từng giai đoạn 

select transactions.t_type, COUNT(transactions.t_id) 'slgd' 
from branch join customer on branch.br_id=customer.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no = transactions.ac_no
where branch.br_name like N'%Đà Nẵng' and (year(transactions.t_date)>2015 and year(transactions.t_date)<2019)
group by transactions.t_type 


-- Ai là người thực hiện giao dịch gửi nhiều nhất vào Huế
select  cust_name, t_amount
from ((branch b join customer c on b.br_id=c.br_id)
				join account a on c.Cust_id = a.cust_id )
                join transactions t on a.ac_no=t.ac_no
where t_type='1' and (select br_id from branch where br_name like N'%Huế') = c.br_id
group by cust_name, t_amount
having t_amount >= (select top 1 t_amount
					from ((branch b join customer c on b.br_id=c.br_id)
									join account a on c.Cust_id = a.cust_id )
									join transactions t on a.ac_no=t.ac_no
					where t_type='1' and (select br_id from branch where br_name like N'%Huế') = c.br_id
					order by t_amount desc)