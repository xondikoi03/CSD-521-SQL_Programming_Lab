-- Movie Production and Streaming Platform Database Design: --

-- A leading Movie Production and Streaming Platform produces, acquires, and streams movies across multiple genres to subscribers worldwide.
-- The platform maintains information about movies, actors, directors, users, subscriptions, ratings, and viewing history to provide personalized recommendations and analyze audience preferences.
-- Each movie is directed by one or more directors and features multiple actors, while an actor can appear in many movies. Registered users can watch any available movie, rate it, and review their viewing history. 
-- The platform uses this information to identify popular movies, evaluate director and actor performance, analyze user engagement, and generate personalized recommendations.
-- The management wants to develop a  database system that efficiently stores production and streaming data and supports complex analytical queries involving multiple relationships, user behavior, movie popularity, and viewing trends.
-- For the above problem statement, Consider the following entities and their Relationships. Create a RDB in 3 NF for the following. Insert appropriate records in each tables. 

-- =============================================================================
-- 1. DATABASE CREATION AND NORMALIZED SCHEMA (3NF)
-- =============================================================================
DROP DATABASE IF EXISTS StreamingPlatformDB;
CREATE DATABASE StreamingPlatformDB;
USE StreamingPlatformDB;

-- Drop dependent tables first
DROP TABLE IF EXISTS WatchHistory;
DROP TABLE IF EXISTS Rating;
DROP TABLE IF EXISTS MovieDirector;
DROP TABLE IF EXISTS MovieActor;
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Director;
DROP TABLE IF EXISTS Actor;
DROP TABLE IF EXISTS Movie;

-- Movie Table
CREATE TABLE Movie (
    MovieId INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(150) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    Language VARCHAR(50) NOT NULL,
    ReleaseYear INT NOT NULL,
    Duration INT NOT NULL,
    ProductionHouse VARCHAR(100) NOT NULL,
    CONSTRAINT chk_movie_genre CHECK (Genre IN ('Action', 'Comedy', 'Thriller', 'Drama', 'Sci-Fi')), -- only 5 genres are allowed
    CONSTRAINT chk_movie_duration CHECK (Duration >= 120)
);

-- Actor Table
CREATE TABLE Actor (
    Actorid INT PRIMARY KEY AUTO_INCREMENT,
    ActorName VARCHAR(100) NOT NULL,
    Gender CHAR(1) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Nationality VARCHAR(50) NOT NULL,
    CONSTRAINT chk_actor_gender CHECK (Gender IN ('M', 'F'))
);

-- Director Table
CREATE TABLE Director (
    Directorid INT PRIMARY KEY AUTO_INCREMENT,
    DirectorName VARCHAR(100) NOT NULL,
    Nationality VARCHAR(50) NOT NULL,
    ExperienceYears INT NOT NULL CHECK (ExperienceYears >= 0)
);

-- User Table
CREATE TABLE User (
    Userid INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Country VARCHAR(50) NOT NULL,
    SubscriptionType VARCHAR(20) NOT NULL,
    JoinDate DATE NOT NULL,
    CONSTRAINT chk_user_subscription CHECK (SubscriptionType IN ('monthly', 'yearly')) -- SubscriptionType can only be 'monthly' or 'yearly'
);

