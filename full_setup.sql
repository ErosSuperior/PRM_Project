/* 
   FULL DATABASE SETUP SCRIPT FOR HOMESERVICEAPP
   This script drops the existing database, creates it from scratch, 
   sets up the schema, and seeds it with test data.
*/

USE master;
GO

IF DB_ID('HomeServiceApp') IS NOT NULL
BEGIN
    ALTER DATABASE HomeServiceApp SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HomeServiceApp;
END
GO

CREATE DATABASE HomeServiceApp;
GO

USE HomeServiceApp;
GO

-- =============================================
-- 1. SCHEMA CREATION
-- =============================================

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) CHECK (Role IN ('customer','worker','admin')) 
         DEFAULT 'customer',
    Address NVARCHAR(MAX),
    Avatar NVARCHAR(255),
    RefreshToken NVARCHAR(255) NULL,
    RefreshTokenExpirationTime DATETIME2 NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_Users_Role ON Users(Role);
GO

CREATE TABLE ServiceCategories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    ImageUrl NVARCHAR(255),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE ServicePackages (
    PackageId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NOT NULL,
    PackageName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(12,2) NOT NULL,
    DurationHours INT NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Package_Category
    FOREIGN KEY (CategoryId)
    REFERENCES ServiceCategories(CategoryId)
    ON DELETE CASCADE
);
GO

CREATE INDEX IX_Package_Category ON ServicePackages(CategoryId);
GO

CREATE TABLE Workers (
    WorkerId INT PRIMARY KEY,
    ExperienceYears INT DEFAULT 0,
    Bio NVARCHAR(MAX),
    IsAvailable BIT DEFAULT 1,
    AverageRating DECIMAL(3,2) DEFAULT 0,
    TotalReviews INT DEFAULT 0,

    CONSTRAINT FK_Worker_User
    FOREIGN KEY (WorkerId)
    REFERENCES Users(UserId)
    ON DELETE CASCADE
);
GO

CREATE TABLE Bookings (
    BookingId INT IDENTITY(1,1) PRIMARY KEY,
    BookingCode NVARCHAR(20) UNIQUE,
    CustomerId INT NOT NULL,
    WorkerId INT NULL,
    PackageId INT NOT NULL,
    BookingDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NULL,
    Address NVARCHAR(MAX) NOT NULL,
    Note NVARCHAR(MAX),
    TotalPrice DECIMAL(12,2),
    Status NVARCHAR(20) 
        CHECK (Status IN ('pending','confirmed','in_progress','completed','cancelled'))
        DEFAULT 'pending',
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Booking_Customer FOREIGN KEY (CustomerId)
        REFERENCES Users(UserId),

    CONSTRAINT FK_Booking_Worker FOREIGN KEY (WorkerId)
        REFERENCES Users(UserId),

    CONSTRAINT FK_Booking_Package FOREIGN KEY (PackageId)
        REFERENCES ServicePackages(PackageId)
);
GO

CREATE INDEX IX_Booking_Customer ON Bookings(CustomerId);
CREATE INDEX IX_Booking_Worker ON Bookings(WorkerId);
CREATE INDEX IX_Booking_Status ON Bookings(Status);
GO

CREATE TABLE Ratings (
    RatingId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL,
    CustomerId INT NOT NULL,
    WorkerId INT NOT NULL,
    RatingScore INT CHECK (RatingScore BETWEEN 1 AND 5),
    Comment NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Rating_Booking FOREIGN KEY (BookingId)
        REFERENCES Bookings(BookingId)
        ON DELETE CASCADE,

    CONSTRAINT FK_Rating_Customer FOREIGN KEY (CustomerId)
        REFERENCES Users(UserId),

    CONSTRAINT FK_Rating_Worker FOREIGN KEY (WorkerId)
        REFERENCES Users(UserId)
);
GO

CREATE INDEX IX_Rating_Worker ON Ratings(WorkerId);
GO

CREATE TABLE Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL,
    PaymentMethod NVARCHAR(20) 
        CHECK (PaymentMethod IN ('cash','bank_transfer','momo')),
    PaymentStatus NVARCHAR(20)
        CHECK (PaymentStatus IN ('pending','paid','failed'))
        DEFAULT 'pending',
    TransactionCode NVARCHAR(100),
    PaidAt DATETIME2 NULL,

    CONSTRAINT FK_Payment_Booking
        FOREIGN KEY (BookingId)
        REFERENCES Bookings(BookingId)
        ON DELETE CASCADE
);
GO

-- =============================================
-- 2. VIEWS, TRIGGERS, AND PROCEDURES
-- =============================================

CREATE TRIGGER TR_UpdateWorkerRating
ON Ratings
AFTER INSERT
AS
BEGIN
    UPDATE w
    SET 
        AverageRating = (
            SELECT AVG(CAST(RatingScore AS FLOAT))
            FROM Ratings r
            WHERE r.WorkerId = w.WorkerId
        ),
        TotalReviews = (
            SELECT COUNT(*)
            FROM Ratings r
            WHERE r.WorkerId = w.WorkerId
        )
    FROM Workers w
    INNER JOIN inserted i ON w.WorkerId = i.WorkerId;
END;
GO

CREATE VIEW ViewBookingDetail AS
SELECT 
    b.BookingId,
    b.BookingCode,
    b.BookingDate,
    b.Status,
    c.FullName AS CustomerName,
    w.FullName AS WorkerName,
    sp.PackageName,
    sp.Price
