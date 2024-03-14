use BANK

-- 1.	Chuyển đổi đầu số điện thoại di động theo quy định của bộ Thông tin và truyền thông nếu biết mã khách của họ.

create proc CDSo (@cust_id varchar(6))
as 
begin
	DECLARE @number varchar(100), @fistpone varchar(100), @newnumber varchar(100), @len int, @phone varchar(11)
	set @phone = (select cust_phone
						from customer
						where cust_id = @cust_id)
	set @len= len(@phone)
	if @len =11
	begin
	set @number =(select trim(right(cust_phone,LEN(cust_phone) -4)) 
						from customer
						where cust_id = @cust_id )

	set @fistpone = (select trim(left(cust_phone,4)) 
						from customer
						where cust_id = @cust_id )
	set @newnumber = case @fistpone when '0162' then '032'
								when '016_' then '033'
								when '0120' then '070'
								when '0121' then '071'
								when '0122' then '072'
								when '0123' then '083'
								when '0124' then '084'
								when '0125' then '085'
								when '0126' then '076'
								when '0127' then '081'
								when '0128' then '078'
								when '0129' then '082'
								when '0186' then '056'
								when '0188' then '058'
								when '0199' then '059'
							end
		set @phone = @newnumber + @number
		update customer set cust_phone = @phone 
						where cust_id = @cust_id
		end
end

exec CDSo '000001'
go

-- 2.	Đưa ra nhận xét về nhà mạng của khách hàng đang sử dụng nếu biết mã khách? (Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)
-- input: mã khách
-- output: nhận xét

alter proc KTSo (@cust_id varchar(6))
as 
begin
	DECLARE  @phone varchar(11), @Nx nvarchar(100)
	set @phone = (select cust_phone
						from customer
						where cust_id = @cust_id)

	begin
	set @Nx= case	when @phone like '016[2,3,4,5,6,7,8]%'  then 'Viettel'
					when @phone like  '07[0,9,7,6,8]%' then 'MobiFone'
					when @phone like '08[1,2,3,4,5]%' then 'Vinaphone'
					when @phone like '05[6,8]%' then 'Vietnamobile'
					else 'Khac'
					end
	end
	print @Nx
end

exec KTSo '000001'
go

select cust_phone from  customer where cust_id = '000001'

-- 3.	Hãy nhận định khách hàng ở vùng nông thôn hay thành thị nếu biết mã khách hàng của họ. Gợi ý: nông thôn thì địa chỉ thường có chứa chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện”
-- input: mã khách hàng
-- output: nhận xét 

create proc KTtt (@cust_id varchar(6), @nx nvarchar(100) out)
as 
begin
	DECLARE @cust_ad nvarchar(100)
	set @cust_ad = (select cust_ad from customer where cust_id= @cust_id)
	set @nx = case when @cust_ad like '%Thôn%' 
					or @cust_ad like '%Xóm%'
					or (@cust_ad like '%Xã%' 
					and @cust_ad not like '%Thị Xã%')
					or @cust_ad like '%đội%'
					or @cust_ad like '%Huyện%' then 'Nông Thôn'
					else 'Thành Phố'
					end
end

-- 4.	Kiểm tra khách hàng đã mở tài khoản tại ngân hàng hay chưa nếu biết họ tên và số điện thoại của họ.
-- input: họ tên và số điện thoại của họ


alter PROC KTTK ( @cust_name nvarchar(100), @cust_phone varchar(15),@kh nvarchar(100) out)
as
begin
	declare @c int = 0
	set @c = (select count(*) from customer where cust_phone = @cust_phone and cust_name= @cust_name )
	set @kh = case when @c >0 then N'khc'
					else N'khm'
					end
end

Declare @b nvarchar(100)
exec KTTK 'Trần Thị Hằng','0865907675',@b out 
print @b

-----------
create function FKTTK (@cust_name nvarchar(100), @cust_phone varchar(15))
returns bit
as
begin
	declare @c int = 0, @kh nvarchar(100)
	set @c = (select count(*) from customer where cust_phone = @cust_phone and cust_name= @cust_name )
	return case when @c>0 then 1
				else 0
				end
end

select dbo.fkttk('Trần Thị Hằng','0865907675')


--5.	Thêm một bản ghi vào bảng TRANSACTIONS nếu biết các thông tin ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm:
--a.	Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý
--b.	Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
--c.	Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
--d.	Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
--e.	Tính mã giao dịch mới
--f.	Thêm mới bản ghi vào bảng TRANSACTIONS
--g.	Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch

