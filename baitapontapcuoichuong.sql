use bank

--1 Có bao nhiêu khách hàng có ở Quảng Nam thuộc chi nhánh ngân hàng Vietcombank Đà Nẵng
select COUNT(customer.br_id) 'so luong'
from customer join branch on customer.br_id=branch.br_id
where cust_ad like N'%Quảng Nam' and br_name like N'Vietcombank Đà Nẵng'


--2 Hiển thị danh sách khách hàng thuộc chi nhánh Vũng Tàu và số dư trong tài khoản của họ.
select customer.cust_id,customer.cust_name,account.ac_no,ac_balance
from customer join account on customer.cust_id=account.cust_id
			  join branch on customer.br_id=branch.br_id
where br_name like N'Vietcombank Vũng Tàu'


--3 Trong quý 1 năm 2012, có bao nhiêu khách hàng thực hiện giao dịch rút tiền tại Ngân hàng Vietcombank?
select COUNT(customer.cust_id) 'so luong giao dich q1 2012'
from customer join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where t_type = 0 and (MONTH(t_date) between 1 and 3) and YEAR(t_date)=2012


--4Thống kê số lượng giao dịch, tổng tiền giao dịch trong từng tháng của năm 2014
select MONTH(t_date) 'thang', COUNT(t_id) 'so luong giao dich', sum( t_amount) 'tong tien giao dich'
from account join transactions on account.ac_no=transactions.ac_no
where YEAR(t_date)=2012 
group by MONTH(t_date)

--5Thống kê tổng tiền khách hàng gửi của mỗi chi nhánh, sắp xếp theo thứ tự giảm dần của tổng tiền
select br_name, sum(t_amount) ' tổng tiền'
from customer join branch on customer.br_id=branch.br_id
			  join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
group by br_name
order by sum(t_amount) desc


--6 Chi nhánh Sài Gòn có bao nhiêu khách hàng không thực hiện bất kỳ giao dịch nào trong vòng 3 năm trở lại đây. Nếu có thể, hãy hiển thị tên và số điện thoại của các khách đó để phòng marketing xử lý.
select DISTINCT cust_name, cust_phone
from customer left outer join branch on customer.br_id=branch.br_id
			  left outer join account on customer.cust_id=account.cust_id
			  left outer join  transactions on account.ac_no=transactions.ac_no
WHERE br_name like N'Vietcombank Sài Gòn'
and t_date  < DATEADD(year, -3, GETDATE()) or t_date =''
union
select 'SL',COUNT( DISTINCT customer.cust_id)
from customer left outer join branch on customer.br_id=branch.br_id
			  left outer join account on customer.cust_id=account.cust_id
			  left outer join  transactions on account.ac_no=transactions.ac_no
WHERE br_name like N'Vietcombank Sài Gòn'
and t_date  < DATEADD(year, -3, GETDATE()) or t_date =''


--7 Thống kê thông tin giao dịch theo mùa, nội dung thống kê gồm: số lượng giao dịch, lượng tiền giao dịch trung bình, tổng tiền giao dịch, lượng tiền giao dịch nhiều nhất, lượng tiền giao dịch ít nhất.
SELECT
	  Case
	  when DATEPART(q,t_date)=1 then N'Xuân'
	  when DATEPART(q,t_date)=2 then N'Hạ'
	  when DATEPART(q,t_date)=3 then N'Thu '
	  when DATEPART(q,t_date)=4 then N'Đông'
	  end
	  ,
	  COUNT(*) 'Số lượng giao dịch',
	  AVG(t_amount) 'Lượng tiền giao dịch trung bình',
	  SUM(t_amount) 'Tổng tiền giao dịch',
	  MAX(t_amount) 'Giao dịch nhiều nhất',
	  MIN(t_amount) 'Giao dịch ít nhất'
FROM transactions
GROUP BY DATEPART(q,t_date);


