-- A travel agency manages business trips for its customers. 
-- The agency has several Salespersons who arrange trips for customers.
-- 1. A salesperson can arrange many trips.
-- 2. A trip is arranged by one salesperson.
-- 3. A customer can plan and book many trips.
-- 4. A trip can be booked by many customers.
-- 5. Therefore, the relationship between Customer and Trip is many-to-many.
-- 6. Appropriate primary key, foreign key, NOT NULL, UNIQUE, CHECK and other constraints must be used.


-- =============================================================================
-- 1. DATABASE & 3NF SCHEMA CREATION
-- =============================================================================
DROP DATABASE IF EXISTS TravelAgencyDB;
CREATE DATABASE TravelAgencyDB;
USE TravelAgencyDB;

-- Drop dependent tables first
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Trip;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Salesperson;

-- Salesperson Table
CREATE TABLE Salesperson (
    salesperson_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    experience_years INT NOT NULL,
    CONSTRAINT chk_salesperson_exp CHECK (experience_years > 0)
);

-- Trip Table (Salesperson -> Trip is 1:M)
CREATE TABLE Trip (
    trip_id INT PRIMARY KEY AUTO_INCREMENT,
    destination VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    salesperson_id INT NOT NULL,
    CONSTRAINT chk_trip_cost CHECK (cost >= 0),
    CONSTRAINT chk_trip_dates CHECK (end_date >= start_date),
    CONSTRAINT fk_trip_salesperson FOREIGN KEY (salesperson_id) 
        REFERENCES Salesperson(salesperson_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Customer Table
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL
);

-- Booking Table (Customer <-> Trip M:M junction)
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    trip_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_status VARCHAR(20) NOT NULL,
    CONSTRAINT chk_booking_status CHECK (booking_status IN ('Confirmed', 'Pending', 'Cancelled')),
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) 
        REFERENCES Customer(customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_booking_trip FOREIGN KEY (trip_id) 
        REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- =============================================================================
-- 2. SAMPLE DATA INSERTION
-- =============================================================================

INSERT INTO Salesperson (salesperson_id, name, email, phone, experience_years) VALUES
(1, 'Ramesh Nair', 'ramesh.n@agency.com', '9811111111', 5),
(2, 'Sunita Rao', 'sunita.r@agency.com', '9822222222', 8),
(3, 'Vikram Deshmukh', 'vikram.d@agency.com', '9833333333', 3),
(4, 'Deepa Joshi', 'deepa.j@agency.com', '9844444444', 6);

INSERT INTO Trip (trip_id, destination, start_date, end_date, cost, salesperson_id) VALUES
(101, 'Mumbai', '2026-11-01', '2026-11-05', 45000.00, 1),
(102, 'Delhi', '2026-11-10', '2026-11-15', 38000.00, 1),
(103, 'Bengaluru', '2026-11-20', '2026-11-24', 52000.00, 2),
(104, 'London', '2026-12-01', '2026-12-08', 185000.00, 2),
(105, 'Dubai', '2026-12-10', '2026-12-15', 120000.00, 3),
(106, 'Mumbai', '2026-12-20', '2026-12-23', 32000.00, 4),
(107, 'Goa', '2026-12-25', '2026-12-29', 28000.00, 1); -- Trip with no confirmed bookings

INSERT INTO Customer (customer_id, name, email, phone, city) VALUES
(1, 'Amit Sharma', 'amit.s@gmail.com', '9911111111', 'Pune'),
(2, 'Pooja Kulkarni', 'pooja.k@gmail.com', '9922222222', 'Nagpur'),
(3, 'Rajesh Gupta', 'rajesh.g@yahoo.com', '9933333333', 'Indore'),
(4, 'Sneha Patil', 'sneha.p@gmail.com', '9944444444', 'Pune'),
(5, 'Karan Johar', 'karan.j@gmail.com', '9955555555', 'Ahmedabad');

INSERT INTO Booking (booking_id, customer_id, trip_id, booking_date, booking_status) VALUES
-- Amit: booked all trips of Salesperson 1 (101, 102, 107), plus 103, 104 (> 3 trips booked, has Confirmed + Cancelled)
(1, 1, 101, '2026-10-01', 'Confirmed'),
(2, 1, 102, '2026-10-02', 'Confirmed'),
(3, 1, 107, '2026-10-03', 'Pending'),
(4, 1, 103, '2026-10-04', 'Confirmed'),
(5, 1, 104, '2026-10-05', 'Cancelled'),
-- Pooja: never booked Mumbai, never cancelled any booking
(6, 2, 103, '2026-10-06', 'Confirmed'),
(7, 2, 104, '2026-10-07', 'Confirmed'),
-- Rajesh: has Confirmed and Cancelled bookings, booked Mumbai
(8, 3, 101, '2026-10-08', 'Confirmed'),
(9, 3, 102, '2026-10-09', 'Cancelled'),
-- Sneha: booked Dubai (> 1,00,000 cost), never cancelled
(10, 4, 105, '2026-10-10', 'Confirmed'),
-- Karan: Pending booking for Mumbai (106)
(11, 5, 106, '2026-10-11', 'Pending');


-- =============================================================================
-- 3. QUERIES
-- =============================================================================

-- 1. Display customer name, booking ID, and booking status for all bookings
SELECT 
    c.name AS customer_name,
    b.booking_id,
    b.booking_status
FROM Customer c
JOIN Booking b ON c.customer_id = b.customer_id;

-- 2. Display destination and salesperson name for every trip
SELECT 
    t.destination,
    s.name AS salesperson_name
FROM Trip t
JOIN Salesperson s ON t.salesperson_id = s.salesperson_id;

-- 3. Display customer name and destination for every confirmed booking
SELECT 
    c.name AS customer_name,
    t.destination
FROM Customer c
JOIN Booking b ON c.customer_id = b.customer_id
JOIN Trip t ON b.trip_id = t.trip_id
WHERE b.booking_status = 'Confirmed';

-- 4. Display the number of trips arranged by each salesperson
SELECT 
    s.salesperson_id,
    s.name AS salesperson_name,
    COUNT(t.trip_id) AS trips_arranged
FROM Salesperson s
LEFT JOIN Trip t ON s.salesperson_id = t.salesperson_id
GROUP BY s.salesperson_id, s.name;

-- 5. Display the number of customers who have booked each trip
SELECT 
    t.trip_id,
    t.destination,
    COUNT(b.booking_id) AS total_customers_booked
FROM Trip t
LEFT JOIN Booking b ON t.trip_id = b.trip_id
GROUP BY t.trip_id, t.destination;

-- 6. Display names of customers who have not booked any trip to Mumbai
SELECT name 
FROM Customer
WHERE customer_id NOT IN (
    SELECT b.customer_id
    FROM Booking b
    JOIN Trip t ON b.trip_id = t.trip_id
    WHERE t.destination = 'Mumbai'
);

-- 7. Display names of customers who have both a confirmed booking and a cancelled booking
SELECT c.name
FROM Customer c
WHERE EXISTS (
    SELECT 1 FROM Booking b WHERE b.customer_id = c.customer_id AND b.booking_status = 'Confirmed'
)
AND EXISTS (
    SELECT 1 FROM Booking b WHERE b.customer_id = c.customer_id AND b.booking_status = 'Cancelled'
);

-- 8. Display names of customers who have booked every trip arranged by a particular salesperson (e.g., Salesperson ID = 1)
SELECT c.name
FROM Customer c
JOIN Booking b ON c.customer_id = b.customer_id
JOIN Trip t ON b.trip_id = t.trip_id
WHERE t.salesperson_id = 1
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT t.trip_id) = (
    SELECT COUNT(*) 
    FROM Trip 
    WHERE salesperson_id = 1
);