ALTER PROC NEW_TRANSACTIONS (@DATE DATE,@TIME TIME,@AC_NO VARCHAR(10), @type char(1),@amount numeric(15,0))
as
begin
	declare @d int ,@max char(10), @t_id char(10), @ac_bl numeric(15,0),@n char(1)
	set @d = (select count(ac_no) from account where ac_no = @ac_no group by ac_no)
	if @Date <= getdate()
	begin
		if @d = 1
		begin
			if @type = '1' or @type = '0'
			begin
				if @amount >0
				begin
					set	@max = (select max(cast(t_id as numeric))+1 from transactions)
					set @t_id  = concat(REPLICATE('0', 10-len(@max)),@max)
					insert into TRANSACTIONS values (@t_id, @type, @amount, @date, @time, @ac_no)
					set @ac_bl = (select ac_balance from ACCOUNT where ac_no = @ac_no)
					if @type = '1'
					begin
						update ACCOUNT set ac_balance = ac_balance - @amount where ac_no = @ac_no
					end
					else 
					begin
						update ACCOUNT set ac_balance = ac_balance + @amount where ac_no = @ac_no
					end
				end
				return
			end
			return
		end
		return
	end
	return
end

exec NEW_TRANSACTIONS '2020/02/23','23:54','1000000007','1', 50000

select * from TRANSACTIONS where ac_no = '1000000007' and t_type = '1'

-- cách 2

--input :--ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch
--output :--ret (1: thành công, 0: thất bại)
go
create or alter proc cau11ham	 @ngay date,
								 @tg time,
								 @stk varchar(10),
								 @loai char(1),
								 @tien money,
								 @ret bit out
as
begin
	--a.
	if @ngay is null or @tg is null or @ngay>getdate()
	begin
		set @ret=0
		return
	end
	--b.
	if not exists( select 1 from account where Ac_no=@stk)  ---lấy gì có trong account cũng đc--
	begin
		set @ret=0
		return
	end
	--c.
	if @loai not in ('1','0')
	begin
		set @ret=0
		return
	end
	--d.
	if @tien<=0
	begin
		set @ret=0
		return
	end
	--e.
	declare @mamoi varchar(10)=dbo.()
	--f.
	begin transaction 
		insert into transactions values(@MaGDmoi,@loaiGD,@SoTienGD,@ngayGD,@thoigianGD,@SoTK)
		if @@ROWCOUNT < 0
		begin
			rollback transaction 
			set @ret = 0
			return
		end
	--g.
		update account 
		set ac_balance = case @loai	when 1 then ac_balance + @tien
									when 0 then ac_balance - @tien
					end
	--where @stk = Ac_no
		if @@ROWCOUNT <= 0
		begin
			rollback transaction 
			set @ret = 0
			return
		end
		commit transaction 
	set @ret=1

end
--test
go
declare @ngay date = '2023-10-30',
		@tg time = '13:00:00',
		@stk varchar(10)= '1000000003',
		@loai char(1)= '1',
		@tien money=1,
		@ret bit
exec spCau47K211 @ngay,@tg,@stk,@loai,@tien,@ret out 
print @ret 
select * from account 
select * from transactions




--------------------HÀM-------------------------

--1.	Trả về tên chi nhánh ngân hàng nếu biết mã của nó. -- hàm
alter FUNCTION fbrname (@br_id char(10))
RETURNS nvarchar(50)
AS
BEGIN
	declare @br_name nvarchar(50)
	set @br_name = (select br_name from branch where br_id=@br_id)
	RETURN @br_name
END;

select dbo.fbrname('VB001')

-- 2.	Kiểm tra một khách hàng nào đó đã tồn tại trong hệ thống CSDL của ngân hàng chưa nếu biết: họ tên, số điện thoại của họ.
-- Đã tồn tại trả về 1, ngược lại trả về 0 


-- 3.	Trả về số tiền có trong tài khoản nếu biết mã tài khoản
create FUNCTION fac_balance (@ac_no char(10))
RETURNS numeric(15,0)
AS
BEGIN
	declare @ac_balance numeric(15,0)
	set @ac_balance = (select ac_balance from account where ac_no=@ac_no)
	RETURN @ac_balance
END;

select dbo.fac_balance('1000000041')


-- 4. Hàm tạo mã tự động bằng max +1
Create FUNCTION ft_id()
RETURNS char(10)
as 
begin
	declare @max char(10), @t_id char(10) 
	set	@max = (select top 1 t_id from transactions order by t_id DESC)
	set @max= @max + 1
	set @t_id  = REPLICATE('0', 10-len(@max)) + @max
	RETURN @t_id
end

select dbo.ft_id()


