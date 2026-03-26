USE HomeServiceApp;
GO

-- 1. Xóa toàn bộ dữ liệu cũ theo đúng thứ tự ràng buộc (Constraints)
DELETE FROM Payments;
DELETE FROM Ratings;
DELETE FROM Bookings;
DELETE FROM Workers;
DELETE FROM ServicePackages;
DELETE FROM ServiceCategories;
DELETE FROM Users;
GO

-- 2. Reset Identity (Đưa ID về lại số 1)
DBCC CHECKIDENT ('ServiceCategories', RESEED, 0);
DBCC CHECKIDENT ('ServicePackages', RESEED, 0);
DBCC CHECKIDENT ('Users', RESEED, 0);
DBCC CHECKIDENT ('Bookings', RESEED, 0);
DBCC CHECKIDENT ('Ratings', RESEED, 0);
DBCC CHECKIDENT ('Payments', RESEED, 0);
GO

-- 3. Chèn Categories (Danh mục dịch vụ)
INSERT INTO ServiceCategories (CategoryName, Description, ImageUrl) VALUES
(N'Dọn dẹp nhà cửa', N'Dịch vụ dọn dẹp, vệ sinh nhà ở định kỳ hoặc chuyên sâu.', 'https://img.freepik.com/free-photo/housewife-cleaning-home_23-2148222320.jpg'),
(N'Sửa chữa điện nước', N'Sửa chữa hệ thống điện, bóng đèn, vòi nước, bồn cầu.', 'https://img.freepik.com/free-photo/plumber-fixing-sink_23-2148113166.jpg'),
(N'Bảo trì máy lạnh', N'Vệ sinh, nạp gas và sửa chữa máy lạnh các loại.', 'https://img.freepik.com/free-photo/technician-servicing-air-conditioner_23-2148113160.jpg');
GO

-- 4. Chèn Service Packages (Gói dịch vụ) - Bắt đầu từ CategoryId = 1
INSERT INTO ServicePackages (CategoryId, PackageName, Description, Price, DurationHours) VALUES
(1, N'Dọn dẹp cơ bản (2h)', N'Quét dọn, lau chùi sàn nhà, vệ sinh toilet cơ bản.', 200000, 2),
(1, N'Dọn dẹp chuyên sâu (4h)', N'Vệ sinh toàn bộ nhà, lau kính, hút bụi sofa.', 400000, 4),
(2, N'Sửa điện dân dụng', N'Kiểm tra lỗi điện, thay ổ cắm, bóng đèn.', 150000, 1),
(2, N'Sửa ống nước', N'Thông tắc bồn cầu, thay vòi sen, vòi nước.', 180000, 1),
(3, N'Vệ sinh máy lạnh (1 bộ)', N'Vệ sinh dàn nóng, dàn lạnh, kiểm tra gas.', 250000, 1);
GO

-- 5. Chèn Users (Mật khẩu 'Demo123!' với mã hash bạn vừa cung cấp)
DECLARE @PwdHash NVARCHAR(255) = '$2a$11$L4hRO0.Lyd7c9BHHp6cQueqI9AGIVV3F34UwdTY9ndb6Pn2W99d2G'; 

INSERT INTO Users (FullName, Email, Phone, PasswordHash, Role, Address) VALUES
(N'Quản trị viên', 'admin@homeservice.com', '0901234567', @PwdHash, 'admin', N'123 Lê Lợi, Quận 1, TP.HCM'),
(N'Nguyễn Văn Thợ', 'worker@homeservice.com', '0912345678', @PwdHash, 'worker', N'456 Nguyễn Huệ, Quận 3, TP.HCM'),
(N'Trần Thị Khách', 'customer@homeservice.com', '0923456789', @PwdHash, 'customer', N'789 Cách Mạng Tháng 8, Quận 10, TP.HCM');
GO

-- 6. Chèn Worker Profiles (UserId của thợ là 2)
INSERT INTO Workers (WorkerId, ExperienceYears, Bio, IsAvailable, AverageRating, TotalReviews) VALUES
(2, 5, N'Chuyên viên sửa chữa điện nước với 5 năm kinh nghiệm. Nhiệt tình, đúng giờ.', 1, 5.0, 1);
GO

-- 7. Chèn Bookings (Lịch hẹn mẫu) - CustomerId=3, PackageId=1
INSERT INTO Bookings (BookingCode, CustomerId, PackageId, BookingDate, StartTime, Address, Note, TotalPrice, Status, WorkerId) VALUES
('BK1001', 3, 1, CAST(GETDATE() AS DATE), '08:00:00', N'789 Cách Mạng Tháng 8, Quận 10, TP.HCM', N'Cần dọn dẹp kỹ phòng khách.', 200000, 'completed', 2),
('BK1002', 3, 3, DATEADD(day, 1, GETDATE()), '14:00:00', N'789 Cách Mạng Tháng 8, Quận 10, TP.HCM', N'Kiểm tra điện bếp.', 150000, 'pending', 2);
GO

-- 8. Chèn Ratings (BookingId=1)
INSERT INTO Ratings (BookingId, CustomerId, WorkerId, RatingScore, Comment) VALUES
(1, 3, 2, 5, N'Dịch vụ rất tốt, thợ làm việc rất sạch sẽ!');
GO

-- 9. Chèn Payments (BookingId=1)
INSERT INTO Payments (BookingId, PaymentMethod, PaymentStatus, TransactionCode, PaidAt) VALUES
(1, 'cash', 'paid', 'CASH001', GETDATE());
GO
