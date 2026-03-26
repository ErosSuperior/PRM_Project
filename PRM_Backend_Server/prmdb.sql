IF DB_ID('HomeServiceApp') IS NOT NULL
    DROP DATABASE HomeServiceApp;
GO

CREATE DATABASE HomeServiceApp;
GO

USE HomeServiceApp;
GO


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