-- MovieActor Junction Table (M:N)
CREATE TABLE MovieActor (
    Movieid INT NOT NULL,
    Actorid INT NOT NULL,
    CharacterName VARCHAR(100) NOT NULL,
    PRIMARY KEY (Movieid, Actorid),
    -- Foreign Key Constraints: 
    CONSTRAINT fk_ma_movie FOREIGN KEY (Movieid) REFERENCES Movie(MovieId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ma_actor FOREIGN KEY (Actorid) REFERENCES Actor(Actorid) ON DELETE CASCADE ON UPDATE CASCADE
);

-- MovieDirector Junction Table (M:N)
CREATE TABLE MovieDirector (
    Movieid INT NOT NULL,
    Directorid INT NOT NULL,
    PRIMARY KEY (Movieid, Directorid),
    CONSTRAINT fk_md_movie FOREIGN KEY (Movieid) REFERENCES Movie(MovieId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_md_director FOREIGN KEY (Directorid) REFERENCES Director(Directorid) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Rating Table
CREATE TABLE Rating (
    Ratingid INT PRIMARY KEY AUTO_INCREMENT,
    Userid INT NOT NULL,
    Movieid INT NOT NULL,
    RatingValue DECIMAL(3, 1) NOT NULL,
    RatingDate DATE NOT NULL,
    -- Rating value must be between 0 and 5, inclusive:
    CONSTRAINT chk_rating_value CHECK (RatingValue BETWEEN 0 AND 5), 
    CONSTRAINT fk_rating_user FOREIGN KEY (Userid) REFERENCES User(Userid) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rating_movie FOREIGN KEY (Movieid) REFERENCES Movie(MovieId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- WatchHistory Table
CREATE TABLE WatchHistory (
    Watchid INT PRIMARY KEY AUTO_INCREMENT,
    Userid INT NOT NULL,
    Movieid INT NOT NULL,
    WatchDate DATE NOT NULL,
    WatchDuration INT NOT NULL CHECK (WatchDuration >= 0),
    DeviceType VARCHAR(20) NOT NULL,
    -- DeviceType can only be 'Mobile' or 'laptop':
    CONSTRAINT chk_device_type CHECK (DeviceType IN ('Mobile', 'laptop')),
    CONSTRAINT fk_wh_user FOREIGN KEY (Userid) REFERENCES User(Userid) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_wh_movie FOREIGN KEY (Movieid) REFERENCES Movie(MovieId) ON DELETE CASCADE ON UPDATE CASCADE
);


-- =============================================================================
-- 2. INSERT SAMPLE RECORDS
-- =============================================================================

-- Movies (Genres: Action, Comedy, Thriller, Drama, Sci-Fi; Duration >= 120)
INSERT INTO Movie (MovieId, Title, Genre, Language, ReleaseYear, Duration, ProductionHouse) VALUES
(1, 'Avengers: Endgame', 'Action', 'English', 2019, 181, 'Marvel Studios'),
(2, 'Andhadhun', 'Thriller', 'Hindi', 2018, 139, 'Viacom18 Studios'),
(3, '3 Idiots', 'Comedy', 'Hindi', 2009, 170, 'Vinod Chopra Films'),
(4, 'Interstellar', 'Sci-Fi', 'English', 2014, 169, 'Syncopy'),
(5, 'Dangal', 'Drama', 'Hindi', 2016, 161, 'Aamir Khan Productions'),
(6, 'Action Jackson', 'Action', 'Hindi', 2014, 144, 'Baba Films'),
(7, 'Avatar', 'Sci-Fi', 'English', 2009, 162, '20th Century Fox'),
(8, 'Article 15', 'Drama', 'Hindi', 2019, 130, 'Benaras Media Works'),
(9, 'Anbe Sivam', 'Drama', 'Tamil', 2003, 160, 'Lakshmi Movie Makers'),
(10, 'A Wednesday', 'Thriller', 'Hindi', 2008, 124, 'UTV Motion Pictures'),
(11, 'Asuran', 'Action', 'Tamil', 2019, 141, 'V Creations'),
(12, 'Drishyam', 'Thriller', 'Malayalam', 2013, 160, 'Aashirvad Cinemas'),
(13, 'Gangs of Wasseypur', 'Action', 'Hindi', 2012, 160, 'AKFPL'),
(14, 'Swades', 'Drama', 'Hindi', 2004, 210, 'Ashutosh Gowariker Prod'),
(15, 'Inception', 'Sci-Fi', 'English', 2010, 148, 'Syncopy'),
(16, 'The Dark Knight', 'Action', 'English', 2008, 152, 'Warner Bros.'),
(17, 'The Dark Knight Rises', 'Action', 'English', 2012, 164, 'Warner Bros.'),
(18, 'The Matrix', 'Sci-Fi', 'English', 1999, 136, 'Warner Bros.'),
(19, 'The Shawshank Redemption', 'Drama', 'English', 1994, 142, 'Castle Rock Entertainment'),
(20, 'The Godfather', 'Drama', 'English', 1972, 175, 'Paramount Pictures'),
(21, 'The Godfather: Part II', 'Drama', 'English', 1974, 202, 'Paramount Pictures'),
(22, 'The Godfather: Part III', 'Drama', 'English', 1990, 162, 'Paramount Pictures'),
(23, 'The Lord of the Rings: The Fellowship of the Ring', 'Action', 'English', 2001, 178, 'New Line Cinema'),
(24, 'The Lord of the Rings: The Two Towers', 'Action', 'English', 2002, 179, 'New Line Cinema'),
(25, 'The Lord of the Rings: The Return of the King', 'Action', 'English', 2003, 201, 'New Line Cinema');


-- Actors (Gender: M or F)
INSERT INTO Actor (Actorid, ActorName, Gender, DateOfBirth, Nationality) VALUES
(1, 'Robert Downey Jr.', 'M', '1965-04-04', 'American'),
(2, 'Ayushmann Khurrana', 'M', '1984-09-14', 'Indian'),
(3, 'Aamir Khan', 'M', '1965-03-14', 'Indian'),
(4, 'Akshay Kumar', 'M', '1967-09-09', 'Indian'),
(5, 'Dilip Kumar', 'M', '1922-12-11', 'Indian'),
(6, 'Matthew McConaughey', 'M', '1969-11-04', 'American'),
(7, 'Kamal Haasan', 'M', '1954-11-07', 'Indian'),
(8, 'Tabu', 'F', '1971-11-04', 'Indian'),
(9, 'Kareena Kapoor', 'F', '1980-09-21', 'Indian'),
(10, 'Anne Hathaway', 'F', '1982-11-12', 'American'),
(11, 'Leonardo DiCaprio', 'M', '1974-11-11', 'American'),
(12, 'Christian Bale', 'M', '1974-01-30', 'British'),
(13, 'Keanu Reeves', 'M', '1964-09-02', 'Canadian'),
(14, 'Morgan Freeman', 'M', '1937-06-01', 'American'),
(15, 'Marlon Brando', 'M', '1924-04-03', 'American'),
(16, 'Al Pacino', 'M', '1940-04-25', 'American'),
(17, 'Elijah Wood', 'M', '1981-01-28', 'American'),
(18, 'Ian McKellen', 'M', '1939-05-25', 'British');

-- Directors
INSERT INTO Director (Directorid, DirectorName, Nationality, ExperienceYears) VALUES
(1, 'Christopher Nolan', 'British', 26),
(2, 'Sriram Raghavan', 'Indian', 20),
(3, 'Rajkumar Hirani', 'Indian', 22),
(4, 'Nitesh Tiwari', 'Indian', 15),
(5, 'Anthony Russo', 'American', 24),
(6, 'Anurag Kashyap', 'Indian', 25),
(7, 'Ashutosh Gowariker', 'Indian', 30),
(8, 'Steven Spielberg', 'American', 45),
(9, 'Martin Scorsese', 'American', 50),
(10, 'Quentin Tarantino', 'American', 35);


-- Users (SubscriptionType: monthly or yearly)
INSERT INTO User (Userid, UserName, Email, Country, SubscriptionType, JoinDate) VALUES
(1, 'Rohan Verma', 'rohan.verma@gmail.com', 'India', 'yearly', '2023-01-15'),
(2, 'Priya Nair', 'priya.nair@yahoo.com', 'India', 'monthly', '2023-03-20'),
(3, 'John Miller', 'john.m@gmail.com', 'USA', 'yearly', '2023-04-10'),
(4, 'Emma Watson', 'emma.w@outlook.com', 'UK', 'monthly', '2023-05-12'),
(5, 'Suresh Patel', 'suresh.patel@gmail.com', 'India', 'yearly', '2023-06-01'),
(6, 'Liam Neeson', 'liam.n@gmail.com', 'Canada', 'monthly', '2023-07-22'),
(7, 'Sophia Lee', 'sophia.lee@gmail.com', 'USA', 'monthly', '2023-08-15');

-- MovieActor Links
INSERT INTO MovieActor (Movieid, Actorid, CharacterName) VALUES
(1, 1, 'Tony Stark / Iron Man'),
(2, 2, 'Akash'),
(2, 8, 'Simi'),
(3, 3, 'Rancho'),
(3, 9, 'Pia'),
(4, 6, 'Cooper'),
(4, 10, 'Brand'),
(5, 3, 'Mahavir Singh Phogat'),
(8, 2, 'Ayan Ranjan'),
(9, 7, 'Nallasivam'),
(10, 8, 'Suresh'),
(11, 9, 'Raj'),
(12, 10, 'Amit'),
(13, 11, 'Rohan'),
(14, 12, 'Vikram'),
(15, 1, 'Extractor');

-- MovieDirector Links
-- Notice: Anurag Kashyap directs both Gangs of Wasseypur (Action) and a Drama film to satisfy query 16
INSERT INTO MovieDirector (Movieid, Directorid) VALUES
(1, 5),   -- Avengers -> Anthony Russo
(2, 2),   -- Andhadhun -> Sriram Raghavan
(3, 3),   -- 3 Idiots -> Rajkumar Hirani
(4, 1),   -- Interstellar -> Christopher Nolan
(5, 4),   -- Dangal -> Nitesh Tiwari
(8, 6),   -- Article 15 -> Anurag Kashyap (Drama)
(13, 6),  -- Gangs of Wasseypur -> Anurag Kashyap (Action)
(15, 1),  -- Inception -> Christopher Nolan
(16, 7),  -- Swades -> Ashutosh Gowariker
(17, 1),  -- The Dark Knight Rises -> Christopher Nolan
(18, 1),  -- The Matrix -> Christopher Nolan
(19, 8),  -- The Shawshank Redemption -> Steven Spielberg
(20, 9),  -- The Godfather -> Martin Scorsese
(21, 9),  -- The Godfather: Part II -> Martin Scorsese
(22, 9),  -- The Godfather: Part III -> Martin Scorsese
(23, 10), -- The Lord of the Rings: The Fellowship of the Ring -> Quentin Tarantino
(24, 10), -- The Lord of the Rings: The Two Towers -> Quentin Tarantino
(25, 10); -- The Lord of the Rings: The Return of the King -> Quentin Tarantino
-- Ratings (0 to 5)
INSERT INTO Rating (Ratingid, Userid, Movieid, RatingValue, RatingDate) VALUES
(1, 1, 1, 4.8, '2024-01-10'),
(2, 2, 2, 4.5, '2024-01-15'),
(3, 3, 3, 5.0, '2024-02-01'),
(4, 4, 4, 4.7, '2024-02-14'),
(5, 1, 5, 4.9, '2024-03-01'),
(6, 5, 1, 4.2, '2024-03-05'),
(7, 2, 3, 3.8, '2024-03-10'),
(8, 6, 6, 2.5, '2024-03-12'),
(9, 7, 4, 4.0, '2024-03-15'),
(10, 3, 5, 4.6, '2024-03-20'),
(11, 1, 2, 3.9, '2024-03-25'),
(12, 2, 1, 4.1, '2024-03-30'),
(13, 4, 3, 4.3, '2024-04-05'),
(14, 5, 2, 3.5, '2024-04-10'),
(15, 6, 5, 4.8, '2024-04-15'),
(16, 7, 6, 2.9, '2024-04-20');

-- WatchHistory (DeviceType: Mobile or laptop)
-- Notice: Movies 7, 9, 10, 11, 12, 14 are left unwatched to satisfy query 14
INSERT INTO WatchHistory (Watchid, Userid, Movieid, WatchDate, WatchDuration, DeviceType) VALUES
(1, 1, 1, '2024-01-09', 181, 'laptop'),
(2, 1, 2, '2024-01-12', 139, 'Mobile'),
(3, 2, 2, '2024-01-14', 120, 'Mobile'),
(4, 3, 3, '2024-01-28', 170, 'laptop'),
(5, 4, 4, '2024-02-12', 169, 'laptop'),
(6, 5, 1, '2024-03-02', 180, 'Mobile'),
(7, 1, 5, '2024-03-04', 161, 'laptop'),
(8, 2, 3, '2024-03-08', 90,  'Mobile'),
(9, 3, 5, '2024-03-18', 161, 'laptop'),
(10, 4, 4, '2024-03-22', 169, 'Mobile'),
(11, 5, 2, '2024-04-08', 139, 'laptop'),
(12, 6, 6, '2024-04-18', 144, 'Mobile'),
(13, 7, 1, '2024-04-22', 181, 'laptop');


-- =============================================================================
-- 3. ANALYTICAL QUERIES
-- =============================================================================

-- 1. Display distinct user countries
SELECT DISTINCT Country 
FROM User;

-- 2. Find movies whose title starts with 'A'
SELECT * 
FROM Movie 
WHERE Title LIKE 'A%';

-- 3. Find actors whose names end with 'Kumar'
SELECT * 
FROM Actor 
WHERE ActorName LIKE '%Kumar';

-- 4. Find users whose email contains 'gmail'
SELECT * 
FROM User 
WHERE Email LIKE '%gmail%';

-- 5. Display ratings between 4 and 5
SELECT * 
FROM Rating 
WHERE RatingValue BETWEEN 4.0 AND 5.0;

-- 6. Display movies whose genre is either Action, Comedy, or Thriller
SELECT * 
FROM Movie 
WHERE Genre IN ('Action', 'Comedy', 'Thriller');

-- 7. Display movie names whose language is not Hindi
SELECT Title, Language 
FROM Movie 
WHERE Language != 'Hindi';

-- 8. Count total movies
SELECT COUNT(*) AS TotalMovies 
FROM Movie;

-- 9. Find the average rating of all movies
SELECT ROUND(AVG(RatingValue), 2) AS OverallAverageRating 
FROM Rating;

-- 10. Count movies in each genre
SELECT Genre, COUNT(*) AS MovieCount 
FROM Movie 
GROUP BY Genre;

-- 11. Display genres having more than five movies
SELECT Genre, COUNT(*) AS MovieCount 
FROM Movie 
GROUP BY Genre 
HAVING COUNT(*) > 5;

-- 12. Display movie title, director, actors and average rating
SELECT 
    m.Title,
    GROUP_CONCAT(DISTINCT d.DirectorName SEPARATOR ', ') AS Directors,
    GROUP_CONCAT(DISTINCT a.ActorName SEPARATOR ', ') AS Actors,
    ROUND(AVG(r.RatingValue), 2) AS AverageRating
FROM Movie m
LEFT JOIN MovieDirector md ON m.MovieId = md.Movieid
LEFT JOIN Director d ON md.Directorid = d.Directorid
LEFT JOIN MovieActor ma ON m.MovieId = ma.Movieid
LEFT JOIN Actor a ON ma.Actorid = a.Actorid
LEFT JOIN Rating r ON m.MovieId = r.Movieid
GROUP BY m.MovieId, m.Title;

-- 13. List users with total movies watched
SELECT 
    u.Userid,
    u.UserName,
    COUNT(w.Watchid) AS TotalMoviesWatched
FROM User u
LEFT JOIN WatchHistory w ON u.Userid = w.Userid
GROUP BY u.Userid, u.UserName;

-- 14. Find movies never watched
SELECT m.MovieId, m.Title, m.Genre 
FROM Movie m
LEFT JOIN WatchHistory w ON m.MovieId = w.Movieid
WHERE w.Watchid IS NULL;

-- 15. Display genre-wise average ratings
SELECT 
    m.Genre,
    ROUND(AVG(r.RatingValue), 2) AS GenreAverageRating
FROM Movie m
JOIN Rating r ON m.MovieId = r.Movieid
GROUP BY m.Genre;

-- 16. Directors who have worked in both Action and Drama genres
SELECT 
    d.Directorid,
    d.DirectorName
FROM Director d
JOIN MovieDirector md ON d.Directorid = md.Directorid
JOIN Movie m ON md.Movieid = m.MovieId
WHERE m.Genre IN ('Action', 'Drama')
GROUP BY d.Directorid, d.DirectorName
HAVING COUNT(DISTINCT m.Genre) = 2;