-- Database: Airline Reservation System
-- Use Case: An airline needs to process rows one at a time in scenarios where set-based SQL isn't sufficient 
-- — e.g., iterating through waitlisted passengers to confirm seats as cancellations free them up, or applying
-- tiered frequent-flyer bonuses sequentially. Cursors allow controlled, row-by-row processing.

DROP DATABASE IF EXISTS AirlineSystemDB;
CREATE DATABASE AirlineSystemDB;
USE AirlineSystemDB;

-- Drop dependent tables first
DROP TABLE IF EXISTS Cancellation;
DROP TABLE IF EXISTS Waitlist;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Passenger;

-- 1. Passenger Table
CREATE TABLE Passenger (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    frequent_flyer_tier VARCHAR(20) NOT NULL,
    miles INT NOT NULL DEFAULT 0 CHECK (miles >= 0),
    CONSTRAINT chk_tier CHECK (frequent_flyer_tier IN ('Bronze', 'Silver', 'Gold', 'Platinum'))
);

-- 2. Flight Table
CREATE TABLE Flight (
    flight_id INT PRIMARY KEY,
    origin VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    flight_date DATE NOT NULL,
    total_seats INT NOT NULL CHECK (total_seats > 0)
);

-- 3. Booking Table
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_number VARCHAR(10),
    status VARCHAR(20) NOT NULL,
    booking_date DATE NOT NULL,
    CONSTRAINT chk_booking_status CHECK (status IN ('Confirmed', 'Cancelled', 'Pending')),
    CONSTRAINT fk_bk_passenger FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id) ON DELETE CASCADE,
    CONSTRAINT fk_bk_flight FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- 4. Waitlist Table
CREATE TABLE Waitlist (
    waitlist_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    request_date DATE NOT NULL,
    priority INT NOT NULL CHECK (priority > 0),
    CONSTRAINT fk_wl_passenger FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id) ON DELETE CASCADE,
    CONSTRAINT fk_wl_flight FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    CONSTRAINT uq_waitlist UNIQUE (passenger_id, flight_id)
);

-- 5. Cancellation Table (1 to 0..1 with Booking)
CREATE TABLE Cancellation (
    cancellation_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL UNIQUE,
    cancel_date DATE NOT NULL,
    refund_amount DECIMAL(10, 2) NOT NULL CHECK (refund_amount >= 0),
    CONSTRAINT fk_cn_booking FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE
);

-- -------------------------------------------------------------
-- Sample Data Insertion
-- -------------------------------------------------------------
INSERT INTO Passenger (passenger_id, name, frequent_flyer_tier, miles) VALUES
(1, 'Aarav Sharma', 'Platinum', 85000),
(2, 'Neha Verma', 'Gold', 62000),
(3, 'Rohan Mehta', 'Silver', 35000),
(4, 'Pooja Nair', 'Bronze', 12000),
(5, 'Vikram Malhotra', 'Platinum', 95000),
(6, 'Simran Kaur', 'Bronze', 8000),
(7, 'Aditya Rao', 'Silver', 45000);

-- Flights (Note: Flights 101 and 102 depart from Mumbai)
INSERT INTO Flight (flight_id, origin, destination, flight_date, total_seats) VALUES
(101, 'Mumbai', 'Delhi', '2026-04-15', 180),
(102, 'Mumbai', 'Bangalore', '2026-05-10', 150),
(103, 'Delhi', 'Goa', '2025-12-20', 160),
(104, 'Chennai', 'Kolkata', '2026-06-01', 140),
(105, 'Pune', 'Dubai', '2026-08-15', 200);

-- Bookings
INSERT INTO Booking (booking_id, passenger_id, flight_id, seat_number, status, booking_date) VALUES
(1, 1, 101, '12A', 'Confirmed', '2026-03-01'),
(2, 1, 102, '14B', 'Confirmed', '2026-03-05'),
(3, 2, 101, '15C', 'Confirmed', '2026-03-02'),
(4, 3, 101, NULL, 'Cancelled', '2026-03-10'),
(5, 3, 104, '05D', 'Confirmed', '2026-03-15'),
(6, 4, 102, '21A', 'Confirmed', '2026-03-20'),
(7, 5, 103, '01A', 'Confirmed', '2025-11-01');
-- Passenger 6 has no bookings
-- Passenger 7 has no bookings

-- Waitlist
INSERT INTO Waitlist (waitlist_id, passenger_id, flight_id, request_date, priority) VALUES
(1, 4, 101, '2026-03-12', 1),   -- Pooja Nair on 101 (has 12000 miles)
(2, 6, 101, '2026-03-15', 2),   -- Simran Kaur on 101 (has 8000 miles)
(3, 3, 102, '2026-03-18', 1),   -- Rohan Mehta on 102 (no booking on 102)
(4, 1, 101, '2026-02-15', 3),   -- Aarav was waitlisted earlier on 101, now has confirmed booking
(5, 7, 105, '2026-04-01', 1);   -- Flight 105 has waitlisted passenger but no confirmed booking

-- Cancellations
INSERT INTO Cancellation (cancellation_id, booking_id, cancel_date, refund_amount) VALUES
(1, 4, '2026-03-12', 4500.00);

-- QUERIES: --

-- 1. Display the name and frequent-flyer tier of all passengers: 
SELECT name, frequent_flyer_tier 
FROM Passenger;