--8 Tìm số tiền giao dịch nhiều nhất trong năm 2016 của chi nhánh Huế. Nếu có thể, hãy đưa ra tên của khách hàng thực hiện giao dịch đó.
select cust_name, t_amount
from customer join branch on customer.br_id=branch.br_id
			  join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where br_name like N'%Huế' and YEAR(t_date)=2016 and t_amount >= (select top 1 t_amount
											from customer join branch on customer.br_id=branch.br_id
														  join account on customer.cust_id=account.cust_id
														  join transactions on account.ac_no=transactions.ac_no
											where YEAR(t_date)=2016 and br_name like N'%Huế'
											order by t_amount desc)

--9 Tìm khách hàng có lượng tiền gửi nhiều nhất vào ngân hàng trong năm 2017 (nhằm mục đích tri ân khách hàng)
select cust_name, t_amount
from customer join branch on customer.br_id=branch.br_id
			  join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where YEAR(t_date)=2017 and t_amount >= (select top 1 t_amount
											from customer join branch on customer.br_id=branch.br_id
														  join account on customer.cust_id=account.cust_id
														  join transactions on account.ac_no=transactions.ac_no
											where YEAR(t_date)=2017 and t_type=1
											order by t_amount desc)

--10 Tìm những khách hàng có cùng chi nhánh với ông Phan Nguyên Anh
select cust_id,cust_name
from customer join branch on customer.br_id=branch.br_id
where cust_name not like N'Phan Nguyên Anh'
	  and branch.br_id like (select branch.br_id
							from customer join branch on customer.br_id=branch.br_id
							where cust_name like N'Phan Nguyên Anh')


--11 Liệt kê những giao dịch thực hiện cùng giờ với giao dịch của ông Lê Nguyễn Hoàng Văn ngày 2016-12-02
select cust_name,t_type,t_time,t_amount
from customer join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where cust_name not like N'Lê Nguyễn Hoàng Văn'
	  and datepart(hour,t_time) = (select datepart(hour,t_time)
								   from customer join account on customer.cust_id=account.cust_id
												 join transactions on account.ac_no=transactions.ac_no
								   where cust_name like N'Lê Nguyễn Hoàng Văn' and t_date = '2016-12-02' )


--12 Hiển thị danh sách khách hàng ở cùng thành phố với Trần Văn Thiện Thanh
select cust_id,cust_name , trim(right(cust_ad,charindex(',',REVERSE(cust_ad))-1))
from customer
where charindex(',',REVERSE(cust_ad))>0
and cust_name not like N'Trần Văn Thiện Thanh'
and trim(right(cust_ad,charindex(',',REVERSE(cust_ad))-1)) = ( select trim(right(cust_ad,charindex(',',REVERSE(cust_ad))-1))
																 from customer
													    		 where charindex(',',REVERSE(cust_ad))>0 and cust_name like N'Trần Văn Thiện Thanh' )


--13 Tìm những giao dịch diễn ra cùng ngày với giao dịch có mã số 0000000217
select t_id,t_time,t_amount
from transactions
where day(t_date) = (select day(t_date)
					 from transactions
					 where t_id = '0000000217')


--14 Tìm những giao dịch cùng loại với giao dịch có mã số 0000000387
select t_id,t_date,t_amount
from transactions
where t_id not like '0000000387' and t_type = (select t_type
					 from transactions
					 where t_id = '0000000387')


--15 Những chi nhánh nào thực hiện nhiều giao dịch gửi tiền trong tháng 12/2015 hơn chi nhánh Đà Nẵng
-- Đang sai: trường hợp bằng truy vấn lồng bằng không nó không thực hiện so sáng
select br_name ,t_type, COUNT (transactions.t_id) ' so giao dich '
from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where MONTH(t_date)=12 and YEAR(t_date) = 2015 and t_type = 1
group by  br_name,t_type
having COUNT (transactions.t_id) > (select COUNT (transactions.t_id)
									from branch join customer on customer.br_id=branch.br_id
												join account on customer.cust_id=account.cust_id
												join transactions on account.ac_no=transactions.ac_no
									where MONTH(t_date)=12 and YEAR(t_date) = 2015 and br_name like N'Vietcombank Đà Nẵng'  and t_type = 1
									group by  br_name)


--16 Hãy liệt kê những tài khoảng trong vòng 6 tháng trở lại đây không phát sinh giao dịch
select account.ac_no,t_date
from account join transactions on transactions.ac_no=account.ac_no
WHERE transactions.t_date < DATEADD(MONTH, -6, GETDATE())

