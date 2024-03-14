-- 1.	Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
--a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
--i.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
--ii.	Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
Create trigger Check_transactions on transactions
for insert
as
begin
	declare @ac_type char(1), @tien float, @t_type char(1)
	select @ac_type = ac_type from inserted
	if @ac_type = '9' 
	begin
		print N'tài khoản đã bị xóa'
		rollback
	end
	else
	begin
		select @tien = t_amount from inserted
		select @t_type = t_type from inserted
		if @t_type = '0' 
		begin
			update account set ac_balance = ac_balance + @tien
		end
		else
		begin
			update account set ac_balance = ac_balance - @tien
		end
		else 
		begin
			print N'không đủ tiền' 
		end
	end
end