-- 9. Display destinations of trips for which no customer has a confirmed booking
SELECT DISTINCT t.destination
FROM Trip t
WHERE NOT EXISTS (
    SELECT 1 
    FROM Booking b 
    WHERE b.trip_id = t.trip_id 
      AND b.booking_status = 'Confirmed'
);

-- 10. Display names of customers who have at least one booking for every destination they have previously booked with status 'Confirmed'
-- (Applies tautologically to all customers who have made confirmed bookings, as their confirmed bookings themselves satisfy the requirement)
SELECT c.name
FROM Customer c
WHERE EXISTS (
    SELECT 1 
    FROM Booking b 
    WHERE b.customer_id = c.customer_id 
      AND b.booking_status = 'Confirmed'
);

-- 11. Find the salesperson(s) who have arranged the maximum number of trips
SELECT 
    s.salesperson_id,
    s.name AS salesperson_name,
    COUNT(t.trip_id) AS trip_count
FROM Salesperson s
JOIN Trip t ON s.salesperson_id = t.salesperson_id
GROUP BY s.salesperson_id, s.name
HAVING COUNT(t.trip_id) = (
    SELECT COUNT(trip_id)
    FROM Trip
    GROUP BY salesperson_id
    ORDER BY COUNT(trip_id) DESC
    LIMIT 1
);

-- 12. Find customers who have booked more than three trips
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(b.booking_id) AS trips_booked
FROM Customer c
JOIN Booking b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(b.booking_id) > 3;

-- 13. Find trips whose cost is greater than the average cost of all trips
SELECT 
    trip_id,
    destination,
    cost
FROM Trip
WHERE cost > (SELECT AVG(cost) FROM Trip);

-- 14. Find salespersons who have arranged trips costing more than ₹1,00,000
SELECT DISTINCT 
    s.salesperson_id,
    s.name AS salesperson_name
FROM Salesperson s
JOIN Trip t ON s.salesperson_id = t.salesperson_id
WHERE t.cost > 100000.00;

-- 15. Find customers who have never cancelled any booking
SELECT 
    c.customer_id,
    c.name AS customer_name
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Booking b 
    WHERE b.customer_id = c.customer_id 
      AND b.booking_status = 'Cancelled'
);