FROM Bookings b
JOIN Users c ON b.CustomerId = c.UserId
LEFT JOIN Users w ON b.WorkerId = w.UserId
JOIN ServicePackages sp ON b.PackageId = sp.PackageId;
GO

CREATE PROCEDURE CreateBooking
    @CustomerId INT,
    @PackageId INT,
    @BookingDate DATE,
    @StartTime TIME,
    @Address NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Price DECIMAL(12,2);

    SELECT @Price = Price
    FROM ServicePackages
    WHERE PackageId = @PackageId;

    INSERT INTO Bookings (
        BookingCode,
        CustomerId,
        PackageId,
        BookingDate,
        StartTime,
        Address,
        TotalPrice
    )
    VALUES (
        'BK' + CAST(DATEDIFF(SECOND,'2000-01-01',SYSDATETIME()) AS NVARCHAR),
        @CustomerId,
        @PackageId,
        @BookingDate,
        @StartTime,
        @Address,
        @Price
    );
END;
GO

-- =============================================
-- 3. SEED TEST DATA
-- =============================================

-- 3.1. Service Categories
INSERT INTO ServiceCategories (CategoryName, Description, ImageUrl) VALUES
(N'Dọn dẹp nhà cửa', N'Dịch vụ dọn dẹp, vệ sinh nhà ở định kỳ hoặc chuyên sâu.', 'https://img.freepik.com/free-photo/housewife-cleaning-home_23-2148222320.jpg'),
(N'Sửa chữa điện nước', N'Sửa chữa hệ thống điện, bóng đèn, vòi nước, bồn cầu.', 'https://img.freepik.com/free-photo/plumber-fixing-sink_23-2148113166.jpg'),
(N'Bảo trì máy lạnh', N'Vệ sinh, nạp gas và sửa chữa máy lạnh các loại.', 'https://img.freepik.com/free-photo/technician-servicing-air-conditioner_23-2148113160.jpg');
GO

-- 3.2. Service Packages
INSERT INTO ServicePackages (CategoryId, PackageName, Description, Price, DurationHours) VALUES
(1, N'Dọn dẹp cơ bản (2h)', N'Quét dọn, lau chùi sàn nhà, vệ sinh toilet cơ bản.', 200000, 2),
(1, N'Dọn dẹp chuyên sâu (4h)', N'Vệ sinh toàn bộ nhà, lau kính, hút bụi sofa.', 400000, 4),
(2, N'Sửa điện dân dụng', N'Kiểm tra lỗi điện, thay ổ cắm, bóng đèn.', 150000, 1),
(2, N'Sửa ống nước', N'Thông tắc bồn cầu, thay vòi sen, vòi nước.', 180000, 1),
(3, N'Vệ sinh máy lạnh (1 bộ)', N'Vệ sinh dàn nóng, dàn lạnh, kiểm tra gas.', 250000, 1);
GO

-- 3.3. Users (Initial accounts with 'Demo123!')
DECLARE @PwdHash NVARCHAR(255) = '$2a$11$L4hRO0.Lyd7c9BHHp6cQueqI9AGIVV3F34UwdTY9ndb6Pn2W99d2G'; 

INSERT INTO Users (FullName, Email, Phone, PasswordHash, Role, Address) VALUES
(N'Quản trị viên', 'admin@homeservice.com', '0901234567', @PwdHash, 'admin', N'123 Lê Lợi, Quận 1, TP.HCM'),
(N'Nguyễn Văn Thợ', 'worker@homeservice.com', '0912345678', @PwdHash, 'worker', N'456 Nguyễn Huệ, Quận 3, TP.HCM'),
(N'Trần Thị Khách', 'customer@homeservice.com', '0923456789', @PwdHash, 'customer', N'789 Cách Mạng Tháng 8, Quận 10, TP.HCM');
GO

-- 3.4. Worker Profiles (UserId=2)
INSERT INTO Workers (WorkerId, ExperienceYears, Bio, IsAvailable, AverageRating, TotalReviews) VALUES
(2, 5, N'Chuyên viên sửa chữa điện nước với 5 năm kinh nghiệm. Nhiệt tình, đúng giờ.', 1, 5.0, 1);
GO

-- 3.5. Bookings
INSERT INTO Bookings (BookingCode, CustomerId, PackageId, BookingDate, StartTime, Address, Note, TotalPrice, Status, WorkerId) VALUES
('BK101', 3, 1, CAST(GETDATE() AS DATE), '08:00:00', N'789 Cách Mạng Tháng 8, Quận 10, TP.HCM', N'Cần dọn dẹp kỹ phòng khách.', 200000, 'completed', 2),
('BK102', 3, 3, DATEADD(day, 1, GETDATE()), '14:00:00', N'789 Cách Mạng Tháng 8, Quận 10, TP.HCM', N'Kiểm tra máy lạnh phòng ngủ.', 250000, 'pending', 2);
GO

-- 3.6. Ratings
INSERT INTO Ratings (BookingId, CustomerId, WorkerId, RatingScore, Comment) VALUES
(1, 3, 2, 5, N'Dịch vụ rất tốt, thợ làm việc rất sạch sẽ!');
GO

-- 3.7. Payments
INSERT INTO Payments (BookingId, PaymentMethod, PaymentStatus, TransactionCode, PaidAt) VALUES
(1, 'cash', 'paid', 'CASH_001', GETDATE());
GO

PRINT 'DATABASE SETUP COMPLETED SUCCESSFULLY.';
GO
