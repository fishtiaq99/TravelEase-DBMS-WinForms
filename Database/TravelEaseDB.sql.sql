create database TravelEase;

use TravelEase;

-- Table for Traveler
---------- CREATED ------------
CREATE TABLE Traveler (
    TravelerID INT PRIMARY KEY,
    Name VARCHAR(255),
    Password VARCHAR(255) CHECK (LEN(Password) > 8 AND Password LIKE '%[A-Za-z]%' AND Password LIKE '%[0-9]%' AND Password LIKE '%[!@#$%^&*()_+\\-=\\[\\]{};":,.<>?]%'),
    Address TEXT,
    Gender VARCHAR(10),
    Nationality VARCHAR(100),
    DOB DATE,
    TravelHistory TEXT,
    PreferredTripTypes TEXT,
    AdminManager INT,
    FOREIGN KEY (AdminManager) REFERENCES Admin(AdminID)
);

ALTER TABLE Traveler ADD RegistrationDate DATETIME DEFAULT GETDATE();

ALTER TABLE Traveler
ADD ApprovalFlag BIT NOT NULL DEFAULT 0;

ALTER TABLE TourOperator
ADD ApprovalFlag BIT NOT NULL DEFAULT 0;

-- Update Traveler table
UPDATE Traveler
SET ApprovalFlag = 1
WHERE TravelerID BETWEEN 1 AND 100;

-- Update TourOperator table
UPDATE TourOperator
SET ApprovalFlag = 1
WHERE OperatorID BETWEEN 1 AND 100;

-- Table for TravelerEmail
---------- CREATED -----------
CREATE TABLE TravelerEmail (
    Email VARCHAR(255),
    TravelerID INT,  -- Adding TravelerID to link to the Traveler table
    PRIMARY KEY (Email, TravelerID),  -- Composite primary key to ensure unique emails for each traveler
    CHECK (Email LIKE '%_@__%.__%'),  -- Basic email format validation
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID)  -- Linking to Traveler table
);

-- First drop the existing constraint
ALTER TABLE TravelerEmail DROP CONSTRAINT FK_TravelerE__Trave__5EBF139D;

-- Then recreate it with ON DELETE CASCADE
ALTER TABLE TravelerEmail
ADD CONSTRAINT FK_TravelerE__Trave__5EBF139D
FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID)
ON DELETE CASCADE;


-- Table for TravelerPhoneNumber
--------- CREATED ------------
CREATE TABLE TravelerPhoneNumber (
    PhoneNumber VARCHAR(11),
    TravelerID INT,  -- Adding TravelerID to link to the Traveler table
    PRIMARY KEY (PhoneNumber, TravelerID),  -- Composite primary key to ensure unique phone numbers for each traveler
    CHECK (LEN(PhoneNumber) = 11 AND PhoneNumber LIKE '[0-9]%'),  -- Validation to ensure 11 digits and only numbers
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID)  -- Linking to Traveler table
);


--------- CREATED ----------
CREATE TABLE Wishlist (
    WishID INT PRIMARY KEY,  -- Corrected to match the column name in WishlistAdd
    TravelerID INT,
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID)
);

-- Table for WishlistAdd, representing the ternary relationship between Traveler, Wishlist, and Booking
---------- CREATED ----------
CREATE TABLE WishlistAdd (
    WishlistID INT,  -- Foreign key linking to Wishlist
    TravelerID INT,  -- Foreign key linking to Traveler
    TripID INT,   -- Foreign key linking to Trip
    DateAdded DATETIME DEFAULT GETDATE(),  -- Date when the booking was added to the wishlist
    PRIMARY KEY (WishlistID, TravelerID, TripID),  -- Composite primary key
    FOREIGN KEY (WishlistID) REFERENCES Wishlist(WishID),  -- Foreign key to Wishlist
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID),  -- Foreign key to Traveler
    FOREIGN KEY (TripID) REFERENCES Trip(TripID)  -- Foreign key to Booking
);


-- Table for Review
------- CREATED --------
CREATE TABLE Review (
    ReviewID INT PRIMARY KEY,
    TravelerID INT,
    TripID INT,
    Rating INT,
    Comments TEXT,
    ReviewDate DATE,
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID),
    FOREIGN KEY (TripID) REFERENCES Trip(TripID)
);

-- Table for Booking
---------- CREATED --------
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY,
    TravelerID INT,
    TripID INT,
    BookingDate DATE,
    NumOfParticipants INT,
    TotalPrice DECIMAL(10, 2),
    PaymentStatus VARCHAR(50),
    BookingStatus VARCHAR(50),
    CancellationReason TEXT,
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID),
    FOREIGN KEY (TripID) REFERENCES Trip(TripID)
);

-- Table for Payment
--------- CREATED ----------
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    BookingID INT,
    Amount DECIMAL(10, 2),
    PaymentDate DATE,
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);


------- CREATED -----------
CREATE TABLE Overlooks (
    TourOperatorID INT,  -- Foreign key linking to TourOperator
    PaymentID INT,       -- Foreign key linking to Payment
    BookingID INT,       -- Foreign key linking to Booking
    DateOverlooked DATETIME DEFAULT GETDATE(),  -- Date when the payment was overlooked by the tour operator
    PRIMARY KEY (TourOperatorID, PaymentID),  -- Composite primary key to ensure each payment is overseen by a unique tour operator
    FOREIGN KEY (TourOperatorID) REFERENCES TourOperator(OperatorID),  -- Foreign key to TourOperator
    FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID),  -- Foreign key to Payment
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)  -- Foreign key to Booking
);

SELECT * FROM TourOperator
SELECT * FROM Inquiries
SELECT * FROM Admin
SELECT * FROM Booking WHERE TravelerID=2
SELECT * FROM Traveler WHERE TravelerID=2
-- Table for Trip
---------- CREATED -----------
CREATE TABLE Trip (
    TripID INT PRIMARY KEY,  -- Primary key for Trip
    OperatorID INT,  -- Foreign key referencing TourOperator
    Title VARCHAR(255),  -- Title of the trip
    Price DECIMAL(10, 2),  -- Price of the trip
    Capacity INT,  -- Maximum capacity of people for the trip
    TripType VARCHAR(100),  -- Type of the trip (e.g., adventure, cultural, etc.)
    Description TEXT,  -- Detailed description of the trip (including cancellation policy)
	PassesDescription TEXT,
    StartDate DATE,  -- Start date of the trip
    EndDate DATE,  -- End date of the trip
    Duration INT,  -- Duration of the trip (in days)
    TripStatus VARCHAR(50),  -- Status of the trip (e.g., available, completed, etc.)
    AvailableSlots INT,  -- Number of available slots for the trip
    GroupSize INT,  -- Group size for the trip
    Rating DECIMAL(3, 2),  -- Average rating of the trip
    FOREIGN KEY (OperatorID) REFERENCES TourOperator(OperatorID)  -- Foreign key referencing TourOperator table
);


-- Table for Involves, representing the relationship between Trip and Service Provider
------------ CREATED -----------
CREATE TABLE TripInvolves (
    TripID INT,  -- Foreign key from Trip table
    ServiceProviderID INT,  -- Foreign key from Hotel/Service Provider table
    Role VARCHAR(100),  -- Role of the service provider in the trip (optional)
    PRIMARY KEY (TripID, ServiceProviderID),  -- Composite primary key
    FOREIGN KEY (TripID) REFERENCES Trip(TripID),  -- Foreign key to Trip
    FOREIGN KEY (ServiceProviderID) REFERENCES HotelServiceProvider(ServiceProviderID)  -- Foreign key to Hotel/Service Provider
);




-------- CREATED -------
CREATE TABLE Activities (
    ActivityID INT PRIMARY KEY,  -- Unique identifier for each activity
    TripID INT,  -- Foreign key linking the activity to a trip
    ActivityDescription TEXT,  -- Description of the activity
    ActivityDate DATE,  -- Date of the activity (if applicable)
    FOREIGN KEY (TripID) REFERENCES Trip(TripID)  -- Foreign key from Trip
);

----------- CREATED -----------
CREATE TABLE TripDestinations (
    TripID INT,
    DestinationID INT,
    PRIMARY KEY (TripID, DestinationID),  -- Composite primary key
    FOREIGN KEY (TripID) REFERENCES Trip(TripID),  -- Foreign key from Trip
    FOREIGN KEY (DestinationID) REFERENCES Destination(DestinationID)  -- Foreign key from Destination
);


-- Table for Destination
--------- CREATED ----------
CREATE TABLE Destination (
    DestinationID INT PRIMARY KEY,
    Name VARCHAR(255),
    Description TEXT,
    Country VARCHAR(100),
    Region VARCHAR(100),
    DateAdded DATE
);



-- Table for Tour Operator
------------ CREATED -----------
CREATE TABLE TourOperator (
    OperatorID INT PRIMARY KEY,
    AdminID INT,  -- Foreign key linking Admin to TourOperator
    CompanyName VARCHAR(255),
    CompanyAddress TEXT,
    ContactPhone VARCHAR(11),
    ContactEmail VARCHAR(255) UNIQUE,
    Password VARCHAR(255),
    TripsOffered TEXT,  -- List of trips offered, can be normalized into another table if needed
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID),  -- Admin manages the Tour Operator
    CHECK (ContactEmail LIKE '%_@__%.__%'),
    CHECK ((LEN(ContactPhone) = 11) AND ContactPhone LIKE '[0-9]%')  -- Phone validation: only 10 digits allowed
);

-- Table for ServiceProvider
---------- CREATED -------------
CREATE TABLE HotelServiceProvider (
    ServiceProviderID INT PRIMARY KEY,
    ProviderName VARCHAR(255),
    ServiceRatings DECIMAL(3, 2),
    ProviderType VARCHAR(50),
    ContactInfo VARCHAR(255),
    ServiceDetails TEXT,
    AvailableRooms INT,
    DateRegistered DATE
);


-- Table for Admin
--------- CREATED -----------
CREATE TABLE Admin (
    AdminID INT PRIMARY KEY,
    Name VARCHAR(255),
    Password VARCHAR(255),
    Role VARCHAR(100),
    Permissions TEXT,
    DateCreated DATETIME  
);

-- Table for Emails (separate table for multiple emails per Admin)
------------ CREATED -----------
CREATE TABLE AdminEmails (
    EmailID INT PRIMARY KEY, 
    AdminID INT,
    Email VARCHAR(255) UNIQUE,
    IsPrimary BIT,  -- To mark the primary email
    DateAdded DATETIME,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID),  -- Links to Admin table
    CHECK (Email LIKE '%_@__%.__%')  -- Ensures the email has a basic format (text@text.text)
);

-- Table for AuditTrail
------------ CREATED -----------
CREATE TABLE AuditTrail (
    AuditID INT PRIMARY KEY,
    ActionType VARCHAR(50),
    EntityAffected VARCHAR(255),
    Timestamp DATETIME,
    AdminID INT,
    Details TEXT,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);


-- Table for ServiceProviderPerformance
------------- CREATED -----------------
CREATE TABLE ServiceProviderPerformance (
    ServiceProviderID INT,  -- Foreign key from ServiceProvider
    TourOperatorID INT,  -- Foreign key from TourOperator who evaluated the performance
    HotelOccupancyRate DECIMAL(5, 2),  -- Performance metric for hotels
    GuideRatings DECIMAL(3, 2),  -- Rating for the guides
    TransportOnTimePerformance DECIMAL(5, 2),  -- Transport punctuality performance
    ServiceUtilization DECIMAL(5, 2),  -- Utilization of services
    PRIMARY KEY (ServiceProviderID, TourOperatorID),  -- Composite primary key
    FOREIGN KEY (ServiceProviderID) REFERENCES HotelServiceProvider(ServiceProviderID),  -- Linking to ServiceProvider
    FOREIGN KEY (TourOperatorID) REFERENCES TourOperator(OperatorID)  -- Linking to TourOperator who made the evaluation
);


-- Table for Inquiries, representing inquiries made by a traveler regarding a booking
------------- CREATED -------------
CREATE TABLE Inquiries (
    InquiryID INT PRIMARY KEY,  -- Unique identifier for the inquiry
    TravelerID INT,  -- Foreign key linking to Traveler
    BookingID INT,   -- Foreign key linking to Booking
    TourOperatorID INT,  -- Foreign key linking to TourOperator
    InquiryTime DATETIME,  -- Time when the inquiry was made
    ResponseTime DATETIME,  -- Time when the response was given

    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID),  -- Foreign key to Traveler
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),  -- Foreign key to Booking
    FOREIGN KEY (TourOperatorID) REFERENCES TourOperator(OperatorID)  -- Foreign key to TourOperator
);

ALTER TABLE Inquiries
ADD TripID INT;

ALTER TABLE Inquiries
ADD CONSTRAINT FK_Inquiries_Trip
FOREIGN KEY (TripID) REFERENCES Trip(TripID)
ON DELETE CASCADE;



-- Table for Oversees, where an Admin oversees the Reviews
------------ CREATED -----------
CREATE TABLE Oversees (
    AdminID INT,  -- Foreign key linking to Admin
    ReviewID INT,  -- Foreign key linking to Review
    DateOverseen DATETIME,  -- Date when the review was overseen by the admin
    PRIMARY KEY (AdminID, ReviewID),  -- Composite primary key to ensure unique overseen reviews per admin
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID),  -- Foreign key to Admin table
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID)  -- Foreign key to Review table
);

-- Table for the ternary relationship between Traveler, Inquiry, and Booking
--------------- CREATED -----------
CREATE TABLE TravelerInquiryBooking (
    InquiryID INT,  -- Foreign key linking to Inquiry
    TravelerID INT,  -- Foreign key linking to Traveler
    BookingID INT,   -- Foreign key linking to Booking
	Inquiry varchar(250),
    PRIMARY KEY (InquiryID, TravelerID, BookingID),  -- Composite primary key
    FOREIGN KEY (InquiryID) REFERENCES Inquiries(InquiryID),  -- Foreign key to Inquiry
    FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID),  -- Foreign key to Traveler
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)  -- Foreign key to Booking
);




-- Table for Evaluates, where a TourOperator evaluates a ServiceProviderPerformance
--------- CREATED -------
CREATE TABLE Evaluation (
    OperatorID INT,  -- Foreign key from TourOperator
    ServiceProviderID INT,  -- Foreign key from ServiceProviderPerformance
    EvaluationDate DATETIME,  -- Date when the evaluation was made
    PRIMARY KEY (OperatorID, ServiceProviderID),  -- Composite primary key to ensure unique evaluations by each operator for each provider
    FOREIGN KEY (OperatorID) REFERENCES TourOperator(OperatorID),  -- Foreign key to TourOperator
    FOREIGN KEY (ServiceProviderID) REFERENCES HotelServiceProvider(ServiceProviderID)  -- Foreign key to ServiceProviderPerformance
);



drop table AuditTrail;




-- Table for AuditTrail
------------ CREATED -----------
CREATE TABLE AuditTrail (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    ActionType VARCHAR(50),
    EntityAffected VARCHAR(255),
    EntityID INT,
    Timestamp DATETIME DEFAULT GETDATE()
);




CREATE TABLE TourCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT
);



INSERT INTO TourCategory (CategoryName)
SELECT DISTINCT TripType
FROM Trip
WHERE TripType IS NOT NULL
  AND TripType NOT IN (SELECT CategoryName FROM TourCategory);

UPDATE TourCategory
SET Description = 'Exciting, action-packed experiences including hiking, rafting, and extreme sports.'
WHERE CategoryName = 'Adventure';

UPDATE TourCategory
SET Description = 'Relaxing holidays by the sea, featuring beaches, resorts, and ocean activities.'
WHERE CategoryName = 'Beach';

UPDATE TourCategory
SET Description = 'Tours of urban attractions, landmarks, shopping, and cultural experiences in major cities.'
WHERE CategoryName = 'City Tour';

UPDATE TourCategory
SET Description = 'Immersive experiences in art, history, traditions, and heritage sites.'
WHERE CategoryName = 'Cultural';

UPDATE TourCategory
SET Description = 'High-end travel experiences with luxury accommodations, dining, and services.'
WHERE CategoryName = 'Luxury';

UPDATE TourCategory
SET Description = 'Trips to mountainous regions including trekking, skiing, and scenic stays.'
WHERE CategoryName = 'Mountain';

UPDATE TourCategory
SET Description = 'Wildlife safaris and nature exploration in forests, savannahs, and national parks.'
WHERE CategoryName = 'Safari';






CREATE TRIGGER trg_TourCategory_Insert
ON TourCategory
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'TourCategory', CategoryID
    FROM inserted;
END;


CREATE TRIGGER trg_TourCategory_Update
ON TourCategory
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'TourCategory', CategoryID
    FROM inserted;
END;

CREATE TRIGGER trg_TourCategory_Delete
ON TourCategory
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'TourCategory', CategoryID
    FROM deleted;
END;



ALTER TABLE TourCategory
ADD CONSTRAINT UQ_TourCategory_CategoryName UNIQUE (CategoryName);

ALTER TABLE Trip
ADD CONSTRAINT FK_Trip_TripType_TourCategory
FOREIGN KEY (TripType) REFERENCES TourCategory(CategoryName)
ON DELETE NO ACTION
ON UPDATE CASCADE;



--------------- TRIGGERS ---------------

CREATE TRIGGER trg_Traveler_Insert
ON Traveler
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Traveler', TravelerID
    FROM inserted;
END;


CREATE TRIGGER trg_Traveler_Update
ON Traveler
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Traveler', TravelerID
    FROM inserted;
END;


CREATE TRIGGER trg_Traveler_Delete
ON Traveler
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Traveler', TravelerID
    FROM deleted;
END;


-- INSERT
CREATE TRIGGER trg_TravelerEmail_Insert
ON TravelerEmail
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'TravelerEmail', TravelerID
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_TravelerEmail_Update
ON TravelerEmail
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'TravelerEmail', TravelerID
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_TravelerEmail_Delete
ON TravelerEmail
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'TravelerEmail', TravelerID
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_TravelerPhoneNumber_Insert
ON TravelerPhoneNumber
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'TravelerPhoneNumber', TravelerID
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_TravelerPhoneNumber_Update
ON TravelerPhoneNumber
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'TravelerPhoneNumber', TravelerID
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_TravelerPhoneNumber_Delete
ON TravelerPhoneNumber
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'TravelerPhoneNumber', TravelerID
    FROM deleted;
END;


-- INSERT
CREATE TRIGGER trg_Wishlist_Insert
ON Wishlist
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Wishlist', WishID
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Wishlist_Update
ON Wishlist
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Wishlist', WishID
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Wishlist_Delete
ON Wishlist
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Wishlist', WishID
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_WishlistAdd_Insert
ON WishlistAdd
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'WishlistAdd', TravelerID
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_WishlistAdd_Update
ON WishlistAdd
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'WishlistAdd', TravelerID
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_WishlistAdd_Delete
ON WishlistAdd
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'WishlistAdd', TravelerID
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_Review_Insert
ON Review
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Review', ReviewID
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Review_Update
ON Review
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Review', ReviewID
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Review_Delete
ON Review
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Review', ReviewID
    FROM deleted;
END;


-- INSERT
CREATE TRIGGER trg_Booking_Insert ON Booking AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Booking', BookingID FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Booking_Update ON Booking AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Booking', BookingID FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Booking_Delete ON Booking AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Booking', BookingID FROM deleted;
END;

CREATE TRIGGER trg_Payment_Insert ON Payment AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Payment', PaymentID FROM inserted;
END;

CREATE TRIGGER trg_Payment_Update ON Payment AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Payment', PaymentID FROM inserted;
END;

CREATE TRIGGER trg_Payment_Delete ON Payment AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Payment', PaymentID FROM deleted;
END;

CREATE TRIGGER trg_Overlooks_Insert ON Overlooks AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Overlooks', PaymentID FROM inserted;
END;

CREATE TRIGGER trg_Overlooks_Update ON Overlooks AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Overlooks', PaymentID FROM inserted;
END;

CREATE TRIGGER trg_Overlooks_Delete ON Overlooks AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Overlooks', PaymentID FROM deleted;
END;

CREATE TRIGGER trg_Trip_Insert ON Trip AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Trip', TripID FROM inserted;
END;

CREATE TRIGGER trg_Trip_Update ON Trip AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Trip', TripID FROM inserted;
END;

CREATE TRIGGER trg_Trip_Delete ON Trip AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Trip', TripID FROM deleted;
END;

CREATE TRIGGER trg_TripInvolves_Insert ON TripInvolves AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'TripInvolves', TripID FROM inserted;
END;

CREATE TRIGGER trg_TripInvolves_Update ON TripInvolves AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'TripInvolves', TripID FROM inserted;
END;

CREATE TRIGGER trg_TripInvolves_Delete ON TripInvolves AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'TripInvolves', TripID FROM deleted;
END;

CREATE TRIGGER trg_Activities_Insert ON Activities AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Activities', ActivityID FROM inserted;
END;

CREATE TRIGGER trg_Activities_Update ON Activities AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Activities', ActivityID FROM inserted;
END;

CREATE TRIGGER trg_Activities_Delete ON Activities AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Activities', ActivityID FROM deleted;
END;

CREATE TRIGGER trg_TripDestinations_Insert ON TripDestinations AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'TripDestinations', TripID FROM inserted;
END;

CREATE TRIGGER trg_TripDestinations_Update ON TripDestinations AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'TripDestinations', TripID FROM inserted;
END;

CREATE TRIGGER trg_TripDestinations_Delete ON TripDestinations AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'TripDestinations', TripID FROM deleted;
END;

CREATE TRIGGER trg_Destination_Insert ON Destination AFTER INSERT AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'INSERT', 'Destination', DestinationID FROM inserted;
END;

CREATE TRIGGER trg_Destination_Update ON Destination AFTER UPDATE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'UPDATE', 'Destination', DestinationID FROM inserted;
END;

CREATE TRIGGER trg_Destination_Delete ON Destination AFTER DELETE AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID)
    SELECT 'DELETE', 'Destination', DestinationID FROM deleted;
END;


-- INSERT
CREATE TRIGGER trg_TourOperator_Insert
ON TourOperator
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'TourOperator', OperatorID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_TourOperator_Update
ON TourOperator
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'TourOperator', OperatorID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_TourOperator_Delete
ON TourOperator
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'TourOperator', OperatorID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_HotelServiceProvider_Insert
ON HotelServiceProvider
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'HotelServiceProvider', ServiceProviderID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_HotelServiceProvider_Update
ON HotelServiceProvider
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'HotelServiceProvider', ServiceProviderID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_HotelServiceProvider_Delete
ON HotelServiceProvider
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'HotelServiceProvider', ServiceProviderID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_Admin_Insert
ON Admin
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'Admin', AdminID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Admin_Update
ON Admin
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'Admin', AdminID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Admin_Delete
ON Admin
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'Admin', AdminID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_AdminEmails_Insert
ON AdminEmails
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'AdminEmails', EmailID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_AdminEmails_Update
ON AdminEmails
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'AdminEmails', EmailID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_AdminEmails_Delete
ON AdminEmails
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'AdminEmails', EmailID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_ServiceProviderPerformance_Insert
ON ServiceProviderPerformance
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'ServiceProviderPerformance', ServiceProviderID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_ServiceProviderPerformance_Update
ON ServiceProviderPerformance
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'ServiceProviderPerformance', ServiceProviderID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_ServiceProviderPerformance_Delete
ON ServiceProviderPerformance
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'ServiceProviderPerformance', ServiceProviderID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_Inquiries_Insert
ON Inquiries
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'Inquiries', InquiryID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Inquiries_Update
ON Inquiries
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'Inquiries', InquiryID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Inquiries_Delete
ON Inquiries
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'Inquiries', InquiryID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_Oversees_Insert
ON Oversees
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'Oversees', ReviewID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Oversees_Update
ON Oversees
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'Oversees', ReviewID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Oversees_Delete
ON Oversees
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'Oversees', ReviewID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_TravelerInquiryBooking_Insert
ON TravelerInquiryBooking
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'TravelerInquiryBooking', InquiryID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_TravelerInquiryBooking_Update
ON TravelerInquiryBooking
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'TravelerInquiryBooking', InquiryID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_TravelerInquiryBooking_Delete
ON TravelerInquiryBooking
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'TravelerInquiryBooking', InquiryID, GETDATE()
    FROM deleted;
END;

-- INSERT
CREATE TRIGGER trg_Evaluation_Insert
ON Evaluation
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'INSERT', 'Evaluation', ServiceProviderID, GETDATE()
    FROM inserted;
END;

-- UPDATE
CREATE TRIGGER trg_Evaluation_Update
ON Evaluation
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'UPDATE', 'Evaluation', ServiceProviderID, GETDATE()
    FROM inserted;
END;

-- DELETE
CREATE TRIGGER trg_Evaluation_Delete
ON Evaluation
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditTrail (ActionType, EntityAffected, EntityID, Timestamp)
    SELECT 'DELETE', 'Evaluation', ServiceProviderID, GETDATE()
    FROM deleted;
END;
--------------------
--------------------
--LOADING THE DATA--
--------------------
--------------------




-- ADMIN TABLE DATA
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (1, 'Kara Ross', 'password831', 'Admin', 'manage_users,edit', '2024-09-08 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (2, 'Valerie Ibarra', 'password174', 'Super Admin', 'delete,view,manage_users', '2021-08-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (3, 'Mary Miller', 'password593', 'Admin', 'edit,view,manage_users,delete', '2023-04-05 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (4, 'Crystal Solomon', 'password945', 'Super Admin', 'manage_users,view', '2020-04-16 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (5, 'Stephen Tran', 'password646', 'Super Admin', 'edit,manage_users', '2020-03-05 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (6, 'Peter Herrera', 'password114', 'Super Admin', 'manage_users,edit,view', '2020-08-17 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (7, 'Jared Lin', 'password240', 'Super Admin', 'manage_users,view,edit', '2022-06-04 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (8, 'Billy Summers', 'password602', 'Super Admin', 'delete,edit,manage_users,view', '2020-02-28 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (9, 'Stephanie Clark', 'password407', 'Super Admin', 'delete,view,manage_users', '2023-08-04 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (10, 'Benjamin Petty', 'password866', 'Super Admin', 'edit,manage_users,view,delete', '2020-11-14 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (11, 'Justin Thompson', 'password305', 'Super Admin', 'manage_users,delete,edit,view', '2023-04-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (12, 'Taylor Townsend', 'password963', 'Admin', 'edit,delete', '2024-03-25 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (13, 'Nathan Contreras', 'password210', 'Admin', 'delete,manage_users,view', '2023-04-04 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (14, 'Brittany Bauer', 'password838', 'Admin', 'manage_users,delete,edit', '2020-10-08 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (15, 'Mark Ramirez', 'password914', 'Admin', 'delete,manage_users,view', '2024-05-20 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (16, 'Kimberly Bowers', 'password798', 'Admin', 'edit,view,delete,manage_users', '2024-12-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (17, 'Anthony Gutierrez', 'password958', 'Admin', 'manage_users,edit,delete,view', '2024-12-15 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (18, 'Darlene Flores', 'password767', 'Admin', 'view,delete', '2021-09-03 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (19, 'Tara Gonzales', 'password599', 'Super Admin', 'manage_users,delete,view,edit', '2022-12-18 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (20, 'Lisa Shelton', 'password143', 'Super Admin', 'edit,delete,view,manage_users', '2023-05-06 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (21, 'Karen Jones', 'password965', 'Super Admin', 'delete,manage_users', '2022-12-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (22, 'Brian Johnson', 'password955', 'Admin', 'view,manage_users,delete,edit', '2023-07-04 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (23, 'Brian Buchanan DDS', 'password286', 'Super Admin', 'edit,manage_users', '2021-05-30 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (24, 'Glenn Reed', 'password870', 'Super Admin', 'delete,edit,view,manage_users', '2023-04-24 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (25, 'Jessica Rodriguez', 'password608', 'Admin', 'manage_users,delete,view', '2024-03-22 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (26, 'Gregory Mcdaniel', 'password871', 'Super Admin', 'view,manage_users,delete', '2020-07-17 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (27, 'Jennifer Vance', 'password930', 'Super Admin', 'edit,view', '2020-04-06 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (28, 'Ashley Mcclure', 'password971', 'Super Admin', 'manage_users,view,edit,delete', '2024-10-12 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (29, 'Tracy Boone', 'password755', 'Super Admin', 'view,delete,manage_users', '2022-03-22 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (30, 'Shannon Cordova', 'password194', 'Super Admin', 'view,delete', '2024-09-17 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (31, 'Carol Gonzales', 'password472', 'Super Admin', 'manage_users,delete,edit,view', '2021-01-16 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (32, 'Taylor Powell', 'password810', 'Super Admin', 'delete,manage_users,view', '2024-07-19 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (33, 'Charles Weaver', 'password568', 'Admin', 'edit,view', '2022-12-31 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (34, 'Jason Tran', 'password301', 'Admin', 'manage_users,delete,view,edit', '2025-04-15 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (35, 'Christina Mejia', 'password741', 'Super Admin', 'manage_users,edit,delete,view', '2025-01-09 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (36, 'Aimee Medina', 'password510', 'Admin', 'edit,view,delete,manage_users', '2022-01-02 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (37, 'Thomas Williams', 'password692', 'Admin', 'view,manage_users,edit,delete', '2024-07-03 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (38, 'Alexander Davis', 'password982', 'Admin', 'manage_users,delete,edit', '2024-02-09 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (39, 'Carol Stephens', 'password883', 'Super Admin', 'manage_users,view,edit,delete', '2020-01-22 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (40, 'Ronald Thompson', 'password171', 'Admin', 'delete,edit,view', '2021-10-22 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (41, 'Lisa Johnson', 'password650', 'Super Admin', 'delete,edit', '2022-03-15 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (42, 'Dominique Murray', 'password699', 'Super Admin', 'delete,view,manage_users', '2021-01-07 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (43, 'Tammy Perez', 'password219', 'Super Admin', 'delete,edit,manage_users,view', '2022-07-30 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (44, 'Sharon Jackson', 'password699', 'Super Admin', 'delete,edit,view,manage_users', '2024-05-30 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (45, 'Anna Howard', 'password560', 'Admin', 'edit,delete', '2022-04-21 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (46, 'Megan Schwartz', 'password792', 'Super Admin', 'delete,view', '2024-01-08 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (47, 'Leslie Lynch', 'password364', 'Admin', 'view,manage_users', '2020-07-08 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (48, 'Jessica Pena', 'password603', 'Super Admin', 'manage_users,delete,view,edit', '2020-01-05 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (49, 'Tom Lee', 'password786', 'Super Admin', 'edit,manage_users', '2021-02-14 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (50, 'John Garza', 'password332', 'Super Admin', 'manage_users,edit,view,delete', '2021-12-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (51, 'Emily Lindsey', 'password895', 'Admin', 'view,manage_users', '2023-09-10 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (52, 'Thomas Kidd', 'password650', 'Admin', 'edit,manage_users,delete,view', '2020-06-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (53, 'Mariah Haley', 'password982', 'Admin', 'manage_users,edit,delete,view', '2021-11-10 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (54, 'Sarah Flores', 'password564', 'Admin', 'manage_users,view', '2022-08-11 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (55, 'Carol Franklin', 'password383', 'Admin', 'view,delete', '2020-08-09 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (56, 'Brandon Sandoval DVM', 'password989', 'Super Admin', 'delete,manage_users,edit', '2023-09-24 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (57, 'Mark Miller', 'password492', 'Admin', 'view,delete,edit,manage_users', '2021-09-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (58, 'Victor Mills', 'password357', 'Super Admin', 'manage_users,view,edit,delete', '2023-09-21 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (59, 'Marisa Walters', 'password136', 'Admin', 'view,delete,edit', '2021-08-14 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (60, 'Daniel Miller', 'password830', 'Super Admin', 'manage_users,delete', '2024-01-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (61, 'Christopher Davenport', 'password423', 'Super Admin', 'delete,edit,manage_users,view', '2022-10-01 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (62, 'Katherine Webster', 'password657', 'Super Admin', 'edit,view,delete', '2021-02-15 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (63, 'David Perkins', 'password985', 'Admin', 'edit,delete,manage_users', '2022-05-10 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (64, 'April Mcdonald', 'password309', 'Admin', 'edit,view,manage_users', '2023-01-29 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (65, 'Christina Vincent', 'password261', 'Admin', 'view,manage_users', '2025-01-30 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (66, 'Eric Bishop', 'password529', 'Super Admin', 'delete,edit,manage_users,view', '2023-08-30 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (67, 'Denise Blanchard MD', 'password444', 'Super Admin', 'manage_users,edit,view,delete', '2020-11-20 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (68, 'Joshua Barajas', 'password314', 'Super Admin', 'delete,manage_users', '2020-09-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (69, 'Robert Sullivan', 'password815', 'Super Admin', 'view,manage_users,delete,edit', '2021-05-24 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (70, 'Samantha Nolan', 'password614', 'Admin', 'view,edit', '2020-01-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (71, 'Cheryl Harris', 'password702', 'Super Admin', 'view,manage_users', '2020-12-29 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (72, 'Gina Schmidt', 'password851', 'Super Admin', 'delete,edit,view', '2024-08-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (73, 'Ms. Kristine Lee', 'password225', 'Admin', 'manage_users,delete,edit', '2022-08-17 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (74, 'Michael Thompson', 'password656', 'Super Admin', 'view,delete,edit', '2020-10-03 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (75, 'Timothy Adams', 'password252', 'Super Admin', 'view,delete', '2024-11-13 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (76, 'Ashley Horne', 'password198', 'Super Admin', 'manage_users,edit', '2020-06-23 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (77, 'Brian Fletcher', 'password781', 'Admin', 'manage_users,view', '2022-07-22 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (78, 'Harold Smith', 'password992', 'Admin', 'manage_users,view,edit,delete', '2023-03-26 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (79, 'Lauren Santos', 'password990', 'Admin', 'delete,manage_users,view', '2024-05-11 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (80, 'Jennifer Richardson', 'password342', 'Admin', 'manage_users,delete,edit', '2023-05-11 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (81, 'Katherine White', 'password911', 'Super Admin', 'edit,delete,view', '2024-11-19 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (82, 'Holly Vasquez', 'password617', 'Admin', 'edit,view', '2025-02-25 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (83, 'Sydney Thomas', 'password801', 'Super Admin', 'manage_users,delete,edit,view', '2021-08-13 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (84, 'Veronica Curry', 'password154', 'Super Admin', 'edit,manage_users,view,delete', '2022-02-16 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (85, 'Patricia Graham', 'password132', 'Admin', 'manage_users,delete,edit', '2023-08-13 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (86, 'Linda Carey', 'password732', 'Super Admin', 'view,edit', '2024-02-15 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (87, 'Eric Lewis', 'password268', 'Admin', 'view,edit,manage_users', '2024-06-13 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (88, 'Casey Crawford', 'password116', 'Super Admin', 'manage_users,view,edit,delete', '2022-03-24 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (89, 'Claire Bryant', 'password493', 'Super Admin', 'delete,manage_users', '2021-07-14 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (90, 'Barbara Morales', 'password529', 'Super Admin', 'view,delete', '2020-02-04 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (91, 'David Harris', 'password982', 'Super Admin', 'manage_users,delete,edit,view', '2020-03-30 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (92, 'Christina Rivera', 'password527', 'Super Admin', 'delete,manage_users,view,edit', '2020-07-08 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (93, 'David Sanders', 'password392', 'Admin', 'delete,edit', '2023-08-22 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (94, 'Audrey Williams', 'password839', 'Super Admin', 'edit,manage_users,delete', '2023-04-27 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (95, 'Robert Hanna', 'password892', 'Super Admin', 'view,delete', '2023-08-28 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (96, 'Alicia Travis', 'password510', 'Super Admin', 'manage_users,delete,edit', '2023-02-26 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (97, 'Nichole Allen', 'password100', 'Super Admin', 'view,edit,delete', '2021-08-25 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (98, 'Jose Garcia', 'password877', 'Super Admin', 'delete,edit,view,manage_users', '2022-02-20 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (99, 'Kristen Herrera', 'password597', 'Super Admin', 'view,delete,edit,manage_users', '2021-10-10 00:00:00');
INSERT INTO Admin (AdminID, Name, Password, Role, Permissions, DateCreated) VALUES (100, 'Tracy Obrien', 'password314', 'Admin', 'delete,manage_users,view,edit', '2021-09-11 00:00:00');


-- ADMIN EMAIL TABLE DATA
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (1, 1, 'wallacedana@gmail.com', 1, '2022-06-02');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (2, 1, 'thomaskyle@sanchez-butler.biz', 0, '2022-10-30');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (3, 2, 'daniel63@riley.com', 1, '2023-05-01');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (4, 3, 'patriciadougherty@valenzuela.com', 1, '2024-03-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (5, 4, 'roy45@bird.com', 1, '2023-09-05');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (6, 4, 'elizabethknight@hotmail.com', 0, '2024-08-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (7, 5, 'crystal56@herrera-martin.net', 1, '2022-04-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (8, 5, 'raymondjones@lee.biz', 0, '2022-11-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (9, 5, 'ian26@meyer.biz', 0, '2024-12-09');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (10, 6, 'eacosta@hotmail.com', 1, '2020-12-11');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (11, 6, 'nixonedward@hotmail.com', 0, '2024-01-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (12, 7, 'mrichard@johnson-robertson.com', 1, '2020-07-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (13, 7, 'mario55@sandoval.com', 0, '2024-01-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (14, 8, 'qjenkins@gmail.com', 1, '2021-11-01');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (15, 9, 'jaydaniels@gmail.com', 1, '2022-08-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (16, 9, 'gdavenport@wood.com', 0, '2021-08-31');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (17, 10, 'sbrown@soto.com', 1, '2021-07-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (18, 10, 'wolfdevin@yahoo.com', 0, '2023-10-23');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (19, 10, 'iwashington@smith.com', 0, '2021-12-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (20, 11, 'bfuller@gmail.com', 1, '2024-09-23');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (21, 11, 'parkerdenise@gmail.com', 0, '2021-08-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (22, 12, 'angelica91@riley.com', 1, '2024-07-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (23, 13, 'rebecca08@cook-myers.com', 1, '2022-04-05');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (24, 14, 'thomas45@peters.net', 1, '2020-11-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (25, 15, 'littlenicole@yahoo.com', 1, '2024-01-31');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (26, 16, 'mia76@montes.net', 1, '2023-10-18');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (27, 17, 'ericevans@wolf-franklin.com', 1, '2024-01-28');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (28, 17, 'haleyanthony@hotmail.com', 0, '2020-02-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (29, 17, 'julia11@hotmail.com', 0, '2020-01-16');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (30, 18, 'gwalker@hotmail.com', 1, '2021-03-24');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (31, 19, 'reidnicholas@yahoo.com', 1, '2024-05-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (32, 20, 'saradonovan@gmail.com', 1, '2021-03-27');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (33, 21, 'madison04@hughes.com', 1, '2024-05-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (34, 21, 'vincentstephanie@hotmail.com', 0, '2024-10-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (35, 21, 'cynthiasmith@morrow.org', 0, '2022-07-30');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (36, 22, 'smedina@smith-price.com', 1, '2024-04-21');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (37, 22, 'ltorres@yahoo.com', 0, '2022-10-07');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (38, 22, 'mark61@warner-lawson.org', 0, '2020-05-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (39, 23, 'shanegriffin@king.org', 1, '2021-12-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (40, 23, 'ddavis@yahoo.com', 0, '2022-10-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (41, 24, 'cherylhernandez@gmail.com', 1, '2023-09-18');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (42, 24, 'faulknerwendy@gmail.com', 0, '2020-10-24');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (43, 25, 'xmunoz@powell.net', 1, '2024-01-12');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (44, 25, 'mendezjennifer@keller.info', 0, '2021-01-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (45, 25, 'lisakennedy@hotmail.com', 0, '2025-01-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (46, 26, 'cmitchell@spence.com', 1, '2025-03-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (47, 26, 'gsalas@nunez-andrade.com', 0, '2025-03-26');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (48, 26, 'tpayne@king.com', 0, '2022-05-02');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (49, 27, 'katrina67@hall.info', 1, '2021-11-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (50, 28, 'fgibson@yahoo.com', 1, '2022-04-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (51, 28, 'hayley84@yahoo.com', 0, '2023-07-12');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (52, 28, 'davidhorn@hotmail.com', 0, '2023-01-24');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (53, 29, 'thomasamy@huber.org', 1, '2024-12-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (54, 30, 'pbrown@yahoo.com', 1, '2020-03-27');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (55, 30, 'jack27@white.com', 0, '2022-06-14');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (56, 30, 'taylorrobert@harper-lee.org', 0, '2021-02-08');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (57, 31, 'adrian70@hotmail.com', 1, '2021-06-18');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (58, 31, 'rwalker@blackburn-young.org', 0, '2023-06-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (59, 31, 'wolferobert@yahoo.com', 0, '2022-02-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (60, 32, 'donnawatts@patterson.com', 1, '2022-01-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (61, 32, 'briannagonzalez@myers.com', 0, '2020-12-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (62, 33, 'vanessa57@pacheco-thompson.com', 1, '2021-04-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (63, 34, 'psingh@sanchez-chung.com', 1, '2022-08-11');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (64, 34, 'tiffany07@yahoo.com', 0, '2020-04-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (65, 35, 'briannaburke@warren.com', 1, '2021-11-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (66, 35, 'jacksonsabrina@lynch.com', 0, '2024-01-10');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (67, 35, 'contreraslaura@hotmail.com', 0, '2020-09-16');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (68, 36, 'sharonmueller@barnes.com', 1, '2025-04-11');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (69, 36, 'justinevans@jacobs.com', 0, '2021-01-09');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (70, 36, 'selliott@smith.com', 0, '2022-08-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (71, 37, 'grayandre@hotmail.com', 1, '2020-08-24');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (72, 38, 'meganneal@hotmail.com', 1, '2022-10-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (73, 38, 'gregory83@gmail.com', 0, '2020-01-11');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (74, 39, 'kathleen92@gmail.com', 1, '2023-08-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (75, 40, 'gooddonna@cook.com', 1, '2020-10-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (76, 40, 'dkhan@lewis.info', 0, '2020-02-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (77, 40, 'alexandraruiz@hill-stone.com', 0, '2025-04-16');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (78, 41, 'richard11@hughes.com', 1, '2021-03-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (79, 42, 'jared37@jones.com', 1, '2025-02-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (80, 42, 'thomasscott@charles.com', 0, '2020-01-22');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (81, 43, 'hernandezgerald@hotmail.com', 1, '2022-03-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (82, 43, 'yperez@hotmail.com', 0, '2024-05-09');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (83, 43, 'jesselynch@bennett-boyer.com', 0, '2020-09-10');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (84, 44, 'eric67@garcia.net', 1, '2020-09-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (85, 44, 'blackolivia@gmail.com', 0, '2022-08-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (86, 45, 'garciashelly@brown.com', 1, '2023-02-23');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (87, 45, 'paul39@perry.com', 0, '2024-01-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (88, 45, 'lisa08@gmail.com', 0, '2023-10-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (89, 46, 'diana31@hotmail.com', 1, '2022-04-22');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (90, 46, 'virginiahines@reed-casey.com', 0, '2025-03-30');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (91, 47, 'millernicholas@durham.com', 1, '2021-10-09');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (92, 48, 'rhonda33@gmail.com', 1, '2021-02-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (93, 48, 'jefferylam@white.com', 0, '2021-02-07');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (94, 48, 'pfuller@gonzalez-brown.com', 0, '2023-07-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (95, 49, 'linda27@garrett.net', 1, '2020-02-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (96, 49, 'megan00@carson.biz', 0, '2021-07-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (97, 49, 'collinstiffany@yahoo.com', 0, '2020-01-30');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (98, 50, 'kevin49@yahoo.com', 1, '2022-03-07');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (99, 50, 'stewartmichael@hotmail.com', 0, '2024-12-14');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (100, 50, 'alexandra99@hotmail.com', 0, '2022-11-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (101, 51, 'stephanie70@alvarez.com', 1, '2020-02-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (102, 51, 'juan17@oneill.biz', 0, '2023-02-05');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (103, 52, 'bullockjessica@hotmail.com', 1, '2020-04-14');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (104, 52, 'pwilliams@yahoo.com', 0, '2023-11-07');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (105, 52, 'lawrence69@yahoo.com', 0, '2023-05-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (106, 53, 'brittanyhernandez@wilson.biz', 1, '2020-10-27');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (107, 54, 'aalvarez@reed-clark.info', 1, '2024-11-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (108, 54, 'uholmes@walker.info', 0, '2020-05-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (109, 54, 'frandall@mcmillan-brown.net', 0, '2022-03-01');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (110, 55, 'jonathanrobinson@gmail.com', 1, '2022-01-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (111, 56, 'kellyjill@gmail.com', 1, '2024-04-16');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (112, 57, 'omiller@garcia.info', 1, '2021-06-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (113, 58, 'esimpson@hotmail.com', 1, '2022-12-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (114, 58, 'calebdorsey@johnson.com', 0, '2023-04-27');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (115, 59, 'tiffany61@bender.net', 1, '2021-12-26');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (116, 60, 'coreyreid@yahoo.com', 1, '2021-08-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (117, 60, 'wknox@gmail.com', 0, '2024-09-02');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (118, 60, 'whitneyyoung@hotmail.com', 0, '2020-02-01');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (119, 61, 'tarabray@yahoo.com', 1, '2024-07-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (120, 62, 'antonio19@gmail.com', 1, '2025-01-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (121, 63, 'dhoover@mccarthy.com', 1, '2020-06-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (122, 63, 'walkerterri@gmail.com', 0, '2024-12-07');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (123, 64, 'martinezrichard@hotmail.com', 1, '2022-04-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (124, 64, 'eugene97@yahoo.com', 0, '2023-10-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (125, 64, 'evandavies@yahoo.com', 0, '2022-06-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (126, 65, 'patrickpowell@cabrera.com', 1, '2022-07-18');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (127, 65, 'williamschultz@parks.info', 0, '2024-01-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (128, 65, 'grahamgregory@delgado-freeman.com', 0, '2024-11-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (129, 66, 'sabrinaschaefer@gmail.com', 1, '2024-05-10');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (130, 66, 'elizabeth26@kim.info', 0, '2024-03-02');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (131, 66, 'nguyenmichael@hotmail.com', 0, '2022-08-27');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (132, 67, 'martinrobert@evans.com', 1, '2022-06-09');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (133, 67, 'rebeccacompton@sosa.com', 0, '2024-09-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (134, 67, 'gonzalezbrittney@hotmail.com', 0, '2021-10-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (135, 68, 'tsmith@gmail.com', 1, '2020-01-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (136, 69, 'bmitchell@cruz.biz', 1, '2024-07-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (137, 70, 'georgegarcia@myers.com', 1, '2022-01-30');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (138, 71, 'shellycox@foster-heath.biz', 1, '2024-05-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (139, 72, 'rose68@ball.com', 1, '2022-09-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (140, 72, 'tylercole@frazier.com', 0, '2021-06-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (141, 73, 'jtaylor@hotmail.com', 1, '2022-06-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (142, 73, 'nalexander@hotmail.com', 0, '2021-10-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (143, 73, 'steven92@chapman.com', 0, '2020-07-10');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (144, 74, 'tinamontgomery@yahoo.com', 1, '2020-07-20');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (145, 75, 'justinjackson@johnson.com', 1, '2020-11-14');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (146, 75, 'sheryl60@harris-sanchez.com', 0, '2020-12-01');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (147, 76, 'bailey32@hunt.biz', 1, '2021-09-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (148, 77, 'christopherwilliams@hotmail.com', 1, '2024-10-17');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (149, 77, 'frank10@yahoo.com', 0, '2024-12-23');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (150, 78, 'rmassey@kane.com', 1, '2021-08-23');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (151, 78, 'richardsandoval@blevins-berry.com', 0, '2021-03-12');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (152, 79, 'acastillo@jenkins.com', 1, '2021-04-18');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (153, 79, 'dawn84@gmail.com', 0, '2020-08-26');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (154, 80, 'danieljoshua@yahoo.com', 1, '2022-03-26');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (155, 81, 'erikarobbins@gmail.com', 1, '2020-03-02');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (156, 81, 'riverachristopher@lin.com', 0, '2022-10-22');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (157, 82, 'bakerallen@moreno.com', 1, '2024-06-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (158, 82, 'barkerthomas@yahoo.com', 0, '2024-12-21');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (159, 83, 'mblair@vazquez-mills.info', 1, '2023-09-23');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (160, 84, 'patrick04@townsend.org', 1, '2020-10-28');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (161, 84, 'michael47@morrison.com', 0, '2021-02-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (162, 85, 'langbeth@horton-larson.info', 1, '2020-09-19');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (163, 85, 'susangreen@owens.org', 0, '2022-06-10');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (164, 85, 'donnagibson@yahoo.com', 0, '2021-06-30');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (165, 86, 'wwhite@yahoo.com', 1, '2023-11-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (166, 86, 'stephenselizabeth@hartman.biz', 0, '2024-10-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (167, 87, 'dustinmoore@shaw-griffin.biz', 1, '2021-02-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (168, 88, 'vweber@dominguez.com', 1, '2021-11-07');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (169, 88, 'sheila11@gmail.com', 0, '2022-11-12');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (170, 88, 'susanlang@taylor.com', 0, '2020-09-24');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (171, 89, 'csweeney@smith.com', 1, '2020-11-16');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (172, 89, 'wgilmore@yahoo.com', 0, '2020-05-14');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (173, 90, 'jennifer63@hotmail.com', 1, '2023-08-15');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (174, 90, 'beth37@hotmail.com', 0, '2022-07-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (175, 91, 'rogersrebecca@bauer.com', 1, '2024-03-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (176, 91, 'blackwellangela@wright.com', 0, '2020-11-29');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (177, 91, 'larryroy@hotmail.com', 0, '2020-12-06');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (178, 92, 'iwatson@gmail.com', 1, '2021-01-12');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (179, 93, 'marcus28@sullivan.com', 1, '2023-03-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (180, 94, 'katherine48@berry-holloway.com', 1, '2022-09-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (181, 95, 'richardcruz@rogers.com', 1, '2023-02-21');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (182, 95, 'nmendez@gmail.com', 0, '2020-10-08');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (183, 96, 'williamsmorgan@gmail.com', 1, '2020-08-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (184, 96, 'kristinmeyer@hotmail.com', 0, '2024-12-13');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (185, 97, 'logan04@yahoo.com', 1, '2020-06-18');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (186, 97, 'ericwilliams@gmail.com', 0, '2022-11-16');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (187, 98, 'qgarcia@yahoo.com', 1, '2020-02-25');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (188, 98, 'jodi99@gmail.com', 0, '2021-06-02');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (189, 98, 'mendozadarin@robinson.com', 0, '2024-11-01');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (190, 99, 'emily48@yahoo.com', 1, '2022-01-04');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (191, 100, 'johnsonkatrina@mathis.com', 1, '2021-03-03');
INSERT INTO AdminEmails (EmailID, AdminID, Email, IsPrimary, DateAdded) VALUES (192, 100, 'lmoore@gmail.com', 0, '2020-01-17');


-- DESTINATION TABLE DATA 
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (1, 'Paris', 'Capital city of France, known for its art, fashion, and culture.', 'France', 'Europe', '2021-07-10');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (2, 'Tokyo', 'The capital of Japan, known for its bustling metropolitan atmosphere and historical temples.', 'Japan', 'Asia', '2022-01-14');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (3, 'New York', 'Known as "The Big Apple", a global hub for finance, arts, and culture.', 'USA', 'North America', '2025-01-15');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (4, 'Sydney', 'Famous for its Opera House and Harbour Bridge, located in Australia.', 'Australia', 'Oceania', '2023-10-29');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (5, 'London', 'The capital of the United Kingdom, with rich history and iconic landmarks like the Big Ben and Buckingham Palace.', 'United Kingdom', 'Europe', '2025-04-04');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (6, 'Berlin', 'Germany’s capital, known for its modern art, history, and vibrant culture.', 'Germany', 'Europe', '2021-08-12');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (7, 'Rome', 'Capital of Italy, famous for its ancient history, including the Colosseum and Vatican City.', 'Italy', 'Europe', '2020-08-16');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (8, 'Cape Town', 'A major city in South Africa, known for its stunning beaches and Table Mountain.', 'South Africa', 'Africa', '2022-08-30');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (9, 'Dubai', 'A modern city in the UAE known for its luxury shopping, ultramodern architecture, and lively nightlife.', 'United Arab Emirates', 'Asia', '2024-12-21');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (10, 'Bangkok', 'Capital of Thailand, known for its vibrant street life, temples, and nightlife.', 'Thailand', 'Asia', '2023-08-30');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (11, 'Barcelona', 'Located in Spain, known for its unique architecture and cultural heritage.', 'Spain', 'Europe', '2022-10-31');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (12, 'Cairo', 'The capital of Egypt, home to the Great Pyramids and the Sphinx.', 'Egypt', 'Africa', '2022-04-12');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (13, 'Toronto', 'The largest city in Canada, known for its modern architecture and diverse culture.', 'Canada', 'North America', '2020-11-06');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (14, 'Moscow', 'The capital of Russia, rich in history and culture, home to landmarks like the Kremlin and Red Square.', 'Russia', 'Europe', '2020-07-19');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (15, 'Los Angeles', 'Known for its entertainment industry, including Hollywood and beautiful beaches.', 'USA', 'North America', '2024-02-28');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (16, 'Singapore', 'A small city-state in Southeast Asia, known for its cleanliness, shopping, and culinary experiences.', 'Singapore', 'Asia', '2021-11-22');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (17, 'Athens', 'The capital of Greece, famous for its ancient monuments and artworks.', 'Greece', 'Europe', '2021-02-05');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (18, 'Istanbul', 'A transcontinental city in Turkey, blending modern culture with historic architecture.', 'Turkey', 'Asia/Europe', '2023-01-20');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (19, 'Madrid', 'Capital of Spain, known for its royal palaces and art museums.', 'Spain', 'Europe', '2022-01-02');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (20, 'Lagos', 'A bustling city in Nigeria, known for its nightlife, markets, and art scene.', 'Nigeria', 'Africa', '2023-01-19');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (21, 'Dubai', 'A futuristic city with iconic landmarks, world-class shopping, and luxury hotels.', 'United Arab Emirates', 'Asia', '2022-07-20');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (22, 'Buenos Aires', 'Capital of Argentina, famous for its European-style architecture and tango music.', 'Argentina', 'South America', '2022-05-08');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (23, 'Lima', 'The capital city of Peru, home to the Inca civilization and rich history.', 'Peru', 'South America', '2021-04-29');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (24, 'Sydney', 'Famous for its Opera House, beaches, and outdoor lifestyle.', 'Australia', 'Oceania', '2021-05-28');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (25, 'Zurich', 'The largest city in Switzerland, known for its banking industry, cleanliness, and stunning landscapes.', 'Switzerland', 'Europe', '2021-03-07');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (26, 'Rome', 'City with millennia of history, famous for its ruins, Vatican, and Roman architecture.', 'Italy', 'Europe', '2021-11-30');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (27, 'Bangkok', 'Capital of Thailand, known for its temples, street food, and vibrant atmosphere.', 'Thailand', 'Asia', '2022-10-07');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (28, 'Mumbai', 'The financial capital of India, famous for its film industry (Bollywood).', 'India', 'Asia', '2021-08-30');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (29, 'New Delhi', 'Capital of India, rich in history and landmarks like the Red Fort and India Gate.', 'India', 'Asia', '2022-09-01');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (30, 'Berlin', 'Known for its modernist architecture, art scene, and vibrant history.', 'Germany', 'Europe', '2024-08-03');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (31, 'Marrakech', 'A city in Morocco known for its vibrant souks, historic palaces, and rich culture.', 'Morocco', 'Africa', '2023-04-17');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (32, 'Kyoto', 'Famous for its classical Buddhist temples, gardens, and traditional wooden houses.', 'Japan', 'Asia', '2020-03-18');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (33, 'Rio de Janeiro', 'Known for its stunning beaches, Carnival, and the famous Christ the Redeemer statue.', 'Brazil', 'South America', '2023-05-27');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (34, 'Cape Town', 'Located in South Africa, famous for its breathtaking scenery and rich history.', 'South Africa', 'Africa', '2024-06-22');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (35, 'Amsterdam', 'Known for its canals, museums, and cycling culture.', 'Netherlands', 'Europe', '2024-08-10');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (36, 'Cairo', 'Capital of Egypt, home to the Great Pyramids and the Sphinx, with rich ancient history.', 'Egypt', 'Africa', '2021-07-04');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (37, 'Seoul', 'The capital of South Korea, known for its mix of modern and traditional architecture.', 'South Korea', 'Asia', '2020-05-24');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (38, 'San Francisco', 'Known for its iconic Golden Gate Bridge, steep hills, and tech scene.', 'USA', 'North America', '2023-12-31');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (39, 'Istanbul', 'A transcontinental city in Turkey, blending European and Asian cultures with rich history.', 'Turkey', 'Asia/Europe', '2021-09-30');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (40, 'Vancouver', 'A Canadian city known for its beautiful natural surroundings and outdoor lifestyle.', 'Canada', 'North America', '2023-03-04');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (41, 'Lisbon', 'Capital of Portugal, known for its cobbled streets, stunning viewpoints, and seafood.', 'Portugal', 'Europe', '2024-09-14');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (42, 'Hong Kong', 'A vibrant city known for its skyline, harbor, and rich cultural heritage.', 'China', 'Asia', '2023-06-17');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (43, 'Mumbai', 'India’s financial capital, famous for Bollywood, the Gateway of India, and its cuisine.', 'India', 'Asia', '2024-08-02');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (44, 'Montreal', 'A bilingual Canadian city known for its French influence, festivals, and food.', 'Canada', 'North America', '2021-10-07');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (45, 'Buenos Aires', 'The capital of Argentina, known for its European-style architecture and tango music.', 'Argentina', 'South America', '2025-01-04');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (46, 'Athens', 'Famous for its ancient landmarks such as the Acropolis and Parthenon.', 'Greece', 'Europe', '2022-08-16');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (47, 'Vienna', 'The capital of Austria, known for its imperial palaces, art, and classical music scene.', 'Austria', 'Europe', '2022-01-25');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (48, 'Stockholm', 'The capital of Sweden, known for its archipelago and historical buildings.', 'Sweden', 'Europe', '2024-11-27');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (49, 'Dubai', 'Known for its luxury shopping, futuristic skyscrapers, and desert safaris.', 'United Arab Emirates', 'Asia', '2022-09-27');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (50, 'Quebec City', 'A charming Canadian city, known for its European-style architecture and historic Old Town.', 'Canada', 'North America', '2023-02-06');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (51, 'Lagos', 'A coastal city in Nigeria, known for its vibrant markets and beautiful beaches.', 'Nigeria', 'Africa', '2023-01-18');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (52, 'Rio de Janeiro', 'Brazilian city known for its spectacular beaches, Christ the Redeemer statue, and Carnival.', 'Brazil', 'South America', '2022-11-16');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (53, 'Los Angeles', 'Known for Hollywood, beaches, and a center of entertainment and technology.', 'USA', 'North America', '2020-09-08');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (54, 'Dubai', 'A city known for its skyscrapers, luxury hotels, and world-class shopping.', 'United Arab Emirates', 'Asia', '2021-05-22');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (55, 'Moscow', 'Capital of Russia, known for its grand architecture, Red Square, and Kremlin.', 'Russia', 'Europe', '2024-12-12');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (56, 'Singapore', 'A clean, efficient city-state known for its futuristic architecture, gardens, and multiculturalism.', 'Singapore', 'Asia', '2022-05-27');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (57, 'Bali', 'A tropical island in Indonesia, known for its beaches, rice terraces, and temples.', 'Indonesia', 'Asia', '2022-11-06');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (58, 'Tulum', 'A resort town in Mexico known for its beautiful beaches and ancient Mayan ruins.', 'Mexico', 'North America', '2023-05-15');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (59, 'Prague', 'Known for its medieval architecture, beautiful squares, and old-world charm.', 'Czech Republic', 'Europe', '2021-04-26');
INSERT INTO Destination (DestinationID, Name, Description, Country, Region, DateAdded) VALUES (60, 'Dubai', 'Famous for luxury, shopping, and modern architecture including the Burj Khalifa.', 'United Arab Emirates', 'Asia', '2021-10-28');


-- HOTEL SERVICE PROVIDER TABLE DATA
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (1, 'Pruitt, Maddox and Thomas', 1.24, 'Accommodation/Hotel', 'melanie80@miller-carter.com', 'Hotel professor international safe nearly get reveal decide.', 17.0, '2021-11-24');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (2, 'Leach, Bruce and Randolph', 2.29, 'Transport', 'mark13@gmail.com', 'Including clearly how wall.', NULL, '2020-05-26');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (3, 'Pena and Sons', 3.04, 'Tour Guides', 'jasmineguerrero@russell.com', 'This seven family position.', NULL, '2020-03-25');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (4, 'Olson and Sons', 1.8, 'Tour Guides', 'ernest25@rogers-johnson.com', 'Staff actually sit professional season organization party.', NULL, '2022-12-19');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (5, 'Henry-Fischer', 2.49, 'Accommodation/Hotel', 'stacyjohnson@wilson-sharp.com', 'Direction hit night argue network instead.', 60.0, '2020-06-23');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (6, 'Yang, Johnson and Stout', 4.05, 'Accommodation/Hotel', 'paul72@yahoo.com', 'Process these ask military war.', 72.0, '2024-12-10');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (7, 'Robinson Group', 4.56, 'Accommodation/Hotel', 'christopherfoster@martinez.net', 'Thing miss week word on second wind.', 44.0, '2024-11-14');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (8, 'Johnson LLC', 1.56, 'Transport', 'mhampton@gibbs.net', 'Nice teach job shoulder wish purpose answer.', NULL, '2024-07-11');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (9, 'Morgan and Sons', 2.77, 'Tour Guides', 'amy89@chung.com', 'Design magazine lead mouth amount.', NULL, '2023-04-11');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (10, 'Andrews-Vasquez', 2.15, 'Transport', 'jennifersimmons@yahoo.com', 'Impact article investment hour writer look.', NULL, '2024-10-08');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (11, 'Hahn, Lam and Mann', 3.36, 'Accommodation/Hotel', 'stephanie64@hotmail.com', 'Human next fast.', 29.0, '2024-08-12');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (12, 'Walsh-Huffman', 3.77, 'Transport', 'rsmith@donovan.com', 'Network factor key mind clearly discover traditional.', NULL, '2021-01-29');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (13, 'Kramer-Rubio', 4.62, 'Tour Guides', 'wturner@gmail.com', 'Instead former ask purpose.', NULL, '2022-06-30');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (14, 'Ward and Sons', 3.51, 'Transport', 'qmoore@coffey.com', 'Risk policy Mr nor watch.', NULL, '2022-05-17');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (15, 'Griffith, Pearson and Moore', 3.69, 'Tour Guides', 'gary09@hotmail.com', 'Something above make wall follow single mean draw.', NULL, '2023-12-04');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (16, 'Ruiz Ltd', 4.56, 'Transport', 'kimberly35@walter.com', 'Thing fly quality myself production simply culture.', NULL, '2022-03-17');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (17, 'Henry, Flores and Flores', 3.08, 'Transport', 'ialvarez@davis.com', 'Candidate will suffer its.', NULL, '2023-01-23');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (18, 'Martinez Group', 1.38, 'Accommodation/Hotel', 'mitchellmcdowell@yahoo.com', 'Discussion director various program picture environmental.', 19.0, '2024-08-15');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (19, 'Savage, Taylor and Smith', 4.09, 'Tour Guides', 'gguzman@yahoo.com', 'Itself beautiful full eight technology blue.', NULL, '2023-04-02');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (20, 'Hill Ltd', 1.65, 'Accommodation/Hotel', 'icox@holmes.info', 'Notice girl behind popular decision.', 51.0, '2021-08-15');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (21, 'Williams-Luna', 3.51, 'Transport', 'nhughes@white.com', 'Young school product.', NULL, '2024-02-23');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (22, 'Romero-Villegas', 3.28, 'Accommodation/Hotel', 'benjamin05@hill-martinez.com', 'Scene year back language study build prevent.', 89.0, '2023-12-13');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (23, 'Stevens, Garrett and Taylor', 4.81, 'Tour Guides', 'carla10@pham.com', 'Relate majority challenge treatment majority section sing.', NULL, '2022-01-08');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (24, 'Gross, Smith and Nelson', 4.8, 'Tour Guides', 'frances75@kennedy.com', 'Among writer national share across fish.', NULL, '2020-01-11');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (25, 'Rodriguez, Flores and Cole', 4.33, 'Accommodation/Hotel', 'joshua24@montes-sherman.com', 'Apply to find fight production race age item.', 25.0, '2024-03-21');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (26, 'Torres, Bird and Cook', 3.96, 'Transport', 'perezkathryn@hotmail.com', 'Finish seem order ball.', NULL, '2022-12-06');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (27, 'Goodwin Ltd', 3.26, 'Transport', 'zharris@gmail.com', 'Hundred music drive true own floor.', NULL, '2023-03-24');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (28, 'Hopkins PLC', 4.29, 'Tour Guides', 'nathanielhall@hoffman.com', 'Store store true end decide writer decision.', NULL, '2024-01-23');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (29, 'Decker-Gilbert', 3.42, 'Accommodation/Hotel', 'watsondenise@li.com', 'Step war power discover that drive.', 1.0, '2023-06-29');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (30, 'Ramos-Montgomery', 2.9, 'Tour Guides', 'vanessasalazar@yahoo.com', 'Close throughout feeling glass lay.', NULL, '2024-06-26');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (31, 'Lester-Cummings', 1.21, 'Transport', 'gwendolynramos@moore.com', 'Later science American radio score manage we.', NULL, '2021-01-26');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (32, 'Cunningham LLC', 1.16, 'Transport', 'jennifer70@yahoo.com', 'Stand through positive high Democrat.', NULL, '2021-11-20');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (33, 'Smith Group', 2.03, 'Transport', 'kristin99@gmail.com', 'Nature others main different chance citizen financial produce.', NULL, '2023-11-13');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (34, 'Vasquez and Sons', 3.19, 'Tour Guides', 'allenmary@yahoo.com', 'Us born each strategy but.', NULL, '2023-07-30');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (35, 'Ortega-Barnett', 1.77, 'Accommodation/Hotel', 'davidmcintosh@montoya-thomas.info', 'Affect meet argue himself agree recognize away right.', 91.0, '2025-03-03');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (36, 'Davis Group', 2.65, 'Tour Guides', 'beckerdaniel@ford-woods.com', 'Move since might fact military.', NULL, '2022-10-02');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (37, 'Rose Group', 1.82, 'Accommodation/Hotel', 'xsmith@gmail.com', 'Turn likely upon business ten could teach.', 54.0, '2021-02-24');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (38, 'Griffith, Henderson and Sparks', 4.19, 'Tour Guides', 'rkidd@yahoo.com', 'Player agreement have week across between though.', NULL, '2022-10-10');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (39, 'Greer-Rocha', 1.83, 'Tour Guides', 'jeffreydelacruz@gmail.com', 'Everything government meet check show hear rich.', NULL, '2022-10-22');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (40, 'Hess-Davis', 1.04, 'Tour Guides', 'eric60@carrillo-martinez.com', 'Already better each lead.', NULL, '2020-06-27');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (41, 'Jones-Glover', 4.44, 'Transport', 'tranmarcia@gmail.com', 'Degree his sport then analysis.', NULL, '2021-06-20');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (42, 'Johnson-Hamilton', 3.42, 'Tour Guides', 'echambers@hotmail.com', 'She song star evening.', NULL, '2023-04-29');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (43, 'Stevens, Owens and Richards', 4.89, 'Transport', 'johncooley@peterson.com', 'Model join before ready.', NULL, '2022-09-05');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (44, 'Wilson, Green and Watkins', 3.72, 'Transport', 'jessicarodriguez@murphy.com', 'Toward area until sure.', NULL, '2024-08-06');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (45, 'Russell Ltd', 4.38, 'Transport', 'mjohnson@newman.com', 'Finally various sport at state.', NULL, '2023-01-03');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (46, 'Morrison, Dixon and Owens', 3.72, 'Transport', 'hcalderon@hotmail.com', 'Friend economy reduce as amount.', NULL, '2020-01-16');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (47, 'Hunter, Hardy and Bailey', 1.21, 'Transport', 'andreamclean@yahoo.com', 'Role fear subject executive right rate two.', NULL, '2024-05-01');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (48, 'Smith-Perry', 4.02, 'Transport', 'thomasjones@hotmail.com', 'Buy fill like food whatever win.', NULL, '2024-02-19');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (49, 'Foley, Sanders and Gonzales', 2.08, 'Accommodation/Hotel', 'paynestephanie@yahoo.com', 'Identify hope he establish man.', 88.0, '2024-09-19');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (50, 'Crawford Group', 2.96, 'Accommodation/Hotel', 'qpage@garcia.com', 'Number degree interest.', 59.0, '2020-08-21');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (51, 'Vasquez, Harris and Rogers', 4.29, 'Accommodation/Hotel', 'jonesaaron@atkins.com', 'Somebody executive mean look score.', 11.0, '2023-09-30');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (52, 'Robertson, Rodriguez and Kaiser', 3.66, 'Accommodation/Hotel', 'mary25@hunter-marquez.net', 'Well name both will.', 40.0, '2024-06-10');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (53, 'Torres-Brown', 2.08, 'Accommodation/Hotel', 'duncanjoseph@flores.biz', 'Receive look seven page available its.', 11.0, '2021-05-10');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (54, 'Francis, Evans and Green', 4.94, 'Accommodation/Hotel', 'matthewsmith@robinson-lyons.net', 'Today maintain other yet.', 1.0, '2023-04-28');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (55, 'Gillespie, Macdonald and Knight', 3.36, 'Accommodation/Hotel', 'kalexander@nguyen.org', 'Thousand almost bring well break.', 23.0, '2024-12-11');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (56, 'Carpenter Ltd', 3.23, 'Accommodation/Hotel', 'goodwinmarc@proctor.com', 'On check radio less card article public.', 58.0, '2022-05-14');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (57, 'Fletcher, Gross and Walker', 2.63, 'Tour Guides', 'richardcantu@hotmail.com', 'Inside play discussion end owner.', NULL, '2024-02-16');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (58, 'Decker LLC', 2.47, 'Tour Guides', 'lindsey63@yahoo.com', 'Sound pass guy require bar.', NULL, '2022-10-01');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (59, 'Small, Barry and Summers', 1.55, 'Tour Guides', 'abaker@gmail.com', 'Hour next face father senior watch.', NULL, '2025-02-22');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (60, 'Baker, Gonzalez and Patterson', 1.89, 'Transport', 'anthony50@gill.com', 'Force century forget body federal dog make.', NULL, '2025-02-25');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (61, 'Lawrence LLC', 1.91, 'Transport', 'nramirez@hotmail.com', 'Far daughter either just.', NULL, '2023-03-11');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (62, 'Clark Inc', 4.92, 'Accommodation/Hotel', 'michael39@mills.info', 'Also among actually.', 65.0, '2024-11-06');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (63, 'Schmidt-Massey', 2.66, 'Tour Guides', 'maria14@hotmail.com', 'Hit old make skin.', NULL, '2025-01-09');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (64, 'Lopez, Butler and Turner', 3.65, 'Transport', 'leejimmy@hotmail.com', 'Better seek loss.', NULL, '2021-04-21');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (65, 'Becker, Soto and Sherman', 3.91, 'Transport', 'richardlopez@garza.com', 'Culture cultural even available whom.', NULL, '2021-03-04');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (66, 'Foster, Barton and Thomas', 3.45, 'Accommodation/Hotel', 'denise50@burch-lawrence.com', 'Health citizen two late.', 36.0, '2025-01-13');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (67, 'Walton, Nelson and Gordon', 1.9, 'Tour Guides', 'angelawilliams@klein.com', 'Leader space stay check.', NULL, '2024-07-25');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (68, 'Dudley, Patrick and Mayo', 4.77, 'Transport', 'dodsonalexis@perez-garcia.com', 'Close production drop of show.', NULL, '2020-09-24');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (69, 'Bishop-Mitchell', 1.72, 'Tour Guides', 'wthomas@yahoo.com', 'There four blue any professional certain model.', NULL, '2023-12-20');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (70, 'Reeves-Hill', 3.63, 'Tour Guides', 'shannontorres@nelson-rogers.com', 'Service building cultural career health member.', NULL, '2020-05-20');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (71, 'Tran, Scott and Boyd', 1.61, 'Tour Guides', 'thomasholloway@yahoo.com', 'Responsibility TV professional this amount discover.', NULL, '2022-07-01');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (72, 'Frazier Group', 2.41, 'Accommodation/Hotel', 'lewisashley@yahoo.com', 'Television defense pull image foot fly other.', 9.0, '2024-02-21');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (73, 'Moreno, Taylor and Ford', 3.94, 'Accommodation/Hotel', 'catherine07@hamilton.com', 'No research change four despite more.', 14.0, '2023-07-12');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (74, 'Jackson, Gill and Riddle', 4.82, 'Tour Guides', 'normantrevor@hotmail.com', 'Guess usually remain material pick tend specific car.', NULL, '2023-03-09');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (75, 'Rodriguez Ltd', 4.59, 'Accommodation/Hotel', 'jromero@hotmail.com', 'Law receive get while wind drop behind.', 40.0, '2020-04-05');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (76, 'Hunter-Meza', 2.23, 'Tour Guides', 'reyeszachary@smith-solis.com', 'Nation court professional natural.', NULL, '2020-10-04');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (77, 'Fisher, Key and Snyder', 3.68, 'Accommodation/Hotel', 'bridgesmelissa@yahoo.com', 'Dream car home consumer raise.', 54.0, '2021-11-01');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (78, 'Lee-Daniels', 4.09, 'Tour Guides', 'lydia20@brooks-rice.com', 'Matter dark head anyone tonight full baby bar.', NULL, '2020-09-27');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (79, 'Morrison-Clark', 4.17, 'Transport', 'angela68@hotmail.com', 'Speak down democratic at Mr purpose man.', NULL, '2024-04-05');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (80, 'Sandoval Inc', 4.27, 'Tour Guides', 'gabriel99@cardenas.com', 'Sure body stuff cell thousand still yet simple.', NULL, '2024-06-17');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (81, 'Valentine-Duncan', 2.43, 'Tour Guides', 'thomas72@hotmail.com', 'Suffer lead ask general subject.', NULL, '2023-10-25');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (82, 'Gonzalez, Ortiz and Torres', 3.39, 'Accommodation/Hotel', 'shannon94@yahoo.com', 'Town far plan analysis.', 22.0, '2023-05-06');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (83, 'French, Wilson and Clements', 2.17, 'Tour Guides', 'dwayne11@hotmail.com', 'Guess instead machine range girl write information.', NULL, '2023-05-04');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (84, 'Brewer and Sons', 1.22, 'Tour Guides', 'baileychan@faulkner.com', 'Executive food instead buy most born hit.', NULL, '2021-09-05');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (85, 'Moore-Anderson', 2.19, 'Accommodation/Hotel', 'emueller@yahoo.com', 'Hear situation class war.', 64.0, '2023-01-12');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (86, 'Rojas and Sons', 2.7, 'Tour Guides', 'twatson@gmail.com', 'A pick leg soon get face.', NULL, '2020-09-18');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (87, 'Cordova, Ross and Huerta', 4.67, 'Tour Guides', 'costajesse@gmail.com', 'Available kid themselves usually way.', NULL, '2024-12-20');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (88, 'Vargas, Zamora and Chapman', 2.88, 'Transport', 'cgreen@gonzalez.com', 'According candidate finish half.', NULL, '2023-09-05');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (89, 'Martinez, Williams and Duke', 3.77, 'Transport', 'nmorgan@rios-floyd.org', 'Management cold especially care spend.', NULL, '2024-01-22');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (90, 'Hammond-Hammond', 1.74, 'Tour Guides', 'rodriguezcynthia@green.com', 'Authority what ok.', NULL, '2021-03-13');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (91, 'Henry-Jones', 3.18, 'Accommodation/Hotel', 'edwardhowe@hotmail.com', 'Such all our eye walk soon.', 55.0, '2023-07-23');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (92, 'Kerr-Long', 4.48, 'Tour Guides', 'williamstara@patel-cooper.com', 'Operation live institution.', NULL, '2023-06-28');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (93, 'Smith-Malone', 1.94, 'Tour Guides', 'nwhite@johnson.com', 'You financial take deep around.', NULL, '2024-07-08');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (94, 'Crawford, Jones and Washington', 3.45, 'Transport', 'jessicawilliams@yahoo.com', 'Him land good movie down around near decade.', NULL, '2020-05-17');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (95, 'Scott-Ramirez', 1.79, 'Transport', 'thomasjonathan@hotmail.com', 'Current east imagine.', NULL, '2021-08-06');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (96, 'Jones, Herrera and Black', 2.33, 'Transport', 'tiffany46@johnson.info', 'Game relate you deep.', NULL, '2022-02-17');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (97, 'Bradshaw Inc', 2.18, 'Accommodation/Hotel', 'danielhardy@gmail.com', 'Party share old.', 78.0, '2023-11-06');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (98, 'Kelly and Sons', 4.76, 'Accommodation/Hotel', 'nicole51@perez.com', 'Approach form school player.', 81.0, '2020-09-18');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (99, 'Bowen Inc', 1.3, 'Accommodation/Hotel', 'jeffery06@gmail.com', 'Film mission event free would still according run.', 95.0, '2021-05-25');
INSERT INTO HotelServiceProvider (ServiceProviderID, ProviderName, ServiceRatings, ProviderType, ContactInfo, ServiceDetails, AvailableRooms, DateRegistered) VALUES (100, 'Johnson, Shaffer and Perez', 4.61, 'Accommodation/Hotel', 'brownkevin@hotmail.com', 'Former hold born memory push Democrat.', 45.0, '2021-02-07');



UPDATE HotelServiceProvider SET Password = 'Password1!' WHERE ServiceProviderID = 1;
UPDATE HotelServiceProvider SET Password = 'SecurePass2!' WHERE ServiceProviderID = 2;
UPDATE HotelServiceProvider SET Password = 'TourGuidePass3!' WHERE ServiceProviderID = 3;
UPDATE HotelServiceProvider SET Password = 'Staff123!' WHERE ServiceProviderID = 4;
UPDATE HotelServiceProvider SET Password = 'HotelPass456!' WHERE ServiceProviderID = 5;
UPDATE HotelServiceProvider SET Password = 'HotelMaster7!' WHERE ServiceProviderID = 6;
UPDATE HotelServiceProvider SET Password = 'RobinsonPass8!' WHERE ServiceProviderID = 7;
UPDATE HotelServiceProvider SET Password = 'SecureTransport9!' WHERE ServiceProviderID = 8;
UPDATE HotelServiceProvider SET Password = 'DesignLead10!' WHERE ServiceProviderID = 9;
UPDATE HotelServiceProvider SET Password = 'InvestmentHour11!' WHERE ServiceProviderID = 10;
UPDATE HotelServiceProvider SET Password = 'FastHuman12!' WHERE ServiceProviderID = 11;
UPDATE HotelServiceProvider SET Password = 'KeyMind13!' WHERE ServiceProviderID = 12;
UPDATE HotelServiceProvider SET Password = 'FormerAsk14!' WHERE ServiceProviderID = 13;
UPDATE HotelServiceProvider SET Password = 'RiskPolicy15!' WHERE ServiceProviderID = 14;
UPDATE HotelServiceProvider SET Password = 'SingleDraw16!' WHERE ServiceProviderID = 15;
UPDATE HotelServiceProvider SET Password = 'FlyQuality17!' WHERE ServiceProviderID = 16;
UPDATE HotelServiceProvider SET Password = 'SufferIts18!' WHERE ServiceProviderID = 17;
UPDATE HotelServiceProvider SET Password = 'Discussion19!' WHERE ServiceProviderID = 18;
UPDATE HotelServiceProvider SET Password = 'FullTechnology20!' WHERE ServiceProviderID = 19;
UPDATE HotelServiceProvider SET Password = 'GirlDecision21!' WHERE ServiceProviderID = 20;
UPDATE HotelServiceProvider SET Password = 'value1!strong' WHERE ServiceProviderID = 21;
UPDATE HotelServiceProvider SET Password = 'value2!strong' WHERE ServiceProviderID = 22;
UPDATE HotelServiceProvider SET Password = 'value3!strong' WHERE ServiceProviderID = 23;
UPDATE HotelServiceProvider SET Password = 'value4!strong' WHERE ServiceProviderID = 24;
UPDATE HotelServiceProvider SET Password = 'value5!strong' WHERE ServiceProviderID = 25;
UPDATE HotelServiceProvider SET Password = 'value6!strong' WHERE ServiceProviderID = 26;
UPDATE HotelServiceProvider SET Password = 'value7!strong' WHERE ServiceProviderID = 27;
UPDATE HotelServiceProvider SET Password = 'value8!strong' WHERE ServiceProviderID = 28;
UPDATE HotelServiceProvider SET Password = 'value9!strong' WHERE ServiceProviderID = 29;
UPDATE HotelServiceProvider SET Password = 'value10!strong' WHERE ServiceProviderID = 30;
UPDATE HotelServiceProvider SET Password = 'value11!strong' WHERE ServiceProviderID = 31;
UPDATE HotelServiceProvider SET Password = 'value12!strong' WHERE ServiceProviderID = 32;
UPDATE HotelServiceProvider SET Password = 'value13!strong' WHERE ServiceProviderID = 33;
UPDATE HotelServiceProvider SET Password = 'value14!strong' WHERE ServiceProviderID = 34;
UPDATE HotelServiceProvider SET Password = 'value15!strong' WHERE ServiceProviderID = 35;
UPDATE HotelServiceProvider SET Password = 'value16!strong' WHERE ServiceProviderID = 36;
UPDATE HotelServiceProvider SET Password = 'value17!strong' WHERE ServiceProviderID = 37;
UPDATE HotelServiceProvider SET Password = 'value18!strong' WHERE ServiceProviderID = 38;
UPDATE HotelServiceProvider SET Password = 'value19!strong' WHERE ServiceProviderID = 39;
UPDATE HotelServiceProvider SET Password = 'value20!strong' WHERE ServiceProviderID = 40;
UPDATE HotelServiceProvider SET Password = 'value21!strong' WHERE ServiceProviderID = 41;
UPDATE HotelServiceProvider SET Password = 'value22!strong' WHERE ServiceProviderID = 42;
UPDATE HotelServiceProvider SET Password = 'value23!strong' WHERE ServiceProviderID = 43;
UPDATE HotelServiceProvider SET Password = 'value24!strong' WHERE ServiceProviderID = 44;
UPDATE HotelServiceProvider SET Password = 'value25!strong' WHERE ServiceProviderID = 45;
UPDATE HotelServiceProvider SET Password = 'value26!strong' WHERE ServiceProviderID = 46;
UPDATE HotelServiceProvider SET Password = 'value27!strong' WHERE ServiceProviderID = 47;
UPDATE HotelServiceProvider SET Password = 'value28!strong' WHERE ServiceProviderID = 48;
UPDATE HotelServiceProvider SET Password = 'value29!strong' WHERE ServiceProviderID = 49;
UPDATE HotelServiceProvider SET Password = 'value30!strong' WHERE ServiceProviderID = 50;
UPDATE HotelServiceProvider SET Password = 'value31!strong' WHERE ServiceProviderID = 51;
UPDATE HotelServiceProvider SET Password = 'value32!strong' WHERE ServiceProviderID = 52;
UPDATE HotelServiceProvider SET Password = 'value33!strong' WHERE ServiceProviderID = 53;
UPDATE HotelServiceProvider SET Password = 'value34!strong' WHERE ServiceProviderID = 54;
UPDATE HotelServiceProvider SET Password = 'value35!strong' WHERE ServiceProviderID = 55;
UPDATE HotelServiceProvider SET Password = 'value36!strong' WHERE ServiceProviderID = 56;
UPDATE HotelServiceProvider SET Password = 'value37!strong' WHERE ServiceProviderID = 57;
UPDATE HotelServiceProvider SET Password = 'value38!strong' WHERE ServiceProviderID = 58;
UPDATE HotelServiceProvider SET Password = 'value59!strong' WHERE ServiceProviderID = 59;
UPDATE HotelServiceProvider SET Password = 'value60!strong' WHERE ServiceProviderID = 60;
UPDATE HotelServiceProvider SET Password = 'value61!strong' WHERE ServiceProviderID = 61;
UPDATE HotelServiceProvider SET Password = 'value62!strong' WHERE ServiceProviderID = 62;
UPDATE HotelServiceProvider SET Password = 'value63!strong' WHERE ServiceProviderID = 63;
UPDATE HotelServiceProvider SET Password = 'value64!strong' WHERE ServiceProviderID = 64;
UPDATE HotelServiceProvider SET Password = 'value65!strong' WHERE ServiceProviderID = 65;
UPDATE HotelServiceProvider SET Password = 'value66!strong' WHERE ServiceProviderID = 66;
UPDATE HotelServiceProvider SET Password = 'value67!strong' WHERE ServiceProviderID = 67;
UPDATE HotelServiceProvider SET Password = 'value68!strong' WHERE ServiceProviderID = 68;
UPDATE HotelServiceProvider SET Password = 'value69!strong' WHERE ServiceProviderID = 69;
UPDATE HotelServiceProvider SET Password = 'value70!strong' WHERE ServiceProviderID = 70;
UPDATE HotelServiceProvider SET Password = 'value71!strong' WHERE ServiceProviderID = 71;
UPDATE HotelServiceProvider SET Password = 'value72!strong' WHERE ServiceProviderID = 72;
UPDATE HotelServiceProvider SET Password = 'value73!strong' WHERE ServiceProviderID = 73;
UPDATE HotelServiceProvider SET Password = 'value74!strong' WHERE ServiceProviderID = 74;
UPDATE HotelServiceProvider SET Password = 'value75!strong' WHERE ServiceProviderID = 75;
UPDATE HotelServiceProvider SET Password = 'value76!strong' WHERE ServiceProviderID = 76;
UPDATE HotelServiceProvider SET Password = 'value77!strong' WHERE ServiceProviderID = 77;
UPDATE HotelServiceProvider SET Password = 'value78!strong' WHERE ServiceProviderID = 78;
UPDATE HotelServiceProvider SET Password = 'value79!strong' WHERE ServiceProviderID = 79;
UPDATE HotelServiceProvider SET Password = 'value80!strong' WHERE ServiceProviderID = 80;
UPDATE HotelServiceProvider SET Password = 'value81!strong' WHERE ServiceProviderID = 81;
UPDATE HotelServiceProvider SET Password = 'value82!strong' WHERE ServiceProviderID = 82;
UPDATE HotelServiceProvider SET Password = 'value83!strong' WHERE ServiceProviderID = 83;
UPDATE HotelServiceProvider SET Password = 'value84!strong' WHERE ServiceProviderID = 84;
UPDATE HotelServiceProvider SET Password = 'value85!strong' WHERE ServiceProviderID = 85;
UPDATE HotelServiceProvider SET Password = 'value86!strong' WHERE ServiceProviderID = 86;
UPDATE HotelServiceProvider SET Password = 'value87!strong' WHERE ServiceProviderID = 87;
UPDATE HotelServiceProvider SET Password = 'value88!strong' WHERE ServiceProviderID = 88;
UPDATE HotelServiceProvider SET Password = 'value89!strong' WHERE ServiceProviderID = 89;
UPDATE HotelServiceProvider SET Password = 'value90!strong' WHERE ServiceProviderID = 90;
UPDATE HotelServiceProvider SET Password = 'value91!strong' WHERE ServiceProviderID = 91;
UPDATE HotelServiceProvider SET Password = 'value92!strong' WHERE ServiceProviderID = 92;
UPDATE HotelServiceProvider SET Password = 'value93!strong' WHERE ServiceProviderID = 93;
UPDATE HotelServiceProvider SET Password = 'value94!strong' WHERE ServiceProviderID = 94;
UPDATE HotelServiceProvider SET Password = 'value95!strong' WHERE ServiceProviderID = 95;
UPDATE HotelServiceProvider SET Password = 'value96!strong' WHERE ServiceProviderID = 96;
UPDATE HotelServiceProvider SET Password = 'value97!strong' WHERE ServiceProviderID = 97;
UPDATE HotelServiceProvider SET Password = 'value98!strong' WHERE ServiceProviderID = 98;
UPDATE HotelServiceProvider SET Password = 'value99!strong' WHERE ServiceProviderID = 99;
UPDATE HotelServiceProvider SET Password = 'value100!strong' WHERE ServiceProviderID = 100;


ALTER TABLE HotelServiceProvider
ADD Charges DECIMAL(10, 2);


UPDATE HotelServiceProvider SET Charges = 50.00 WHERE ServiceProviderID = 1;
UPDATE HotelServiceProvider SET Charges = 60.00 WHERE ServiceProviderID = 2;
UPDATE HotelServiceProvider SET Charges = 70.00 WHERE ServiceProviderID = 3;
UPDATE HotelServiceProvider SET Charges = 80.00 WHERE ServiceProviderID = 4;
UPDATE HotelServiceProvider SET Charges = 90.00 WHERE ServiceProviderID = 5;
UPDATE HotelServiceProvider SET Charges = 100.00 WHERE ServiceProviderID = 6;
UPDATE HotelServiceProvider SET Charges = 110.00 WHERE ServiceProviderID = 7;
UPDATE HotelServiceProvider SET Charges = 120.00 WHERE ServiceProviderID = 8;
UPDATE HotelServiceProvider SET Charges = 130.00 WHERE ServiceProviderID = 9;
UPDATE HotelServiceProvider SET Charges = 140.00 WHERE ServiceProviderID = 10;

UPDATE HotelServiceProvider SET Charges = 150.00 WHERE ServiceProviderID = 11;
UPDATE HotelServiceProvider SET Charges = 160.00 WHERE ServiceProviderID = 12;
UPDATE HotelServiceProvider SET Charges = 170.00 WHERE ServiceProviderID = 13;
UPDATE HotelServiceProvider SET Charges = 180.00 WHERE ServiceProviderID = 14;
UPDATE HotelServiceProvider SET Charges = 190.00 WHERE ServiceProviderID = 15;
UPDATE HotelServiceProvider SET Charges = 200.00 WHERE ServiceProviderID = 16;
UPDATE HotelServiceProvider SET Charges = 210.00 WHERE ServiceProviderID = 17;
UPDATE HotelServiceProvider SET Charges = 220.00 WHERE ServiceProviderID = 18;
UPDATE HotelServiceProvider SET Charges = 230.00 WHERE ServiceProviderID = 19;
UPDATE HotelServiceProvider SET Charges = 240.00 WHERE ServiceProviderID = 20;

UPDATE HotelServiceProvider SET Charges = 250.00 WHERE ServiceProviderID = 21;
UPDATE HotelServiceProvider SET Charges = 260.00 WHERE ServiceProviderID = 22;
UPDATE HotelServiceProvider SET Charges = 270.00 WHERE ServiceProviderID = 23;
UPDATE HotelServiceProvider SET Charges = 280.00 WHERE ServiceProviderID = 24;
UPDATE HotelServiceProvider SET Charges = 290.00 WHERE ServiceProviderID = 25;
UPDATE HotelServiceProvider SET Charges = 300.00 WHERE ServiceProviderID = 26;
UPDATE HotelServiceProvider SET Charges = 310.00 WHERE ServiceProviderID = 27;
UPDATE HotelServiceProvider SET Charges = 320.00 WHERE ServiceProviderID = 28;
UPDATE HotelServiceProvider SET Charges = 330.00 WHERE ServiceProviderID = 29;
UPDATE HotelServiceProvider SET Charges = 340.00 WHERE ServiceProviderID = 30;

UPDATE HotelServiceProvider SET Charges = 350.00 WHERE ServiceProviderID = 31;
UPDATE HotelServiceProvider SET Charges = 360.00 WHERE ServiceProviderID = 32;
UPDATE HotelServiceProvider SET Charges = 370.00 WHERE ServiceProviderID = 33;
UPDATE HotelServiceProvider SET Charges = 380.00 WHERE ServiceProviderID = 34;
UPDATE HotelServiceProvider SET Charges = 390.00 WHERE ServiceProviderID = 35;
UPDATE HotelServiceProvider SET Charges = 400.00 WHERE ServiceProviderID = 36;
UPDATE HotelServiceProvider SET Charges = 410.00 WHERE ServiceProviderID = 37;
UPDATE HotelServiceProvider SET Charges = 420.00 WHERE ServiceProviderID = 38;
UPDATE HotelServiceProvider SET Charges = 430.00 WHERE ServiceProviderID = 39;
UPDATE HotelServiceProvider SET Charges = 440.00 WHERE ServiceProviderID = 40;

UPDATE HotelServiceProvider SET Charges = 450.00 WHERE ServiceProviderID = 41;
UPDATE HotelServiceProvider SET Charges = 460.00 WHERE ServiceProviderID = 42;
UPDATE HotelServiceProvider SET Charges = 470.00 WHERE ServiceProviderID = 43;
UPDATE HotelServiceProvider SET Charges = 480.00 WHERE ServiceProviderID = 44;
UPDATE HotelServiceProvider SET Charges = 490.00 WHERE ServiceProviderID = 45;
UPDATE HotelServiceProvider SET Charges = 500.00 WHERE ServiceProviderID = 46;
UPDATE HotelServiceProvider SET Charges = 510.00 WHERE ServiceProviderID = 47;
UPDATE HotelServiceProvider SET Charges = 520.00 WHERE ServiceProviderID = 48;
UPDATE HotelServiceProvider SET Charges = 530.00 WHERE ServiceProviderID = 49;
UPDATE HotelServiceProvider SET Charges = 540.00 WHERE ServiceProviderID = 50;

UPDATE HotelServiceProvider SET Charges = 550.00 WHERE ServiceProviderID = 51;
UPDATE HotelServiceProvider SET Charges = 560.00 WHERE ServiceProviderID = 52;
UPDATE HotelServiceProvider SET Charges = 570.00 WHERE ServiceProviderID = 53;
UPDATE HotelServiceProvider SET Charges = 580.00 WHERE ServiceProviderID = 54;
UPDATE HotelServiceProvider SET Charges = 590.00 WHERE ServiceProviderID = 55;
UPDATE HotelServiceProvider SET Charges = 600.00 WHERE ServiceProviderID = 56;
UPDATE HotelServiceProvider SET Charges = 610.00 WHERE ServiceProviderID = 57;
UPDATE HotelServiceProvider SET Charges = 620.00 WHERE ServiceProviderID = 58;
UPDATE HotelServiceProvider SET Charges = 630.00 WHERE ServiceProviderID = 59;
UPDATE HotelServiceProvider SET Charges = 640.00 WHERE ServiceProviderID = 60;

UPDATE HotelServiceProvider SET Charges = 650.00 WHERE ServiceProviderID = 61;
UPDATE HotelServiceProvider SET Charges = 660.00 WHERE ServiceProviderID = 62;
UPDATE HotelServiceProvider SET Charges = 670.00 WHERE ServiceProviderID = 63;
UPDATE HotelServiceProvider SET Charges = 680.00 WHERE ServiceProviderID = 64;
UPDATE HotelServiceProvider SET Charges = 690.00 WHERE ServiceProviderID = 65;
UPDATE HotelServiceProvider SET Charges = 700.00 WHERE ServiceProviderID = 66;
UPDATE HotelServiceProvider SET Charges = 710.00 WHERE ServiceProviderID = 67;
UPDATE HotelServiceProvider SET Charges = 720.00 WHERE ServiceProviderID = 68;
UPDATE HotelServiceProvider SET Charges = 730.00 WHERE ServiceProviderID = 69;
UPDATE HotelServiceProvider SET Charges = 740.00 WHERE ServiceProviderID = 70;

UPDATE HotelServiceProvider SET Charges = 750.00 WHERE ServiceProviderID = 71;
UPDATE HotelServiceProvider SET Charges = 760.00 WHERE ServiceProviderID = 72;
UPDATE HotelServiceProvider SET Charges = 770.00 WHERE ServiceProviderID = 73;
UPDATE HotelServiceProvider SET Charges = 780.00 WHERE ServiceProviderID = 74;
UPDATE HotelServiceProvider SET Charges = 790.00 WHERE ServiceProviderID = 75;
UPDATE HotelServiceProvider SET Charges = 800.00 WHERE ServiceProviderID = 76;
UPDATE HotelServiceProvider SET Charges = 810.00 WHERE ServiceProviderID = 77;
UPDATE HotelServiceProvider SET Charges = 820.00 WHERE ServiceProviderID = 78;
UPDATE HotelServiceProvider SET Charges = 830.00 WHERE ServiceProviderID = 79;
UPDATE HotelServiceProvider SET Charges = 840.00 WHERE ServiceProviderID = 80;

UPDATE HotelServiceProvider SET Charges = 850.00 WHERE ServiceProviderID = 81;
UPDATE HotelServiceProvider SET Charges = 860.00 WHERE ServiceProviderID = 82;
UPDATE HotelServiceProvider SET Charges = 870.00 WHERE ServiceProviderID = 83;
UPDATE HotelServiceProvider SET Charges = 880.00 WHERE ServiceProviderID = 84;
UPDATE HotelServiceProvider SET Charges = 890.00 WHERE ServiceProviderID = 85;
UPDATE HotelServiceProvider SET Charges = 900.00 WHERE ServiceProviderID = 86;
UPDATE HotelServiceProvider SET Charges = 910.00 WHERE ServiceProviderID = 87;
UPDATE HotelServiceProvider SET Charges = 920.00 WHERE ServiceProviderID = 88;
UPDATE HotelServiceProvider SET Charges = 930.00 WHERE ServiceProviderID = 89;
UPDATE HotelServiceProvider SET Charges = 940.00 WHERE ServiceProviderID = 90;

UPDATE HotelServiceProvider SET Charges = 950.00 WHERE ServiceProviderID = 91;
UPDATE HotelServiceProvider SET Charges = 960.00 WHERE ServiceProviderID = 92;
UPDATE HotelServiceProvider SET Charges = 970.00 WHERE ServiceProviderID = 93;
UPDATE HotelServiceProvider SET Charges = 980.00 WHERE ServiceProviderID = 94;
UPDATE HotelServiceProvider SET Charges = 990.00 WHERE ServiceProviderID = 95;
UPDATE HotelServiceProvider SET Charges = 1000.00 WHERE ServiceProviderID = 96;
UPDATE HotelServiceProvider SET Charges = 1010.00 WHERE ServiceProviderID = 97;
UPDATE HotelServiceProvider SET Charges = 1020.00 WHERE ServiceProviderID = 98;
UPDATE HotelServiceProvider SET Charges = 1030.00 WHERE ServiceProviderID = 99;
UPDATE HotelServiceProvider SET Charges = 1040.00 WHERE ServiceProviderID = 100;

-- AUDIT TRAIL TABLE DATA
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (1, 'CREATE', 'ServiceProvider', '2023-05-04', 36, 'Created a new service provider record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (2, 'CREATE', 'Booking', '2022-08-02', 89, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (3, 'DELETE', 'Destination', '2021-04-17', 10, 'Deleted a destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (4, 'DELETE', 'ServiceProvider', '2024-06-18', 13, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (5, 'UPDATE', 'Booking', '2020-10-16', 64, 'Updated booking details for traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (6, 'CREATE', 'Admin', '2024-11-18', 16, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (7, 'CREATE', 'Destination', '2021-07-16', 76, 'Created a new destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (8, 'DELETE', 'ServiceProvider', '2021-03-03', 33, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (9, 'CREATE', 'ServiceProvider', '2022-11-16', 16, 'Created a new service provider record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (10, 'DELETE', 'Admin', '2020-05-25', 75, 'Deleted an Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (11, 'CREATE', 'ServiceProvider', '2020-02-28', 35, 'Created a new service provider record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (12, 'UPDATE', 'ServiceProvider', '2021-08-08', 89, 'Updated service provider details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (13, 'UPDATE', 'ServiceProvider', '2025-01-02', 15, 'Updated service provider details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (14, 'UPDATE', 'ServiceProvider', '2022-08-21', 23, 'Marked service provider as "inactive".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (15, 'UPDATE', 'Admin', '2020-05-21', 22, 'Updated Admin account details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (16, 'CREATE', 'Booking', '2020-05-21', 85, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (17, 'DELETE', 'ServiceProvider', '2024-11-19', 9, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (18, 'DELETE', 'ServiceProvider', '2023-04-27', 3, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (19, 'UPDATE', 'Booking', '2020-01-20', 2, 'Changed booking status to "Completed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (20, 'UPDATE', 'Admin', '2021-06-01', 25, 'Updated Admin account details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (21, 'DELETE', 'Admin', '2021-04-03', 10, 'Deleted an Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (22, 'UPDATE', 'Trip', '2024-02-12', 51, 'Updated trip details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (23, 'DELETE', 'Destination', '2023-02-22', 99, 'Deleted a destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (24, 'CREATE', 'Admin', '2021-09-10', 11, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (25, 'UPDATE', 'Admin', '2022-05-09', 70, 'Updated Admin permissions.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (26, 'UPDATE', 'Destination', '2024-02-29', 18, 'Marked a destination as "inactive".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (27, 'DELETE', 'Trip', '2024-05-13', 28, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (28, 'CREATE', 'Trip', '2021-06-10', 52, 'Created a new trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (29, 'UPDATE', 'Admin', '2020-12-12', 39, 'Updated Admin permissions.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (30, 'DELETE', 'Booking', '2025-03-15', 68, 'Canceled a booking.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (31, 'CREATE', 'Trip', '2024-01-14', 33, 'Created a new trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (32, 'UPDATE', 'Destination', '2020-10-18', 30, 'Marked a destination as "inactive".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (33, 'DELETE', 'Booking', '2022-12-05', 16, 'Deleted a booking record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (34, 'CREATE', 'Booking', '2025-01-01', 43, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (35, 'UPDATE', 'Booking', '2025-01-01', 87, 'Changed booking status to "Confirmed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (36, 'UPDATE', 'Booking', '2025-02-09', 46, 'Changed booking status to "Confirmed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (37, 'UPDATE', 'Admin', '2022-11-21', 53, 'Assigned a new role to Admin.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (38, 'CREATE', 'Trip', '2024-04-07', 5, 'Created a new trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (39, 'UPDATE', 'Trip', '2022-01-31', 82, 'Updated trip details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (40, 'UPDATE', 'Booking', '2021-02-18', 38, 'Changed booking status to "Completed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (41, 'UPDATE', 'Trip', '2022-12-24', 42, 'Closed a trip for new bookings.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (42, 'DELETE', 'Trip', '2023-08-22', 46, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (43, 'DELETE', 'Admin', '2020-06-27', 34, 'Deleted an Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (44, 'CREATE', 'Destination', '2024-09-03', 55, 'Created a new destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (45, 'DELETE', 'Trip', '2024-10-03', 60, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (46, 'DELETE', 'Admin', '2025-02-27', 33, 'Deleted an Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (47, 'DELETE', 'Destination', '2024-05-11', 62, 'Deleted a destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (48, 'UPDATE', 'Destination', '2023-02-11', 80, 'Marked a destination as "inactive".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (49, 'CREATE', 'Destination', '2022-06-04', 8, 'Created a new destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (50, 'CREATE', 'Admin', '2023-09-10', 58, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (51, 'DELETE', 'Trip', '2021-09-06', 11, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (52, 'CREATE', 'Admin', '2024-03-08', 51, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (53, 'CREATE', 'Admin', '2021-05-27', 47, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (54, 'UPDATE', 'Admin', '2024-09-05', 65, 'Updated Admin account details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (55, 'CREATE', 'ServiceProvider', '2023-11-10', 3, 'Created a new service provider record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (56, 'CREATE', 'Trip', '2024-02-11', 43, 'Created a new trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (57, 'UPDATE', 'Booking', '2021-08-23', 75, 'Changed booking status to "Confirmed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (58, 'UPDATE', 'Destination', '2021-09-10', 64, 'Updated destination details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (59, 'UPDATE', 'Admin', '2021-08-27', 88, 'Updated Admin permissions.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (60, 'UPDATE', 'Admin', '2020-02-15', 39, 'Updated Admin account details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (61, 'CREATE', 'Booking', '2022-01-18', 26, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (62, 'DELETE', 'ServiceProvider', '2024-01-29', 51, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (63, 'UPDATE', 'Booking', '2021-05-07', 58, 'Changed booking status to "Confirmed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (64, 'UPDATE', 'Admin', '2022-07-08', 36, 'Updated Admin account details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (65, 'CREATE', 'Booking', '2020-07-04', 82, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (66, 'DELETE', 'ServiceProvider', '2022-12-24', 75, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (67, 'DELETE', 'Trip', '2024-12-10', 99, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (68, 'DELETE', 'ServiceProvider', '2022-02-07', 71, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (69, 'DELETE', 'Trip', '2024-06-03', 32, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (70, 'UPDATE', 'Trip', '2020-03-20', 78, 'Updated trip details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (71, 'CREATE', 'Destination', '2024-02-25', 39, 'Created a new destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (72, 'CREATE', 'Booking', '2023-10-09', 18, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (73, 'DELETE', 'Booking', '2021-05-20', 71, 'Deleted a booking record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (74, 'UPDATE', 'Trip', '2020-12-10', 45, 'Changed trip status to "Available".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (75, 'DELETE', 'Admin', '2022-12-23', 84, 'Deleted an Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (76, 'CREATE', 'Trip', '2024-09-29', 48, 'Created a new trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (77, 'CREATE', 'Destination', '2023-01-08', 13, 'Created a new destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (78, 'UPDATE', 'Trip', '2022-12-02', 6, 'Closed a trip for new bookings.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (79, 'UPDATE', 'Trip', '2021-01-27', 46, 'Updated trip details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (80, 'DELETE', 'Trip', '2022-04-27', 87, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (81, 'DELETE', 'Admin', '2023-05-08', 65, 'Deleted an Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (82, 'CREATE', 'Trip', '2024-12-14', 93, 'Created a new trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (83, 'UPDATE', 'Destination', '2021-02-02', 79, 'Updated destination details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (84, 'DELETE', 'Trip', '2022-10-27', 72, 'Deleted a trip record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (85, 'CREATE', 'ServiceProvider', '2020-06-10', 91, 'Created a new service provider record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (86, 'CREATE', 'Booking', '2021-09-25', 34, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (87, 'DELETE', 'Destination', '2020-02-26', 95, 'Deleted a destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (88, 'UPDATE', 'Booking', '2023-05-25', 51, 'Changed booking status to "Confirmed".');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (89, 'CREATE', 'ServiceProvider', '2021-05-03', 16, 'Created a new service provider record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (90, 'CREATE', 'Booking', '2020-01-21', 47, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (91, 'CREATE', 'Booking', '2023-02-16', 10, 'Created a new booking for a traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (92, 'DELETE', 'Booking', '2020-10-27', 95, 'Deleted a booking record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (93, 'UPDATE', 'ServiceProvider', '2022-09-19', 36, 'Updated service provider details.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (94, 'CREATE', 'Admin', '2024-07-12', 15, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (95, 'DELETE', 'Booking', '2021-07-13', 60, 'Deleted a booking record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (96, 'UPDATE', 'Booking', '2022-08-26', 86, 'Updated booking details for traveler.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (97, 'CREATE', 'Admin', '2023-06-07', 41, 'Created a new Admin account.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (98, 'CREATE', 'Destination', '2023-02-26', 55, 'Created a new destination record.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (99, 'DELETE', 'ServiceProvider', '2024-05-12', 71, 'Deleted a service provider.');
INSERT INTO AuditTrail (AuditID, ActionType, EntityAffected, Timestamp, AdminID, Details) VALUES (100, 'UPDATE', 'Trip', '2023-11-10', 96, 'Updated trip details.');



-- TOUR OPERATOR TABLE DATA
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (1, 100, 'Vargas-Waters', '31359 Anthony Station Apt. 341, Jacobberg, AK 38676', '15120106960', 'vdavis@pearson-hill.net', 'password972', 'Tour of Ancient Greece, Caribbean Island Getaway, European Tour, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (2, 42, 'Haney, Peters and Daugherty', '525 Mcguire Lodge, Amberburgh, IL 57095', '81459479476', 'calebduncan@campos-giles.com', 'password990', 'Cultural Tour of Japan, Road Trip Across the USA');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (3, 40, 'Nelson Inc', '037 Saunders Glens Suite 656, Port Keith, WV 92514', '50233869236', 'fvaldez@hotmail.com', 'password746', 'Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (4, 9, 'Allison-Howard', '8840 Gibbs Valley, Wellsport, MN 31856', '73731829997', 'steven87@bean-brown.org', 'password992', 'New Zealand Adventure, Thailand Cultural Tour, Luxury Cruise, Mountain Hiking in Switzerland, Safari in South Africa');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (5, 89, 'Johnson-Woods', '759 Maria Field Suite 248, East Jamie, FL 33769', '04616127833', 'sarahwarner@patton.biz', 'password215', 'Safari in South Africa, Thailand Cultural Tour, Paris City Break');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (6, 45, 'Hall PLC', '062 Audrey Summit Apt. 858, Timothystad, LA 15151', '12173198038', 'sylviadavis@green.info', 'password789', 'Safari in South Africa, New Zealand Adventure, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (7, 21, 'Carey, Rodriguez and Bass', '555 Francis Trail Suite 974, Port Davidland, ME 06255', '45717251285', 'lpearson@yahoo.com', 'password589', 'Thailand Cultural Tour, Luxury Cruise, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (8, 36, 'Williams, Reynolds and Rodriguez', '1979 Adam Lodge, Michaelton, NV 26821', '47189607223', 'kimberlybryan@simon-blackburn.net', 'password862', 'Luxury Cruise, Cultural Tour of Japan, Safari in South Africa, Historic Egypt Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (9, 5, 'Gould, Williams and Boyer', 'PSC 4695, Box 3636, APO AP 08559', '18457108920', 'ericeverett@patel.com', 'password668', 'Beach Vacation in Bali, Paris City Break, Tour of Ancient Greece, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (10, 11, 'Davidson, Anderson and Brown', '4957 Michael Road Apt. 616, East Robert, MO 31965', '51073490191', 'wendy69@cook.com', 'password825', 'Tour of Ancient Greece, Historic Egypt Tour, Australian Outback Adventure, Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (11, 27, 'Hamilton-Gibbs', '894 William Loop, Port Chelsea, ID 83536', '94227398125', 'tracy29@craig-cook.com', 'password948', 'New Zealand Adventure, South American Expedition, Tour of Ancient Greece, Paris City Break');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (12, 33, 'Brooks LLC', '0830 Stephanie Mews Suite 543, North Jessicaberg, DC 60898', '84553735055', 'tylermay@hotmail.com', 'password592', 'Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (13, 43, 'Bauer, Morales and Shaw', '2653 Shaffer Views, Taylorfort, NH 10916', '82064273809', 'robert77@bray.net', 'password613', 'South American Expedition, Luxury Cruise, Safari in South Africa');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (14, 28, 'Morgan-Conley', '1744 Ayala Roads Apt. 212, Gabriellehaven, ND 01072', '65748373709', 'anthonyhoffman@browning.com', 'password809', 'Wildlife Safari in Kenya, Caribbean Island Getaway, Mountain Hiking in Switzerland, Luxury Cruise, Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (15, 67, 'Shea, Wright and Campos', '2759 Kaitlyn Burgs, Lake Amy, MT 45600', '92756219305', 'katherinesingh@gonzales.com', 'password694', 'Historic Egypt Tour, Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (16, 31, 'Welch, Ross and Mendoza', '165 Smith Junction Apt. 711, Lake Gregoryberg, VA 60931', '55645728041', 'michaelshelton@deleon.net', 'password823', 'Cultural Tour of Japan, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (17, 34, 'Matthews-Johnson', '33306 Ramos Prairie Suite 066, Westtown, ND 16309', '06943131621', 'matthew15@gmail.com', 'password652', 'Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (18, 47, 'Montes PLC', '48449 Montgomery View, Morenohaven, CT 51230', '73046041315', 'perezbrittney@hotmail.com', 'password151', 'European Tour, Thailand Cultural Tour, Road Trip Across the USA, South American Expedition, Safari in South Africa');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (19, 18, 'Vasquez, Delacruz and Wagner', '908 Thomas Hill, Jessicastad, AR 59912', '27175077049', 'matthewsstacy@gmail.com', 'password787', 'Caribbean Island Getaway, European Tour, Road Trip Across the USA, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (20, 100, 'Salazar, Anderson and Scott', '4128 Garcia Dam Apt. 637, South Travismouth, AK 69336', '89329083554', 'nancy01@gmail.com', 'password931', 'European Tour, Wildlife Safari in Kenya, New Zealand Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (21, 18, 'Gomez LLC', '427 Marsh Field, Annamouth, NM 59651', '15668918381', 'peter23@hotmail.com', 'password556', 'Road Trip Across the USA, South American Expedition, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (22, 48, 'Mann-Pierce', '4196 Larry Points Suite 125, East Melissa, SD 57440', '28917027059', 'richardbell@gmail.com', 'password402', 'Safari in South Africa, South American Expedition');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (23, 75, 'Hayes, Goodman and Petty', '27135 Brenda Flat, Jasonland, NE 08465', '18574022241', 'cterry@erickson.net', 'password531', 'Cultural Tour of Japan, Australian Outback Adventure, Road Trip Across the USA, Safari in South Africa');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (24, 43, 'Wilson, Thornton and White', '5318 Alexander Tunnel, Russellmouth, CA 31746', '28289072070', 'mackenzie52@haynes.com', 'password994', 'Luxury Cruise, Paris City Break');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (25, 72, 'Hill-Jones', '9951 Hickman Tunnel Apt. 470, Port Kevin, CT 18878', '28582773181', 'lriddle@hotmail.com', 'password748', 'Paris City Break, European Tour, Caribbean Island Getaway, Tour of Ancient Greece, Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (26, 46, 'Bennett PLC', '12757 Lopez Fords, New James, NM 29093', '34817791201', 'latoyakerr@norris-pearson.info', 'password997', 'European Tour, Historic Egypt Tour, Road Trip Across the USA, New Zealand Adventure, Australian Outback Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (27, 79, 'Walker, Taylor and Villarreal', 'USS Harris, FPO AA 18549', '32547956246', 'carlastout@yahoo.com', 'password417', 'Wildlife Safari in Kenya, Cultural Tour of Japan, Australian Outback Adventure, Safari in South Africa, Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (28, 46, 'Blankenship-Rodriguez', '646 Wright Station Apt. 573, Lake Roberta, NE 58920', '47425268968', 'williamwalton@hotmail.com', 'password580', 'Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (29, 19, 'Bridges-Morales', '85121 Green Ports, Emilyport, NC 55677', '45697556391', 'hmurray@zimmerman.com', 'password388', 'Australian Outback Adventure, Historic Egypt Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (30, 14, 'Hughes, Hall and Perry', '3432 Ashley Place, North Scottview, SD 89082', '19710041314', 'cblackwell@gmail.com', 'password466', 'New Zealand Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (31, 33, 'Steele, Mcdonald and Brown', '7840 Michael Loop Apt. 312, Port Robertchester, VT 72137', '08305122867', 'hebertcody@gmail.com', 'password219', 'Australian Outback Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (32, 85, 'Macdonald, Jackson and Hardin', '228 Alexander Prairie, New Mary, IA 76813', '35206357925', 'gmccoy@yahoo.com', 'password699', 'Mountain Hiking in Switzerland, South American Expedition, Australian Outback Adventure, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (33, 35, 'Mendoza-Brooks', '4845 Molina Tunnel Suite 045, North Angelicaburgh, MA 26544', '86107067944', 'jessica05@reyes.com', 'password312', 'Wildlife Safari in Kenya, New Zealand Adventure, Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (34, 86, 'Jones-Waters', 'PSC 6389, Box 3489, APO AA 07683', '21395138864', 'danielgardner@yahoo.com', 'password852', 'Safari in South Africa, Beach Vacation in Bali, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (35, 26, 'Hawkins, Gibson and French', '30575 Heather Estates, Cindyshire, OR 42668', '24856274170', 'tsmith@gmail.com', 'password689', 'European Tour, South American Expedition, Paris City Break, Beach Vacation in Bali');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (36, 27, 'Branch-Wagner', '7479 Deborah Throughway, Lake Juliachester, IN 64003', '70398843136', 'hjones@hotmail.com', 'password416', 'Luxury Cruise, Paris City Break, Wildlife Safari in Kenya, Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (37, 54, 'Atkinson-Peck', '2837 Gardner Walk, Ryanport, AK 78740', '36584799086', 'jim29@hotmail.com', 'password256', 'Wildlife Safari in Kenya, Road Trip Across the USA, Paris City Break, Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (38, 33, 'Craig-Flores', '492 Emily Vista Suite 564, Maryhaven, CA 45573', '27122536334', 'duffysarah@yahoo.com', 'password236', 'Paris City Break, Safari in South Africa, Caribbean Island Getaway, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (39, 53, 'Webb PLC', '390 Luna Drive, Scottberg, ID 45373', '77186055648', 'veronica71@gmail.com', 'password550', 'Wildlife Safari in Kenya, Road Trip Across the USA, Cultural Tour of Japan, Historic Egypt Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (40, 81, 'Espinoza, Murphy and Davis', '53485 Jane Springs, Melanieberg, NJ 05343', '09097948429', 'ashley45@gmail.com', 'password635', 'European Tour, Paris City Break, New Zealand Adventure, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (41, 73, 'Robinson-Bradley', '002 Villanueva Station Suite 037, East Barbaramouth, MD 85140', '56250535817', 'kinggerald@yahoo.com', 'password697', 'Beach Vacation in Bali, Road Trip Across the USA, Thailand Cultural Tour, Australian Outback Adventure, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (42, 76, 'Brooks-Evans', '30621 Kristina Extension, Jasontown, VT 35494', '20070679760', 'qross@gmail.com', 'password825', 'Caribbean Island Getaway, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (43, 1, 'Carroll-Morgan', '78523 Hopkins Land, Floydshire, KS 17061', '39023310829', 'nedwards@soto.com', 'password316', 'Wildlife Safari in Kenya, Tour of Ancient Greece, Paris City Break, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (44, 62, 'Franco, Rose and Davis', '33720 Mills Wells Apt. 986, Cynthiamouth, OH 41665', '24493822818', 'benjaminsteven@ryan.com', 'password696', 'South American Expedition, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (45, 96, 'Allen LLC', '485 Joshua Cove, Lawsonview, MO 50978', '64283008220', 'sampsonholly@woodward.biz', 'password153', 'European Tour, Paris City Break, New Zealand Adventure, Luxury Cruise, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (46, 30, 'Phillips-Cameron', '453 Thompson Cliff Suite 936, New Peter, GA 66555', '25192034816', 'halldiane@moreno.com', 'password969', 'Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (47, 1, 'Harris-Franklin', '8580 Jill Circle Apt. 754, Jonesmouth, OR 17711', '10493975505', 'jgreer@yahoo.com', 'password127', 'Cultural Tour of Japan, Tour of Ancient Greece, New Zealand Adventure, Wildlife Safari in Kenya, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (48, 80, 'Montgomery and Sons', '114 Hansen Gardens, New Antonioland, NE 21632', '79527940047', 'hhodge@chan.info', 'password522', 'Safari in South Africa, Road Trip Across the USA, Historic Egypt Tour, Luxury Cruise, Beach Vacation in Bali');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (49, 33, 'Castro Group', '747 Pamela Square Apt. 784, Ortizland, TX 83962', '76219647813', 'lkelley@yahoo.com', 'password993', 'Mountain Hiking in Switzerland, Paris City Break, Historic Egypt Tour, Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (50, 49, 'Johnson Ltd', '250 Moore Vista Apt. 918, Davidmouth, MA 96888', '03959449656', 'mooremorgan@yahoo.com', 'password897', 'Historic Egypt Tour, Australian Outback Adventure, Luxury Cruise, Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (51, 13, 'Jackson, Ross and Johnson', '01259 Harrison Overpass Suite 229, Jodiport, IL 22798', '82357924461', 'paul74@owens-king.info', 'password118', 'Thailand Cultural Tour, Australian Outback Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (52, 12, 'Brown-Gibbs', '47050 Eric Via Suite 147, Latoyaland, OK 77122', '08812158835', 'cranealexander@yahoo.com', 'password818', 'Caribbean Island Getaway, Mountain Hiking in Switzerland, Paris City Break');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (53, 16, 'Collins Group', '564 Jones Lodge, Jessicastad, ND 53076', '93730772565', 'douglasmorrow@rodriguez-weaver.com', 'password173', 'Cultural Tour of Japan, Caribbean Island Getaway, Tour of Ancient Greece, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (54, 7, 'Mcbride Group', '617 Debbie Vista, Beardview, WV 62157', '88170809979', 'williamsonkarla@turner.com', 'password974', 'Beach Vacation in Bali, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (55, 34, 'Robertson Group', '8560 Harris Road Apt. 493, Port Michelle, NV 24312', '06970148502', 'dpalmer@lang.com', 'password785', 'Australian Outback Adventure, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (56, 34, 'West-Avila', '74312 Gonzalez Roads Apt. 523, South Amandatown, MO 32014', '90196600286', 'ytownsend@weaver.biz', 'password299', 'Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (57, 85, 'Guzman-Jenkins', '04856 Johnson Camp Apt. 353, Suarezchester, IN 35958', '69192979745', 'hahnamy@gmail.com', 'password703', 'Tour of Ancient Greece, New Zealand Adventure, Beach Vacation in Bali, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (58, 87, 'Moore PLC', '36093 Mcpherson Stravenue, Paulstad, PA 15683', '93072783042', 'perryphillip@gmail.com', 'password674', 'Mountain Hiking in Switzerland, Beach Vacation in Bali, Cultural Tour of Japan, Historic Egypt Tour, New Zealand Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (59, 58, 'Smith, Mcneil and Davila', '5103 Nancy Club, Cindyview, UT 31409', '64803109668', 'lcervantes@arnold-nichols.com', 'password324', 'Luxury Cruise, European Tour, Wildlife Safari in Kenya, South American Expedition, Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (60, 94, 'Jones-Blackwell', '2823 Aaron Harbors Suite 787, Angelaside, AZ 71042', '42552776120', 'dodsonlori@hotmail.com', 'password799', 'South American Expedition');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (61, 12, 'Pearson Ltd', '2159 King Common, East Troy, PA 47981', '00733193217', 'catherinewaller@yahoo.com', 'password515', 'Mountain Hiking in Switzerland, Road Trip Across the USA, South American Expedition');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (62, 33, 'Hernandez, Hill and Mccarthy', '54762 Warner Skyway, North Luis, AK 19683', '22210473655', 'josephreilly@gmail.com', 'password357', 'Paris City Break, Cultural Tour of Japan, European Tour, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (63, 8, 'Campbell-Joseph', '51900 Matthew Road, Brittanyborough, AK 76094', '07067179201', 'emckenzie@yahoo.com', 'password252', 'Wildlife Safari in Kenya, Australian Outback Adventure, Road Trip Across the USA, Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (64, 12, 'Shields-Pearson', '3364 Meyer Mountain Suite 248, South Kimberly, TX 62154', '15927554397', 'rachel34@reynolds.com', 'password280', 'Paris City Break, European Tour, Road Trip Across the USA, Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (65, 26, 'Jackson and Sons', '3422 Maria Centers, Jameschester, AL 53126', '28414977292', 'patricia37@yahoo.com', 'password840', 'Caribbean Island Getaway, Safari in South Africa, European Tour, Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (66, 59, 'Reed, Coleman and Keller', '69124 Choi Throughway Apt. 393, East Katieborough, MI 18390', '76353990694', 'gbowers@odom-thompson.info', 'password639', 'New Zealand Adventure, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (67, 90, 'Barr-Salas', '918 Ryan Courts Suite 821, North Williammouth, CT 80873', '32193046611', 'rclayton@yahoo.com', 'password103', 'Australian Outback Adventure, Safari in South Africa, Beach Vacation in Bali, Caribbean Island Getaway, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (68, 93, 'Horne PLC', '319 Tara Club, New Bradfort, MO 83969', '50323474422', 'mdennis@hunter-ortiz.net', 'password445', 'Safari in South Africa, Cultural Tour of Japan, Tour of Ancient Greece, Australian Outback Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (69, 12, 'Smith-Mccann', '49870 Karen Shoal Apt. 614, Katrinaton, SD 39874', '51230988883', 'racheljackson@arias.com', 'password863', 'Cultural Tour of Japan, European Tour, Caribbean Island Getaway, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (70, 49, 'Erickson-Baker', '847 Daniel Crescent, Port Karen, MO 84342', '04715585457', 'whitejoshua@gmail.com', 'password813', 'Luxury Cruise, Historic Egypt Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (71, 63, 'Aguirre Inc', '2644 Gardner Square Suite 964, South Victor, AL 91805', '41836694129', 'amy67@hotmail.com', 'password819', 'Road Trip Across the USA, Luxury Cruise, New Zealand Adventure, Caribbean Island Getaway, European Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (72, 57, 'Moss, Torres and Larson', '752 Hammond Tunnel Suite 252, New Stephanie, SC 99125', '27162472848', 'tylerjones@gmail.com', 'password685', 'Mountain Hiking in Switzerland, New Zealand Adventure, Road Trip Across the USA');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (73, 94, 'Barber-Carlson', '50809 Natalie Ferry, Morrisonbury, CA 29242', '55382170217', 'donaldrose@griffin.com', 'password632', 'New Zealand Adventure, South American Expedition, Thailand Cultural Tour, Historic Egypt Tour, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (74, 81, 'Graham, Young and Horton', '8021 Ellis Burg Apt. 669, Alexisberg, MD 86172', '97854755716', 'murrayjason@peterson-warner.com', 'password920', 'Australian Outback Adventure, New Zealand Adventure, South American Expedition, European Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (75, 28, 'Merritt-Ryan', '59689 Sanchez Turnpike, West Carla, DE 18377', '92992252267', 'krista53@yahoo.com', 'password367', 'Cultural Tour of Japan, Luxury Cruise, Paris City Break');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (76, 18, 'Perkins Inc', '02898 Drew Locks, Anaton, NJ 64029', '44017080514', 'yreed@williams.com', 'password677', 'Caribbean Island Getaway, Tour of Ancient Greece, South American Expedition');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (77, 47, 'Mendoza, Ferrell and Gray', '141 Justin Point Apt. 683, Schmidtfurt, AZ 56869', '91310958839', 'fischermorgan@jenkins.net', 'password121', 'European Tour, Beach Vacation in Bali, Safari in South Africa, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (78, 64, 'Krause, Castillo and Miranda', '0202 Dean Squares, Brightport, ND 70908', '14492835275', 'coopertheresa@sims.org', 'password783', 'Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (79, 99, 'Ward-Davis', '01062 Calderon Village, West Andrea, MD 50255', '94616992416', 'rachelhebert@yahoo.com', 'password476', 'Mountain Hiking in Switzerland, Wildlife Safari in Kenya');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (80, 17, 'Poole-Zavala', '562 Donna Ridges, New Rachelstad, AZ 94229', '72181670229', 'brandon89@myers.com', 'password965', 'European Tour, Beach Vacation in Bali, Tour of Ancient Greece, Australian Outback Adventure, New Zealand Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (81, 9, 'Johnson-Robbins', '40796 Warner Ports Suite 427, North Kristen, ME 56500', '71530752195', 'gillnicole@griffin-frank.com', 'password282', 'Wildlife Safari in Kenya, Tour of Ancient Greece, Safari in South Africa, Thailand Cultural Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (82, 62, 'Price, Scott and Parker', '086 Julie Viaduct, Whitestad, KY 80327', '81818861740', 'anna26@gmail.com', 'password483', 'Mountain Hiking in Switzerland, Wildlife Safari in Kenya, Road Trip Across the USA, Safari in South Africa, Paris City Break');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (83, 29, 'Cobb-Wright', '3160 Emily Via Suite 187, New Michael, OK 09399', '26096869187', 'fmeza@gmail.com', 'password798', 'Beach Vacation in Bali, Tour of Ancient Greece, Thailand Cultural Tour, South American Expedition, Historic Egypt Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (84, 69, 'Blackwell-Sanchez', '914 Emily Islands Apt. 609, East Aaron, MS 52328', '05639469482', 'smithsarah@phelps.com', 'password347', 'Wildlife Safari in Kenya, Historic Egypt Tour, Safari in South Africa, European Tour, Beach Vacation in Bali');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (85, 46, 'Love, Wallace and Lewis', '6842 Cesar Ramp Apt. 028, Tiffanyview, AK 55909', '38117755864', 'hernandezcrystal@wallace.com', 'password815', 'Cultural Tour of Japan, Wildlife Safari in Kenya, Caribbean Island Getaway, Road Trip Across the USA, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (86, 33, 'Duncan-Smith', '8110 Alison Fork Apt. 356, South Thomas, TN 91082', '31142646446', 'mgreene@yahoo.com', 'password191', 'Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (87, 14, 'Hickman Ltd', 'USNS Hunt, FPO AA 26039', '70553717323', 'jodi03@yahoo.com', 'password256', 'Wildlife Safari in Kenya, Luxury Cruise, Safari in South Africa');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (88, 55, 'Silva-Brown', '57474 Mcdonald Drives Suite 333, New Davidland, CO 24736', '07789939986', 'linda00@yahoo.com', 'password390', 'Luxury Cruise');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (89, 33, 'Saunders Inc', '91003 George Plains Suite 223, South Michael, NM 84631', '51734713891', 'johnmartinez@davis.com', 'password126', 'Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (90, 70, 'Santos Ltd', 'PSC 8529, Box 6192, APO AP 20282', '32807936721', 'knorris@garner-schultz.net', 'password736', 'European Tour, Road Trip Across the USA, New Zealand Adventure, Paris City Break, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (91, 13, 'Hogan Group', 'Unit 7192 Box 0103, DPO AA 20824', '27479023378', 'tbrown@lambert-collins.org', 'password362', 'Thailand Cultural Tour, Safari in South Africa, European Tour');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (92, 93, 'Price-Lopez', '8834 Fitzgerald Point Suite 953, Deanbury, MT 26071', '90855347743', 'ymedina@kennedy-mueller.com', 'password864', 'Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (93, 28, 'Pugh Ltd', '788 White Land, Ericside, NM 52126', '61224732351', 'ofreeman@pratt.org', 'password215', 'Road Trip Across the USA, Tour of Ancient Greece');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (94, 88, 'Kelley Inc', '27644 Carroll Dam, South Sherry, AR 80066', '99307205580', 'stephaniemack@yahoo.com', 'password381', 'New Zealand Adventure, Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (95, 99, 'Wright-Perry', '5893 Clarence Vista Apt. 435, East Nathanland, TN 34202', '02876505001', 'jthomas@silva.com', 'password362', 'European Tour, Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (96, 19, 'Garcia, Briggs and Mcdonald', '755 Heather Parks, New Johnmouth, WV 04435', '74827464686', 'ydiaz@hotmail.com', 'password412', 'Cultural Tour of Japan, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (97, 86, 'Morgan LLC', '60882 Javier Mountains Suite 991, Kathleenborough, MA 90465', '73149339510', 'jeffreybeck@gmail.com', 'password491', 'Cultural Tour of Japan, Thailand Cultural Tour, European Tour, Caribbean Island Getaway');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (98, 98, 'Gordon, Rogers and Newman', '9668 Sosa Villages Apt. 417, East Lisamouth, MA 35521', '99214945389', 'smithjerry@martinez-johnson.com', 'password742', 'New Zealand Adventure');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (99, 1, 'Cruz, Frost and Park', '0300 Wallace Port, North Gary, DE 91801', '53245363672', 'cindy32@hotmail.com', 'password348', 'Mountain Hiking in Switzerland');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (100, 35, 'Dodson PLC', '78538 Christina Burg, Lake Raymondborough, FL 46094', '25864461372', 'monica83@lewis.org', 'password427', 'Safari in South Africa, Cultural Tour of Japan');
INSERT INTO TourOperator (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered) VALUES (101, 1, 'Dodson PLC', '78538 Christina Burg, Lake Raymondborough, FL 46094', '25064461372', 'monica183@lewis.org', 'password427', 'Safari in South Africa, Cultural Tour of Japan');



-- TRIPS TABLE DATA
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (1, 51, 'Australian Expedition', 4233.36, 32, 'Adventure', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Book a tour and get a free guide!', '2025-03-25', '2025-04-07', 13, 'Completed', 12, 1, 1.63);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (2, 91, 'American Expedition', 2797.26, 24, 'Cultural', 'Embark on an ancient Greek tour and explore ruins like the Acropolis, Parthenon, and visit picturesque islands like Santorini.', 'Early bird discount: 20% off if you book now!', '2025-02-11', '2025-03-03', 20, 'Cancelled', 12, 1, 1.68);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (3, 50, 'African Expedition', 1188.34, 5, 'Safari', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Free museum entry included with this trip.', '2025-02-05', '2025-02-21', 16, 'Completed', 2, 1, 4.83);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (4, 32, 'European Tour', 3458.21, 26, 'Beach', 'Go on a wildlife safari in Kenya. Explore Masai Mara, see lions, elephants, and more, and enjoy luxury tented camps.', 'Free museum entry included with this trip.', '2025-01-18', '2025-03-26', 67, 'Available', 22, 1, 3.3);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (5, 7, 'Asian Getaway', 3233.09, 42, 'Mountain', 'Experience the stunning beauty of New Zealand on a guided adventure. Visit geothermal parks, beaches, and Maori cultural sites.', 'Get a free activity pass for every booking!', '2025-03-09', '2025-03-20', 11, 'Cancelled', 29, 1, 3.57);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (6, 89, 'Asian Expedition', 2535.29, 6, 'Luxury', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Limited time offer: Extra 10% off on group bookings.', '2025-02-09', '2025-04-05', 55, 'Cancelled', 1, 1, 3.7);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (7, 29, 'African Getaway', 1144.02, 49, 'Adventure', 'Embark on an ancient Greek tour and explore ruins like the Acropolis, Parthenon, and visit picturesque islands like Santorini.', 'Special rates for returning customers.', '2025-01-07', '2025-03-13', 65, 'Available', 38, 1, 1.0);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (8, 10, 'Australian Tour', 3731.31, 16, 'City Tour', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Get a free activity pass for every booking!', '2025-01-01', '2025-03-05', 63, 'Available', 2, 1, 3.1);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (9, 71, 'African Adventure', 2549.01, 31, 'Mountain', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Early bird discount: 20% off if you book now!', '2025-03-13', '2025-04-11', 29, 'Cancelled', 15, 1, 3.51);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (10, 20, 'European Expedition', 4464.62, 50, 'City Tour', 'Relax and unwind in the Caribbean with our tropical beach resort tour. Enjoy all-inclusive packages and watersport activities.', 'Buy 2 get 1 free on selected activities!', '2025-02-05', '2025-04-08', 62, 'Available', 47, 1, 2.68);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (11, 14, 'African Tour', 2229.57, 18, 'Beach', 'Explore the heart of Europe with this immersive cultural tour. Visit historic cities like Paris, Rome, and Amsterdam.', 'Free museum entry included with this trip.', '2025-03-16', '2025-04-15', 30, 'Cancelled', 13, 1, 1.14);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (12, 55, 'African Adventure', 1339.84, 25, 'Beach', 'Enjoy a nature-filled expedition in Canada’s Rocky Mountains. Hike, camp, and explore Canada’s pristine wilderness.', 'Buy 2 get 1 free on selected activities!', '2025-01-20', '2025-04-07', 77, 'Completed', 11, 1, 3.49);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (13, 51, 'African Tour', 1990.01, 34, 'Cultural', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Get a free activity pass for every booking!', '2025-03-06', '2025-03-11', 5, 'Completed', 28, 1, 2.58);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (14, 96, 'European Expedition', 2936.02, 7, 'City Tour', 'Enjoy a nature-filled expedition in Canada’s Rocky Mountains. Hike, camp, and explore Canada’s pristine wilderness.', '25% off for early bookings!', '2025-04-09', '2025-04-12', 3, 'Available', 1, 1, 3.48);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (15, 68, 'American Tour', 2061.2, 4, 'Beach', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Free entry for kids below 12 years!', '2025-03-04', '2025-03-06', 2, 'Available', 2, 1, 3.15);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (16, 44, 'African Adventure', 3494.16, 7, 'Safari', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Special combo deals with other trips.', '2025-03-09', '2025-04-09', 31, 'Cancelled', 0, 1, 4.0);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (17, 75, 'African Cruise', 4051.25, 8, 'Beach', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Special combo deals with other trips.', '2025-01-06', '2025-03-18', 71, 'Cancelled', 3, 1, 2.55);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (18, 70, 'Australian Safari', 3366.14, 21, 'Mountain', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Get a free activity pass for every booking!', '2025-02-06', '2025-03-16', 38, 'Completed', 20, 1, 4.53);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (19, 59, 'African Tour', 4261.01, 48, 'Luxury', 'Embark on an ancient Greek tour and explore ruins like the Acropolis, Parthenon, and visit picturesque islands like Santorini.', 'Special rates for returning customers.', '2025-01-02', '2025-01-18', 16, 'Completed', 2, 1, 4.1);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (20, 28, 'Asian Tour', 1685.58, 35, 'City Tour', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', '25% off for early bookings!', '2025-02-18', '2025-04-15', 56, 'Completed', 11, 1, 3.67);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (21, 99, 'African Safari', 4076.23, 5, 'Cultural', 'Go on a wildlife safari in Kenya. Explore Masai Mara, see lions, elephants, and more, and enjoy luxury tented camps.', 'Limited time offer: Extra 10% off on group bookings.', '2025-02-24', '2025-03-04', 8, 'Completed', 4, 1, 2.65);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (22, 20, 'Asian Tour', 3084.8, 18, 'Luxury', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Early bird discount: 20% off if you book now!', '2025-04-14', '2025-04-15', 1, 'Available', 12, 1, 4.99);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (23, 56, 'European Getaway', 3174.12, 11, 'Safari', 'Enjoy a nature-filled expedition in Canada’s Rocky Mountains. Hike, camp, and explore Canada’s pristine wilderness.', 'Free entry for kids below 12 years!', '2025-03-28', '2025-04-15', 18, 'Available', 0, 1, 3.98);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (24, 93, 'African Safari', 1940.95, 19, 'Mountain', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Limited time offer: Extra 10% off on group bookings.', '2025-02-09', '2025-03-09', 28, 'Completed', 2, 1, 1.34);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (25, 54, 'Asian Safari', 1311.78, 13, 'Mountain', 'Explore the heart of Europe with this immersive cultural tour. Visit historic cities like Paris, Rome, and Amsterdam.', 'Special rates for returning customers.', '2025-02-08', '2025-03-16', 36, 'Cancelled', 3, 1, 3.6);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (26, 11, 'Asian Cruise', 3258.16, 29, 'Mountain', 'Join us on an adventurous hike through the Swiss Alps. Explore nature, stunning views, and breathtaking landscapes.', 'Free entry for kids below 12 years!', '2025-01-17', '2025-03-26', 68, 'Completed', 20, 1, 2.39);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (27, 64, 'American Tour', 2658.16, 40, 'Safari', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Free entry for kids below 12 years!', '2025-04-12', '2025-04-12', 0, 'Available', 5, 1, 2.82);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (28, 84, 'African Safari', 2158.3, 26, 'Luxury', 'Tour the historic city of Rome and visit landmarks like the Colosseum, Vatican City, and Pantheon.', 'Early bird discount: 20% off if you book now!', '2025-02-04', '2025-02-14', 10, 'Cancelled', 17, 1, 3.79);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (29, 96, 'Asian Safari', 1401.91, 26, 'Beach', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Free entry for kids below 12 years!', '2025-01-26', '2025-01-30', 4, 'Available', 20, 1, 4.5);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (30, 7, 'American Tour', 3774.23, 34, 'Luxury', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Early bird discount: 20% off if you book now!', '2025-04-07', '2025-04-12', 5, 'Available', 1, 1, 3.34);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (31, 24, 'Australian Safari', 3332.3, 17, 'Safari', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Special combo deals with other trips.', '2025-02-01', '2025-04-07', 65, 'Available', 10, 42, 3.54);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (32, 39, 'European Tour', 4864.66, 37, 'City Tour', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Free museum entry included with this trip.', '2025-01-12', '2025-01-19', 7, 'Completed', 35, 30, 2.64);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (33, 50, 'Asian Adventure', 1915.85, 39, 'Luxury', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Special rates for returning customers.', '2025-03-07', '2025-03-09', 2, 'Completed', 19, 43, 4.21);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (34, 1, 'European Expedition', 3040.72, 30, 'Mountain', 'Enjoy a nature-filled expedition in Canada’s Rocky Mountains. Hike, camp, and explore Canada’s pristine wilderness.', 'Free museum entry included with this trip.', '2025-01-11', '2025-02-22', 42, 'Completed', 4, 47, 4.34);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (35, 49, 'African Tour', 3960.0, 50, 'Cultural', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Early bird discount: 20% off if you book now!', '2025-01-27', '2025-02-11', 15, 'Cancelled', 27, 25, 3.77);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (36, 81, 'Asian Cruise', 1929.25, 13, 'Cultural', 'Explore the heart of Europe with this immersive cultural tour. Visit historic cities like Paris, Rome, and Amsterdam.', 'Free entry for kids below 12 years!', '2025-03-28', '2025-04-12', 15, 'Completed', 11, 29, 2.39);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (37, 41, 'Australian Adventure', 1079.4, 5, 'Cultural', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Limited time offer: Extra 10% off on group bookings.', '2025-01-28', '2025-02-13', 16, 'Available', 2, 48, 2.08);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (38, 99, 'African Expedition', 4280.28, 24, 'Safari', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Special rates for returning customers.', '2025-03-22', '2025-03-31', 9, 'Completed', 8, 14, 4.69);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (39, 36, 'Australian Adventure', 3401.03, 7, 'Beach', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Book a tour and get a free guide!', '2025-03-04', '2025-03-31', 27, 'Cancelled', 5, 22, 2.37);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (40, 30, 'American Adventure', 1574.95, 34, 'Adventure', 'Experience the thrill of a safari in South Africa. See the Big Five in their natural habitat while staying at luxury lodges.', 'Early bird discount: 20% off if you book now!', '2025-03-29', '2025-04-05', 7, 'Available', 4, 43, 2.76);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (41, 94, 'European Tour', 2048.39, 45, 'Adventure', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Special combo deals with other trips.', '2025-02-26', '2025-03-12', 14, 'Available', 45, 18, 1.69);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (42, 62, 'African Adventure', 4688.25, 39, 'Safari', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Free entry for kids below 12 years!', '2025-04-12', '2025-04-12', 0, 'Completed', 29, 12, 4.97);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (43, 85, 'Australian Adventure', 1512.3, 23, 'Luxury', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Buy 2 get 1 free on selected activities!', '2025-03-29', '2025-04-04', 6, 'Completed', 11, 33, 4.27);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (44, 90, 'Australian Getaway', 3650.87, 41, 'Safari', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Buy 2 get 1 free on selected activities!', '2025-01-25', '2025-01-26', 1, 'Available', 32, 23, 1.45);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (45, 89, 'African Getaway', 2985.13, 16, 'Beach', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Book a tour and get a free guide!', '2025-03-13', '2025-03-17', 4, 'Available', 12, 15, 1.43);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (46, 86, 'African Expedition', 4610.09, 44, 'Beach', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Free entry for kids below 12 years!', '2025-03-06', '2025-03-07', 1, 'Available', 43, 35, 3.41);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (47, 9, 'Australian Safari', 4287.2, 19, 'Cultural', 'Experience the thrill of a safari in South Africa. See the Big Five in their natural habitat while staying at luxury lodges.', 'Special rates for returning customers.', '2025-01-20', '2025-02-11', 22, 'Completed', 4, 37, 3.11);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (48, 19, 'Asian Safari', 3834.79, 14, 'Cultural', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Book a tour and get a free guide!', '2025-03-20', '2025-03-27', 7, 'Available', 3, 8, 4.21);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (49, 13, 'African Safari', 4056.96, 5, 'Beach', 'Enjoy a nature-filled expedition in Canada’s Rocky Mountains. Hike, camp, and explore Canada’s pristine wilderness.', 'Early bird discount: 20% off if you book now!', '2025-01-10', '2025-03-14', 63, 'Cancelled', 5, 37, 3.58);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (50, 59, 'American Cruise', 3686.84, 2, 'City Tour', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', '25% off for early bookings!', '2025-03-11', '2025-03-22', 11, 'Available', 0, 16, 3.68);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (51, 4, 'Australian Expedition', 3452.85, 47, 'Cultural', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Special combo deals with other trips.', '2025-04-02', '2025-04-15', 13, 'Available', 18, 12, 2.52);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (52, 35, 'Australian Expedition', 4739.06, 46, 'Cultural', 'Experience the thrill of a safari in South Africa. See the Big Five in their natural habitat while staying at luxury lodges.', 'Free entry for kids below 12 years!', '2025-03-30', '2025-04-10', 11, 'Completed', 25, 5, 3.22);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (53, 32, 'American Tour', 1238.49, 31, 'Luxury', 'Experience the stunning beauty of New Zealand on a guided adventure. Visit geothermal parks, beaches, and Maori cultural sites.', 'Get a free activity pass for every booking!', '2025-04-12', '2025-04-13', 1, 'Cancelled', 16, 31, 1.95);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (54, 39, 'African Cruise', 1237.42, 19, 'Cultural', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Buy 2 get 1 free on selected activities!', '2025-03-30', '2025-04-15', 16, 'Completed', 6, 15, 2.05);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (55, 1, 'African Cruise', 4432.16, 34, 'City Tour', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Limited time offer: Extra 10% off on group bookings.', '2025-02-13', '2025-03-27', 42, 'Cancelled', 6, 28, 4.78);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (56, 4, 'Asian Getaway', 4791.82, 50, 'Safari', 'Tour the historic city of Rome and visit landmarks like the Colosseum, Vatican City, and Pantheon.', 'Early bird discount: 20% off if you book now!', '2025-01-31', '2025-02-26', 26, 'Cancelled', 45, 27, 3.16);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (57, 99, 'European Safari', 1101.67, 11, 'Adventure', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Limited time offer: Extra 10% off on group bookings.', '2025-02-10', '2025-04-01', 50, 'Completed', 1, 26, 2.05);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (58, 28, 'Australian Adventure', 3044.48, 43, 'City Tour', 'Explore the heart of Europe with this immersive cultural tour. Visit historic cities like Paris, Rome, and Amsterdam.', 'Buy 2 get 1 free on selected activities!', '2025-02-03', '2025-04-10', 66, 'Cancelled', 42, 45, 3.86);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (59, 63, 'African Expedition', 4910.96, 46, 'City Tour', 'Join us on an adventurous hike through the Swiss Alps. Explore nature, stunning views, and breathtaking landscapes.', 'Limited time offer: Extra 10% off on group bookings.', '2025-01-01', '2025-02-10', 40, 'Completed', 21, 26, 3.39);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (60, 13, 'Australian Adventure', 4508.76, 14, 'Beach', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Early bird discount: 20% off if you book now!', '2025-01-23', '2025-02-20', 28, 'Cancelled', 11, 17, 2.07);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (61, 81, 'European Getaway', 2821.94, 4, 'City Tour', 'Relax and unwind in the Caribbean with our tropical beach resort tour. Enjoy all-inclusive packages and watersport activities.', 'Get a free activity pass for every booking!', '2025-03-06', '2025-04-01', 26, 'Cancelled', 3, 10, 2.06);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (62, 59, 'Australian Adventure', 2267.7, 40, 'Mountain', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Get a free activity pass for every booking!', '2025-02-13', '2025-02-26', 13, 'Cancelled', 35, 13, 2.61);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (63, 30, 'African Safari', 4690.05, 2, 'Beach', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Free entry for kids below 12 years!', '2025-03-21', '2025-03-25', 4, 'Available', 1, 44, 1.81);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (64, 75, 'Asian Safari', 3428.36, 40, 'Cultural', 'Go on a wildlife safari in Kenya. Explore Masai Mara, see lions, elephants, and more, and enjoy luxury tented camps.', 'Free museum entry included with this trip.', '2025-02-08', '2025-04-15', 66, 'Available', 27, 24, 1.97);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (65, 65, 'Australian Getaway', 1012.67, 5, 'City Tour', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Get a free activity pass for every booking!', '2025-01-03', '2025-04-04', 91, 'Completed', 4, 42, 4.41);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (66, 28, 'African Getaway', 2270.81, 37, 'Beach', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Free entry for kids below 12 years!', '2025-03-30', '2025-04-10', 11, 'Available', 20, 12, 3.57);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (67, 14, 'Australian Adventure', 2116.59, 31, 'Safari', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Special rates for returning customers.', '2025-03-26', '2025-04-09', 14, 'Cancelled', 19, 37, 3.81);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (68, 5, 'Asian Cruise', 2199.48, 35, 'Cultural', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Buy 2 get 1 free on selected activities!', '2025-01-02', '2025-02-19', 48, 'Cancelled', 19, 35, 2.07);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (69, 28, 'Australian Safari', 2493.17, 8, 'City Tour', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', '25% off for early bookings!', '2025-02-20', '2025-04-05', 44, 'Available', 1, 7, 2.31);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (70, 91, 'American Adventure', 1391.93, 21, 'City Tour', 'Explore the vibrant city of Barcelona. Visit the Sagrada Familia, Park Guell, and enjoy the Mediterranean cuisine and nightlife.', 'Limited time offer: Extra 10% off on group bookings.', '2025-01-05', '2025-04-04', 89, 'Available', 7, 48, 1.67);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (71, 42, 'American Safari', 1616.22, 30, 'Cultural', 'Embark on an ancient Greek tour and explore ruins like the Acropolis, Parthenon, and visit picturesque islands like Santorini.', 'Early bird discount: 20% off if you book now!', '2025-04-07', '2025-04-09', 2, 'Cancelled', 4, 21, 1.72);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (72, 28, 'European Safari', 4806.86, 50, 'Beach', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Early bird discount: 20% off if you book now!', '2025-03-15', '2025-04-07', 23, 'Completed', 38, 7, 2.03);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (73, 60, 'Australian Expedition', 3535.32, 8, 'Luxury', 'Tour the historic city of Rome and visit landmarks like the Colosseum, Vatican City, and Pantheon.', 'Buy 2 get 1 free on selected activities!', '2025-01-05', '2025-02-28', 54, 'Cancelled', 2, 3, 2.36);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (74, 90, 'Asian Tour', 2902.26, 46, 'Luxury', 'Experience the thrill of a safari in South Africa. See the Big Five in their natural habitat while staying at luxury lodges.', 'Free entry for kids below 12 years!', '2025-02-18', '2025-04-07', 48, 'Available', 36, 50, 1.46);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (75, 63, 'African Expedition', 4207.91, 45, 'Adventure', 'Embark on an ancient Greek tour and explore ruins like the Acropolis, Parthenon, and visit picturesque islands like Santorini.', 'Get a free activity pass for every booking!', '2025-04-12', '2025-04-15', 3, 'Cancelled', 26, 21, 3.8);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (76, 49, 'African Expedition', 1873.53, 45, 'Mountain', 'Experience the stunning beauty of New Zealand on a guided adventure. Visit geothermal parks, beaches, and Maori cultural sites.', 'Limited time offer: Extra 10% off on group bookings.', '2025-01-15', '2025-03-13', 57, 'Cancelled', 41, 11, 4.45);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (77, 88, 'Australian Cruise', 3008.21, 28, 'Cultural', 'Explore the heart of Europe with this immersive cultural tour. Visit historic cities like Paris, Rome, and Amsterdam.', 'Get a free activity pass for every booking!', '2025-02-18', '2025-03-07', 17, 'Available', 22, 10, 4.05);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (78, 33, 'Australian Expedition', 3461.85, 26, 'Beach', 'Experience the stunning beauty of New Zealand on a guided adventure. Visit geothermal parks, beaches, and Maori cultural sites.', 'Limited time offer: Extra 10% off on group bookings.', '2025-01-01', '2025-03-12', 70, 'Cancelled', 12, 41, 3.4);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (79, 53, 'Australian Tour', 2492.55, 14, 'Mountain', 'Experience the stunning beauty of New Zealand on a guided adventure. Visit geothermal parks, beaches, and Maori cultural sites.', 'Special combo deals with other trips.', '2025-03-24', '2025-04-02', 9, 'Available', 4, 7, 4.72);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (80, 78, 'African Tour', 1024.24, 23, 'City Tour', 'Join us on an adventurous hike through the Swiss Alps. Explore nature, stunning views, and breathtaking landscapes.', 'Buy 2 get 1 free on selected activities!', '2025-03-15', '2025-04-01', 17, 'Cancelled', 15, 11, 3.31);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (81, 74, 'European Adventure', 3712.46, 45, 'Luxury', 'Discover the vibrant culture of India with this tour. Visit the Taj Mahal, Jaipur’s palaces, and experience traditional festivals.', 'Limited time offer: Extra 10% off on group bookings.', '2025-02-20', '2025-03-05', 13, 'Available', 25, 50, 4.16);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (82, 29, 'American Tour', 3989.93, 43, 'Cultural', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', 'Book a tour and get a free guide!', '2025-04-03', '2025-04-04', 1, 'Completed', 24, 50, 2.98);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (83, 8, 'African Expedition', 4576.84, 30, 'Adventure', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Early bird discount: 20% off if you book now!', '2025-04-03', '2025-04-08', 5, 'Cancelled', 15, 42, 4.97);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (84, 28, 'European Adventure', 2310.82, 26, 'Beach', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Free entry for kids below 12 years!', '2025-02-26', '2025-04-04', 37, 'Completed', 19, 8, 4.86);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (85, 77, 'American Safari', 3806.06, 47, 'Cultural', 'Relax and unwind in the Caribbean with our tropical beach resort tour. Enjoy all-inclusive packages and watersport activities.', 'Free entry for kids below 12 years!', '2025-02-06', '2025-03-17', 39, 'Cancelled', 42, 21, 3.73);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (86, 21, 'African Safari', 2008.07, 49, 'Cultural', 'Relax and unwind in the Caribbean with our tropical beach resort tour. Enjoy all-inclusive packages and watersport activities.', 'Early bird discount: 20% off if you book now!', '2025-02-20', '2025-04-15', 54, 'Completed', 35, 17, 1.59);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (87, 28, 'European Expedition', 3098.38, 38, 'Luxury', 'Discover ancient Egyptian history with visits to the Pyramids, the Sphinx, and temples in Cairo and Luxor.', '25% off for early bookings!', '2025-01-11', '2025-03-16', 64, 'Cancelled', 27, 48, 1.99);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (88, 53, 'American Safari', 3489.12, 7, 'Safari', 'Relax on pristine beaches in Bali. Enjoy yoga, beach activities, and scenic excursions to temples and cultural sites.', 'Book a tour and get a free guide!', '2025-04-14', '2025-04-16', 2, 'Cancelled', 4, 46, 3.51);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (89, 83, 'European Cruise', 2392.99, 7, 'Luxury', 'Relax and unwind in the Caribbean with our tropical beach resort tour. Enjoy all-inclusive packages and watersport activities.', 'Free entry for kids below 12 years!', '2025-01-31', '2025-03-03', 31, 'Completed', 7, 20, 2.8);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (90, 41, 'African Getaway', 1589.5, 42, 'City Tour', 'Tour the historic city of Rome and visit landmarks like the Colosseum, Vatican City, and Pantheon.', 'Buy 2 get 1 free on selected activities!', '2025-03-27', '2025-04-14', 18, 'Completed', 19, 37, 3.81);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (91, 9, 'African Adventure', 3529.17, 25, 'Mountain', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Early bird discount: 20% off if you book now!', '2025-01-13', '2025-04-15', 92, 'Available', 21, 13, 3.77);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (92, 25, 'Asian Cruise', 3454.01, 43, 'Cultural', 'Embark on an ancient Greek tour and explore ruins like the Acropolis, Parthenon, and visit picturesque islands like Santorini.', 'Special rates for returning customers.', '2025-04-12', '2025-04-14', 2, 'Cancelled', 40, 32, 3.64);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (93, 27, 'American Tour', 1519.26, 42, 'Luxury', 'Relax and unwind in the Caribbean with our tropical beach resort tour. Enjoy all-inclusive packages and watersport activities.', 'Early bird discount: 20% off if you book now!', '2025-03-12', '2025-04-15', 34, 'Cancelled', 10, 6, 3.17);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (94, 3, 'African Adventure', 3478.8, 43, 'Luxury', 'A luxury cruise across the Mediterranean. Enjoy world-class amenities while visiting top destinations like Italy, Greece, and Spain.', 'Buy 2 get 1 free on selected activities!', '2025-01-29', '2025-03-12', 42, 'Completed', 3, 15, 2.12);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (95, 46, 'American Cruise', 1786.53, 39, 'Mountain', 'Experience the stunning beauty of New Zealand on a guided adventure. Visit geothermal parks, beaches, and Maori cultural sites.', 'Special combo deals with other trips.', '2025-01-07', '2025-03-18', 70, 'Available', 37, 22, 2.2);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (96, 20, 'Australian Tour', 2451.0, 47, 'Safari', 'Join us on an adventurous hike through the Swiss Alps. Explore nature, stunning views, and breathtaking landscapes.', 'Book a tour and get a free guide!', '2025-04-16', '2025-04-16', 0, 'Completed', 45, 30, 2.36);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (97, 54, 'American Tour', 3192.67, 50, 'Luxury', 'Experience the thrill of a safari in South Africa. See the Big Five in their natural habitat while staying at luxury lodges.', 'Buy 2 get 1 free on selected activities!', '2025-01-23', '2025-03-04', 40, 'Completed', 16, 31, 1.36);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (98, 75, 'Australian Getaway', 4464.06, 28, 'Safari', 'Enjoy a cultural tour of Japan, including visits to Tokyo, Kyoto, and Osaka. Experience traditional tea ceremonies and festivals.', 'Special rates for returning customers.', '2025-01-13', '2025-03-08', 54, 'Available', 13, 49, 3.92);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (99, 97, 'American Adventure', 1044.59, 43, 'Safari', 'Enjoy a serene road trip across the USA. From coast to coast, experience iconic landmarks, small towns, and national parks.', 'Special combo deals with other trips.', '2025-04-09', '2025-04-12', 3, 'Available', 7, 2, 4.93);
INSERT INTO Trip (TripID, OperatorID, Title, Price, Capacity, TripType, Description, PassesDescription, StartDate, EndDate, Duration, TripStatus, AvailableSlots, GroupSize, Rating) VALUES (100, 73, 'American Tour', 1084.04, 5, 'Luxury', 'Enjoy a nature-filled expedition in Canada’s Rocky Mountains. Hike, camp, and explore Canada’s pristine wilderness.', 'Book a tour and get a free guide!', '2025-03-13', '2025-04-01', 19, 'Completed', 3, 44, 4.13);



-- TRIP ACTIVITIES TABLE DATA
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (1, 91, 'Birdwatching in the Serengeti.', '2024-07-08');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (2, 26, 'Private yacht tour of the Greek islands.', '2023-04-26');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (3, 11, 'Relaxation and yoga retreat in Bali.', '2024-04-07');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (4, 98, 'Scuba diving in the Maldives.', '2024-06-24');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (5, 50, 'Cave exploration in New Zealand.', '2025-02-13');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (6, 57, 'Snorkeling and island hopping in the Philippines.', '2025-01-20');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (7, 36, 'Zip-lining through the Costa Rican rainforests.', '2025-02-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (8, 85, 'Scuba diving in the Maldives.', '2023-11-26');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (9, 94, 'Luxury cruise through the fjords of Norway.', '2023-05-01');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (10, 62, 'Guided walking tour to explore wildlife.', '2024-05-07');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (11, 47, 'Private yacht tour of the Greek islands.', '2023-12-01');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (12, 35, 'Day excursions to various Caribbean islands.', '2025-01-17');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (13, 34, 'Hiking through the Grand Canyon.', '2024-11-26');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (14, 20, 'Exclusive shopping experience in Paris.', '2025-01-22');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (15, 55, 'Private yacht tour of the Greek islands.', '2025-03-08');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (16, 72, 'Cultural exchange program in Japan with local artisans.', '2025-02-14');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (17, 95, 'Luxury wine tasting in the vineyards of Bordeaux.', '2024-03-08');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (18, 96, 'Day excursions to various Caribbean islands.', '2024-12-05');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (19, 64, 'Mountain climbing expedition in the Swiss Alps.', '2024-05-29');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (20, 52, 'Luxury wine tasting in the vineyards of Bordeaux.', '2023-06-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (21, 100, 'Luxury wine tasting in the vineyards of Bordeaux.', '2024-10-30');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (22, 51, 'Helicopter ride over the Grand Canyon.', '2024-07-17');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (23, 99, 'Luxury cruise through the fjords of Norway.', '2023-06-24');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (24, 57, 'Mountain climbing expedition in the Swiss Alps.', '2025-02-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (25, 11, 'Surfing lessons at Bondi Beach.', '2023-07-23');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (26, 100, 'Birdwatching in the Serengeti.', '2024-06-11');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (27, 70, 'Snorkeling and island hopping in the Philippines.', '2024-07-02');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (28, 8, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2024-06-17');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (29, 35, 'Private yacht tour of the Greek islands.', '2025-02-25');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (30, 55, 'Mountain climbing expedition in the Swiss Alps.', '2024-01-26');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (31, 79, 'Snorkeling and island hopping in the Philippines.', '2024-07-28');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (32, 77, 'Day excursions to various Caribbean islands.', '2024-05-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (33, 2, 'Scuba diving in the Maldives.', '2025-03-05');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (34, 93, 'Relaxation and yoga retreat in Bali.', '2023-07-17');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (35, 24, 'Mountain climbing expedition in the Swiss Alps.', '2025-03-22');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (36, 92, 'Visit to the historic city of Venice during a Mediterranean cruise.', '2024-12-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (37, 80, 'Zip-lining through the Costa Rican rainforests.', '2025-03-20');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (38, 75, 'Mountain climbing expedition in the Swiss Alps.', '2025-03-21');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (39, 1, 'Helicopter ride over the Grand Canyon.', '2024-08-12');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (40, 66, 'Private yacht tour of the Greek islands.', '2024-10-20');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (41, 63, 'Private yacht tour of the Greek islands.', '2024-02-15');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (42, 50, 'Day excursions to various Caribbean islands.', '2023-09-06');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (43, 90, 'Zip-lining through the Costa Rican rainforests.', '2024-04-21');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (44, 80, 'Visit to the Taj Mahal followed by a cultural performance.', '2023-08-02');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (45, 32, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2024-08-08');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (46, 87, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2025-02-21');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (47, 60, 'Visit to the Taj Mahal followed by a cultural performance.', '2023-09-21');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (48, 71, 'Traditional tea ceremony in Kyoto.', '2024-10-13');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (49, 9, 'Luxury wine tasting in the vineyards of Bordeaux.', '2024-10-14');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (50, 81, 'Birdwatching in the Serengeti.', '2023-05-21');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (51, 96, 'Luxury wine tasting in the vineyards of Bordeaux.', '2023-05-16');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (52, 95, 'Guided walking tour to explore wildlife.', '2024-08-15');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (53, 82, 'Luxury cruise through the fjords of Norway.', '2023-04-28');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (54, 64, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2024-09-27');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (55, 80, 'Luxury cruise through the fjords of Norway.', '2023-09-18');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (56, 18, 'Private yacht tour of the Greek islands.', '2024-11-16');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (57, 95, 'Relaxation and yoga retreat in Bali.', '2024-07-26');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (58, 96, 'Zip-lining through the Costa Rican rainforests.', '2025-04-11');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (59, 62, 'Snorkeling and island hopping in the Philippines.', '2024-02-09');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (60, 41, 'Visit to the Taj Mahal followed by a cultural performance.', '2024-08-20');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (61, 33, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2023-08-27');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (62, 6, 'Day excursions to various Caribbean islands.', '2023-09-11');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (63, 53, 'Guided walking tour to explore wildlife.', '2024-12-01');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (64, 81, 'Relaxation and yoga retreat in Bali.', '2024-07-15');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (65, 48, 'Safari in Kruger National Park to see the Big Five.', '2023-06-13');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (66, 77, 'Birdwatching in the Serengeti.', '2024-09-07');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (67, 25, 'Visit to the historic city of Venice during a Mediterranean cruise.', '2023-11-20');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (68, 57, 'Zip-lining through the Costa Rican rainforests.', '2023-08-01');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (69, 90, 'Surfing lessons at Bondi Beach.', '2023-10-15');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (70, 10, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2023-11-28');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (71, 1, 'Guided city tour of ancient Rome.', '2023-09-09');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (72, 45, 'Hiking through the Grand Canyon.', '2023-11-12');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (73, 29, 'Morning game drive followed by an evening safari.', '2025-04-05');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (74, 60, 'Guided city tour of ancient Rome.', '2023-11-09');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (75, 84, 'Birdwatching in the Serengeti.', '2023-06-01');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (76, 52, 'Exclusive shopping experience in Paris.', '2024-07-31');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (77, 3, 'Private yacht tour of the Greek islands.', '2024-04-27');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (78, 57, 'Surfing lessons at Bondi Beach.', '2023-04-29');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (79, 98, 'Helicopter ride over the Grand Canyon.', '2023-09-10');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (80, 25, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2023-10-16');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (81, 1, 'Hiking through the Grand Canyon.', '2024-06-07');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (82, 55, 'Hiking through the Grand Canyon.', '2024-09-15');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (83, 15, 'Zip-lining through the Costa Rican rainforests.', '2024-03-31');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (84, 27, 'Cruise with stops in Barcelona, Rome, and Monaco.', '2024-08-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (85, 68, 'Morning game drive followed by an evening safari.', '2023-06-30');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (86, 39, 'Guided city tour of ancient Rome.', '2024-05-09');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (87, 66, 'Guided city tour of ancient Rome.', '2023-08-30');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (88, 47, 'Morning game drive followed by an evening safari.', '2024-11-04');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (89, 41, 'Cultural exchange program in Japan with local artisans.', '2025-01-12');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (90, 28, 'Luxury wine tasting in the vineyards of Bordeaux.', '2023-11-23');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (91, 59, 'Zip-lining through the Costa Rican rainforests.', '2025-04-10');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (92, 81, 'Birdwatching in the Serengeti.', '2023-10-03');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (93, 59, 'Surfing lessons at Bondi Beach.', '2024-05-13');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (94, 96, 'Visit to the historic city of Venice during a Mediterranean cruise.', '2024-01-05');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (95, 37, 'Zip-lining through the Costa Rican rainforests.', '2023-04-30');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (96, 7, 'Snorkeling and island hopping in the Philippines.', '2024-07-02');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (97, 5, 'Morning game drive followed by an evening safari.', '2024-06-26');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (98, 68, 'Visit to the Taj Mahal followed by a cultural performance.', '2024-02-23');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (99, 79, 'Birdwatching in the Serengeti.', '2025-01-14');
INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate) VALUES (100, 97, 'Guided city tour of ancient Rome.', '2024-11-28');


-- TRIP INVOLVES TABLE DATA
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (1, 38, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (2, 83, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (2, 37, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (2, 62, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (3, 33, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (4, 68, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (4, 66, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (5, 9, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (6, 56, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (6, 91, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (7, 21, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (7, 40, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (7, 94, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (8, 80, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (8, 34, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (9, 27, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (9, 76, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (9, 80, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (10, 77, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (10, 29, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (10, 28, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (11, 95, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (11, 67, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (11, 16, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (12, 45, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (12, 59, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (12, 86, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (13, 6, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (13, 76, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (14, 78, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (15, 35, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (15, 32, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (16, 53, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (17, 39, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (17, 32, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (17, 87, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (18, 27, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (18, 49, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (19, 88, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (19, 86, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (19, 65, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (20, 41, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (20, 12, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (21, 13, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (22, 62, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (22, 32, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (22, 93, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (23, 69, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (23, 47, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (23, 70, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (24, 57, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (24, 79, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (24, 66, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (25, 90, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (25, 7, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (25, 70, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (26, 32, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (26, 96, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (27, 92, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (28, 94, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (29, 94, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (29, 49, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (29, 65, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (30, 44, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (30, 10, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (31, 44, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (31, 5, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (31, 64, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (32, 35, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (33, 62, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (34, 79, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (34, 75, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (35, 43, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (35, 68, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (35, 91, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (36, 31, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (37, 7, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (38, 5, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (38, 97, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (39, 31, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (40, 75, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (40, 24, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (41, 59, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (41, 85, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (42, 81, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (43, 14, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (44, 94, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (44, 38, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (44, 94, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (45, 58, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (46, 90, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (46, 53, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (46, 88, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (47, 25, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (47, 84, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (48, 24, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (48, 60, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (49, 87, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (49, 80, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (49, 70, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (50, 95, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (51, 53, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (51, 18, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (52, 38, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (52, 44, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (53, 68, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (53, 46, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (53, 59, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (54, 2, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (54, 43, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (55, 58, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (55, 84, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (55, 6, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (56, 71, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (56, 85, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (57, 17, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (57, 19, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (58, 59, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (58, 39, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (59, 91, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (59, 65, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (60, 44, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (60, 49, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (60, 89, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (61, 31, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (61, 15, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (62, 50, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (62, 73, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (63, 88, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (63, 20, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (64, 40, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (65, 87, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (66, 52, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (66, 30, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (66, 10, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (67, 67, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (68, 76, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (68, 81, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (69, 25, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (69, 14, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (69, 62, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (70, 24, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (71, 63, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (71, 98, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (71, 81, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (72, 99, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (72, 22, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (73, 26, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (73, 34, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (74, 48, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (75, 93, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (75, 30, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (75, 2, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (76, 31, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (77, 45, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (78, 57, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (79, 65, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (79, 8, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (80, 59, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (80, 23, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (81, 54, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (82, 69, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (82, 10, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (82, 85, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (83, 49, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (83, 32, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (83, 84, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (84, 53, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (85, 75, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (85, 37, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (85, 100, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (86, 21, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (86, 19, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (87, 34, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (88, 65, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (89, 90, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (90, 31, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (90, 5, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (90, 15, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (91, 87, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (92, 85, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (93, 23, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (93, 15, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (93, 11, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (94, 19, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (94, 98, 'Activity Leader');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (94, 37, 'Food Provider');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (95, 8, 'Entertainment');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (95, 18, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (95, 97, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (96, 67, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (97, 35, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (98, 61, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (98, 96, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (98, 46, 'Tour Guide');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (99, 59, 'Transport');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (100, 18, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (100, 9, 'Accommodation');
INSERT INTO TripInvolves (TripID, ServiceProviderID, Role) VALUES (100, 4, 'Food Provider');


-- HOTEL SERVICE PROVIDER PERFORMANCE TABLE DATA
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (51.0, 92.0, 93.68, 3.93, 98.29, 97.35);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (34.0, 78.0, 52.46, 2.2, 97.17, 89.64);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (6.0, 4.0, 53.56, 3.7, 66.36, 74.36);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (96.0, 41.0, 69.81, 3.87, 71.79, 54.65);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (62.0, 45.0, 50.1, 3.2, 81.9, 53.57);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (86.0, 26.0, 51.66, 3.22, 68.29, 94.0);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (63.0, 68.0, 62.89, 3.23, 63.74, 56.2);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (48.0, 88.0, 71.98, 4.46, 90.98, 97.17);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (81.0, 98.0, 50.96, 2.67, 72.57, 95.6);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (21.0, 83.0, 80.54, 1.41, 87.68, 94.86);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (14.0, 86.0, 71.3, 3.9, 67.09, 66.49);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (86.0, 70.0, 76.62, 1.31, 99.24, 81.02);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (30.0, 62.0, 71.93, 1.25, 83.41, 88.66);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (73.0, 59.0, 96.46, 1.15, 61.25, 98.24);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (77.0, 83.0, 96.79, 4.51, 91.97, 54.4);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (20.0, 60.0, 56.89, 2.27, 74.23, 98.93);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (57.0, 27.0, 71.86, 1.58, 77.68, 77.06);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (79.0, 42.0, 52.61, 1.94, 78.86, 88.35);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (46.0, 16.0, 93.01, 3.53, 67.83, 68.99);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (2.0, 74.0, 94.71, 4.65, 65.15, 52.49);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (8.0, 46.0, 97.08, 2.85, 61.6, 56.43);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (59.0, 77.0, 67.16, 2.81, 88.59, 91.99);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (54.0, 39.0, 58.62, 2.06, 86.36, 74.38);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (18.0, 14.0, 93.41, 1.97, 77.7, 52.86);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (59.0, 51.0, 93.57, 2.37, 67.46, 77.83);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (62.0, 35.0, 71.54, 2.3, 63.92, 51.38);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (26.0, 2.0, 74.26, 4.31, 61.82, 83.27);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (98.0, 60.0, 72.32, 2.44, 74.77, 80.75);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (12.0, 56.0, 64.32, 1.71, 88.27, 51.5);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (49.0, 51.0, 79.8, 4.54, 98.44, 59.97);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (13.0, 89.0, 68.43, 3.19, 75.69, 83.37);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (24.0, 12.0, 52.26, 1.54, 82.38, 90.7);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (88.0, 100.0, 86.62, 2.57, 81.17, 99.77);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (1.0, 77.0, 85.31, 2.71, 76.21, 99.34);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (4.0, 24.0, 84.78, 4.08, 86.32, 81.54);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (85.0, 11.0, 60.65, 1.95, 62.18, 83.46);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (17.0, 73.0, 50.69, 2.91, 74.95, 94.52);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (35.0, 21.0, 62.44, 1.9, 86.89, 61.38);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (28.0, 51.0, 65.63, 4.13, 63.81, 52.97);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (73.0, 97.0, 91.74, 4.32, 79.95, 85.64);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (61.0, 58.0, 81.35, 3.34, 83.91, 95.16);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (64.0, 81.0, 53.32, 3.85, 67.27, 60.43);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (65.0, 60.0, 60.51, 2.04, 91.75, 57.16);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (31.0, 49.0, 64.85, 3.32, 98.06, 69.52);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (46.0, 90.0, 66.37, 3.59, 63.99, 99.7);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (39.0, 32.0, 99.48, 1.08, 87.31, 90.08);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (38.0, 62.0, 89.07, 2.8, 97.42, 94.52);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (19.0, 84.0, 79.64, 4.02, 84.65, 75.83);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (66.0, 96.0, 62.15, 1.37, 63.41, 95.4);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (73.0, 3.0, 64.47, 2.89, 69.16, 73.47);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (7.0, 62.0, 68.64, 4.26, 76.77, 53.83);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (93.0, 37.0, 93.96, 4.31, 62.83, 90.58);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (16.0, 44.0, 64.59, 4.95, 72.93, 68.86);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (74.0, 1.0, 84.83, 2.43, 84.02, 92.19);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (3.0, 59.0, 86.57, 3.04, 74.96, 59.84);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (22.0, 13.0, 97.21, 3.92, 66.36, 90.87);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (18.0, 48.0, 75.7, 2.72, 98.43, 59.34);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (10.0, 96.0, 83.39, 1.01, 74.44, 89.65);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (66.0, 28.0, 70.43, 2.18, 88.11, 89.75);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (71.0, 96.0, 67.57, 2.78, 84.69, 88.81);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (50.0, 12.0, 83.06, 4.36, 70.24, 53.63);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (56.0, 46.0, 97.87, 3.26, 86.26, 54.44);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (9.0, 50.0, 69.95, 4.49, 90.57, 57.69);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (62.0, 42.0, 71.93, 2.54, 73.7, 64.6);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (28.0, 49.0, 64.04, 1.1, 98.58, 58.07);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (78.0, 16.0, 90.42, 2.55, 75.43, 61.37);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (84.0, 27.0, 99.83, 1.21, 77.33, 91.47);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (53.0, 74.0, 84.85, 3.79, 96.73, 63.5);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (39.0, 58.0, 84.32, 3.01, 78.55, 98.85);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (12.0, 36.0, 94.76, 3.28, 96.64, 63.25);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (9.0, 75.0, 50.63, 2.04, 76.5, 76.76);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (93.0, 69.0, 88.08, 1.1, 65.97, 67.41);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (14.0, 23.0, 69.78, 3.12, 96.31, 98.97);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (41.0, 77.0, 70.96, 2.75, 84.16, 96.28);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (83.0, 49.0, 69.62, 2.41, 96.1, 73.53);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (4.0, 53.0, 73.25, 4.42, 69.1, 74.45);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (89.0, 10.0, 87.25, 1.85, 92.48, 87.37);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (5.0, 14.0, 93.73, 2.84, 86.14, 60.55);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (30.0, 84.0, 84.75, 2.65, 81.0, 67.44);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (70.0, 73.0, 92.72, 3.54, 73.84, 91.56);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (82.0, 56.0, 75.57, 2.77, 79.47, 61.69);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (27.0, 64.0, 74.77, 3.71, 83.23, 90.26);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (19.0, 35.0, 57.04, 3.3, 65.39, 97.92);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (20.0, 29.0, 59.71, 3.65, 75.73, 78.55);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (22.0, 84.0, 62.09, 4.18, 63.14, 91.76);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (48.0, 42.0, 97.27, 2.95, 85.99, 71.29);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (87.0, 77.0, 95.66, 1.79, 60.26, 82.86);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (48.0, 69.0, 89.9, 4.99, 67.46, 93.48);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (44.0, 77.0, 87.83, 4.07, 64.83, 94.56);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (16.0, 96.0, 58.45, 1.67, 63.04, 61.87);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (24.0, 58.0, 63.32, 1.39, 79.72, 75.1);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (96.0, 19.0, 83.19, 2.1, 62.69, 62.82);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (61.0, 35.0, 89.06, 4.36, 66.14, 56.65);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (99.0, 38.0, 81.02, 2.12, 88.98, 65.88);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (62.0, 54.0, 61.74, 3.02, 99.98, 54.97);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (67.0, 44.0, 72.63, 3.58, 96.68, 58.76);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (27.0, 37.0, 90.78, 3.44, 93.71, 89.92);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (74.0, 93.0, 61.41, 3.03, 60.72, 97.75);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (97.0, 17.0, 52.85, 2.22, 82.52, 97.09);
INSERT INTO ServiceProviderPerformance (ServiceProviderID, TourOperatorID, HotelOccupancyRate, GuideRatings, TransportOnTimePerformance, ServiceUtilization) VALUES (60.0, 24.0, 64.57, 1.77, 89.4, 91.99);

-- Check the definition of the constraint
SELECT OBJECT_DEFINITION(OBJECT_ID('CK__Traveler__Passwo__59FA5E80'));
ALTER TABLE Traveler
DROP CONSTRAINT CK__Traveler__Passwo__59FA5E80;

ALTER TABLE Traveler
ADD CONSTRAINT CK_Traveler_Password
CHECK (
    LEN([Password]) > 8 
    AND [Password] LIKE '%[A-Za-z]%' 
    AND [Password] LIKE '%[0-9]%' 
    AND [Password] LIKE '%[!]%'
);


ALTER TABLE HotelServiceProvider
ADD Password VARCHAR(255) NULL;

ALTER TABLE HotelServiceProvider
ADD CONSTRAINT chk_PasswordStrength
CHECK (
    LEN([Password]) > 8 
    AND [Password] LIKE '%[A-Za-z]%' 
    AND [Password] LIKE '%[0-9]%' 
    AND [Password] LIKE '%[!]%'
);

-- TRAVELER TABLE DATA
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (1, 'Ethan Carter', 'Password2849!', 'USCGC Nielsen, FPO AE 01244', 'Male', 'India', '1971-07-04', 'Backpacking through Europe, including stops in Italy and France.', 'Adventure, Safari', 99);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (2, 'Alice Brown', 'Password7258!', '6472 Lewis Overpass, North Keith, MD 12823', 'Female', 'Australia', '2002-11-05', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Beach, Luxury', 62);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (3, 'Ethan Carter', 'Password3304!', '426 Danielle Parks Apt. 774, Whitneyfurt, IL 41737', 'Female', 'Brazil', '1999-03-19', 'Trekking in the Amazon rainforest, learning about indigenous cultures.', 'Adventure, Cultural, Beach', 98);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (4, 'Jane Smith', 'Password1610!', '475 William Terrace Suite 566, Port Deannaview, CT 41535', 'Female', 'India', '1972-07-10', 'Trekking in the Amazon rainforest, learning about indigenous cultures.', 'Luxury, Adventure', 25);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (5, 'Sophia Lewis', 'Password5434!', '1329 Trevor View Suite 062, East Megantown, NY 84192', 'Female', 'Australia', '1974-06-25', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Beach', 39);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (6, 'Lucas Young', 'Password3519!', '580 Olson Throughway Apt. 671, Charlesmouth, MS 69273', 'Female', 'South Africa', '1998-01-17', 'Trekking in the Himalayas, exploring remote villages.', 'Historical, Safari, Luxury', 16);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (7, 'John Doe', 'Password2954!', 'Unit 2764 Box 9037, DPO AA 93203', 'Female', 'Germany', '2006-04-27', 'Exploring Australia’s Great Barrier Reef, snorkeling and diving.', 'Historical', 47);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (8, 'Jane Smith', 'Password2926!', '3816 Wallace Well, Kellytown, RI 88693', 'Male', 'Australia', '1956-11-27', 'Cruised through the Caribbean islands, enjoying sunny beaches.', 'Beach, Cultural', 68);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (9, 'Lucas Young', 'Password2642!', '6611 Todd Turnpike Apt. 782, Elizabethton, GA 64442', 'Female', 'South Africa', '1973-12-14', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Cruise, Luxury, Adventure', 2);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (10, 'Sophia Lewis', 'Password5432!', '39605 Jeffery Port Apt. 010, South Amber, PA 51054', 'Female', 'UK', '1982-12-12', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Historical, Luxury', 98);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (11, 'Charlotte Green', 'Password8483!', '9523 Gonzalez Junctions, Aliciahaven, NM 88973', 'Male', 'Australia', '2001-01-23', 'A nature retreat in the Swiss Alps, hiking and relaxing.', 'Cultural, Adventure, Safari', 79);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (12, 'Ava Scott', 'Password6231!', '20395 Parker Prairie, Marilynview, CO 48226', 'Female', 'Australia', '1996-10-14', 'Visited Paris for a cultural tour and sightseeing.', 'Safari, Cruise', 38);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (13, 'Isabella Walker', 'Password3998!', '175 Johnson Land, Carpenterborough, MN 47625', 'Male', 'Brazil', '1975-12-04', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Historical, Adventure, Beach', 82);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (14, 'Emily Davis', 'Password1095!', '32581 Kelly Flat, Amandaburgh, NY 87145', 'Female', 'Australia', '1958-11-12', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Historical, Beach, Adventure', 47);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (15, 'Charlotte Green', 'Password5905!', '108 Williams Plaza Suite 280, Gomezview, CA 79093', 'Male', 'Australia', '1991-10-24', 'Tour of historic castles in Scotland, hiking and guided tours.', 'Adventure, Cruise, Beach', 90);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (16, 'Mia Perez', 'Password2818!', '269 Katherine Passage Apt. 027, New Susanville, WY 64684', 'Male', 'Australia', '1972-12-27', 'Relaxed on the beaches of Bali, enjoying water sports and yoga.', 'Historical, Safari', 79);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (17, 'Jane Smith', 'Password5822!', '9060 Melody Centers, Jamesview, AL 03140', 'Male', 'USA', '1955-07-06', 'Visited Paris for a cultural tour and sightseeing.', 'Safari, Luxury', 39);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (18, 'Lucas Young', 'Password5387!', '82166 Gregory Parks, Flynnton, KY 47245', 'Male', 'USA', '1976-03-21', 'Visited Paris for a cultural tour and sightseeing.', 'Cultural', 96);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (19, 'Emma White', 'Password1639!', '730 Marcus Prairie, Tiffanyton, PA 71572', 'Male', 'Australia', '1960-05-21', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Cultural, Beach, Adventure', 23);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (20, 'Mia Perez', 'Password7182!', '9657 Courtney Ranch, Mortonberg, ME 38533', 'Female', 'UK', '1988-03-22', 'Backpacking through Europe, including stops in Italy and France.', 'Safari, Cultural', 81);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (21, 'Lucas Young', 'Password1776!', '34375 William Camp Apt. 158, North Kristine, ID 95129', 'Male', 'Canada', '1964-04-23', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Adventure', 55);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (22, 'Sarah Miller', 'Password1439!', '6771 Lisa Dam Apt. 945, East Carlaburgh, CA 28123', 'Female', 'UK', '1974-08-30', 'Explored the ancient ruins of Egypt, including the Pyramids of Giza.', 'Cultural, Cruise, Safari', 42);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (23, 'Emma White', 'Password5029!', 'PSC 5660, Box 1764, APO AP 14619', 'Male', 'India', '1963-08-16', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Historical, Adventure', 25);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (24, 'Oliver Harris', 'Password5258!', '0561 Wendy Ranch, Lake Stevenfurt, IA 18534', 'Male', 'USA', '1966-07-15', 'Exploring Australia’s Great Barrier Reef, snorkeling and diving.', 'Historical, Safari', 84);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (25, 'Emma White', 'Password2144!', '755 Foley Forges Suite 814, East Sheilachester, VT 79841', 'Female', 'Brazil', '1987-07-10', 'Cruised through the Caribbean islands, enjoying sunny beaches.', 'Cruise, Adventure, Beach', 12);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (26, 'Alice Brown', 'Password8765!', 'Unit 7973 Box 3131, DPO AP 04968', 'Male', 'Germany', '1973-06-22', 'Trekking in the Amazon rainforest, learning about indigenous cultures.', 'Safari', 79);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (27, 'Bob Johnson', 'Password3648!', '741 Sara Pines Apt. 084, North Jenniferview, NE 95239', 'Male', 'Germany', '1978-12-28', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Cultural', 53);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (28, 'Bob Johnson', 'Password8366!', '89350 Holly Lodge, Ericksonland, OR 56390', 'Female', 'India', '1994-11-11', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Adventure, Luxury, Historical', 69);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (29, 'Michael Clark', 'Password8922!', '71623 Cohen Drives Apt. 710, South Kristen, MN 15040', 'Female', 'Germany', '1961-01-23', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Luxury, Adventure', 79);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (30, 'Jane Smith', 'Password2743!', '207 Sullivan Freeway Suite 298, Lisaview, UT 22320', 'Female', 'USA', '1967-11-27', 'Cruised through the Caribbean islands, enjoying sunny beaches.', 'Safari', 92);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (31, 'Ethan Carter', 'Password2199!', '1832 Mason Parkway, New Meganbury, NV 16034', 'Male', 'USA', '1964-10-17', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Cultural, Safari, Luxury', 50);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (32, 'John Doe', 'Password2401!', 'PSC 5423, Box 0230, APO AE 72098', 'Male', 'Germany', '1995-12-30', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Cruise, Historical, Safari', 1);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (33, 'Mason Allen', 'Password4727!', '2857 Delgado Vista Suite 050, Webbmouth, ME 68116', 'Female', 'Germany', '1970-06-18', 'Relaxed on the beaches of Bali, enjoying water sports and yoga.', 'Beach, Adventure, Cruise', 34);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (34, 'Emma White', 'Password1295!', '86532 Kathryn Crest Suite 925, Osborneberg, VT 80328', 'Female', 'Germany', '1987-03-10', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Adventure, Historical, Safari', 18);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (35, 'John Doe', 'Password8453!', '400 Aaron Trail Suite 346, East Charles, SD 49474', 'Male', 'South Africa', '1984-01-07', 'Exploring Australia’s Great Barrier Reef, snorkeling and diving.', 'Cultural', 93);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (36, 'James King', 'Password5703!', '44579 Joshua Overpass, Stevenport, KY 75611', 'Male', 'UK', '1968-04-06', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Cultural', 1);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (37, 'Mason Allen', 'Password1354!', '38038 Walker Knoll, Brewertown, NM 38174', 'Female', 'Australia', '1982-07-23', 'Explored the ancient ruins of Egypt, including the Pyramids of Giza.', 'Cultural', 65);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (38, 'Ethan Carter', 'Password4966!', '742 Palmer Roads, Andersonland, NH 49544', 'Male', 'USA', '2006-02-28', 'Backpacking through Europe, including stops in Italy and France.', 'Adventure, Beach', 70);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (39, 'Alice Brown', 'Password2184!', '92895 Brooks Underpass Suite 496, West Donaldhaven, FL 35525', 'Female', 'USA', '1959-04-06', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Adventure, Historical, Beach', 34);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (40, 'Oliver Harris', 'Password6333!', '80112 Cummings Viaduct Apt. 475, Lisashire, MT 46877', 'Female', 'Germany', '1979-01-05', 'Backpacking through Europe, including stops in Italy and France.', 'Adventure, Cultural, Cruise', 97);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (41, 'Liam Moore', 'Password6739!', '67882 Justin Center, Jeffreybury, ND 11471', 'Male', 'South Africa', '1972-04-02', 'Relaxed on the beaches of Bali, enjoying water sports and yoga.', 'Historical, Adventure', 39);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (42, 'David Wilson', 'Password4591!', '4930 Nunez Viaduct Apt. 842, Willischester, ND 04120', 'Male', 'India', '1955-06-14', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Luxury, Historical', 94);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (43, 'Emma White', 'Password7840!', '77363 Darren Grove, New John, MI 16013', 'Female', 'India', '2001-09-09', 'Road trip across the USA, from New York to Los Angeles.', 'Safari, Beach, Adventure', 22);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (44, 'David Wilson', 'Password1902!', '800 Stephanie Freeway Suite 706, Port Danielberg, OR 14799', 'Male', 'South Africa', '1997-08-03', 'Cultural exchange program in Japan, experiencing traditional tea ceremonies.', 'Safari, Cultural', 25);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (45, 'Emma White', 'Password9271!', '096 Taylor Plains Suite 444, New Cherylbury, SD 97557', 'Male', 'South Africa', '1965-11-26', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Beach, Luxury', 91);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (46, 'John Doe', 'Password6650!', '272 Chambers Locks, South Alexanderport, UT 68088', 'Female', 'Australia', '1996-02-13', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Cruise, Safari, Cultural', 21);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (47, 'Emma White', 'Password3903!', '89367 Pam Green Apt. 689, Port Scottmouth, OR 40846', 'Male', 'UK', '1975-04-18', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Adventure, Safari', 52);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (48, 'Alice Brown', 'Password4185!', '162 Bobby Crescent Apt. 351, East Patricia, NE 66164', 'Male', 'USA', '1988-03-14', 'Safari in South Africa, exploring Kruger National Park.', 'Beach, Cultural', 28);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (49, 'James King', 'Password4104!', 'PSC 7878, Box 9555, APO AP 39197', 'Male', 'Brazil', '1970-06-19', 'Visited the Great Wall of China and other historical landmarks.', 'Safari, Cultural', 28);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (50, 'Oliver Harris', 'Password5316!', '87394 Martinez Terrace, East Jasonville, IA 23303', 'Male', 'Brazil', '1994-08-01', 'A culinary tour of Italy, exploring local markets and cooking classes.', 'Cultural, Adventure, Historical', 5);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (51, 'James King', 'Password7367!', '46440 Williams Springs, Carpentermouth, MO 97706', 'Male', 'Brazil', '1981-06-19', 'Explored the ancient ruins of Egypt, including the Pyramids of Giza.', 'Beach, Safari, Adventure', 89);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (52, 'Ava Scott', 'Password1629!', '007 Holly Viaduct Apt. 560, South Seanview, GA 20901', 'Male', 'Australia', '1960-04-03', 'Relaxed on the beaches of Bali, enjoying water sports and yoga.', 'Adventure', 86);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (53, 'Michael Clark', 'Password8431!', '71451 Logan Extension, North April, NM 17282', 'Male', 'Canada', '1970-10-08', 'Trekking in the Himalayas, exploring remote villages.', 'Beach', 1);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (54, 'Bob Johnson', 'Password6681!', '892 Saunders Corner, South Natashaside, UT 56374', 'Female', 'UK', '1996-02-14', 'A nature retreat in the Swiss Alps, hiking and relaxing.', 'Safari, Historical', 89);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (55, 'Liam Moore', 'Password5511!', '520 Hood Rapids, Fisherton, HI 44017', 'Female', 'UK', '1987-08-03', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Cultural', 12);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (56, 'Oliver Harris', 'Password3303!', '0290 Jasmine Alley Suite 555, Port Brian, UT 18156', 'Female', 'USA', '1983-06-21', 'Tour of historic castles in Scotland, hiking and guided tours.', 'Adventure, Cruise', 31);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (57, 'James King', 'Password4035!', '61766 Michael Summit Suite 085, Lake Michelle, NH 19986', 'Female', 'Australia', '1988-02-04', 'Explored the ancient ruins of Egypt, including the Pyramids of Giza.', 'Beach', 17);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (58, 'Emma White', 'Password6067!', 'USCGC Johnston, FPO AA 09319', 'Female', 'South Africa', '1993-08-12', 'A culinary tour of Italy, exploring local markets and cooking classes.', 'Adventure', 74);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (59, 'Alice Brown', 'Password1631!', 'PSC 8687, Box 3401, APO AE 23486', 'Male', 'Australia', '1991-11-25', 'Relaxed on the beaches of Bali, enjoying water sports and yoga.', 'Historical, Cultural, Luxury', 43);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (60, 'Charlotte Green', 'Password3748!', '7661 Jasmine Springs, Lake Destinyfort, OH 37083', 'Female', 'Australia', '2004-02-14', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Historical', 23);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (61, 'Jane Smith', 'Password8287!', '4912 Mullen Village Apt. 039, New Cheryl, WA 09720', 'Male', 'Australia', '1975-09-06', 'Visited Paris for a cultural tour and sightseeing.', 'Cultural', 79);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (62, 'Ava Scott', 'Password8202!', '138 Mcknight Port Suite 712, East Andrea, NV 23847', 'Female', 'UK', '1977-05-16', 'Relaxed on the beaches of Bali, enjoying water sports and yoga.', 'Safari', 83);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (63, 'Charlotte Green', 'Password3039!', '8680 Tiffany Light Suite 210, North Carolynberg, OH 05351', 'Male', 'India', '1959-03-07', 'Trekking in the Himalayas, exploring remote villages.', 'Cruise, Cultural, Beach', 35);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (64, 'Isabella Walker', 'Password3649!', 'USNV Grant, FPO AP 26061', 'Male', 'South Africa', '1981-03-04', 'Luxury cruise across the Mediterranean, stopping in Italy, Spain, and Greece.', 'Historical, Beach', 80);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (65, 'Isabella Walker', 'Password1505!', '4929 Rios Highway Suite 800, Port Michael, AR 13238', 'Female', 'Brazil', '1967-03-11', 'Safari in South Africa, exploring Kruger National Park.', 'Historical', 8);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (66, 'Charlotte Green', 'Password4617!', '0867 Kathryn Alley, East Ryanton, PA 85589', 'Male', 'Brazil', '1955-08-31', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Cruise, Cultural', 7);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (67, 'Emily Davis', 'Password8576!', '60958 Rasmussen Burgs Apt. 601, Kathyfurt, NH 62067', 'Female', 'Canada', '2002-12-10', 'Tour of historic castles in Scotland, hiking and guided tours.', 'Luxury', 83);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (68, 'David Wilson', 'Password7111!', '60673 Anderson Views Apt. 219, Port Stephanie, SD 22966', 'Male', 'Brazil', '1956-02-20', 'Trekking in the Amazon rainforest, learning about indigenous cultures.', 'Historical', 83);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (69, 'Alice Brown', 'Password8465!', 'PSC 1128, Box 0764, APO AE 74532', 'Male', 'South Africa', '1987-10-25', 'Tour of historic castles in Scotland, hiking and guided tours.', 'Safari, Luxury', 85);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (70, 'Jane Smith', 'Password4378!', '9264 Kenneth Locks, Collinsburgh, AR 49680', 'Male', 'Canada', '1998-04-16', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Historical, Beach, Cultural', 19);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (71, 'Isabella Walker', 'Password4147!', '93323 Hill Cove Apt. 449, Amytown, HI 34416', 'Female', 'Australia', '2005-07-27', 'Tour of historic castles in Scotland, hiking and guided tours.', 'Historical', 5);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (72, 'Charlotte Green', 'Password9199!', '6873 Shelton Islands, Lake Bethfort, IA 66728', 'Female', 'Brazil', '1982-06-24', 'Visit to Iceland, exploring glaciers, volcanoes, and hot springs.', 'Adventure', 91);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (73, 'Bob Johnson', 'Password6448!', '807 Brian Manors, Millerfort, WA 73694', 'Male', 'South Africa', '1987-02-15', 'Trekking in the Himalayas, exploring remote villages.', 'Adventure, Cultural', 39);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (74, 'Emma White', 'Password7766!', '403 Amanda Lodge Apt. 629, Lake Alicialand, MS 60464', 'Male', 'USA', '2002-03-09', 'Trekking in the Amazon rainforest, learning about indigenous cultures.', 'Cultural', 16);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (75, 'Isabella Walker', 'Password8729!', '1738 Reyes Squares, Phillipsland, WV 79303', 'Male', 'South Africa', '1965-12-13', 'Trekking in the Himalayas, exploring remote villages.', 'Cruise, Safari', 51);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (76, 'Lucas Young', 'Password4092!', '587 Taylor Fork, Hernandezchester, MI 69762', 'Female', 'Brazil', '1970-02-12', 'Tour of historic castles in Scotland, hiking and guided tours.', 'Cultural', 14);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (77, 'John Doe', 'Password7261!', '64607 Carolyn Point, West Parkerside, LA 54594', 'Male', 'USA', '1997-01-15', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Cruise, Historical', 33);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (78, 'Emily Davis', 'Password1680!', '482 Perez Circles, North Robinport, MT 36155', 'Female', 'USA', '2003-12-04', 'Visited Paris for a cultural tour and sightseeing.', 'Cultural, Luxury, Safari', 68);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (79, 'Oliver Harris', 'Password8049!', '24985 Bernard Cove Suite 697, Port Shannon, NM 28319', 'Male', 'USA', '1977-12-15', 'Visited Paris for a cultural tour and sightseeing.', 'Adventure', 81);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (80, 'James King', 'Password5034!', '0402 Wright Motorway, North Veronicaville, NM 23596', 'Male', 'Australia', '1967-04-14', 'A nature retreat in the Swiss Alps, hiking and relaxing.', 'Adventure, Historical', 99);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (81, 'Alice Brown', 'Password6998!', '83445 Flores Street, Smithport, WY 20590', 'Female', 'South Africa', '1994-06-13', 'Visited Paris for a cultural tour and sightseeing.', 'Beach, Adventure', 21);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (82, 'Sarah Miller', 'Password8411!', '1447 Rojas Mission Suite 251, Julieburgh, MS 17561', 'Male', 'USA', '2006-01-10', 'Trekking in the Amazon rainforest, learning about indigenous cultures.', 'Luxury, Cruise', 31);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (83, 'Mason Allen', 'Password5301!', '322 Bush Road Apt. 351, Janetfurt, GA 86791', 'Female', 'USA', '1991-05-31', 'Visited Paris for a cultural tour and sightseeing.', 'Adventure, Beach', 20);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (84, 'Liam Moore', 'Password5091!', '54095 Boyer Pass Suite 029, Port Antonio, GA 95768', 'Female', 'USA', '1971-11-08', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Luxury', 77);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (85, 'Mia Perez', 'Password5628!', '588 Lee Square, New Keithfurt, LA 61588', 'Male', 'Germany', '1978-09-02', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Beach', 80);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (86, 'Emily Davis', 'Password6435!', '65312 Smith Parkways Apt. 298, Thomaston, NJ 20851', 'Male', 'India', '1955-03-25', 'Cruised through the Caribbean islands, enjoying sunny beaches.', 'Beach, Safari, Cruise', 67);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (87, 'David Wilson', 'Password8746!', '91474 Ian Lights, Johnsonborough, AZ 15513', 'Male', 'India', '2005-11-09', 'Exploring Australia’s Great Barrier Reef, snorkeling and diving.', 'Safari, Adventure, Historical', 35);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (88, 'Michael Clark', 'Password6175!', '4731 Alisha Harbor, Shawnhaven, WI 53856', 'Male', 'Canada', '1958-03-16', 'Road trip across the USA, from New York to Los Angeles.', 'Beach', 3);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (89, 'Isabella Walker', 'Password9111!', '511 Baker Bypass, New Kathy, MS 57833', 'Female', 'South Africa', '1976-11-16', 'Exploring Australia’s Great Barrier Reef, snorkeling and diving.', 'Adventure, Historical, Cruise', 1);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (90, 'David Wilson', 'Password3811!', '7942 Flores Fork, Melvinton, CA 74101', 'Male', 'Australia', '1984-06-25', 'Cultural immersion in India, exploring Delhi, Jaipur, and Agra.', 'Safari', 5);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (91, 'John Doe', 'Password3377!', '72765 Daniel Cove Suite 247, New Russellmouth, TX 96091', 'Female', 'India', '1997-03-28', 'Road trip across the USA, from New York to Los Angeles.', 'Cultural, Luxury', 19);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (92, 'Liam Moore', 'Password6410!', 'USS Patterson, FPO AE 68456', 'Female', 'Australia', '1994-10-14', 'Exploring Australia’s Great Barrier Reef, snorkeling and diving.', 'Safari, Cruise, Cultural', 92);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (93, 'Ava Scott', 'Password2446!', '923 Wilson Spring, Port Michael, NH 18201', 'Male', 'India', '2002-03-02', 'Visited Paris for a cultural tour and sightseeing.', 'Historical', 14);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (94, 'Jane Smith', 'Password8977!', '4000 Tony Trace, New Katie, OH 31325', 'Male', 'Germany', '1991-03-26', 'Luxury cruise across the Mediterranean, stopping in Italy, Spain, and Greece.', 'Adventure, Luxury', 5);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (95, 'Sarah Miller', 'Password9639!', '4136 Sullivan Roads, Amandabury, KS 75846', 'Female', 'UK', '1966-12-20', 'Safari in South Africa, exploring Kruger National Park.', 'Cultural, Luxury, Historical', 19);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (96, 'James King', 'Password2476!', '1914 Raymond Ports Suite 986, Stephanieport, HI 16577', 'Female', 'India', '1959-10-18', 'Guided tour of Machu Picchu, Peru, hiking the Inca Trail.', 'Cruise, Beach, Historical', 13);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (97, 'James King', 'Password6321!', '497 Tracey Via Apt. 271, South Ginachester, NC 96985', 'Male', 'Australia', '1995-07-30', 'Explored the ancient ruins of Egypt, including the Pyramids of Giza.', 'Adventure', 35);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (98, 'Bob Johnson', 'Password3635!', '844 Wells Route, East Andreashire, WY 96752', 'Male', 'UK', '1983-01-14', 'Experience of Venice by gondola ride, visiting St. Mark"s Basilica.', 'Luxury, Adventure, Cruise', 61);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (99, 'Sarah Miller', 'Password8183!', '256 Jason Skyway Apt. 267, North Kelseystad, TX 43415', 'Male', 'South Africa', '1956-05-18', 'Cruised through the Caribbean islands, enjoying sunny beaches.', 'Beach, Adventure', 80);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (100, 'Emma White', 'Password3110!', '112 Lara Mountains, Lake Bianca, MI 50294', 'Male', 'Brazil', '1969-08-02', 'A culinary tour of Italy, exploring local markets and cooking classes.', 'Safari, Luxury, Beach', 86);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (106, 'Ethan Carter', 'Password2849!', 'USCGC Nielsen, FPO AE 01244', 'Male', 'India', '1971-07-04', 'Backpacking through Europe, including stops in Italy and France.', 'Adventure, Safari', 99);
INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager) VALUES (100, 'Emma White', 'Password3110!', '112 Lara Mountains, Lake Bianca, MI 50294', 'Male', 'Brazil', '1969-08-02', 'A culinary tour of Italy, exploring local markets and cooking classes.', 'Safari, Luxury, Beach', 86);


UPDATE Traveler SET RegistrationDate = '2024-11-21' WHERE TravelerID = 1;
UPDATE Traveler SET RegistrationDate = '2024-11-14' WHERE TravelerID = 2;
UPDATE Traveler SET RegistrationDate = '2024-10-29' WHERE TravelerID = 3;
UPDATE Traveler SET RegistrationDate = '2025-04-05' WHERE TravelerID = 4;
UPDATE Traveler SET RegistrationDate = '2024-05-22' WHERE TravelerID = 5;
UPDATE Traveler SET RegistrationDate = '2025-03-21' WHERE TravelerID = 6;
UPDATE Traveler SET RegistrationDate = '2024-10-07' WHERE TravelerID = 7;
UPDATE Traveler SET RegistrationDate = '2024-11-29' WHERE TravelerID = 8;
UPDATE Traveler SET RegistrationDate = '2024-07-18' WHERE TravelerID = 9;
UPDATE Traveler SET RegistrationDate = '2024-09-18' WHERE TravelerID = 10;
UPDATE Traveler SET RegistrationDate = '2024-06-29' WHERE TravelerID = 11;
UPDATE Traveler SET RegistrationDate = '2024-09-30' WHERE TravelerID = 12;
UPDATE Traveler SET RegistrationDate = '2024-10-02' WHERE TravelerID = 13;
UPDATE Traveler SET RegistrationDate = '2024-06-20' WHERE TravelerID = 14;
UPDATE Traveler SET RegistrationDate = '2024-10-12' WHERE TravelerID = 15;
UPDATE Traveler SET RegistrationDate = '2024-12-22' WHERE TravelerID = 16;
UPDATE Traveler SET RegistrationDate = '2025-04-07' WHERE TravelerID = 17;
UPDATE Traveler SET RegistrationDate = '2025-03-16' WHERE TravelerID = 18;
UPDATE Traveler SET RegistrationDate = '2024-09-18' WHERE TravelerID = 19;
UPDATE Traveler SET RegistrationDate = '2025-04-07' WHERE TravelerID = 20;
UPDATE Traveler SET RegistrationDate = '2025-01-08' WHERE TravelerID = 21;
UPDATE Traveler SET RegistrationDate = '2024-05-26' WHERE TravelerID = 22;
UPDATE Traveler SET RegistrationDate = '2024-08-11' WHERE TravelerID = 23;
UPDATE Traveler SET RegistrationDate = '2025-03-02' WHERE TravelerID = 24;
UPDATE Traveler SET RegistrationDate = '2024-09-09' WHERE TravelerID = 25;
UPDATE Traveler SET RegistrationDate = '2024-11-09' WHERE TravelerID = 26;
UPDATE Traveler SET RegistrationDate = '2024-11-21' WHERE TravelerID = 27;
UPDATE Traveler SET RegistrationDate = '2024-08-08' WHERE TravelerID = 28;
UPDATE Traveler SET RegistrationDate = '2024-08-28' WHERE TravelerID = 29;
UPDATE Traveler SET RegistrationDate = '2024-11-07' WHERE TravelerID = 30;
UPDATE Traveler SET RegistrationDate = '2025-01-25' WHERE TravelerID = 31;
UPDATE Traveler SET RegistrationDate = '2024-12-21' WHERE TravelerID = 32;
UPDATE Traveler SET RegistrationDate = '2024-07-25' WHERE TravelerID = 33;
UPDATE Traveler SET RegistrationDate = '2024-11-27' WHERE TravelerID = 34;
UPDATE Traveler SET RegistrationDate = '2024-12-05' WHERE TravelerID = 35;
UPDATE Traveler SET RegistrationDate = '2025-04-25' WHERE TravelerID = 36;
UPDATE Traveler SET RegistrationDate = '2024-12-31' WHERE TravelerID = 37;
UPDATE Traveler SET RegistrationDate = '2024-11-09' WHERE TravelerID = 38;
UPDATE Traveler SET RegistrationDate = '2024-10-06' WHERE TravelerID = 39;
UPDATE Traveler SET RegistrationDate = '2025-04-10' WHERE TravelerID = 40;
UPDATE Traveler SET RegistrationDate = '2024-06-07' WHERE TravelerID = 41;
UPDATE Traveler SET RegistrationDate = '2024-09-17' WHERE TravelerID = 42;
UPDATE Traveler SET RegistrationDate = '2024-11-26' WHERE TravelerID = 43;
UPDATE Traveler SET RegistrationDate = '2024-11-13' WHERE TravelerID = 44;
UPDATE Traveler SET RegistrationDate = '2024-06-16' WHERE TravelerID = 45;
UPDATE Traveler SET RegistrationDate = '2025-02-15' WHERE TravelerID = 46;
UPDATE Traveler SET RegistrationDate = '2024-11-04' WHERE TravelerID = 47;
UPDATE Traveler SET RegistrationDate = '2024-07-30' WHERE TravelerID = 48;
UPDATE Traveler SET RegistrationDate = '2025-02-25' WHERE TravelerID = 49;
UPDATE Traveler SET RegistrationDate = '2024-11-24' WHERE TravelerID = 50;
UPDATE Traveler SET RegistrationDate = '2024-06-05' WHERE TravelerID = 51;
UPDATE Traveler SET RegistrationDate = '2025-01-13' WHERE TravelerID = 52;
UPDATE Traveler SET RegistrationDate = '2024-06-16' WHERE TravelerID = 53;
UPDATE Traveler SET RegistrationDate = '2025-02-20' WHERE TravelerID = 54;
UPDATE Traveler SET RegistrationDate = '2024-12-18' WHERE TravelerID = 55;
UPDATE Traveler SET RegistrationDate = '2024-08-07' WHERE TravelerID = 56;
UPDATE Traveler SET RegistrationDate = '2024-06-07' WHERE TravelerID = 57;
UPDATE Traveler SET RegistrationDate = '2025-04-04' WHERE TravelerID = 58;
UPDATE Traveler SET RegistrationDate = '2024-05-17' WHERE TravelerID = 59;
UPDATE Traveler SET RegistrationDate = '2024-06-06' WHERE TravelerID = 60;
UPDATE Traveler SET RegistrationDate = '2024-10-07' WHERE TravelerID = 61;
UPDATE Traveler SET RegistrationDate = '2024-07-01' WHERE TravelerID = 62;
UPDATE Traveler SET RegistrationDate = '2024-08-23' WHERE TravelerID = 63;
UPDATE Traveler SET RegistrationDate = '2025-03-28' WHERE TravelerID = 64;
UPDATE Traveler SET RegistrationDate = '2024-09-03' WHERE TravelerID = 65;
UPDATE Traveler SET RegistrationDate = '2025-02-02' WHERE TravelerID = 66;
UPDATE Traveler SET RegistrationDate = '2024-06-23' WHERE TravelerID = 67;
UPDATE Traveler SET RegistrationDate = '2024-12-18' WHERE TravelerID = 68;
UPDATE Traveler SET RegistrationDate = '2025-02-22' WHERE TravelerID = 69;
UPDATE Traveler SET RegistrationDate = '2024-10-17' WHERE TravelerID = 70;
UPDATE Traveler SET RegistrationDate = '2025-01-06' WHERE TravelerID = 71;
UPDATE Traveler SET RegistrationDate = '2024-08-30' WHERE TravelerID = 72;
UPDATE Traveler SET RegistrationDate = '2025-03-14' WHERE TravelerID = 73;
UPDATE Traveler SET RegistrationDate = '2025-04-12' WHERE TravelerID = 74;
UPDATE Traveler SET RegistrationDate = '2025-01-20' WHERE TravelerID = 75;
UPDATE Traveler SET RegistrationDate = '2025-01-15' WHERE TravelerID = 76;
UPDATE Traveler SET RegistrationDate = '2025-02-06' WHERE TravelerID = 77;
UPDATE Traveler SET RegistrationDate = '2025-05-07' WHERE TravelerID = 78;
UPDATE Traveler SET RegistrationDate = '2025-04-04' WHERE TravelerID = 79;
UPDATE Traveler SET RegistrationDate = '2024-06-06' WHERE TravelerID = 80;
UPDATE Traveler SET RegistrationDate = '2025-01-09' WHERE TravelerID = 81;
UPDATE Traveler SET RegistrationDate = '2024-12-23' WHERE TravelerID = 82;
UPDATE Traveler SET RegistrationDate = '2024-12-04' WHERE TravelerID = 83;
UPDATE Traveler SET RegistrationDate = '2024-09-18' WHERE TravelerID = 84;
UPDATE Traveler SET RegistrationDate = '2024-07-11' WHERE TravelerID = 85;
UPDATE Traveler SET RegistrationDate = '2025-03-09' WHERE TravelerID = 86;
UPDATE Traveler SET RegistrationDate = '2024-08-29' WHERE TravelerID = 87;
UPDATE Traveler SET RegistrationDate = '2024-12-21' WHERE TravelerID = 88;
UPDATE Traveler SET RegistrationDate = '2024-07-25' WHERE TravelerID = 89;
UPDATE Traveler SET RegistrationDate = '2024-07-23' WHERE TravelerID = 90;
UPDATE Traveler SET RegistrationDate = '2024-06-02' WHERE TravelerID = 91;
UPDATE Traveler SET RegistrationDate = '2024-06-21' WHERE TravelerID = 92;
UPDATE Traveler SET RegistrationDate = '2025-01-16' WHERE TravelerID = 93;
UPDATE Traveler SET RegistrationDate = '2024-12-21' WHERE TravelerID = 94;
UPDATE Traveler SET RegistrationDate = '2025-01-25' WHERE TravelerID = 95;
UPDATE Traveler SET RegistrationDate = '2025-02-01' WHERE TravelerID = 96;
UPDATE Traveler SET RegistrationDate = '2025-03-02' WHERE TravelerID = 97;
UPDATE Traveler SET RegistrationDate = '2024-06-04' WHERE TravelerID = 98;
UPDATE Traveler SET RegistrationDate = '2024-05-28' WHERE TravelerID = 99;
UPDATE Traveler SET RegistrationDate = '2025-04-29' WHERE TravelerID = 100;



UPDATE Booking SET PaymentStatus = 'Pending' Where BookingID=103 
UPDATE Booking SET BookingStatus = 'Pending' Where BookingID=103 

-- First drop the existing constraint
ALTER TABLE TravelerEmail DROP CONSTRAINT FK_TravelerE__Trave__5EBF139D;

-- Then recreate it with ON DELETE CASCADE
ALTER TABLE TravelerEmail
ADD CONSTRAINT FK_TravelerE__Trave__5EBF139D
FOREIGN KEY (TravelerID) REFERENCES Traveler(TravelerID)
ON DELETE CASCADE;


ALTER TABLE TripInvolves
ADD AcceptanceFlag BIT DEFAULT 0;

Update TripInvolves 
set AcceptanceFlag = 1
where TripID between 1 and 100;

-- TRAVELER PHONE TABLE DATA
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('13708484305', 1);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('96011680009', 2);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('29729440281', 3);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('34620930609', 4);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('48573231525', 5);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('61079742585', 6);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('74639012375', 7);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('43115518163', 8);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('48763924261', 9);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('23668196496', 10);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('94033798095', 11);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('75794336648', 12);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('65326514143', 13);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('32250770299', 14);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('63111613178', 15);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('98636256785', 16);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('23363823118', 17);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('34705664747', 18);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('71404912166', 19);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('81294119463', 20);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('71211420226', 21);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('78555049455', 22);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('95110856438', 23);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('90816275428', 24);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('30193713408', 25);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('71550768039', 26);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('50227767095', 27);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('23352534223', 28);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('23437462206', 29);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('89482873540', 30);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('21317989741', 31);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('11918727273', 32);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('74094008541', 33);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('76092611379', 34);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('58804193190', 35);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('69111577956', 36);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('38090354465', 37);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('37547708796', 38);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('64945532092', 39);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('77433518234', 40);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('44950648449', 41);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('31621609457', 42);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('25293896875', 43);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('57497862501', 44);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('64826828530', 45);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('57155631250', 46);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('68720843727', 47);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('33732396867', 48);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('42436186718', 49);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('99389839725', 50);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('96365078344', 51);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('62168155460', 52);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('26799527078', 53);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('95365643030', 54);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('04770526609', 55);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('91655828100', 56);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('25847831665', 57);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('08055571428', 58);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('84166134931', 59);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('05764130497', 60);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('21176046033', 61);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('22760915664', 62);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('27296667506', 63);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('20138044306', 64);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('36201462634', 65);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('49030972340', 66);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('23472617177', 67);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('12418587685', 68);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('81750104105', 69);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('81832572322', 70);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('12019476999', 71);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('67791392143', 72);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('70032688063', 73);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('13374635615', 74);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('64877352059', 75);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('75859814974', 76);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('10247969868', 77);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('56440454704', 78);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('89198800610', 79);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('85148653087', 80);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('61523030336', 81);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('81745220592', 82);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('08764411490', 83);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('86821347843', 84);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('47201435331', 85);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('39640529635', 86);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('04644760593', 87);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('80099164411', 88);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('62006725327', 89);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('09369444698', 90);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('87421491298', 91);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('92146118892', 92);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('08989284378', 93);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('82477633104', 94);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('53090629399', 95);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('76425289163', 96);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('60998936660', 97);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('53659788103', 98);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('41889028515', 99);
INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID) VALUES ('41857740544', 100);


-- TRAVELER EMAIL TABLE DATA
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('sandrarogers@austin-carter.com', 1);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('colemanscott@hayden-morales.biz', 2);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('debbie11@yahoo.com', 3);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('gregorybender@steele.com', 4);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('xmack@mcconnell.biz', 5);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('adrianblackwell@ruiz-munoz.com', 6);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('simmonskatelyn@gmail.com', 7);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('xjones@hotmail.com', 8);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('winterswalter@lopez.com', 9);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('austinroy@gmail.com', 10);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('dtorres@rhodes.com', 11);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('victoria51@romero.net', 12);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('chamberscandice@diaz-webster.biz', 13);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('kiaramontgomery@harris.biz', 14);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('frankconway@ballard.com', 15);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ilawrence@west-myers.com', 16);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('pvega@yahoo.com', 17);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('kristylong@gmail.com', 18);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('zvelazquez@gmail.com', 19);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('jeff56@gmail.com', 20);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('yfox@hotmail.com', 21);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('kwilson@baker.info', 22);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('davidsonmolly@byrd.com', 23);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('dennis75@yahoo.com', 24);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ruizheather@smith.com', 25);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('danieldawson@hotmail.com', 26);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('jasonhenry@yahoo.com', 27);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('parkerdonna@yahoo.com', 28);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('donaldstephens@yahoo.com', 29);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('freyjohn@gmail.com', 30);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('hannah50@hotmail.com', 31);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('dwright@gmail.com', 32);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('rpayne@hotmail.com', 33);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('armstrongbrandon@mata.com', 34);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('brent65@miller.com', 35);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('scottjennifer@hotmail.com', 36);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('kimberly24@sanchez.com', 37);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('janet71@murphy-schaefer.net', 38);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('katherinehumphrey@dunn.com', 39);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('tanyaking@sullivan.biz', 40);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('hodgespaul@gmail.com', 41);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('smendoza@hotmail.com', 42);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('omartin@hotmail.com', 43);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('chad55@gmail.com', 44);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('jamestodd@martin.com', 45);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('lisamurray@hotmail.com', 46);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('perezjanice@yahoo.com', 47);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('michellewang@hotmail.com', 48);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('mshepherd@garcia.com', 49);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('michael12@yahoo.com', 50);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ilee@morrison.biz', 51);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('redwards@hotmail.com', 52);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('lukegilbert@hotmail.com', 53);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('daltonabigail@ryan.net', 54);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ugomez@richardson-meyer.com', 55);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('morrisonmark@neal-olson.com', 56);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('heathersanders@gmail.com', 57);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('frank77@lewis.com', 58);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('contrerasgabriel@hotmail.com', 59);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('paulcraig@hotmail.com', 60);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('humphreynathaniel@johnson.info', 61);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('trevor01@yahoo.com', 62);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('alexanderhawkins@rubio-leach.com', 63);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('josedixon@baker.info', 64);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('joanrogers@green.biz', 65);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('shawnnelson@yahoo.com', 66);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('rita82@ross.info', 67);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ronald61@davis.com', 68);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('donald15@hernandez.com', 69);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('james24@phillips.net', 70);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('parkerjohn@tate.biz', 71);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('adriana18@hotmail.com', 72);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('rebeccaallen@gmail.com', 73);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('amyers@kerr.com', 74);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('galvarado@gmail.com', 75);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('reedjohn@gmail.com', 76);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('wheelernicholas@gmail.com', 77);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('thomaspotter@yahoo.com', 78);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('johncook@woods-burnett.com', 79);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('spatel@riggs.com', 80);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('gabriel98@pearson-jefferson.com', 81);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('justin54@anderson.org', 82);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('rowlandlinda@hotmail.com', 83);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('david89@rivera-stout.net', 84);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ehall@reed.com', 85);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('joshuawilcox@gmail.com', 86);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('howebrandon@gmail.com', 87);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('perezpaul@martin-walker.com', 88);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('davisgeorge@hotmail.com', 89);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('amack@brown-lyons.org', 90);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ricemichael@hotmail.com', 91);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('paul87@ochoa-jacobson.com', 92);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('grivera@graves.com', 93);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('cmahoney@oconnor.com', 94);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('ljohnson@norman.biz', 95);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('harrisonkristen@james.com', 96);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('leejoshua@arellano.com', 97);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('riosdaniel@warren-hardy.net', 98);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('kylie33@yahoo.com', 99);
INSERT INTO TravelerEmail (Email, TravelerID) VALUES ('cswanson@hotmail.com', 100);



-- WISHLIST TABLE DATA
INSERT INTO Wishlist (WishID, TravelerID) VALUES (1, 24);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (2, 79);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (3, 26);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (4, 34);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (5, 19);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (6, 10);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (7, 33);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (8, 98);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (9, 48);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (10, 88);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (11, 47);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (12, 76);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (13, 81);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (14, 44);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (15, 92);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (16, 52);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (17, 63);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (18, 39);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (19, 45);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (20, 95);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (21, 62);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (22, 2);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (23, 41);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (24, 46);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (25, 81);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (26, 73);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (27, 82);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (28, 72);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (29, 2);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (30, 65);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (31, 42);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (32, 24);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (33, 48);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (34, 98);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (35, 68);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (36, 75);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (37, 81);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (38, 88);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (39, 56);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (40, 41);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (41, 92);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (42, 28);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (43, 46);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (44, 94);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (45, 99);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (46, 74);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (47, 100);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (48, 82);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (49, 3);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (50, 88);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (51, 47);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (52, 80);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (53, 52);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (54, 66);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (55, 100);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (56, 78);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (57, 70);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (58, 18);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (59, 33);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (60, 81);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (61, 97);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (62, 58);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (63, 19);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (64, 32);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (65, 46);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (66, 76);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (67, 72);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (68, 41);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (69, 18);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (70, 17);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (71, 47);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (72, 52);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (73, 34);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (74, 75);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (75, 32);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (76, 31);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (77, 79);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (78, 70);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (79, 73);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (80, 72);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (81, 98);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (82, 54);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (83, 48);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (84, 1);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (85, 24);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (86, 98);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (87, 34);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (88, 62);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (89, 94);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (90, 93);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (91, 34);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (92, 44);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (93, 62);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (94, 15);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (95, 12);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (96, 74);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (97, 47);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (98, 4);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (99, 27);
INSERT INTO Wishlist (WishID, TravelerID) VALUES (100, 22);


-- REVIEW TABLE DATA
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (1, 78, 53, 1, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-03-25');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (2, 85, 50, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-01-07');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (3, 39, 58, 3, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-01-06');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (4, 30, 47, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-02-06');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (5, 39, 3, 5, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-03-18');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (6, 40, 29, 2, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-03-21');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (7, 63, 42, 2, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-04-10');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (8, 23, 19, 5, 'The trip exceeded my expectations. Great service, great food, and incredible locations.', '2025-02-21');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (9, 60, 46, 1, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-03-24');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (10, 18, 71, 4, 'A truly once-in-a-lifetime experience! Beautiful destinations and excellent service.', '2025-01-16');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (11, 1, 38, 5, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-03-07');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (12, 56, 91, 2, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-04-07');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (13, 65, 32, 4, 'A truly once-in-a-lifetime experience! Beautiful destinations and excellent service.', '2025-04-07');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (14, 1, 57, 3, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-01-19');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (15, 80, 63, 4, 'The trip exceeded my expectations. Great service, great food, and incredible locations.', '2025-02-25');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (16, 2, 28, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-01-24');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (17, 38, 93, 5, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-01-01');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (18, 63, 15, 2, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-01-19');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (19, 52, 41, 3, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-02-26');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (20, 54, 56, 2, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-03-05');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (21, 94, 51, 3, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-03-02');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (22, 93, 55, 1, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-01-19');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (23, 38, 87, 5, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-03-30');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (24, 73, 53, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-04-11');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (25, 61, 21, 5, 'A truly once-in-a-lifetime experience! Beautiful destinations and excellent service.', '2025-01-21');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (26, 64, 40, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-01-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (27, 71, 15, 1, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-03-22');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (28, 18, 42, 1, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-02-21');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (29, 2, 39, 2, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-01-30');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (30, 18, 13, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-03-17');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (31, 16, 17, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-01-14');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (32, 71, 67, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-03-03');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (33, 34, 24, 3, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-03-29');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (34, 53, 72, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-01-03');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (35, 97, 21, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-04-14');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (36, 69, 60, 2, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-02-21');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (37, 33, 56, 2, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-02-09');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (38, 18, 49, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-02-01');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (39, 16, 81, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-01-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (40, 16, 43, 5, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-02-18');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (41, 5, 31, 3, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-01-21');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (42, 87, 32, 3, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-04-11');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (43, 35, 56, 2, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-02-16');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (44, 41, 12, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-01-20');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (45, 65, 79, 1, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-01-06');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (46, 59, 1, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-01-22');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (47, 11, 66, 2, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-02-23');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (48, 44, 43, 5, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-01-31');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (49, 17, 93, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-04-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (50, 23, 79, 2, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-03-08');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (51, 16, 99, 5, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-01-28');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (52, 67, 76, 5, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-01-13');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (53, 66, 5, 1, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-03-03');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (54, 58, 36, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-04-15');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (55, 39, 5, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-02-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (56, 70, 54, 3, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-02-15');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (57, 60, 31, 3, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-03-16');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (58, 11, 36, 2, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-01-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (59, 88, 25, 3, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-01-19');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (60, 87, 76, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-01-31');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (61, 81, 96, 1, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-01-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (62, 72, 17, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-02-04');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (63, 51, 46, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-03-23');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (64, 19, 89, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-04-14');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (65, 49, 21, 1, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-02-27');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (66, 7, 71, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-01-20');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (67, 27, 67, 3, 'Not worth the money. The itinerary was poorly planned, and we didn"t visit all the advertised locations.', '2025-03-27');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (68, 75, 41, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-01-13');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (69, 86, 10, 1, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-02-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (70, 18, 57, 4, 'The trip exceeded my expectations. Great service, great food, and incredible locations.', '2025-04-01');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (71, 66, 8, 2, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-02-10');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (72, 52, 27, 4, 'Amazing trip! Had a fantastic time, the guide was wonderful, and the sights were breathtaking.', '2025-01-01');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (73, 59, 48, 1, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-04-12');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (74, 49, 79, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-03-13');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (75, 69, 82, 1, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-02-18');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (76, 26, 45, 5, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-02-06');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (77, 97, 53, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-01-01');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (78, 14, 10, 2, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-02-10');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (79, 100, 77, 3, 'I had high hopes for this trip, but it didn"t meet the standards. Too rushed and not enough time to explore.', '2025-03-24');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (80, 71, 46, 2, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-01-28');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (81, 58, 29, 4, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-03-13');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (82, 91, 89, 3, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-03-01');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (83, 31, 11, 1, 'Not worth the money. The itinerary was poorly planned, and we didnt visit all the advertised locations.', '2025-01-08');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (84, 40, 96, 4, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-03-13');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (85, 74, 45, 5, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-03-14');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (86, 28, 66, 3, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-03-29');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (87, 26, 10, 4, 'This was a perfect trip for relaxation. Highly enjoyable, beautiful scenery, and fantastic food.', '2025-04-11');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (88, 68, 31, 3, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-04-02');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (89, 57, 88, 1, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-02-25');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (90, 82, 100, 1, 'Very poor experience. The transport was late, and the service was below expectations.', '2025-02-10');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (91, 99, 68, 3, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-02-25');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (92, 23, 83, 1, 'The trip was fine, but there were several issues with the booking process and communication.', '2025-03-28');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (93, 28, 46, 2, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-03-07');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (94, 13, 49, 3, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-03-13');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (95, 10, 35, 3, 'The trip was disappointing. The accommodations were subpar, and the guide was unprofessional.', '2025-03-11');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (96, 88, 85, 1, 'Not worth the money. The itinerary was poorly planned, and we didnt visit all the advertised locations.', '2025-01-22');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (97, 37, 39, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-03-09');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (98, 8, 90, 5, 'The trip exceeded my expectations. Great service, great food, and incredible locations.', '2025-01-24');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (99, 25, 93, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-03-31');
INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate) VALUES (100, 10, 27, 4, 'I loved every moment of this trip. Highly recommend it to anyone looking for an adventure.', '2025-03-18');

UPDATE Booking SET BookingDate='2025-05-13' WHERE TravelerID=1
SELECT * FROM Booking WHERE TravelerID=1
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (105, 1, 57, '2025-01-30', 7, 3853.11, 'Confirmed', 'Confirmed', NULL);

UPDATE Trip SET StartDate= '2025-05-13' WHERE TripID=55
SELECT T.Title, T.StartDate 
FROM Booking B
JOIN Trip T ON B.TripID = T.TripID
WHERE B.TravelerID =1 
AND T.StartDate BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE())


-- BOOKING TABLE DATA
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (1, 66, 57, '2025-01-30', 7, 3853.11, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (2, 39, 72, '2025-02-08', 8, 2744.6, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (3, 52, 30, '2025-01-14', 5, 3471.75, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (4, 77, 6, '2025-02-03', 6, 4807.85, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (5, 77, 70, '2025-04-02', 2, 4859.29, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (6, 77, 93, '2025-04-07', 5, 523.73, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (7, 20, 21, '2025-03-01', 9, 2066.74, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (8, 56, 19, '2025-02-06', 5, 2873.35, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (9, 6, 2, '2025-03-05', 7, 2177.56, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (10, 19, 20, '2025-01-20', 7, 2745.25, 'Paid', 'Cancelled', 'Weather conditions affected the trip');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (11, 30, 36, '2025-03-12', 5, 2177.76, 'Paid', 'Cancelled', 'Weather conditions affected the trip');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (12, 2, 54, '2025-02-26', 9, 566.2, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (13, 21, 97, '2025-01-02', 2, 852.33, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (14, 42, 89, '2025-01-09', 3, 3115.21, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (15, 60, 69, '2025-01-10', 4, 2678.88, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (16, 60, 73, '2025-02-04', 6, 4560.95, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (17, 20, 57, '2025-03-19', 10, 1322.96, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (18, 6, 77, '2025-04-09', 6, 1232.66, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (19, 58, 26, '2025-03-10', 9, 2623.91, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (20, 83, 97, '2025-03-02', 3, 2661.4, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (21, 98, 73, '2025-03-06', 4, 3768.51, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (22, 16, 70, '2025-03-07', 4, 4325.5, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (23, 37, 91, '2025-02-21', 2, 4839.88, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (24, 23, 2, '2025-04-11', 4, 502.83, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (25, 4, 46, '2025-01-15', 4, 750.06, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (26, 49, 85, '2025-02-19', 4, 3032.44, 'Paid', 'Cancelled', 'Unable to attend due to illness');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (27, 98, 13, '2025-03-23', 8, 785.53, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (28, 17, 48, '2025-01-31', 9, 4233.72, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (29, 25, 30, '2025-03-21', 7, 1288.42, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (30, 7, 18, '2025-03-18', 7, 1402.75, 'Pending', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (31, 28, 92, '2025-03-17', 4, 2188.76, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (32, 53, 76, '2025-01-22', 1, 2199.35, 'Pending', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (33, 39, 23, '2025-03-25', 7, 1849.01, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (34, 61, 77, '2025-03-08', 10, 4597.47, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (35, 52, 80, '2025-02-12', 3, 3039.34, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (36, 48, 37, '2025-01-31', 5, 3396.56, 'Pending', 'Cancelled', 'Unable to attend due to illness');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (37, 52, 42, '2025-01-30', 1, 4276.77, 'Paid', 'Cancelled', 'Visa issues');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (38, 22, 92, '2025-01-03', 8, 1311.35, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (39, 26, 51, '2025-01-13', 9, 4753.6, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (40, 53, 69, '2025-03-11', 9, 4732.4, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (41, 52, 25, '2025-03-28', 1, 3224.86, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (42, 27, 24, '2025-04-01', 9, 924.15, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (43, 24, 57, '2025-03-27', 8, 1758.38, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (44, 67, 44, '2025-04-12', 5, 2794.49, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (45, 49, 5, '2025-03-08', 8, 547.74, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (46, 77, 17, '2025-02-04', 7, 3192.22, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (47, 62, 63, '2025-01-03', 6, 551.0, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (48, 82, 47, '2025-03-29', 6, 680.7, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (49, 88, 95, '2025-02-20', 4, 3805.06, 'Paid', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (50, 75, 85, '2025-02-24', 1, 2812.69, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (51, 37, 45, '2025-03-24', 10, 2277.35, 'Paid', 'Cancelled', 'Travel restrictions');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (52, 83, 91, '2025-02-01', 8, 707.4, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (53, 57, 93, '2025-03-16', 4, 1925.7, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (54, 85, 96, '2025-02-22', 8, 3744.08, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (55, 5, 48, '2025-01-28', 7, 3107.14, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (56, 52, 30, '2025-03-31', 1, 3436.87, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (57, 14, 26, '2025-03-02', 7, 1338.77, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (58, 65, 58, '2025-04-01', 10, 2915.97, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (59, 25, 88, '2025-04-16', 8, 2625.27, 'Paid', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (60, 87, 2, '2025-04-09', 9, 3759.53, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (61, 100, 56, '2025-04-04', 2, 764.75, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (62, 4, 47, '2025-02-03', 5, 4496.04, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (63, 12, 25, '2025-02-02', 6, 4135.93, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (64, 82, 98, '2025-01-14', 6, 2603.26, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (65, 56, 24, '2025-02-27', 8, 3372.85, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (66, 9, 58, '2025-02-15', 3, 3393.6, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (67, 54, 61, '2025-04-10', 10, 927.63, 'Paid', 'Cancelled', 'Unable to attend due to illness');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (68, 57, 68, '2025-03-23', 9, 1372.9, 'Paid', 'Cancelled', 'Scheduling conflict');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (69, 38, 14, '2025-01-21', 1, 2785.31, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (70, 32, 78, '2025-02-26', 8, 737.12, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (71, 54, 69, '2025-02-27', 9, 2664.5, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (72, 26, 73, '2025-02-13', 10, 3119.91, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (73, 64, 30, '2025-01-22', 9, 1220.44, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (74, 50, 33, '2025-04-16', 7, 1854.66, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (75, 4, 63, '2025-02-16', 9, 4388.12, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (76, 9, 39, '2025-02-25', 5, 3925.21, 'Paid', 'Cancelled', 'Changed mind about the trip');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (77, 7, 95, '2025-02-07', 7, 2467.84, 'Paid', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (78, 87, 49, '2025-01-22', 8, 2691.01, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (79, 78, 54, '2025-03-08', 9, 4514.13, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (80, 56, 49, '2025-02-19', 6, 1351.72, 'Pending', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (81, 61, 9, '2025-04-15', 6, 600.63, 'Pending', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (82, 99, 23, '2025-02-15', 8, 3946.41, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (83, 67, 68, '2025-03-13', 9, 702.85, 'Paid', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (84, 40, 59, '2025-03-20', 1, 1853.62, 'Failed', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (85, 54, 64, '2025-01-02', 10, 2547.98, 'Failed', 'Cancelled', 'Changed mind about the trip');
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (86, 71, 57, '2025-01-29', 9, 3314.18, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (87, 24, 46, '2025-02-03', 10, 1082.05, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (88, 91, 30, '2025-02-21', 1, 4922.47, 'Pending', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (89, 81, 20, '2025-04-04', 2, 525.82, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (90, 43, 4, '2025-03-13', 10, 4746.85, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (91, 55, 79, '2025-03-26', 4, 1180.8, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (92, 90, 6, '2025-02-13', 9, 2188.9, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (93, 79, 45, '2025-01-29', 2, 1200.11, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (94, 53, 90, '2025-04-05', 10, 1718.7, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (95, 14, 3, '2025-02-27', 2, 2474.93, 'Failed', 'Cancelled', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (96, 47, 38, '2025-01-12', 8, 2284.7, 'Failed', 'Confirmed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (97, 92, 19, '2025-02-27', 6, 4116.77, 'Paid', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (98, 89, 37, '2025-03-24', 10, 1117.29, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (99, 24, 44, '2025-02-16', 8, 1243.68, 'Pending', 'Completed', NULL);
INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason) VALUES (100, 63, 14, '2025-03-11', 5, 809.15, 'Pending', 'Cancelled', 'Unforeseen circumstances');


-- PAYMENTS TABLE DATA
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (1, 65, 3776.3, '2025-02-15', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (2, 38, 2787.44, '2025-02-01', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (3, 71, 2106.49, '2025-02-18', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (4, 33, 2854.83, '2025-04-14', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (5, 53, 2623.83, '2025-02-17', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (6, 78, 3439.59, '2025-02-06', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (7, 49, 4288.64, '2025-01-04', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (8, 90, 2252.6, '2025-04-13', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (9, 15, 2687.67, '2025-04-14', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (10, 6, 1529.43, '2025-02-28', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (11, 93, 2686.57, '2025-03-06', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (12, 5, 3630.31, '2025-04-02', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (13, 76, 3263.37, '2025-01-04', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (14, 81, 1242.65, '2025-01-14', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (15, 9, 3432.96, '2025-01-20', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (16, 36, 4082.27, '2025-03-30', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (17, 44, 4946.0, '2025-03-13', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (18, 32, 1509.52, '2025-03-19', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (19, 66, 3692.11, '2025-01-12', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (20, 16, 690.47, '2025-04-03', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (21, 25, 4351.58, '2025-01-13', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (22, 76, 4573.27, '2025-03-12', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (23, 87, 4124.73, '2025-02-01', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (24, 42, 2196.14, '2025-03-20', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (25, 76, 4972.64, '2025-03-17', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (26, 87, 2224.33, '2025-02-05', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (27, 69, 4987.01, '2025-02-10', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (28, 35, 2197.8, '2025-01-05', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (29, 71, 1508.6, '2025-02-08', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (30, 92, 2304.97, '2025-01-27', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (31, 39, 1243.26, '2025-02-27', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (32, 49, 1175.76, '2025-01-01', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (33, 63, 2678.92, '2025-03-17', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (34, 58, 2021.24, '2025-03-07', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (35, 6, 443.86, '2025-03-03', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (36, 6, 586.25, '2025-03-30', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (37, 64, 1270.01, '2025-01-15', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (38, 41, 134.53, '2025-04-16', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (39, 82, 2224.87, '2025-01-11', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (40, 79, 4829.27, '2025-02-15', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (41, 98, 482.41, '2025-02-16', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (42, 66, 4096.36, '2025-04-03', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (43, 74, 4200.4, '2025-02-14', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (44, 17, 1578.84, '2025-02-19', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (45, 43, 2032.68, '2025-02-17', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (46, 68, 1538.4, '2025-03-31', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (47, 36, 3683.07, '2025-03-23', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (48, 59, 3761.71, '2025-01-15', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (49, 97, 2235.92, '2025-01-06', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (50, 36, 1790.35, '2025-02-27', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (51, 96, 4988.6, '2025-03-13', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (52, 74, 4797.6, '2025-02-12', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (53, 91, 4172.15, '2025-01-07', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (54, 14, 2001.35, '2025-03-11', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (55, 82, 3851.08, '2025-01-30', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (56, 53, 4901.27, '2025-01-18', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (57, 94, 1951.72, '2025-01-19', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (58, 1, 2233.28, '2025-03-16', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (59, 71, 4289.05, '2025-04-15', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (60, 26, 1075.47, '2025-02-03', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (61, 93, 775.46, '2025-03-20', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (62, 14, 711.31, '2025-02-03', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (63, 64, 4485.97, '2025-01-18', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (64, 100, 2057.94, '2025-04-01', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (65, 95, 903.27, '2025-01-07', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (66, 81, 3303.66, '2025-03-19', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (67, 73, 1737.07, '2025-02-01', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (68, 2, 4615.2, '2025-04-08', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (69, 43, 4515.96, '2025-02-10', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (70, 32, 3508.45, '2025-02-27', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (71, 9, 3937.09, '2025-02-01', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (72, 27, 1891.56, '2025-02-28', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (73, 13, 3476.14, '2025-02-01', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (74, 52, 2506.55, '2025-02-11', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (75, 15, 2590.07, '2025-01-30', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (76, 13, 395.33, '2025-04-09', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (77, 56, 1894.62, '2025-01-24', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (78, 24, 2768.33, '2025-02-20', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (79, 10, 2185.84, '2025-01-13', 'PayPal', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (80, 90, 4699.35, '2025-04-05', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (81, 94, 3051.37, '2025-03-06', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (82, 16, 4333.43, '2025-01-08', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (83, 17, 3897.52, '2025-04-10', 'Cash', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (84, 43, 868.85, '2025-01-14', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (85, 66, 1508.08, '2025-03-21', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (86, 13, 211.05, '2025-03-29', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (87, 85, 3558.55, '2025-01-03', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (88, 61, 4617.85, '2025-03-21', 'Bank Transfer', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (89, 73, 1926.92, '2025-03-19', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (90, 45, 2171.44, '2025-02-21', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (91, 88, 2309.84, '2025-02-13', 'Credit Card', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (92, 37, 4252.1, '2025-03-02', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (93, 69, 3987.8, '2025-01-29', 'Credit Card', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (94, 87, 215.55, '2025-02-20', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (95, 72, 339.5, '2025-01-13', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (96, 96, 1370.19, '2025-03-10', 'Bank Transfer', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (97, 57, 2188.43, '2025-03-14', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (98, 66, 1363.07, '2025-03-03', 'Cash', 'Failed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (99, 19, 374.56, '2025-03-24', 'PayPal', 'Completed');
INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus) VALUES (100, 57, 3050.81, '2025-03-02', 'Bank Transfer', 'Failed');



-- WISHLIST ADD TABLE DATA
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (32, 24, 18, '2024-03-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (2, 79, 64, '2023-05-03');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (77, 79, 50, '2025-01-28');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (77, 79, 17, '2024-07-03');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (3, 26, 13, '2024-03-04');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (3, 26, 12, '2024-04-17');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (3, 26, 87, '2024-01-30');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (3, 26, 79, '2023-07-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (3, 26, 60, '2023-07-21');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (73, 34, 24, '2024-03-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (91, 34, 80, '2023-07-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (4, 34, 3, '2025-03-21');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (5, 19, 6, '2024-07-03');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (63, 19, 93, '2024-01-29');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (6, 10, 77, '2024-09-29');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (6, 10, 9, '2024-08-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (7, 33, 81, '2023-05-26');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (59, 33, 41, '2024-03-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (7, 33, 73, '2024-11-23');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (59, 33, 94, '2024-11-08');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (81, 98, 15, '2023-12-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (8, 98, 67, '2024-04-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (81, 98, 100, '2023-08-23');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (8, 98, 60, '2024-09-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (83, 48, 76, '2024-09-30');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (33, 48, 51, '2025-03-02');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (33, 48, 64, '2024-12-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (83, 48, 2, '2024-05-30');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (83, 48, 2, '2023-05-28');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (50, 88, 30, '2023-06-22');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (38, 88, 61, '2023-04-29');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (38, 88, 33, '2025-02-09');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (10, 88, 25, '2024-05-25');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (10, 88, 8, '2023-11-01');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (97, 47, 33, '2023-06-22');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (12, 76, 43, '2024-08-31');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (66, 76, 25, '2024-08-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (60, 81, 58, '2024-08-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (92, 44, 43, '2024-06-04');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (14, 44, 35, '2023-07-26');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (14, 44, 77, '2024-01-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (14, 44, 4, '2024-08-13');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (41, 92, 99, '2023-08-23');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (53, 52, 66, '2025-02-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (17, 63, 17, '2025-02-19');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (17, 63, 95, '2023-10-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (17, 63, 4, '2024-04-18');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (17, 63, 98, '2024-07-20');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (17, 63, 13, '2024-09-26');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (18, 39, 25, '2023-09-05');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (18, 39, 64, '2023-08-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (18, 39, 93, '2023-12-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (18, 39, 45, '2024-08-05');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (18, 39, 1, '2025-02-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (19, 45, 70, '2024-11-29');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (19, 45, 73, '2025-01-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (19, 45, 44, '2023-11-18');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (20, 95, 10, '2023-04-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (20, 95, 97, '2025-02-19');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (20, 95, 75, '2023-05-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (20, 95, 40, '2023-11-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (20, 95, 72, '2024-02-26');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (93, 62, 68, '2024-11-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (21, 62, 7, '2024-05-31');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (88, 62, 43, '2024-11-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (88, 62, 95, '2024-04-19');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (29, 2, 11, '2023-08-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (22, 2, 69, '2024-12-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (22, 2, 32, '2023-07-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (22, 2, 26, '2024-11-17');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (68, 41, 88, '2023-10-18');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (40, 41, 98, '2025-04-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (23, 41, 55, '2024-01-30');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (43, 46, 44, '2024-12-10');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (79, 73, 25, '2023-06-21');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (27, 82, 53, '2025-02-20');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (80, 72, 21, '2024-07-06');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (30, 65, 43, '2023-12-13');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (30, 65, 8, '2024-01-21');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (31, 42, 83, '2025-01-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (31, 42, 42, '2023-07-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (31, 42, 66, '2025-03-09');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (31, 42, 26, '2024-09-25');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (35, 68, 71, '2023-07-23');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (36, 75, 76, '2023-09-23');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (36, 75, 42, '2024-01-25');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (74, 75, 6, '2024-06-05');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (36, 75, 34, '2025-03-10');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (39, 56, 73, '2025-01-06');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (42, 28, 45, '2023-12-18');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (42, 28, 77, '2023-07-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (42, 28, 82, '2024-06-22');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (42, 28, 53, '2024-12-16');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (42, 28, 26, '2024-10-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (89, 94, 23, '2024-09-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (89, 94, 61, '2023-05-08');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (89, 94, 41, '2023-07-09');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (45, 99, 5, '2024-09-05');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (45, 99, 97, '2024-05-28');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (46, 74, 48, '2025-02-05');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (55, 100, 84, '2024-08-25');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (55, 100, 79, '2024-10-26');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (55, 100, 93, '2024-09-17');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (55, 100, 84, '2024-10-29');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (47, 100, 3, '2025-02-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (49, 3, 68, '2024-08-22');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (52, 80, 83, '2024-08-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (52, 80, 24, '2023-10-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (52, 80, 59, '2024-11-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (52, 80, 85, '2025-01-21');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (52, 80, 1, '2024-02-26');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (54, 66, 93, '2023-05-19');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (54, 66, 66, '2023-05-17');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (54, 66, 11, '2023-07-23');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (56, 78, 62, '2023-11-01');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (78, 70, 85, '2023-08-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (78, 70, 44, '2023-11-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (78, 70, 12, '2023-12-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (78, 70, 18, '2023-05-31');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (69, 18, 19, '2023-06-16');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (61, 97, 35, '2025-01-08');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (61, 97, 13, '2023-12-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (61, 97, 15, '2024-10-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (61, 97, 46, '2023-12-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (62, 58, 2, '2024-09-10');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (64, 32, 94, '2023-11-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (75, 32, 24, '2023-09-01');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (75, 32, 37, '2023-08-17');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (75, 32, 32, '2024-12-07');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (70, 17, 40, '2024-07-02');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (70, 17, 96, '2024-12-27');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (70, 17, 54, '2025-01-10');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (70, 17, 53, '2024-07-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (70, 17, 41, '2024-11-25');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (76, 31, 88, '2024-10-01');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (76, 31, 52, '2024-03-30');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (82, 54, 77, '2023-06-04');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (82, 54, 52, '2023-12-03');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (82, 54, 33, '2024-11-05');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (82, 54, 84, '2023-05-20');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (82, 54, 23, '2023-08-04');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (84, 1, 25, '2023-05-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (84, 1, 79, '2023-04-24');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (84, 1, 40, '2024-02-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (84, 1, 75, '2024-02-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (84, 1, 27, '2024-11-18');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (90, 93, 39, '2025-04-04');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (94, 15, 20, '2023-11-14');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (95, 12, 21, '2024-04-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (95, 12, 86, '2023-10-18');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (95, 12, 20, '2024-10-16');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (95, 12, 15, '2023-05-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (95, 12, 20, '2024-08-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (98, 4, 32, '2023-07-11');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (99, 27, 62, '2025-02-15');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (99, 27, 34, '2024-04-09');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (99, 27, 15, '2024-12-12');
INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded) VALUES (100, 22, 7, '2024-11-29');


-- OVERLOOK TABLE DATA
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (11, 35, 6, '2025-01-18');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (20, 28, 35, '2025-01-28');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (40, 96, 96, '2025-04-08');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (93, 45, 43, '2025-03-30');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (86, 47, 36, '2025-03-16');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (81, 92, 37, '2025-02-24');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (69, 68, 2, '2025-02-09');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (25, 39, 82, '2025-02-22');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (78, 62, 14, '2025-03-17');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (98, 55, 82, '2025-01-03');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (36, 26, 87, '2025-03-27');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (49, 16, 36, '2025-04-06');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (93, 52, 74, '2025-01-21');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (69, 53, 91, '2025-01-17');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (39, 94, 87, '2025-01-23');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (73, 43, 74, '2025-03-13');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (49, 42, 66, '2025-01-18');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (100, 13, 76, '2025-03-11');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (74, 77, 56, '2025-03-26');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (67, 80, 90, '2025-01-31');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (2, 28, 35, '2025-02-28');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (33, 46, 68, '2025-01-23');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (67, 34, 58, '2025-02-02');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (9, 46, 68, '2025-01-11');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (95, 47, 36, '2025-03-13');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (44, 20, 16, '2025-01-31');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (38, 83, 17, '2025-01-23');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (28, 82, 16, '2025-01-31');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (97, 63, 64, '2025-04-07');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (56, 79, 10, '2025-04-12');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (49, 26, 87, '2025-01-11');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (64, 54, 14, '2025-01-25');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (71, 10, 6, '2025-03-30');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (57, 63, 64, '2025-02-28');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (43, 15, 9, '2025-01-20');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (83, 37, 64, '2025-03-31');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (72, 90, 45, '2025-03-22');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (13, 21, 25, '2025-01-28');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (71, 70, 32, '2025-04-12');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (36, 44, 17, '2025-01-08');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (87, 70, 32, '2025-03-02');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (82, 48, 59, '2025-03-05');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (98, 83, 17, '2025-04-04');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (39, 20, 16, '2025-02-22');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (28, 51, 96, '2025-04-08');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (19, 63, 64, '2025-01-12');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (23, 1, 65, '2025-01-09');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (57, 86, 13, '2025-01-09');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (2, 37, 64, '2025-02-27');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (15, 46, 68, '2025-01-20');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (27, 28, 35, '2025-02-21');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (62, 59, 71, '2025-02-11');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (89, 80, 90, '2025-01-10');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (8, 13, 76, '2025-02-10');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (79, 24, 42, '2025-01-12');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (89, 61, 93, '2025-02-12');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (56, 16, 36, '2025-03-14');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (70, 100, 57, '2025-01-15');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (60, 44, 17, '2025-01-07');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (18, 27, 69, '2025-01-03');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (7, 17, 44, '2025-01-20');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (62, 2, 38, '2025-02-19');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (14, 60, 26, '2025-03-25');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (73, 53, 91, '2025-01-16');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (43, 94, 87, '2025-01-02');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (84, 77, 56, '2025-02-04');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (29, 10, 6, '2025-03-22');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (24, 84, 43, '2025-01-30');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (59, 3, 71, '2025-01-03');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (66, 47, 36, '2025-02-06');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (99, 76, 13, '2025-03-08');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (68, 1, 65, '2025-02-27');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (62, 73, 13, '2025-02-25');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (56, 22, 76, '2025-04-07');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (7, 12, 5, '2025-01-13');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (66, 4, 33, '2025-03-13');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (68, 45, 43, '2025-02-18');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (1, 11, 93, '2025-01-19');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (11, 23, 87, '2025-02-11');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (84, 59, 71, '2025-01-18');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (17, 100, 57, '2025-02-12');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (76, 44, 17, '2025-01-30');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (78, 72, 27, '2025-01-24');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (90, 31, 39, '2025-01-23');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (100, 55, 82, '2025-03-24');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (53, 24, 42, '2025-03-13');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (2, 34, 58, '2025-02-07');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (49, 23, 87, '2025-04-09');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (81, 93, 69, '2025-01-21');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (12, 31, 39, '2025-03-18');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (62, 70, 32, '2025-01-25');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (78, 45, 43, '2025-04-16');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (71, 88, 61, '2025-01-23');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (56, 74, 52, '2025-03-03');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (100, 60, 26, '2025-01-28');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (72, 40, 79, '2025-04-04');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (27, 98, 66, '2025-03-07');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (28, 14, 81, '2025-03-23');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (51, 76, 13, '2025-03-08');
INSERT INTO Overlooks (TourOperatorID, PaymentID, BookingID, DateOverlooked) VALUES (83, 86, 13, '2025-04-08');


-- TRIP DESTINATIONS TABLE DATA
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (99, 42);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (99, 28);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (99, 17);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (99, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (99, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (100, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (100, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (100, 52);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (100, 3);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (100, 58);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (37, 56);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (37, 35);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (44, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (44, 27);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (5, 55);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (5, 42);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (5, 48);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (5, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (5, 55);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (31, 20);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (31, 58);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (31, 2);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (28, 41);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (28, 41);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (28, 31);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (84, 45);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (84, 12);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (84, 60);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (84, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (24, 52);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (24, 33);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (24, 3);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (24, 5);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (24, 32);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (16, 33);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (16, 11);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (16, 25);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (16, 41);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (16, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (41, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (41, 36);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (41, 17);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (41, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (41, 19);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (51, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (51, 6);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (74, 22);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (74, 27);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (67, 4);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (67, 9);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (67, 24);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (67, 43);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (26, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (26, 49);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (26, 48);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (98, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (98, 59);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (98, 7);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (98, 32);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (59, 23);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (59, 37);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (59, 59);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (59, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (59, 57);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (35, 47);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (35, 19);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (35, 39);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (83, 44);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (83, 31);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (29, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (29, 20);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (6, 47);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (6, 25);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (6, 18);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (6, 18);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (49, 54);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (49, 51);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (96, 38);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (96, 52);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (96, 24);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (96, 43);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (96, 57);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (9, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (9, 24);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (9, 40);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (73, 52);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (73, 48);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (73, 51);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (39, 57);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (39, 25);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (39, 43);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (19, 27);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (19, 25);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (79, 35);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (79, 28);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (79, 22);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (79, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (79, 50);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (40, 51);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (40, 46);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (40, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (40, 5);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (40, 1);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (32, 19);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (32, 41);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (32, 25);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (55, 2);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (55, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (55, 50);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (76, 37);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (76, 51);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (76, 1);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (76, 14);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (76, 23);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (70, 3);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (70, 22);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (70, 3);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (95, 15);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (95, 53);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (95, 26);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (34, 16);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (34, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (34, 37);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (34, 9);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (34, 20);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (11, 8);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (11, 59);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (11, 5);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (11, 24);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (82, 50);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (82, 59);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (82, 35);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (82, 53);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (82, 11);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (30, 33);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (30, 7);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (30, 48);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (30, 32);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (30, 4);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (63, 46);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (63, 17);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (63, 2);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (63, 31);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (63, 12);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (23, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (23, 15);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (23, 40);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (23, 44);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (23, 49);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (1, 2);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (2, 13);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (3, 27);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (4, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (7, 48);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (8, 43);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (10, 45);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (12, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (13, 34);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (14, 35);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (15, 54);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (17, 21);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (18, 1);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (20, 6);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (21, 9);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (22, 6);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (25, 4);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (27, 10);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (33, 25);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (36, 57);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (38, 22);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (42, 14);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (43, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (45, 49);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (46, 28);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (47, 22);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (48, 38);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (50, 32);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (52, 6);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (53, 2);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (54, 11);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (56, 46);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (57, 27);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (58, 37);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (60, 12);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (61, 1);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (62, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (64, 59);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (65, 46);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (66, 1);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (68, 30);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (69, 3);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (71, 9);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (72, 1);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (75, 33);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (77, 34);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (78, 40);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (80, 55);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (81, 24);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (85, 8);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (86, 31);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (87, 5);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (88, 50);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (89, 53);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (90, 52);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (91, 48);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (92, 34);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (93, 43);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (94, 17);
INSERT INTO TripDestinations (TripID, DestinationID) VALUES (97, 36);



-- INQUIRIES TABLE DATA
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (1, 66, 1, 25, '2025-04-01', '2025-04-08');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (2, 39, 2, 82, '2025-04-02', '2025-04-16');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (3, 39, 33, 16, '2025-03-10', '2025-04-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (4, 52, 3, 32, '2025-03-17', '2025-03-24');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (5, 52, 35, 90, '2025-01-14', '2025-01-25');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (6, 52, 37, 45, '2025-01-16', '2025-01-30');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (7, 52, 41, 35, '2025-03-15', '2025-03-25');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (8, 52, 56, 31, '2025-02-14', '2025-03-09');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (9, 77, 4, 16, '2025-01-17', '2025-01-23');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (10, 77, 5, 42, '2025-02-17', '2025-03-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (11, 77, 6, 86, '2025-01-04', '2025-03-17');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (12, 77, 46, 44, '2025-02-10', '2025-03-20');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (13, 20, 7, 8, '2025-01-15', '2025-03-10');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (14, 20, 17, 41, '2025-02-01', '2025-03-31');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (15, 56, 8, 47, '2025-03-05', '2025-04-15');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (16, 56, 65, 96, '2025-01-04', '2025-01-19');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (17, 56, 80, 37, '2025-01-18', '2025-02-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (18, 6, 9, 70, '2025-01-24', '2025-02-14');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (19, 6, 18, 62, '2025-01-27', '2025-03-22');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (20, 19, 10, 30, '2025-03-07', '2025-04-08');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (21, 30, 11, 100, '2025-01-03', '2025-02-07');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (22, 2, 12, 85, '2025-01-14', '2025-03-26');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (23, 21, 13, 31, '2025-03-03', '2025-04-10');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (24, 42, 14, 73, '2025-01-22', '2025-02-14');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (25, 60, 15, 90, '2025-01-18', '2025-02-06');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (26, 60, 16, 22, '2025-02-16', '2025-03-21');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (27, 58, 19, 53, '2025-02-05', '2025-02-27');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (28, 83, 20, 62, '2025-02-22', '2025-02-25');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (29, 83, 52, 75, '2025-03-08', '2025-04-12');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (30, 98, 21, 61, '2025-01-01', '2025-02-04');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (31, 98, 27, 39, '2025-03-29', '2025-04-02');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (32, 16, 22, 32, '2025-03-06', '2025-04-11');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (33, 37, 23, 52, '2025-01-03', '2025-02-10');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (34, 37, 51, 53, '2025-01-19', '2025-03-29');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (35, 23, 24, 20, '2025-01-05', '2025-03-17');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (36, 4, 25, 60, '2025-02-20', '2025-03-26');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (37, 4, 62, 6, '2025-03-13', '2025-03-29');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (38, 4, 75, 46, '2025-01-11', '2025-03-16');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (39, 49, 26, 43, '2025-01-05', '2025-03-16');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (40, 49, 45, 85, '2025-01-13', '2025-01-18');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (41, 17, 28, 34, '2025-02-26', '2025-04-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (42, 25, 29, 17, '2025-02-03', '2025-03-29');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (43, 25, 59, 58, '2025-01-18', '2025-02-26');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (44, 7, 30, 50, '2025-01-03', '2025-03-26');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (45, 7, 77, 76, '2025-01-27', '2025-02-18');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (46, 28, 31, 26, '2025-01-28', '2025-03-15');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (47, 53, 32, 97, '2025-01-25', '2025-03-17');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (48, 53, 40, 5, '2025-04-07', '2025-04-15');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (49, 53, 94, 93, '2025-03-07', '2025-04-06');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (50, 61, 34, 31, '2025-03-07', '2025-04-05');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (51, 61, 81, 58, '2025-01-05', '2025-01-06');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (52, 48, 36, 27, '2025-01-28', '2025-02-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (53, 22, 38, 49, '2025-02-12', '2025-02-25');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (54, 26, 39, 58, '2025-01-29', '2025-02-13');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (55, 26, 72, 54, '2025-02-06', '2025-04-15');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (56, 27, 42, 16, '2025-01-08', '2025-03-16');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (57, 24, 43, 69, '2025-02-21', '2025-02-27');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (58, 24, 87, 83, '2025-02-17', '2025-02-18');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (59, 24, 99, 15, '2025-02-10', '2025-02-23');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (60, 67, 44, 80, '2025-01-31', '2025-03-29');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (61, 67, 83, 7, '2025-01-04', '2025-01-28');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (62, 62, 47, 84, '2025-02-21', '2025-03-29');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (63, 82, 48, 68, '2025-03-03', '2025-04-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (64, 82, 64, 84, '2025-01-08', '2025-02-28');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (65, 88, 49, 45, '2025-03-02', '2025-04-11');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (66, 75, 50, 58, '2025-02-11', '2025-02-22');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (67, 57, 53, 89, '2025-02-07', '2025-03-05');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (68, 57, 68, 100, '2025-01-06', '2025-03-29');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (69, 85, 54, 83, '2025-01-16', '2025-02-11');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (70, 5, 55, 92, '2025-01-06', '2025-01-25');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (71, 14, 57, 75, '2025-02-03', '2025-03-10');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (72, 14, 95, 21, '2025-04-04', '2025-04-13');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (73, 65, 58, 89, '2025-02-27', '2025-03-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (74, 87, 60, 39, '2025-01-19', '2025-03-19');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (75, 87, 78, 63, '2025-02-04', '2025-03-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (76, 100, 61, 52, '2025-03-09', '2025-04-10');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (77, 12, 63, 82, '2025-02-19', '2025-02-21');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (78, 9, 66, 23, '2025-01-18', '2025-03-26');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (79, 9, 76, 42, '2025-01-12', '2025-03-27');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (80, 54, 67, 79, '2025-01-29', '2025-04-05');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (81, 54, 71, 11, '2025-03-18', '2025-03-24');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (82, 54, 85, 32, '2025-01-04', '2025-04-02');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (83, 38, 69, 57, '2025-02-11', '2025-03-02');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (84, 32, 70, 70, '2025-01-02', '2025-02-03');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (85, 64, 73, 32, '2025-01-29', '2025-04-08');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (86, 50, 74, 21, '2025-02-09', '2025-03-07');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (87, 78, 79, 95, '2025-02-20', '2025-03-22');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (88, 99, 82, 91, '2025-02-10', '2025-04-14');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (89, 40, 84, 82, '2025-02-10', '2025-03-21');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (90, 71, 86, 73, '2025-01-11', '2025-04-04');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (91, 91, 88, 67, '2025-02-04', '2025-03-08');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (92, 81, 89, 31, '2025-03-02', '2025-04-09');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (93, 43, 90, 24, '2025-01-11', '2025-04-07');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (94, 55, 91, 4, '2025-01-22', '2025-02-01');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (95, 90, 92, 59, '2025-01-31', '2025-03-23');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (96, 79, 93, 56, '2025-01-26', '2025-02-04');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (97, 47, 96, 21, '2025-02-19', '2025-03-11');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (98, 92, 97, 22, '2025-01-12', '2025-04-07');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (99, 89, 98, 83, '2025-02-01', '2025-02-18');
INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, TourOperatorID, InquiryTime, ResponseTime) VALUES (100, 63, 100, 73, '2025-03-31', '2025-04-07');

ALTER TABLE Inquiries
ADD
    Query VARCHAR(1000),     -- You can adjust the length as needed
    Response VARCHAR(1000);  -- You can adjust the length as needed


-- Insert into InquiryQueries
UPDATE Inquiries SET Query = 'What is the itinerary for this booking?' WHERE InquiryID=1
UPDATE Inquiries SET Query = 'What is the itinerary for this booking?' WHERE InquiryID=2;
UPDATE Inquiries SET Query = 'What are the payment options?' WHERE InquiryID=3;
UPDATE Inquiries SET Query = 'Is hotel accommodation included?' WHERE InquiryID=4;
UPDATE Inquiries SET Query = 'Do you arrange airport transfers?' WHERE InquiryID=5;
UPDATE Inquiries SET Query = 'What is the baggage allowance?' WHERE InquiryID=6;
UPDATE Inquiries SET Query = 'Are travel guides provided?' WHERE InquiryID=7;
UPDATE Inquiries SET Query = 'Can I change the travel date?' WHERE InquiryID=8;
UPDATE Inquiries SET Query = 'What documents are needed?' WHERE InquiryID=9;
UPDATE Inquiries SET Query = 'Is there a loyalty program?' WHERE InquiryID=10;
UPDATE Inquiries SET Query = 'Do you offer group discounts?' WHERE InquiryID=11;
UPDATE Inquiries SET Query = 'Is there a children’s fare?' WHERE InquiryID=12;
UPDATE Inquiries SET Query = 'Are there any extra charges?' WHERE InquiryID=13;
UPDATE Inquiries SET Query = 'Can I choose my travel companion?' WHERE InquiryID=14;
UPDATE Inquiries SET Query = 'What time does the tour start?' WHERE InquiryID=15;
UPDATE Inquiries SET Query = 'Where is the meeting point?' WHERE InquiryID=16;
UPDATE Inquiries SET Query = 'Are travel vaccinations required?' WHERE InquiryID=17;
UPDATE Inquiries SET Query = 'Is travel insurance mandatory?' WHERE InquiryID=18;
UPDATE Inquiries SET Query = 'Are pets allowed on the tour?' WHERE InquiryID=19;
UPDATE Inquiries SET Query = 'What currency should I bring?' WHERE InquiryID=20;
UPDATE Inquiries SET Query = 'Can I cancel and get a full refund?' WHERE InquiryID=21;
UPDATE Inquiries SET Query = 'Are guides multilingual?' WHERE InquiryID=22;
UPDATE Inquiries SET Query = 'Is the tour physically demanding?' WHERE InquiryID=23;
UPDATE Inquiries SET Query = 'Can I join a tour last minute?' WHERE InquiryID=24;
UPDATE Inquiries SET Query = 'Is this destination safe?' WHERE InquiryID=25;
UPDATE Inquiries SET Query = 'Are there shopping stops?' WHERE InquiryID=26;
UPDATE Inquiries SET Query = 'Do you provide local SIM cards?' WHERE InquiryID=27;
UPDATE Inquiries SET Query = 'What if I miss my departure?' WHERE InquiryID=28;
UPDATE Inquiries SET Query = 'Is the tour eco-friendly?' WHERE InquiryID=29;
UPDATE Inquiries SET Query = 'Are COVID tests required?' WHERE InquiryID=30;
UPDATE Inquiries SET Query = 'Do you offer honeymoon packages?' WHERE InquiryID=31;
UPDATE Inquiries SET Query = 'Is there a student package?' WHERE InquiryID=32;
UPDATE Inquiries SET Query = 'What’s included in the price?' WHERE InquiryID=33;
UPDATE Inquiries SET Query = 'Do you provide emergency contacts?' WHERE InquiryID=34;
UPDATE Inquiries SET Query = 'Are masks required?' WHERE InquiryID=35;
UPDATE Inquiries SET Query = 'Can I request a vegetarian meal?' WHERE InquiryID=36;
UPDATE Inquiries SET Query = 'Is Wi-Fi available in hotels?' WHERE InquiryID=37;
UPDATE Inquiries SET Query = 'Do I need a passport?' WHERE InquiryID=38;
UPDATE Inquiries SET Query = 'Can I book just the flight?' WHERE InquiryID=39;
UPDATE Inquiries SET Query = 'What’s the check-out time?' WHERE InquiryID=40;
UPDATE Inquiries SET Query = 'Is the tour wheelchair accessible?' WHERE InquiryID=41;
UPDATE Inquiries SET Query = 'Can I delay my return trip?' WHERE InquiryID=42;
UPDATE Inquiries SET Query = 'Do you offer multilingual brochures?' WHERE InquiryID=43;
UPDATE Inquiries SET Query = 'Are there layovers on the flight?' WHERE InquiryID=44;
UPDATE Inquiries SET Query = 'Do you offer travel insurance?' WHERE InquiryID=45;
UPDATE Inquiries SET Query = 'Can I see reviews from past travelers?' WHERE InquiryID=46;
UPDATE Inquiries SET Query = 'Is there Wi-Fi on the bus?' WHERE InquiryID=47;
UPDATE Inquiries SET Query = 'Are meals included in the tour?' WHERE InquiryID=48;
UPDATE Inquiries SET Query = 'Can I join the tour midway?' WHERE InquiryID=49;
UPDATE Inquiries SET Query = 'Is the itinerary flexible?' WHERE InquiryID=50;
UPDATE Inquiries SET Query = 'What’s the group size limit?' WHERE InquiryID=51;
UPDATE Inquiries SET Query = 'Do you provide bottled water?' WHERE InquiryID=52;
UPDATE Inquiries SET Query = 'Is there a restroom on board?' WHERE InquiryID=53;
UPDATE Inquiries SET Query = 'Can I bring a pet?' WHERE InquiryID=54;
UPDATE Inquiries SET Query = 'Do you offer discounts for seniors?' WHERE InquiryID=55;
UPDATE Inquiries SET Query = 'Are entry tickets included in price?' WHERE InquiryID=56;
UPDATE Inquiries SET Query = 'What should I pack?' WHERE InquiryID=57;
UPDATE Inquiries SET Query = 'Is there a dress code?' WHERE InquiryID=58;
UPDATE Inquiries SET Query = 'Are night stays included?' WHERE InquiryID=59;
UPDATE Inquiries SET Query = 'Can I get a refund?' WHERE InquiryID=60;
UPDATE Inquiries SET Query = 'What is the cancellation policy?' WHERE InquiryID=61;
UPDATE Inquiries SET Query = 'Do you offer student discounts?' WHERE InquiryID=62;
UPDATE Inquiries SET Query = 'Can I pay in installments?' WHERE InquiryID=63;
UPDATE Inquiries SET Query = 'Do you accommodate dietary restrictions?' WHERE InquiryID=64;
UPDATE Inquiries SET Query = 'How early should I arrive?' WHERE InquiryID=65;
UPDATE Inquiries SET Query = 'Do I need to print my ticket?' WHERE InquiryID=66;
UPDATE Inquiries SET Query = 'Will there be photo stops?' WHERE InquiryID=67;
UPDATE Inquiries SET Query = 'Are personal belongings safe?' WHERE InquiryID=68;
UPDATE Inquiries SET Query = 'Is smoking allowed?' WHERE InquiryID=69;
UPDATE Inquiries SET Query = 'Are alcoholic drinks served?' WHERE InquiryID=70;
UPDATE Inquiries SET Query = 'Can I charge my phone on the bus?' WHERE InquiryID=71;
UPDATE Inquiries SET Query = 'Is the guide a local?' WHERE InquiryID=72;
UPDATE Inquiries SET Query = 'Are there restroom breaks?' WHERE InquiryID=73;
UPDATE Inquiries SET Query = 'Is snorkeling gear provided?' WHERE InquiryID=74;
UPDATE Inquiries SET Query = 'Are pets allowed in accommodations?' WHERE InquiryID=75;
UPDATE Inquiries SET Query = 'Do I need a travel adapter?' WHERE InquiryID=76;
UPDATE Inquiries SET Query = 'Can I upgrade my hotel room?' WHERE InquiryID=77;
UPDATE Inquiries SET Query = 'Are there vegan meal options?' WHERE InquiryID=78;
UPDATE Inquiries SET Query = 'What’s the average tour duration?' WHERE InquiryID=79;
UPDATE Inquiries SET Query = 'Is the tour family-friendly?' WHERE InquiryID=80;
UPDATE Inquiries SET Query = 'Can I choose my seat?' WHERE InquiryID=81;
UPDATE Inquiries SET Query = 'Are there any hidden fees?' WHERE InquiryID=82;
UPDATE Inquiries SET Query = 'Will I have free time?' WHERE InquiryID=83;
UPDATE Inquiries SET Query = 'Is tipping expected?' WHERE InquiryID=84;
UPDATE Inquiries SET Query = 'What happens in bad weather?' WHERE InquiryID=85;
UPDATE Inquiries SET Query = 'Is snorkeling mandatory?' WHERE InquiryID=86;
UPDATE Inquiries SET Query = 'Do you provide raincoats?' WHERE InquiryID=87;
UPDATE Inquiries SET Query = 'What languages are supported?' WHERE InquiryID=88;
UPDATE Inquiries SET Query = 'Can I book for next year?' WHERE InquiryID=89;
UPDATE Inquiries SET Query = 'Is early check-in possible?' WHERE InquiryID=90;
UPDATE Inquiries SET Query = 'Are drones allowed on tour?' WHERE InquiryID=91;
UPDATE Inquiries SET Query = 'Will there be live commentary?' WHERE InquiryID=92;
UPDATE Inquiries SET Query = 'Are meals buffet style?' WHERE InquiryID=93;
UPDATE Inquiries SET Query = 'Can I request a specific guide?' WHERE InquiryID=94;
UPDATE Inquiries SET Query = 'Do you provide sleeping bags?' WHERE InquiryID=95;
UPDATE Inquiries SET Query = 'Are rest days included?' WHERE InquiryID=96;
UPDATE Inquiries SET Query = 'Can I extend my stay?' WHERE InquiryID=97;
UPDATE Inquiries SET Query = 'Do you offer travel souvenirs?' WHERE InquiryID=98;
UPDATE Inquiries SET Query = 'Is medical assistance available?' WHERE InquiryID=99;
UPDATE Inquiries SET Query = 'Can I bring my own snacks?' WHERE InquiryID=100;



UPDATE Inquiries SET Response = 'Your itinerary will be shared via email after booking confirmation.' WHERE InquiryID=1;
UPDATE Inquiries SET Response = 'Your itinerary will be shared via email after booking confirmation.' WHERE InquiryID=2;
UPDATE Inquiries SET Response = 'We accept credit cards, debit cards, and online transfers.' WHERE InquiryID=3;
UPDATE Inquiries SET Response = 'Yes, hotel accommodation is included in most packages.' WHERE InquiryID=4;
UPDATE Inquiries SET Response = 'Yes, we provide airport pickup and drop-off services.' WHERE InquiryID=5;
UPDATE Inquiries SET Response = 'You may carry up to 20kg of checked baggage and one cabin bag.' WHERE InquiryID=6;
UPDATE Inquiries SET Response = 'Yes, certified travel guides accompany every tour.' WHERE InquiryID=7;
UPDATE Inquiries SET Response = 'Date changes depend on availability and may incur a fee.' WHERE InquiryID=8;
UPDATE Inquiries SET Response = 'A valid passport and travel visa (if applicable) are required.' WHERE InquiryID=9;
UPDATE Inquiries SET Response = 'Yes, our loyalty program offers points on every booking.' WHERE InquiryID=10;
UPDATE Inquiries SET Response = 'We offer group discounts for 5 or more travelers.' WHERE InquiryID=11;
UPDATE Inquiries SET Response = 'Yes, we offer discounted fares for children under 12.' WHERE InquiryID=12;
UPDATE Inquiries SET Response = 'There may be optional add-ons at extra cost, clearly mentioned during booking.' WHERE InquiryID=13;
UPDATE Inquiries SET Response = 'You may request to travel with a companion when booking as a pair or group.' WHERE InquiryID=14;
UPDATE Inquiries SET Response = 'Most tours begin around 8 AM; check your booking confirmation for exact time.' WHERE InquiryID=15;
UPDATE Inquiries SET Response = 'The meeting point is typically your hotel or a designated central location.' WHERE InquiryID=16;
UPDATE Inquiries SET Response = 'Vaccination requirements vary by destination; we advise checking health advisories.' WHERE InquiryID=17;
UPDATE Inquiries SET Response = 'Travel insurance is highly recommended but not mandatory.' WHERE InquiryID=18;
UPDATE Inquiries SET Response = 'Pets are not permitted on our standard tours.' WHERE InquiryID=19;
UPDATE Inquiries SET Response = 'We recommend bringing the local currency or a card accepted internationally.' WHERE InquiryID=20;
UPDATE Inquiries SET Response = 'Cancellations within the allowed period are eligible for a full refund.' WHERE InquiryID=21;
UPDATE Inquiries SET Response = 'Yes, many of our guides speak multiple languages including English, Spanish, and French.' WHERE InquiryID=22;
UPDATE Inquiries SET Response = 'Some tours involve walking and light physical activity; please check individual tour descriptions.' WHERE InquiryID=23;
UPDATE Inquiries SET Response = 'Yes, subject to availability, we accept bookings up to the day of departure.' WHERE InquiryID=24;
UPDATE Inquiries SET Response = 'We only operate tours in destinations that are considered safe for travel.' WHERE InquiryID=25;
UPDATE Inquiries SET Response = 'Some itineraries include stops at popular shopping areas.' WHERE InquiryID=26;
UPDATE Inquiries SET Response = 'We do not provide SIM cards, but our team can guide you on where to buy one locally.' WHERE InquiryID=27;
UPDATE Inquiries SET Response = 'If you miss your departure, please contact our support team immediately for assistance.' WHERE InquiryID=28;
UPDATE Inquiries SET Response = 'Yes, we strive to reduce our environmental impact and support sustainable tourism.' WHERE InquiryID=29;
UPDATE Inquiries SET Response = 'COVID-19 test requirements depend on destination regulations at the time of travel.' WHERE InquiryID=30;
UPDATE Inquiries SET Response = 'Yes, we offer specially designed honeymoon packages.' WHERE InquiryID=31;
UPDATE Inquiries SET Response = 'Yes, students with valid ID can avail discounts on select packages.' WHERE InquiryID=32;
UPDATE Inquiries SET Response = 'Tour price includes accommodation, transport, guide services, and select meals.' WHERE InquiryID=33;
UPDATE Inquiries SET Response = 'Yes, emergency contact information is provided in your booking confirmation.' WHERE InquiryID=34;
UPDATE Inquiries SET Response = 'Face masks may be required in transport or indoor venues depending on local regulations.' WHERE InquiryID=35;
UPDATE Inquiries SET Response = 'Vegetarian meal options can be arranged upon request during booking.' WHERE InquiryID=36;
UPDATE Inquiries SET Response = 'Most hotels we partner with offer free Wi-Fi in rooms and common areas.' WHERE InquiryID=37;
UPDATE Inquiries SET Response = 'A passport is required for all international travel and ID for domestic travel.' WHERE InquiryID=38;
UPDATE Inquiries SET Response = 'Yes, flight-only bookings are available upon request.' WHERE InquiryID=39;
UPDATE Inquiries SET Response = 'Hotel check-out is usually by 11 AM; exact time will be mentioned in your itinerary.' WHERE InquiryID=40;
UPDATE Inquiries SET Response = 'Some tours are wheelchair accessible; please mention your needs during booking.' WHERE InquiryID=41;
UPDATE Inquiries SET Response = 'You may delay your return for a fee; let us know your preferred return date.' WHERE InquiryID=42;
UPDATE Inquiries SET Response = 'Yes, brochures in multiple languages are available upon request.' WHERE InquiryID=43;
UPDATE Inquiries SET Response = 'Some international flights have layovers; details are shared at the time of booking.' WHERE InquiryID=44;
UPDATE Inquiries SET Response = 'Yes, we offer optional travel insurance during the booking process.' WHERE InquiryID=45;
UPDATE Inquiries SET Response = 'Yes, traveler reviews are available on our website under each tour listing.' WHERE InquiryID=46;
UPDATE Inquiries SET Response = 'Yes, many of our buses are equipped with Wi-Fi; availability varies by route.' WHERE InquiryID=47;
UPDATE Inquiries SET Response = 'Most tours include meals; details are specified in the itinerary.' WHERE InquiryID=48;
UPDATE Inquiries SET Response = 'Joining midway may be possible; please contact support for arrangements.' WHERE InquiryID=49;
UPDATE Inquiries SET Response = 'Some flexibility is allowed for private or custom tours.' WHERE InquiryID=50;
UPDATE Inquiries SET Response = 'Group size varies by tour; most range from 10 to 30 travelers.' WHERE InquiryID=51;
UPDATE Inquiries SET Response = 'Yes, bottled water is provided during excursions and travel.' WHERE InquiryID=52;
UPDATE Inquiries SET Response = 'Yes, our long-distance buses have onboard restrooms.' WHERE InquiryID=53;
UPDATE Inquiries SET Response = 'Pets are not allowed on standard tours; service animals are permitted.' WHERE InquiryID=54;
UPDATE Inquiries SET Response = 'Yes, seniors are eligible for discounted rates on select tours.' WHERE InquiryID=55;
UPDATE Inquiries SET Response = 'Entry tickets to attractions are included unless stated otherwise.' WHERE InquiryID=56;
UPDATE Inquiries SET Response = 'A packing list is included in your tour documentation or available on request.' WHERE InquiryID=57;
UPDATE Inquiries SET Response = 'There is no specific dress code, but comfortable clothing is recommended.' WHERE InquiryID=58;
UPDATE Inquiries SET Response = 'Yes, overnight stays are included as specified in the itinerary.' WHERE InquiryID=59;
UPDATE Inquiries SET Response = 'Refunds depend on cancellation timing; please refer to our refund policy.' WHERE InquiryID=60;
UPDATE Inquiries SET Response = 'Our cancellation policy is available on the booking page and confirmation email.' WHERE InquiryID=61;
UPDATE Inquiries SET Response = 'Yes, student discounts are available for travelers with valid ID.' WHERE InquiryID=62;
UPDATE Inquiries SET Response = 'Installment payments can be arranged through our support team.' WHERE InquiryID=63;
UPDATE Inquiries SET Response = 'Yes, we accommodate dietary needs if informed in advance.' WHERE InquiryID=64;
UPDATE Inquiries SET Response = 'Please arrive at least 15–30 minutes before the scheduled departure time.' WHERE InquiryID=65;
UPDATE Inquiries SET Response = 'You may show a digital ticket, but printed copies are recommended as backup.' WHERE InquiryID=66;
UPDATE Inquiries SET Response = 'Yes, most tours include stops for photography and sightseeing.' WHERE InquiryID=67;
UPDATE Inquiries SET Response = 'We recommend keeping valuables with you; luggage is stored securely.' WHERE InquiryID=68;
UPDATE Inquiries SET Response = 'Smoking is not permitted during transport or on group tours.' WHERE InquiryID=69;
UPDATE Inquiries SET Response = 'Alcohol may be served depending on the tour type and destination regulations.' WHERE InquiryID=70;
UPDATE Inquiries SET Response = 'Most modern buses have USB charging ports or power outlets.' WHERE InquiryID=71;
UPDATE Inquiries SET Response = 'Yes, our local guides bring authentic insights and regional expertise.' WHERE InquiryID=72;
UPDATE Inquiries SET Response = 'Restroom breaks are included during long travel segments.' WHERE InquiryID=73;
UPDATE Inquiries SET Response = 'Yes, snorkeling gear is provided for water-based activities.' WHERE InquiryID=74;
UPDATE Inquiries SET Response = 'Accommodation pet policies vary; please check with us before booking.' WHERE InquiryID=75;
UPDATE Inquiries SET Response = 'A universal travel adapter is recommended, especially for international tours.' WHERE InquiryID=76;
UPDATE Inquiries SET Response = 'Hotel upgrades can be requested for an additional charge.' WHERE InquiryID=77;
UPDATE Inquiries SET Response = 'Yes, vegan meals are available on request in most destinations.' WHERE InquiryID=78;
UPDATE Inquiries SET Response = 'Tour durations vary; most last between 4 to 10 days.' WHERE InquiryID=79;
UPDATE Inquiries SET Response = 'Yes, we offer many family-friendly tours suitable for all ages.' WHERE InquiryID=80;
UPDATE Inquiries SET Response = 'Seat selection is available on flights and some transport services.' WHERE InquiryID=81;
UPDATE Inquiries SET Response = 'No hidden charges; all costs are disclosed at the time of booking.' WHERE InquiryID=82;
UPDATE Inquiries SET Response = 'Yes, we schedule free time in most itineraries for personal exploration.' WHERE InquiryID=83;
UPDATE Inquiries SET Response = 'Tipping is customary in many places but always optional.' WHERE InquiryID=84;
UPDATE Inquiries SET Response = 'In case of bad weather, tours may be rescheduled or adjusted for safety.' WHERE InquiryID=85;
UPDATE Inquiries SET Response = 'Snorkeling is optional and only included on select water-based tours.' WHERE InquiryID=86;
UPDATE Inquiries SET Response = 'Raincoats or ponchos are provided when needed during outdoor tours.' WHERE InquiryID=87;
UPDATE Inquiries SET Response = 'Guides usually speak English; some tours offer multiple language support.' WHERE InquiryID=88;
UPDATE Inquiries SET Response = 'Yes, bookings can be made for tours scheduled in the upcoming year.' WHERE InquiryID=89;
UPDATE Inquiries SET Response = 'Early check-in is subject to hotel availability and may require an extra fee.' WHERE InquiryID=90;
UPDATE Inquiries SET Response = 'Drone usage is subject to local laws and not permitted on all tours.' WHERE InquiryID=91;
UPDATE Inquiries SET Response = 'Yes, some tours include live commentary from expert guides.' WHERE InquiryID=92;
UPDATE Inquiries SET Response = 'Most included meals are buffet-style unless otherwise mentioned.' WHERE InquiryID=93;
UPDATE Inquiries SET Response = 'Specific guide requests are accommodated when possible, subject to availability.' WHERE InquiryID=94;
UPDATE Inquiries SET Response = 'Sleeping bags are provided only on camping tours; please confirm with your package.' WHERE InquiryID=95;
UPDATE Inquiries SET Response = 'Longer tours often include designated rest days in the itinerary.' WHERE InquiryID=96;
UPDATE Inquiries SET Response = 'Yes, extensions can be arranged before or after your tour.' WHERE InquiryID=97;
UPDATE Inquiries SET Response = 'Yes, travel souvenirs are available for purchase on most tours.' WHERE InquiryID=98;
UPDATE Inquiries SET Response = 'Medical assistance is available via tour staff or local emergency services.' WHERE InquiryID=99;
UPDATE Inquiries SET Response = 'Yes, you may bring your own snacks as long as local customs allow it.' WHERE InquiryID=100;



-- OVERSEES TABLE DATA
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (62, 92, '2024-06-13');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (21, 35, '2023-08-16');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (16, 12, '2023-04-25');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (93, 34, '2024-04-14');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (58, 74, '2024-10-14');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (30, 14, '2024-05-12');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (87, 14, '2023-09-09');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (94, 39, '2024-11-02');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (5, 67, '2023-08-09');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (73, 74, '2024-10-07');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (7, 42, '2024-12-31');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (40, 96, '2023-09-25');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (55, 31, '2024-03-01');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (67, 93, '2024-03-11');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (98, 97, '2023-11-19');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (49, 51, '2023-06-09');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (66, 67, '2025-02-26');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (41, 76, '2025-03-26');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (55, 56, '2023-10-07');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (43, 50, '2025-03-04');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (69, 39, '2023-05-18');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (71, 19, '2023-12-15');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (96, 25, '2024-01-28');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (34, 30, '2025-01-28');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (8, 71, '2023-10-30');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (96, 70, '2023-10-31');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (45, 58, '2023-08-05');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (14, 37, '2024-10-11');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (38, 56, '2024-11-11');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (39, 56, '2024-11-26');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (44, 59, '2023-11-06');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (79, 84, '2024-12-24');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (38, 47, '2024-12-27');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (97, 90, '2023-07-02');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (9, 75, '2023-09-26');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (28, 51, '2024-02-15');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (95, 100, '2024-03-14');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (79, 5, '2025-01-24');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (39, 82, '2025-03-23');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (41, 23, '2024-12-29');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (56, 80, '2025-03-14');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (48, 23, '2024-05-28');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (33, 15, '2024-07-25');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (57, 99, '2024-08-10');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (28, 88, '2023-11-18');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (40, 31, '2024-11-10');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (31, 58, '2024-10-09');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (48, 11, '2025-02-09');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (75, 49, '2023-08-18');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (93, 1, '2023-09-24');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (37, 72, '2024-06-07');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (50, 80, '2024-07-03');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (94, 61, '2024-06-05');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (23, 25, '2025-03-01');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (73, 40, '2024-11-26');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (55, 80, '2025-02-25');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (75, 22, '2024-11-21');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (66, 37, '2023-11-27');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (94, 82, '2024-06-10');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (7, 86, '2023-12-23');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (5, 66, '2024-12-06');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (1, 76, '2023-07-23');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (90, 100, '2024-03-21');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (47, 75, '2025-04-13');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (3, 95, '2024-09-06');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (91, 89, '2024-05-29');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (97, 13, '2023-12-31');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (30, 7, '2023-04-27');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (37, 89, '2023-10-07');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (77, 21, '2024-06-14');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (19, 10, '2023-12-30');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (66, 3, '2023-09-04');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (30, 18, '2024-05-21');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (86, 31, '2025-04-06');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (73, 16, '2024-02-24');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (58, 76, '2024-09-25');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (93, 44, '2023-12-31');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (88, 36, '2023-07-10');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (72, 29, '2025-03-02');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (27, 100, '2024-04-27');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (24, 27, '2024-05-11');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (32, 72, '2024-08-27');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (68, 56, '2024-03-30');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (75, 29, '2024-12-09');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (48, 88, '2023-07-29');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (56, 8, '2024-08-22');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (21, 17, '2024-10-16');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (32, 82, '2023-11-12');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (45, 46, '2023-08-21');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (21, 98, '2023-11-01');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (24, 67, '2024-08-13');
INSERT INTO Oversees (AdminID, ReviewID, DateOverseen) VALUES (62, 42, '2023-04-20');



-- TRAVELER INQUIRIES WITH BOOKINGS TABLE DATA
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (1, 66, 1, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (2, 39, 2, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (3, 39, 33, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (4, 52, 3, 'Can I add more people to the group for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (5, 52, 35, 'What is the weather like at the destinations during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (6, 52, 37, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (7, 52, 41, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (8, 52, 56, 'Can I customize the itinerary for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (9, 77, 4, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (10, 77, 5, 'What is the weather like at the destinations during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (11, 77, 6, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (12, 77, 46, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (13, 20, 7, 'What is the weather like at the destinations during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (14, 20, 17, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (15, 56, 8, 'Is there any way to add extra activities during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (16, 56, 65, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (17, 56, 80, 'Is this trip still available for booking?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (18, 6, 9, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (19, 6, 18, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (20, 19, 10, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (21, 30, 11, 'Is this trip still available for booking?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (22, 2, 12, 'What is the maximum group size for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (23, 21, 13, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (24, 42, 14, 'Is there any way to add extra activities during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (25, 60, 15, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (26, 60, 16, 'What is the weather like at the destinations during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (27, 58, 19, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (28, 83, 20, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (29, 83, 52, 'Can I customize the itinerary for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (30, 98, 21, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (31, 98, 27, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (32, 16, 22, 'Can I customize the itinerary for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (33, 37, 23, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (34, 37, 51, 'Could you provide more details on the accommodations included in this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (35, 23, 24, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (36, 4, 25, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (37, 4, 62, 'Can I customize the itinerary for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (38, 4, 75, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (39, 49, 26, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (40, 49, 45, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (41, 17, 28, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (42, 25, 29, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (43, 25, 59, 'Are there any additional costs apart from the listed price?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (44, 7, 30, 'What is the maximum group size for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (45, 7, 77, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (46, 28, 31, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (47, 53, 32, 'Is there any way to add extra activities during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (48, 53, 40, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (49, 53, 94, 'What is the weather like at the destinations during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (50, 61, 34, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (51, 61, 81, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (52, 48, 36, 'Are there any additional costs apart from the listed price?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (53, 22, 38, 'Could you provide more details on the accommodations included in this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (54, 26, 39, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (55, 26, 72, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (56, 27, 42, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (57, 24, 43, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (58, 24, 87, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (59, 24, 99, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (60, 67, 44, 'Could you provide more details on the accommodations included in this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (61, 67, 83, 'Can I customize the itinerary for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (62, 62, 47, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (63, 82, 48, 'What is the maximum group size for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (64, 82, 64, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (65, 88, 49, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (66, 75, 50, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (67, 57, 53, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (68, 57, 68, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (69, 85, 54, 'What is the maximum group size for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (70, 5, 55, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (71, 14, 57, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (72, 14, 95, 'Are there any additional costs apart from the listed price?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (73, 65, 58, 'Can I add more people to the group for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (74, 87, 60, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (75, 87, 78, 'Are there any additional costs apart from the listed price?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (76, 100, 61, 'Is this trip still available for booking?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (77, 12, 63, 'Could you provide more details on the accommodations included in this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (78, 9, 66, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (79, 9, 76, 'What is the cancellation policy for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (80, 54, 67, 'Does this trip include all meals and accommodations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (81, 54, 71, 'Is this trip still available for booking?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (82, 54, 85, 'Are there any additional costs apart from the listed price?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (83, 38, 69, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (84, 32, 70, 'Is this trip still available for booking?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (85, 64, 73, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (86, 50, 74, 'Is there any way to add extra activities during the trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (87, 78, 79, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (88, 99, 82, 'What is the maximum group size for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (89, 40, 84, 'Is there any possibility of extending the trip to additional destinations?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (90, 71, 86, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (91, 91, 88, 'Can I get a refund if I need to cancel due to unforeseen circumstances?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (92, 81, 89, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (93, 43, 90, 'Can I add more people to the group for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (94, 55, 91, 'Is this trip still available for booking?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (95, 90, 92, 'Can I customize the itinerary for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (96, 79, 93, 'How long in advance should I book for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (97, 47, 96, 'Can you provide more details on the transport arrangements?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (98, 92, 97, 'Are there any special discounts or offers for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (99, 89, 98, 'What is the maximum group size for this trip?');
INSERT INTO TravelerInquiryBooking (InquiryID, TravelerID, BookingID, Inquiry) VALUES (100, 63, 100, 'How long in advance should I book for this trip?');




-- EVALUATION TABLE DATA
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (58, 25, '2025-03-06');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (37, 91, '2023-04-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (4, 19, '2025-02-25');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (25, 80, '2024-08-02');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (20, 65, '2024-02-17');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (75, 18, '2023-04-18');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (44, 40, '2023-06-14');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (62, 32, '2024-01-16');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (65, 54, '2023-07-02');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (27, 15, '2023-05-12');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (98, 60, '2025-04-08');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (58, 75, '2025-02-04');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (16, 57, '2023-11-20');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (64, 44, '2024-09-08');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (50, 68, '2024-07-12');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (13, 50, '2023-04-21');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (85, 64, '2024-11-17');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (22, 44, '2024-11-13');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (48, 100, '2024-06-02');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (53, 51, '2023-10-14');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (81, 85, '2024-03-05');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (56, 59, '2024-05-06');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (31, 23, '2023-09-23');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (28, 39, '2023-08-25');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (89, 19, '2025-04-10');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (9, 95, '2023-09-16');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (47, 57, '2023-09-10');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (41, 93, '2024-01-10');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (38, 58, '2023-05-16');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (68, 80, '2024-05-10');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (27, 86, '2024-05-26');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (12, 17, '2025-02-23');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (88, 98, '2025-02-25');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (31, 14, '2023-12-08');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (70, 88, '2023-10-02');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (72, 94, '2024-01-17');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (82, 12, '2024-09-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (26, 37, '2025-02-21');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (53, 50, '2024-09-04');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (49, 85, '2024-08-12');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (27, 58, '2024-04-12');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (62, 77, '2024-01-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (67, 61, '2025-02-15');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (26, 26, '2024-05-25');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (90, 33, '2025-03-24');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (11, 39, '2023-08-21');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (40, 23, '2025-03-15');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (74, 11, '2024-11-13');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (23, 51, '2024-11-04');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (38, 54, '2024-01-14');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (71, 24, '2023-07-08');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (31, 5, '2023-09-26');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (48, 25, '2024-07-23');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (5, 96, '2023-10-06');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (99, 19, '2023-04-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (98, 38, '2024-10-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (89, 16, '2024-02-22');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (71, 73, '2024-11-13');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (4, 58, '2024-10-29');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (58, 48, '2025-03-03');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (87, 47, '2024-10-14');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (54, 33, '2024-04-23');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (43, 42, '2024-05-07');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (11, 27, '2024-08-24');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (21, 73, '2023-11-29');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (8, 45, '2024-01-09');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (65, 65, '2023-10-28');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (32, 89, '2024-09-20');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (65, 42, '2024-02-04');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (87, 52, '2023-07-22');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (52, 55, '2024-10-03');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (64, 85, '2024-10-31');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (61, 76, '2024-03-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (53, 96, '2024-10-21');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (65, 47, '2025-02-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (52, 82, '2023-07-07');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (62, 59, '2023-05-19');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (63, 9, '2024-09-15');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (82, 75, '2023-09-07');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (67, 54, '2025-03-07');
INSERT INTO Evaluation (OperatorID, ServiceProviderID, EvaluationDate) VALUES (9, 32, '2023-06-04');




--*View for Report 7.1*
create view Newregs as
SELECT 
    YEAR(RegistrationDate) AS Year,
    MONTH(RegistrationDate) AS Month,
    COUNT(*) AS NewTravelers,
    NULL AS NewOperators,
    NULL AS NewProviders
FROM Traveler
GROUP BY 
    YEAR(RegistrationDate), 
    MONTH(RegistrationDate)

UNION ALL

-- New Operator Registrations by Month
SELECT 
    YEAR(RegistrationDate) AS Year,
    MONTH(RegistrationDate) AS Month,
    NULL AS NewTravelers,
    COUNT(*) AS NewOperators,
    NULL AS NewProviders
FROM TourOperator
GROUP BY 
    YEAR(RegistrationDate), 
    MONTH(RegistrationDate)

UNION ALL

-- New Service Provider Registrations by Month
SELECT 
    YEAR(DateRegistered) AS Year,
    MONTH(DateRegistered) AS Month,
    NULL AS NewTravelers,
    NULL AS NewOperators,
    COUNT(*) AS NewProviders
FROM HotelServiceProvider
GROUP BY 
    YEAR(DateRegistered), 
    MONTH(DateRegistered);

	--*View for Report 7.2*

create view ActiveUsers as
-- Active Travelers by Month
SELECT 
    YEAR(B.BookingDate) AS Year,
    MONTH(B.BookingDate) AS Month,
    COUNT(DISTINCT B.TravelerID) AS ActiveTravelers,
    NULL AS ActiveOperators
FROM Booking B
WHERE B.BookingStatus = 'Confirmed'  -- Only considering confirmed bookings
GROUP BY 
    YEAR(B.BookingDate), 
    MONTH(B.BookingDate)

UNION ALL

-- Active Operators by Month
SELECT 
    YEAR(T.StartDate) AS Year,
    MONTH(T.StartDate) AS Month,
    NULL AS ActiveTravelers,
    COUNT(DISTINCT TI.ServiceProviderID) AS ActiveOperators
FROM Trip T
JOIN TripInvolves TI ON T.TripID = TI.TripID
JOIN Booking B ON B.TripID = T.TripID
WHERE B.BookingStatus = 'Confirmed'  -- Only considering confirmed bookings
GROUP BY 
    YEAR(T.StartDate), 
    MONTH(T.StartDate);





--	*View for Report 7.3*
CREATE VIEW PartnershipGrowth1 AS
SELECT 
    CONCAT(YEAR(p.DateRegistered), '-', RIGHT('00' + CAST(MONTH(p.DateRegistered) AS VARCHAR(2)), 2)) AS MonthYear,
    COUNT(DISTINCT p.ServiceProviderID) AS NewHotels,
    NULL AS NewOperators
FROM HotelServiceProvider p
GROUP BY 
    YEAR(p.DateRegistered), 
    MONTH(p.DateRegistered)

UNION ALL

-- New Operators by Month
SELECT 
    CONCAT(YEAR(o.RegistrationDate), '-', RIGHT('00' + CAST(MONTH(o.RegistrationDate) AS VARCHAR(2)), 2)) AS MonthYear,
    NULL AS NewHotels,
    COUNT(DISTINCT o.OperatorID) AS NewOperators
FROM TourOperator o
GROUP BY 
    YEAR(o.RegistrationDate), 
    MONTH(o.RegistrationDate);

-- New Operators by Month
SELECT 
    YEAR(o.RegistrationDate) AS Year,
    MONTH(o.RegistrationDate) AS Month,
    NULL AS NewHotels,
    COUNT(DISTINCT o.OperatorID) AS NewOperators
FROM TourOperator o
GROUP BY 
    YEAR(o.RegistrationDate), 
    MONTH(o.RegistrationDate);


--	*View for Report 7.4*
create view NewDestinations as
SELECT 
    YEAR(d.DateAdded) AS Year,
    MONTH(d.DateAdded) AS Month,
    COUNT(DISTINCT d.DestinationID) AS NewDestinations
FROM Destination d
GROUP BY 
    YEAR(d.DateAdded), 
    MONTH(d.DateAdded);


	--View for Report 8.1
create view SucessFailure as
SELECT 
    COUNT(CASE WHEN p.PaymentStatus = 'Completed' THEN 1 END) * 100.0 / COUNT(p.PaymentID) AS SuccessRate,
    COUNT(CASE WHEN p.PaymentStatus = 'Failed' THEN 1 END) * 100.0 / COUNT(p.PaymentID) AS FailureRate
FROM Payment p
WHERE p.PaymentStatus IN ('Completed', 'Failed');

--View for Report 8.2
create view ChargeBack as
SELECT 
    b.BookingID, 
    b.TripID, 
    b.BookingDate, 
    b.NumOfParticipants, 
    b.TotalPrice, 
    b.BookingStatus, 
    p.PaymentStatus, 
    b.CancellationReason
FROM 
    Booking b
JOIN 
    Payment p ON b.BookingID = p.BookingID
WHERE 
    b.BookingStatus = 'Completed' 
    AND p.PaymentStatus = 'Failed';




	create view ChargeBack1 as
SELECT 
    b.BookingID, 
	b.TravelerID,
    b.TripID, 
    b.BookingDate, 
    b.NumOfParticipants, 
    b.TotalPrice, 
    b.BookingStatus, 
    p.PaymentStatus, 
    b.CancellationReason
FROM 
    Booking b
JOIN 
    Payment p ON b.BookingID = p.BookingID
WHERE 
    b.BookingStatus = 'Completed' 
    AND p.PaymentStatus = 'Failed';


--*View for Report 5.1*
create view RegionBookings as
select B.BookingID, D.Country, D.Region
from Booking B
Join Trip T on B.TripID = T.TripID
join TripDestinations TD on T.TripID = TD.TripID
join Destination D on TD.DestinationID = D.DestinationID;


--*View for Report 5.2*
create view SeasonTrends as
select T.TripID, Month(T.StartDate) as Month, D.Country, B.BookingID
from Trip T
join Booking B on T.TripID = B.TripID
join TripDestinations TD on B.TripID = TD.TripID
join Destination D on TD.DestinationID = D.DestinationID;

--*View for 5,3*
create view DestinationSatisfaction as
select R.TripID, D.Country, R.Rating
from Review R
join TripDestinations TD on R.TripID = TD.TripID
join Destination D on TD.DestinationID = D.DestinationID;

--*View for Report 5.4*
select * from EmergingDestinations
create view EmergingDestinations as
WITH MonthlyBookings AS (
    SELECT 
        D.DestinationID,
        D.Name AS DestinationName,
        COUNT(B.BookingID) AS BookingCount,
        SUM(CASE WHEN B.BookingDate >= DATEADD(MONTH, -2, GETDATE()) THEN 1 ELSE 0 END) AS BookingsLast6Months
    FROM 
        Booking B
    JOIN 

        Trip T ON B.TripID = T.TripID
    JOIN 
        TripDestinations TD ON T.TripID = TD.TripID
    JOIN 
        Destination D ON TD.DestinationID = D.DestinationID
    WHERE 
        B.BookingStatus = 'Confirmed'
    GROUP BY 
        D.DestinationID, D.Name
)
SELECT 
    DestinationName, 
    BookingCount,
    BookingsLast6Months,
    (BookingsLast6Months * 1.0 / BookingCount) AS GrowthRate
FROM 
    MonthlyBookings
WHERE 
    (BookingsLast6Months * 1.0 / BookingCount) > 0.1;




--*View for Report 6.2*
create view CommonReasons as
SELECT 
    BookingID,
    CASE
        WHEN CancellationReason LIKE '%Payment%' OR CancellationReason LIKE '%failed%' OR CancellationReason LIKE '%declined%' THEN 'Payment Failures'
        WHEN CancellationReason LIKE '%expensive%' OR CancellationReason LIKE '%high%' OR CancellationReason LIKE '%cost%' THEN 'High Prices'
        WHEN CancellationReason LIKE '%complicated%' OR CancellationReason LIKE '%visa%' OR CancellationReason LIKE '%restrictions%' THEN 'Complex Processes'
        WHEN CancellationReason LIKE '%health%' OR CancellationReason LIKE '%family%' OR CancellationReason LIKE '%mind%' THEN 'Personal Reasons'
        WHEN CancellationReason LIKE '%weather%' OR CancellationReason LIKE '%unforeseen%' OR CancellationReason LIKE '%scheduled%' THEN 'External Factors'
        WHEN CancellationReason LIKE '%scheduling%' THEN 'Time'
        WHEN CancellationReason LIKE '%illness%'THEN 'Health'
        ELSE 'Other'
    END AS CancellationCategory
FROM 
    Booking
WHERE
    CancellationReason IS NOT NULL;

	select * from CommonReasons


--*View for Report 6.3*

-- Abandoned bookings and not completed
create view RecoveryRate AS
SELECT 
    COUNT(CASE WHEN B.PaymentStatus = 'Failed' AND B.BookingStatus != 'Completed' AND B.BookingStatus != 'Confirmed' THEN 1 END) AS AbandonedNotCompleted,
    -- Abandoned bookings and completed later
    COUNT(CASE WHEN B.PaymentStatus != 'Failed' AND B.BookingStatus != 'Completed' AND B.BookingStatus != 'Confirmed' THEN 1 END) AS AbandonedThenCompleted
FROM 
    Trip T
JOIN 
    Booking B ON T.TripID = B.TripID;

--*View for Report 6.4*

create view EstimatedEarnings as
select W.WishlistID, T.Price
from WishlistAdd W
join Trip T on W.TripID = T.TripID;


ALTER TABLE TourOperator ADD RegistrationDate DATETIME DEFAULT GETDATE();

UPDATE TourOperator SET RegistrationDate = '2024-11-21' WHERE OperatorID = 1;
UPDATE TourOperator SET RegistrationDate = '2024-11-14' WHERE OperatorID = 2;
UPDATE TourOperator SET RegistrationDate = '2024-10-29' WHERE OperatorID = 3;
UPDATE TourOperator SET RegistrationDate = '2025-04-05' WHERE OperatorID = 4;
UPDATE TourOperator SET RegistrationDate = '2024-05-22' WHERE OperatorID = 5;
UPDATE TourOperator SET RegistrationDate = '2025-03-21' WHERE OperatorID = 6;
UPDATE TourOperator SET RegistrationDate = '2024-10-07' WHERE OperatorID = 7;
UPDATE TourOperator SET RegistrationDate = '2024-11-29' WHERE OperatorID = 8;
UPDATE TourOperator SET RegistrationDate = '2024-07-18' WHERE OperatorID = 9;
UPDATE TourOperator SET RegistrationDate = '2024-09-18' WHERE OperatorID = 10;
UPDATE TourOperator SET RegistrationDate = '2024-06-29' WHERE OperatorID = 11;
UPDATE TourOperator SET RegistrationDate = '2024-09-30' WHERE OperatorID = 12;
UPDATE TourOperator SET RegistrationDate = '2024-10-02' WHERE OperatorID = 13;
UPDATE TourOperator SET RegistrationDate = '2024-06-20' WHERE OperatorID = 14;
UPDATE TourOperator SET RegistrationDate = '2024-10-12' WHERE OperatorID = 15;
UPDATE TourOperator SET RegistrationDate = '2024-12-22' WHERE OperatorID = 16;
UPDATE TourOperator SET RegistrationDate = '2025-04-07' WHERE OperatorID = 17;
UPDATE TourOperator SET RegistrationDate = '2025-03-16' WHERE OperatorID = 18;
UPDATE TourOperator SET RegistrationDate = '2024-09-18' WHERE OperatorID = 19;
UPDATE TourOperator SET RegistrationDate = '2025-04-07' WHERE OperatorID = 20;
UPDATE TourOperator SET RegistrationDate = '2025-01-08' WHERE OperatorID = 21;
UPDATE TourOperator SET RegistrationDate = '2024-05-26' WHERE OperatorID = 22;
UPDATE TourOperator SET RegistrationDate = '2024-08-11' WHERE OperatorID = 23;
UPDATE TourOperator SET RegistrationDate = '2025-03-02' WHERE OperatorID = 24;
UPDATE TourOperator SET RegistrationDate = '2024-09-09' WHERE OperatorID = 25;
UPDATE TourOperator SET RegistrationDate = '2024-11-09' WHERE OperatorID = 26;
UPDATE TourOperator SET RegistrationDate = '2024-11-21' WHERE OperatorID = 27;
UPDATE TourOperator SET RegistrationDate = '2024-08-08' WHERE OperatorID = 28;
UPDATE TourOperator SET RegistrationDate = '2024-08-28' WHERE OperatorID = 29;
UPDATE TourOperator SET RegistrationDate = '2024-11-07' WHERE OperatorID = 30;
UPDATE TourOperator SET RegistrationDate = '2025-01-25' WHERE OperatorID = 31;
UPDATE TourOperator SET RegistrationDate = '2024-12-21' WHERE OperatorID = 32;
UPDATE TourOperator SET RegistrationDate = '2024-07-25' WHERE OperatorID = 33;
UPDATE TourOperator SET RegistrationDate = '2024-11-27' WHERE OperatorID = 34;
UPDATE TourOperator SET RegistrationDate = '2024-12-05' WHERE OperatorID = 35;
UPDATE TourOperator SET RegistrationDate = '2025-04-25' WHERE OperatorID = 36;
UPDATE TourOperator SET RegistrationDate = '2024-12-31' WHERE OperatorID = 37;
UPDATE TourOperator SET RegistrationDate = '2024-11-09' WHERE OperatorID = 38;
UPDATE TourOperator SET RegistrationDate = '2024-10-06' WHERE OperatorID = 39;
UPDATE TourOperator SET RegistrationDate = '2025-04-10' WHERE OperatorID = 40;
UPDATE TourOperator SET RegistrationDate = '2024-06-07' WHERE OperatorID = 41;
UPDATE TourOperator SET RegistrationDate = '2024-09-17' WHERE OperatorID = 42;
UPDATE TourOperator SET RegistrationDate = '2024-11-26' WHERE OperatorID = 43;
UPDATE TourOperator SET RegistrationDate = '2024-11-13' WHERE OperatorID = 44;
UPDATE TourOperator SET RegistrationDate = '2024-06-16' WHERE OperatorID = 45;
UPDATE TourOperator SET RegistrationDate = '2025-02-15' WHERE OperatorID = 46;
UPDATE TourOperator SET RegistrationDate = '2024-11-04' WHERE OperatorID = 47;
UPDATE TourOperator SET RegistrationDate = '2024-07-30' WHERE OperatorID = 48;
UPDATE TourOperator SET RegistrationDate = '2025-02-25' WHERE OperatorID = 49;
UPDATE TourOperator SET RegistrationDate = '2024-11-24' WHERE OperatorID = 50;
UPDATE TourOperator SET RegistrationDate = '2024-06-05' WHERE OperatorID = 51;
UPDATE TourOperator SET RegistrationDate = '2025-01-13' WHERE OperatorID = 52;
UPDATE TourOperator SET RegistrationDate = '2024-06-16' WHERE OperatorID = 53;
UPDATE TourOperator SET RegistrationDate = '2025-02-20' WHERE OperatorID = 54;
UPDATE TourOperator SET RegistrationDate = '2024-12-18' WHERE OperatorID = 55;
UPDATE TourOperator SET RegistrationDate = '2024-08-07' WHERE OperatorID = 56;
UPDATE TourOperator SET RegistrationDate = '2024-06-07' WHERE OperatorID = 57;
UPDATE TourOperator SET RegistrationDate = '2025-04-04' WHERE OperatorID = 58;
UPDATE TourOperator SET RegistrationDate = '2024-05-17' WHERE OperatorID = 59;
UPDATE TourOperator SET RegistrationDate = '2024-06-06' WHERE OperatorID = 60;
UPDATE TourOperator SET RegistrationDate = '2024-10-07' WHERE OperatorID = 61;
UPDATE TourOperator SET RegistrationDate = '2024-07-01' WHERE OperatorID = 62;
UPDATE TourOperator SET RegistrationDate = '2024-08-23' WHERE OperatorID = 63;
UPDATE TourOperator SET RegistrationDate = '2025-03-28' WHERE OperatorID = 64;
UPDATE TourOperator SET RegistrationDate = '2024-09-03' WHERE OperatorID = 65;
UPDATE TourOperator SET RegistrationDate = '2025-02-02' WHERE OperatorID = 66;
UPDATE TourOperator SET RegistrationDate = '2024-06-23' WHERE OperatorID = 67;
UPDATE TourOperator SET RegistrationDate = '2024-12-18' WHERE OperatorID = 68;
UPDATE TourOperator SET RegistrationDate = '2025-02-22' WHERE OperatorID = 69;
UPDATE TourOperator SET RegistrationDate = '2024-10-17' WHERE OperatorID = 70;
UPDATE TourOperator SET RegistrationDate = '2025-01-06' WHERE OperatorID = 71;
UPDATE TourOperator SET RegistrationDate = '2024-08-30' WHERE OperatorID = 72;
UPDATE TourOperator SET RegistrationDate = '2025-03-14' WHERE OperatorID = 73;
UPDATE TourOperator SET RegistrationDate = '2025-04-12' WHERE OperatorID = 74;
UPDATE TourOperator SET RegistrationDate = '2025-01-20' WHERE OperatorID = 75;
UPDATE TourOperator SET RegistrationDate = '2025-01-15' WHERE OperatorID = 76;
UPDATE TourOperator SET RegistrationDate = '2025-02-06' WHERE OperatorID = 77;
UPDATE TourOperator SET RegistrationDate = '2025-05-07' WHERE OperatorID = 78;
UPDATE TourOperator SET RegistrationDate = '2025-04-04' WHERE OperatorID = 79;
UPDATE TourOperator SET RegistrationDate = '2024-06-06' WHERE OperatorID = 80;
UPDATE TourOperator SET RegistrationDate = '2025-01-09' WHERE OperatorID = 81;
UPDATE TourOperator SET RegistrationDate = '2024-12-23' WHERE OperatorID = 82;
UPDATE TourOperator SET RegistrationDate = '2024-12-04' WHERE OperatorID = 83;
UPDATE TourOperator SET RegistrationDate = '2024-09-18' WHERE OperatorID = 84;
UPDATE TourOperator SET RegistrationDate = '2024-07-11' WHERE OperatorID = 85;
UPDATE TourOperator SET RegistrationDate = '2025-03-09' WHERE OperatorID = 86;
UPDATE TourOperator SET RegistrationDate = '2024-08-29' WHERE OperatorID = 87;
UPDATE TourOperator SET RegistrationDate = '2024-12-21' WHERE OperatorID = 88;
UPDATE TourOperator SET RegistrationDate = '2024-07-25' WHERE OperatorID = 89;
UPDATE TourOperator SET RegistrationDate = '2024-07-23' WHERE OperatorID = 90;
UPDATE TourOperator SET RegistrationDate = '2024-06-02' WHERE OperatorID = 91;
UPDATE TourOperator SET RegistrationDate = '2024-06-21' WHERE OperatorID = 92;
UPDATE TourOperator SET RegistrationDate = '2025-01-16' WHERE OperatorID = 93;
UPDATE TourOperator SET RegistrationDate = '2024-12-21' WHERE OperatorID = 94;
UPDATE TourOperator SET RegistrationDate = '2025-01-25' WHERE OperatorID = 95;
UPDATE TourOperator SET RegistrationDate = '2025-02-01' WHERE OperatorID = 96;
UPDATE TourOperator SET RegistrationDate = '2025-03-02' WHERE OperatorID = 97;
UPDATE TourOperator SET RegistrationDate = '2024-06-04' WHERE OperatorID = 98;
UPDATE TourOperator SET RegistrationDate = '2024-05-28' WHERE OperatorID = 99;
UPDATE TourOperator SET RegistrationDate = '2025-04-29' WHERE OperatorID = 100;


UPDATE Booking SET BookingDate = '2024-12-12' WHERE BookingID=1

select T.TripID, D.Name from Trip T
join TripDestinations TD on T.TripID = TD.TripID 
join Destination D on TD.DestinationID = D.DestinationID;

CREATE VIEW TripDestinationView AS
SELECT 
    T.TripID, 
    D.Name AS DestinationName
FROM 
    Trip T
JOIN 
    TripDestinations TD ON T.TripID = TD.TripID 
JOIN 
    Destination D ON TD.DestinationID = D.DestinationID;


CREATE VIEW TripDestinationView1 AS
SELECT 
    T.TripID, 
    T.TripType,
    B.BookingID,
    D.Name AS DestinationName
FROM 
    Trip T
JOIN 
    TripDestinations TD ON T.TripID = TD.TripID 
JOIN 
    Destination D ON TD.DestinationID = D.DestinationID
JOIN
    Booking B ON B.TripID = T.TripID;

create view OperatorIncome as
select 
T.OperatorID, 
P.Amount as Income
from Trip T
join Booking B on T.TripID = B.TripID
join Payment P on B.BookingID = P.BookingID
where P.PaymentStatus = 'Completed';


create view TourOperatorReviewView as
select T.OperatorID, R.Rating
from TourOperator T
join Trip Tr on T.OperatorID = Tr.OperatorID
join Review R on Tr.TripID = R.TripID;

select * from Inquiries
CREATE VIEW InquiriesView AS
SELECT 
    TourOperatorID, DATEDIFF(HOUR, InquiryTime, ResponseTime) AS ResponseTime
FROM 
    Inquiries