--17 Ông Phạm Duy Khánh thuộc chi nhánh nào? Từ 01/2017 đến nay ông Khánh đã thực hiện bao nhiêu giao dịch gửi tiền vào ngân hàng với tổng số tiền là bao nhiêu.
select cust_name, br_name
,(select count(t_id) from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where cust_name like N'Phạm Duy Khánh' and t_date >= '01/01/2017')
,(select Sum(t_amount)  from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where cust_name like N'Phạm Duy Khánh' and t_date >= '01/01/2017')
from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where cust_name like N'Phạm Duy Khánh' and t_date >= '01/01/2017' 



--18 Thống kê giao dịch theo từng năm, nội dung thống kê gồm: số lượng giao dịch, lượng tiền giao dịch trung bình
select YEAR(t_date) ' năm', COUNT(t_id) 'số lượng giao dịch', SUM(t_amount) ' lượng tiền giao dịch'
from transactions
group by YEAR(t_date)


--19 Thống kê số lượng giao dịch theo ngày và đêm trong năm 2017 ở chi nhánh Hà Nội, Sài Gòn
select br_name, (case 
when	t_time between '6:00:00' and '18:00:00' then N'Ngày'
else N'Đêm'
end) as N'Buổi', COUNT(t_id)

from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where (br_name like N'%Hà Nội%' or br_name like N'%Sài Gòn%') and YEAR(t_date) = 2017 
group by br_name, (case 
when	t_time between '6:00:00' and '18:00:00' then N'Ngày'
else N'Đêm'
end) 




--20 Hiển thị danh sách khách hàng chưa thực hiện giao dịch nào trong năm 2017?
select cust_name,t_date
from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where YEAR(t_date) <>2017


--21 Hiển thị những giao dịch trong mùa xuân của các chi nhánh miền trung. Gợi ý: giả sử một năm có 4 mùa, mỗi mùa kéo dài 3 tháng; chi nhánh miền trung có mã chi nhánh bắt đầu bằng VT.
select cust_name,br_id,t_date
from customer join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where br_id like 'VT%' and MONTH(t_date) between 1 and 3


--22 Hiển thị họ tên và các giao dịch của khách hàng sử dụng số điện thoại có 3 số đầu là 093 và 2 số cuối là 02.
select cust_name,cust_phone,t_amount,t_date
from customer join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where cust_phone like '093%' and cust_phone like '%02'


--23 Hãy liệt kê 2 chi nhánh làm việc kém hiệu quả nhất trong toàn hệ thống (số lượng giao dịch gửi tiền ít nhất) trong quý 3 năm 2017
select top 2 br_name, COUNT(t_id)
from customer join branch on customer.br_id=branch.br_id
			  join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where YEAR(t_date) = 2017 and MONTH(t_date) between 7 and 9
group by br_name
order by COUNT(t_id) asc 
		-- có 5 chi nhánh thực hiện 1 giao dịch


--24 Hãy liệt kê 2 chi nhánh có bận mải nhất hệ thống (thực hiện nhiều giao dịch gửi tiền nhất) trong năm 2017.
select top 2 br_name, COUNT(t_id)
from customer join branch on customer.br_id=branch.br_id
			  join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where YEAR(t_date) = 2017
group by br_name
order by COUNT(t_id) desc 
       -- cà mau cũng 3 


-- 25 Tìm giao dịch gửi tiền nhiều nhất trong mùa đông. Nếu có thể, hãy đưa ra tên của người thực hiện giao dịch và chi nhánh.
select cust_name , br_name , t_amount
from customer join branch on customer.br_id=branch.br_id
			  join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where MONTH(t_date) between 10 and 12 and t_amount = (select top 1 t_amount
													  from transactions
													  where MONTH(t_date) between 10 and 12
													  order by t_amount desc)


-- 26 Để bổ sung nhân sự cho các chi nhánh, cần có kết quả phân tích về cường độ làm việc của họ. Hãy liệt kê những chi nhánh phải làm việc qua trưa và loại giao dịch là gửi tiền.
select branch.br_id, br_name ,COUNT(t_id)
from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where t_time between '12:00:00' and '14:00:00' and t_type=1 
group by branch.br_id, br_name