-- 2.Display the flight ID, origin, destination, and flight date for all flights departing from Mumbai:
SELECT flight_id, origin, destination, flight_date 
FROM Flight 
WHERE origin = 'Mumbai';

-- 3. Display the booking ID, passenger ID, flight ID, seat number, and status for all confirmed bookings:
SELECT booking_id, passenger_id, flight_id, seat_number, status 
FROM Booking 
WHERE status = 'Confirmed';

-- 4.Display the names of passengers who are currently on a waitlist:
SELECT DISTINCT p.name 
FROM Passenger p
JOIN Waitlist w ON p.passenger_id = w.passenger_id;

-- 5. Display the flight ID and destination of flights scheduled after 1 January 2026:
SELECT flight_id, destination 
FROM Flight
WHERE flight_date > '2026-01-01';

-- 6. Display the names and miles of passengers who have more than 50,000 miles:
SELECT name, miles 
FROM Passenger
WHERE miles > 50000;

-- 7. Display the booking ID and cancellation date for all cancelled bookings:
SELECT booking_id, cancel_date 
FROM Cancellation;

-- 8. Display the passenger name, booking ID, and seat number for passengers who have confirmed bookings:
SELECT p.name, b.booking_id, b.seat_number
FROM Passenger p
JOIN Booking b ON p.passenger_id = b.passenger_id
WHERE b.status = 'Confirmed';

-- 9. Display the flight ID and the number of bookings made for each flight:
SELECT flight_id, COUNT(*) AS booking_count
FROM Booking
GROUP BY flight_id;

-- 10. Display the names of passengers along with their waitlist priority for a particular flight (e.g., Flight 101):
SELECT p.name, w.priority
FROM Passenger p
JOIN Waitlist w ON p.passenger_id = w.passenger_id
WHERE w.flight_id = 101
ORDER BY w.priority;

-- 11. Display the names of passengers who have booked at least one flight originating from Mumbai:
SELECT DISTINCT p.name
FROM Passenger p
JOIN Booking b ON p.passenger_id = b.passenger_id
JOIN Flight f ON b.flight_id = f.flight_id
WHERE f.origin = 'Mumbai';

-- 12. Display the names of passengers who have never made a booking:
SELECT name
FROM Passenger
WHERE passenger_id NOT IN (SELECT passenger_id FROM Booking);

-- 13. Display the names of passengers who are on the waitlist for at least one flight but do not have a booking for that flight:
SELECT DISTINCT p.name
FROM Passenger p
JOIN Waitlist w ON p.passenger_id = w.passenger_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Booking b
    WHERE b.passenger_id = p.passenger_id AND b.flight_id = w.flight_id
);

-- 14. Display the flight IDs for which at least one passenger is waitlisted but no confirmed booking exists for that flight:
SELECT DISTINCT w.flight_id
FROM Waitlist w
WHERE NOT EXISTS (
    SELECT 1
    FROM Booking b
    WHERE b.flight_id = w.flight_id AND b.status = 'Confirmed'
);

-- 15. Display the names of passengers who have made bookings for all flights originating from Mumbai (Relational Division):
SELECT p.name
FROM Passenger p
WHERE NOT EXISTS (
    SELECT f.flight_id
    FROM Flight f
    WHERE f.origin = 'Mumbai' AND NOT EXISTS (
        SELECT 1
        FROM Booking b
        WHERE b.passenger_id = p.passenger_id AND b.flight_id = f.flight_id
    )
);

-- 16. Display the names of passengers who have never been waitlisted for any flight:
SELECT name
FROM Passenger
WHERE passenger_id NOT IN (SELECT passenger_id FROM Waitlist);

-- 17. Display the names of passengers who have a confirmed booking as well as a cancellation record for another booking:
SELECT DISTINCT p.name
FROM Passenger p
JOIN Booking b_conf ON p.passenger_id = b_conf.passenger_id AND b_conf.status = 'Confirmed'
JOIN Booking b_canc ON p.passenger_id = b_canc.passenger_id AND b_canc.booking_id != b_conf.booking_id
JOIN Cancellation c ON b_canc.booking_id = c.booking_id;

-- 18. Display the flight IDs for which every waitlisted passenger has at least one booking on some flight:
SELECT DISTINCT w.flight_id
FROM Waitlist w
WHERE NOT EXISTS (
    SELECT 1
    FROM Waitlist w2
    WHERE w2.flight_id = w.flight_id AND NOT EXISTS (
        SELECT 1
        FROM Booking b
        WHERE b.passenger_id = w2.passenger_id
    )
);

-- 19. Display the names of passengers who have more miles than every passenger who is currently on the waitlist for flight 101
SELECT name
FROM Passenger
WHERE miles > ALL (
    SELECT p2.miles
    FROM Passenger p2
    JOIN Waitlist w ON p2.passenger_id = w.passenger_id
    WHERE w.flight_id = 101
);

-- 20. Display the names of passengers who have at least one confirmed booking on every flight for which they have previously been waitlisted:
SELECT p.name
FROM Passenger p
WHERE EXISTS (
    SELECT 1 
    FROM Waitlist w 
    WHERE w.passenger_id = p.passenger_id
)
AND NOT EXISTS (
    SELECT 1 
    FROM Waitlist w
    WHERE w.passenger_id = p.passenger_id
      AND NOT EXISTS (
          SELECT 1 
          FROM Booking b 
          WHERE b.passenger_id = p.passenger_id 
            AND b.flight_id = w.flight_id 
            AND b.status = 'Confirmed'
      )
);
