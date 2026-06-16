-- Active: 1781541426767@@127.0.0.1@5432@football_booking_system
-- Active: 1781541426767@@127.0.0.1@5432@football_booking_system


CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    match_id INTEGER REFERENCES matches(match_id),
    seat_number VARCHAR(10),
    payment_status VARCHAR(20),
    total_cost DECIMAL(10,2) NOT NULL
);

CREATE TABLE matches (
    match_id             SERIAL PRIMARY KEY,
    fixture              VARCHAR(150) NOT NULL,
    tournament_category  VARCHAR(100) NOT NULL,
    base_ticket_price    NUMERIC(10, 2) NOT NULL,
    match_status         VARCHAR(50) NOT NULL CHECK (match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed'))
);

CREATE TABLE bookings (
    booking_id     SERIAL PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES users(user_id),
    match_id       INT NOT NULL REFERENCES matches(match_id),
    seat_number    VARCHAR(20),
    payment_status VARCHAR(20) CHECK (payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')),
    total_cost     NUMERIC(10, 2) NOT NULL
);

INSERT INTO users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan',   '+8801711111111'),
(2, 'Asif Haque',    'asif@mail.com',   'Football Fan',   '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara',    'jannat@mail.com', 'Football Fan',   NULL);
 
INSERT INTO matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150, 'Available'),
(102, 'Man City vs Liverpool',    'Premier League',   120, 'Selling Fast'),
(103, 'Bayern Munich vs PSG',     'Champions League', 130, 'Available'),
(104, 'AC Milan vs Inter Milan',  'Serie A',           90, 'Sold Out'),
(105, 'Juventus vs Roma',         'Serie A',           80, 'Available');
 
INSERT INTO bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150),
(502, 1, 102, 'B-04', 'Confirmed', 120),
(503, 2, 101, 'A-13', 'Confirmed', 150),
(504, 2, 101, NULL,   NULL,        150),
(505, 3, 102, 'C-20', 'Pending',   120);
 

--  - QUERY 1
-- Retrieve all upcoming football matches belonging to the
-- 'Champions League' where the match status is 'Available'.
-- Ans:

SELECT
    match_id,
    fixture,
    base_ticket_price
FROM matches
WHERE tournament_category = 'Champions League'
  AND match_status = 'Available';



-- QUERY 2
-- Search for all users whose full names start with 'Tanvir'
-- or contain the phrase 'Haque' (case-insensitive).
-- Concepts: ILIKE
-- Ans:
SELECT
    user_id,
    full_name,
    email
FROM users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';


-- QUERY 3
-- Retrieve all booking records where the payment status is
-- missing (NULL), replacing the empty result with 'Action Required'.
-- Concepts: IS NULL, COALESCE
-- Ans:

SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM bookings
WHERE payment_status IS NULL;


-- QUERY 4
-- Retrieve match booking details along with the user's full
-- name and the scheduled match fixture teams.
-- Concepts: INNER JOIN
-- Ans:

SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM bookings b
INNER JOIN users   u ON b.user_id   = u.user_id
INNER JOIN matches m ON b.match_id  = m.match_id;

-- QUERY 5
-- Display all users and their booking IDs, ensuring fans who
-- have never bought a ticket are still listed.
-- Concepts: LEFT JOIN
-- Ans:

SELECT
    u.user_id,
    u.full_name,
    b.booking_id
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
ORDER BY u.user_id, b.booking_id;

-- QUERY 6
-- Find all ticket bookings where the total cost is strictly
-- higher than the average cost of all ticket bookings.
-- Concepts: Subquery, AVG
-- Ans:
SELECT
    booking_id,
    match_id,
    total_cost
FROM bookings
WHERE total_cost > (
    SELECT AVG(total_cost) FROM bookings
);

-- QUERY 7
-- Retrieve the top 2 most expensive matches sorted by base
-- ticket price, skipping the absolute highest premium match.
-- Concepts: ORDER BY, LIMIT, OFFSET
-- Ans:
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM matches
ORDER BY base_ticket_price DESC
LIMIT 2 OFFSET 1;