-- 27Hãy liệt kê các giao dịch bất thường. Gợi ý: là các giao dịch gửi tiền những được thực hiện ngoài khung giờ làm việc và cho phép overtime (từ sau 16h đến trước 7h)
select t_id,t_time,t_amount
from transactions
where t_time not between '07:00:00' and '16:00:00'


-- 28 Hãy điều tra những giao dịch bất thường trong năm 2017. Giao dịch bất thường là giao dịch diễn ra trong khoảng thời gian từ 12h đêm tới 3 giờ sáng.
select t_id,t_time,t_amount
from transactions
where t_time between '00:00:00' and '03:00:00' and YEAR(t_date)=2017


-- 29 Có bao nhiêu người ở Đắc Lắc sở hữu nhiều hơn một tài khoản?
select account.cust_id , cust_name, COUNT(ac_no)
from customer join  account on customer.cust_id=account.cust_id
where cust_ad like N'%Đăk Lăk'
group by account.cust_id, cust_name
having COUNT(ac_no)>1


-- 30 Nếu mỗi giao dịch rút tiền ngân hàng thu phí 3.000 đồng, hãy tính xem tổng tiền phí thu được từ thu phí dịch vụ từ năm 2012 đến năm 2017 là bao nhiêu?
select COUNT(t_id) 'so giao dich', COUNT(t_id)*3000 ' so tien thu duoc'
from transactions
where t_type = 1 and YEAR(t_date) between 2012 and 2017


-- 31 hiện thị khách hàng họ trần
select customer.cust_id,left(cust_name,5) 'Họ', trim(right(cust_name,charindex(' ',REVERSE(cust_name))-1)) 'tên',ac_balance
from customer join account on customer.cust_id=account.cust_id
where cust_name like N'Trần%'

-- 32. Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng để chuyển sang ngân hàng khác hoặc chuyển sang hình thức tiết kiệm khác. Hãy lọc những khách hàng có xu hướng rút tiền khỏi ngân hàng bằng hiển thị những người rút gần hết tiền trong tài khoản (tổng tiền rút trong tháng 12/2017 nhiều hơn 100 triệu và số dư trong tài khoản còn lại <= 100.000)
select cust_name ' Tên',Sum(t_amount) ' Tiền gửi' ,ac_balance 'Số dư' ,t_date ' Ngày'
from customer join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
where t_type = '1' and ac_balance <=100000 and MONTH(t_date) = 12 and YEAR(t_date)=2017
group by cust_name,ac_balance,t_date
having Sum(t_amount)>=100000000

-- 33. Thời gian vừa qua, hệ thống CSDL của ngân hàng bị hacker tấn công (giả sử tí cho vui J), tổng tiền trong tài khoản bị thay đổi bất thường. Hãy liệt kê những tài khoản bất thường đó. Gợi ý: tài khoản bất thường là tài khoản có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản
select cust_name ,(select SUM(t_amount) from transactions where t_type = 0 ) , (select Sum(t_amount) from transactions where t_type=0)
,(select SUM(t_amount) from transactions where t_type = 0 ) - (select Sum(t_amount) from transactions where t_type=0)
from customer join account on customer.cust_id=account.cust_id
			  join transactions on account.ac_no=transactions.ac_no
group by cust_name
having (select SUM(t_amount) from transactions where t_type = 0 ) - (select Sum(t_amount) from transactions where t_type=0) = 0-- ac_balance


-- 34. Ngân hàng cần biết những chi nhánh nào có nhiều giao dịch rút tiền vào buổi chiều để chuẩn bị chuyển tiền tới. Hãy liệt kê danh sách các chi nhánh và lượng tiền rút trung bình theo ngày (chỉ xét những giao dịch diễn ra trong buổi chiều), sắp xếp giảm giần theo lượng tiền giao dịch.
select branch.br_id, br_name ,  Sum(t_amount)/COUNT(t_date) 'AGV'
from branch join customer on customer.br_id=branch.br_id
			join account on customer.cust_id=account.cust_id
			join transactions on account.ac_no=transactions.ac_no
where t_time between '13:00:00' and '17:00:00' and t_type=0
group by branch.br_id, br_name

