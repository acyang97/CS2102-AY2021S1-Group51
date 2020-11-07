--FILE TO PUT ALL OUR QUERIES.
-- PUT QUERIES HERE AFTER CONFIRMING IT WORKS,
-- DESCRIBE HOW IT WORKS AND WHAT THE QUERY IS FOR

CREATE TABLE dummy1(
  number INTEGER
);

CREATE TABLE dummy2(
  number INTEGER
);

CREATE OR REPLACE FUNCTION insert_into_dummy1_function() RETURNS trigger AS $$
DECLARE
  counter INTEGER := 1;
  max INTEGER := 5;
BEGIN
  while counter < max LOOP
    INSERT INTO dummy1 VALUES (counter);
    counter := counter + 1;
  END LOOP;
END
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION insert_into_dummy1_function() RETURNS TRIGGER AS $$
BEGIN
  FOR i in 1..12 LOOP
    INSERT INTO dummy1(n) VALUES (i);
  END LOOP;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';



DROP TRIGGER IF EXISTS insert_into_dummy1_trigger ON dummy2;
CREATE TRIGGER insert_into_dummy1_trigger
  AFTER INSERT
  ON dummy2
  FOR EACH ROW
  EXECUTE PROCEDURE insert_into_dummy1_function();

INSERT INTO DUMMY2(n) VALUES (1);


CREATE OR REPLACE FUNCTION insert_into_dummy1_function() RETURNS TRIGGER AS $$
DECLARE
  date1 DATE = current_date;
BEGIN
  WHILE date1 <= date('2020-12-01') LOOP
    INSERT INTO dummy1(d) VALUES (date1);
    date1 := date1 + 1;
  END LOOP;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS insert_into_dummy1_trigger ON dummy2;
CREATE TRIGGER insert_into_dummy1_trigger
  AFTER INSERT
  ON dummy2
  FOR EACH ROW
  EXECUTE PROCEDURE insert_into_dummy1_function();

INSERT INTO DUMMY2(n) VALUES (1);



SELECT pettype, ROUND(AVG(price), 2) AS avg_price, COUNT(*) AS numberr
FROM (SELECT price, pettype FROM fulltimepricelist
UNION
SELECT  price, pettype
FROM PARTTIMEPRICELIST) AS dummy
GROUP BY dummy.pettype;




CREATE OR REPLACE FUNCTION insert_into_dummy1_function() RETURNS TRIGGER AS $$
DECLARE
  counter INTEGER := 0;
  non_consecutive BOOLEAN;
  date1 DATE := date('2020-12-01');
  date2 DATE := date('2020-12-20');
BEGIN
  WHILE date2 <= date('2020-12-31') LOOP
     SELECT (20 != (SELECT COUNT(*)
                  FROM dummy1
                  WHERE date >= date1
                  AND date <= date2
                  AND NEW.username = dummy1.username
                  AND leave = FALSE)) INTO non_consecutive;
    IF non_consecutive = TRUE
      THEN counter := counter + 1;
    END IF;
    date1 := date1 + 1;
    date2 := date2 + 1;
  END LOOP;
  IF counter >= 2 THEN
    RAISE EXCEPTION 'cannot take leave';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS insert_into_dummy1_trigger ON dummy1;
CREATE TRIGGER insert_into_dummy1_trigger
  AFTER UPDATE of leave
  ON dummy1
  FOR EACH ROW
  EXECUTE PROCEDURE insert_into_dummy1_function();



CREATE OR REPLACE FUNCTION insert_into_dummy1_function() RETURNS TRIGGER AS $$
DECLARE
  counter INTEGER := 0;
  consecutive BOOLEAN;
  date1 DATE := date('2020-12-01');
  date2 DATE := date('2020-12-20');
BEGIN
  WHILE date2 <= date('2020-12-31') LOOP
     SELECT (20 = (SELECT COUNT(*)
                  FROM dummy1
                  WHERE date >= date1
                  AND date <= date2
                  AND NEW.username = dummy1.username
                  AND leave = FALSE)) INTO consecutive;
    IF consecutive = TRUE
      THEN counter := counter + 1;
      date1 := date2;
      date2 := date2 + 150;
    END IF;
    date1 := date1 + 1;
    date2 := date2 + 1;
  END LOOP;
  IF counter <= 2 THEN
    RAISE EXCEPTION 'cannot take leave';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS before_insert_into_dummy1_trigger ON dummy1;
CREATE TRIGGER before_insert_into_dummy1_trigger
  AFTER UPDATE of leave
  ON dummy1
  FOR EACH ROW
  EXECUTE PROCEDURE insert_into_dummy1_function();

DROP TRIGGER IF EXISTS after_insert_into_dummy1_trigger ON dummy1;
CREATE TRIGGER after_insert_into_dummy1_trigger
    AFTER UPDATE of leave
    ON dummy1
    FOR EACH ROW
    EXECUTE PROCEDURE insert_into_dummy1_function();

SELECT (20 = (SELECT COUNT(*) FROM dummy1 WHERE date >= date('2020-12-02') AND date <= date('2020-12-21')
  AND leave = FALSE AND username = 'abc'));

UPDATE dummy1 SET leave = True WHERE date = date('2020-12-01')
UPDATE dummy1 SET leave = True WHERE date = date('2020-12-15')
UPDATE dummy1 SET leave = True WHERE date = date('2020-12-21')



INSERT INTO dummy2(username,n) VALUES ('abc', 1);

CREATE TABLE dummy1(
  username VARCHAR,
  date DATE,
  leave BOOLEAN DEFAULT FALSE
);

INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-01');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-02');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-03');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-04');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-05');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-06');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-07');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-08');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-09');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-10');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-11');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-12');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-13');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-14');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-15');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-16');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-17');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-18');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-19');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-20');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-21');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-22');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-23');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-24');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-25');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-26');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-27');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-28');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-29');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-30');
INSERT INTO dummy1(username, date) VALUES ('abc', '2020-12-31');



CREATE OR REPLACE FUNCTION check_if_fulltime_can_take_leave_function() RETURNS trigger AS $$
DECLARE
  counter INTEGER := 0;
  full_time BOOLEAN;
  consecutive BOOLEAN;
  leave_date_in_non_consecutive BOOLEAN := False;
  date1 DATE := date('2021-01-01');
  date2 DATE := date('2021-05-30'); --someone help check if this is 150 days afer 2021-01-01
BEGIN
  SELECT (NEW.username IN (SELECT username FROM FullTime)) INTO full_time;
  IF EXTRACT(YEAR FROM NEW.date) = 2020 AND full_time = TRUE THEN
    RAISE EXCEPTION 'You cannot take leave on this date';
  END IF;
  IF full_time = True THEN
    WHILE date2 <= date('2021-12-31') LOOP
      SELECT (150 = (SELECT COUNT(*)
                    FROM CareTakerAvailability
                    WHERE date >= date1
                      AND date <= date2
                      AND NEW.username = CareTakerAvailability.username
                      AND leave is False)) INTO consecutive;
      --IF NEW.date >= date1 AND NEW.date <= date2 AND consecutive = FALSE THEN
      --  leave_date_in_non_consecutive := True;
      --  date2 := date('2021-12-31');
      --  counter := 2; -- just to break the loop and not hit exception
      --END IF;
      IF consecutive = True THEN
        counter := counter + 1;
        date1 := date1 + 150;
        date2 := date2 + 150;
      END IF;
      date1 := date1 + 1;
      date2 := date2 + 1;
    END LOOP;
  END IF;
  IF counter < 2 THEN  --MEANS HE ONLY HAVE 2 X 150 DAYS, CANNOT TAKE LAVE ALREADY
    RAISE EXCEPTION 'You cannot take leave on this date';
  END IF;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

--select (150 = (SELECT COUNT(*) FROM CareTakerAvailability WHERE leave = FALSE AND date >= date('2021-01-01') AND date <= date('2021-05-30')));
-- trigger to check if the full time can take leave (if it affects the 2 x 150 days thing)
DROP TRIGGER IF EXISTS check_if_fulltime_can_take_leave_trigger ON CareTakerAvailability;
CREATE TRIGGER check_if_fulltime_can_take_leave_trigger
  AFTER UPDATE OF leave
  ON CareTakerAvailability
  FOR EACH ROW
  EXECUTE PROCEDURE check_if_fulltime_can_take_leave_function();

--3. Find all the underperforming full-time caretakers per month (less than 10) AND (another constraint if too ez)

CREATE TABLE CareTakers (
      username VARCHAR;
      rating NUMERIC DEFAULT 0
);

CREATE TABLE CareTakerSalary (
  year INTEGER,
  month INTEGER,
  username VARCHAR,
  petdays INTEGER NOT NULL DEFAULT 0,
  earnings NUMERIC NOT NULL DEFAULT 0,
  final_salary NUMERIC NOT NULL DEFAULT 0
);

CREATE TABLE Bids (
    CTusername VARCHAR,
    rating INTEGER DEFAULT NULL, --to be updated after the bid
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, 'abc', 8);
INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, '123', 14);
INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, 'xyz', 20);
INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, '456', 19);

INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('abc', 2, date('2020-11-25'), date('2020-12-01'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('abc', 3, date('2020-12-02'), date('2020-12-05'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('abc', 4, date('2020-12-02'), date('2020-12-03'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('abc', 2, date('2020-11-25'), date('2020-12-01'));

INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('123', 2, date('2020-11-25'), date('2020-12-01'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('123', 3, date('2020-12-02'), date('2020-12-05'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('123', 4, date('2020-12-02'), date('2020-12-03'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('123', 4, date('2020-11-25'), date('2020-12-01'));

INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('xyz', 2, date('2020-11-25'), date('2020-12-01'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('xyz', 3, date('2020-12-02'), date('2020-12-05'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('xyz', 4, date('2020-12-02'), date('2020-12-03'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('xyz', 2, date('2020-11-25'), date('2020-12-01'));

INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('456', 0, date('2020-12-02'), date('2020-12-03'));
INSERT INTO Bids(CTusername, rating, start_date, end_date) VALUES ('456', 0, date('2020-11-25'), date('2020-12-01'));


SELECT username, rating_in_month
FROM (SELECT DISTINCT username, ROUND(AVG(B.rating), 2) AS rating_in_month
      FROM CareTakerSalary S
      INNER JOIN Bids B ON B.CTusername = S.username
      WHERE S.year = 2020
        AND S.month = 12
        AND petdays < 20
        AND (EXTRACT(YEAR FROM B.start_date) = 2020 OR EXTRACT(YEAR FROM B.end_date) = 2020)
        AND (EXTRACT(MONTH FROM B.start_date) = 12 OR EXTRACT(MONTH FROM B.end_date) = 12)
      GROUP BY username) AS DUMMY
WHERE rating_in_month < 3
ORDER BY rating_in_month DESC
LIMIT 10;



WITH cte(year, month, full_time_earnings, part_time_earnings) AS (
  SELECT Dummy1.year, Dummy1.month, Dummy1.full_time_earnings, Dummy2.part_time_earnings
  FROM (SELECT year, month, SUM(earnings) AS full_time_earnings
        FROM CareTakerSalary C
        WHERE C.username in (SELECT username FROM FullTime)
        GROUP BY C.year, C.month) AS Dummy1
        NATURAL JOIN
        (SELECT year, month, SUM(earnings) AS part_time_earnings
        FROM CareTakerSalary C
        WHERE C.username in (SELECT username FROM PartTime)
        GROUP BY C.year, C.month) AS Dummy2
  ORDER BY year, month
)
SELECT month, ROUND(AVG(full_time_earnings),2) AS full_time_earnings_avg,
              ROUND(AVG(part_time_earnings),2) AS part_time_earnings_avg,
              ROUND(AVG(full_time_earnings) + AVG(part_time_earnings), 2) AS total_earnings_avg
FROM cte
GROUP BY month;

FROM cte

WITH cte(year, month, dog, cat, rabbit, hamster, fish, mice, bird) AS (

WITH cte(year, month, dog,cat, bird, terrapin) AS (
  SELECT year, month, dog, cat, bird, terrapin
  FROM (SELECT C.year, C.month, COUNT(*) AS dog
  FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O
  WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date))
  AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date))
  AND O.category = 'Dog'
  GROUP BY C.year, C.month) AS dummy1
  NATURAL  JOIN
  (SELECT C.year, C.month, COUNT(*) AS cat
  FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O
  WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date))
  AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date))
  AND O.category = 'cAT'
  GROUP BY C.year, C.month) AS dummy2
  NATURAL JOIN
  (SELECT C.year, C.month, COUNT(*) AS bird
  FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O
  WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date))
  AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date))
  AND O.category = 'Bird'
  GROUP BY C.year, C.month) AS dummy3
  NATURAL JOIN
  (SELECT C.year, C.month, COUNT(*) AS terrapin
  FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O
  WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date))
  AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date))
  AND O.category = 'Terrapin'
  GROUP BY C.year, C.month) AS dummy4
)
select * from cte;

query = "WITH cte(year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice) AS ( \
    SELECT Dummy1.year, Dummy1.month, CASE WHEN dog IS NULL THEN 0 ELSE dog END dog, \
                                      CASE WHEN cat IS NULL THEN 0 ELSE cat END cat, \
                                      CASE WHEN bird IS NULL THEN 0 ELSE bird END bird, \
                                      CASE WHEN terrapin IS NULL THEN 0 ELSE terrapin END terrapin, \
                                      CASE WHEN rabbit IS NULL THEN 0 ELSE rabbit END rabbit, \
                                      CASE WHEN hamster IS NULL THEN 0 ELSE hamster END hamster, \
                                      CASE WHEN fish IS NULL THEN 0 ELSE fish END fish, \
                                      CASE WHEN mice IS NULL THEN 0 ELSE mice END mice \
    FROM (SELECT dummy1.year, dummy1.momth, dog, cat, bird, terrapin, rabbit, hamster, fish, mice \
    FROM (SELECT C.year, C.month, COUNT(*) AS dog \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Dog' \
    GROUP BY C.year, C.month) AS dummy1 \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS cat \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Cat' \
    GROUP BY C.year, C.month) AS dummy2 ON dummy2.year = dummy1.year AND dummy2.month = dummy1.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS bird \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Bird' \
    GROUP BY C.year, C.month) AS dummy3 ON dummy3.year = dummy1.year AND dummy3.month = dummy1.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS terrapin \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Terrapin' \
    GROUP BY C.year, C.month) AS dummy8 ON dummy1.year = dummy8.year AND dummy1.month = dummy8.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS rabbit \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Rabbit' \
    GROUP BY C.year, C.month) AS dummy4 ON dummy1.year = dummy4.year AND dummy1.month = dummy4.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS hamster \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Hamster' \
    GROUP BY C.year, C.month) AS dummy5 ON dummy1.year = dummy5.year AND dummy1.month = dummy5.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS fish \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Fish' \
    GROUP BY C.year, C.month) AS dummy6 ON dummy1.year = dummy6.year AND dummy1.month = dummy6.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS mice \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Mice' \
    GROUP BY C.year, C.month) AS dummy7 ON dummy1.year = dummy7.year AND dummy1.month = dummy7.month) AS final \
    JOIN CareTakerSalary CS ON final.year = CS.year AND final.month = CS.month
  ) \
  select year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice, \
  (dog + cat + bird + rabbit + hamster + fish + terrapin + mice) AS total \
  FROM cte \
  ORDER BY year, month"

  select C.year, C.month, CASE WHEN dog IS NULL THEN 0 ELSE dog END dog, \
                                  CASE WHEN cat IS NULL THEN 0 ELSE cat END cat, \
                                  CASE WHEN bird IS NULL THEN 0 ELSE bird END bird, \
                                  CASE WHEN terrapin IS NULL THEN 0 ELSE terrapin END terrapin, \
                                  CASE WHEN rabbit IS NULL THEN 0 ELSE rabbit END rabbit, \
                                  CASE WHEN hamster IS NULL THEN 0 ELSE hamster END hamster, \
                                  CASE WHEN fish IS NULL THEN 0 ELSE fish END fish, \
                                  CASE WHEN mice IS NULL THEN 0 ELSE mice END mice, \
  CASE WHEN (dog + cat + bird + rabbit + hamster + fish + terrapin + mice) IS NULL THEN 0 \
  ELSE (dog + cat + bird + rabbit + hamster + fish + terrapin + mice) END total \
  FROM CareTakerSalary C LEFT JOIN cte ON  C.year = cte.year AND c.month = cte.month \
  ORDER BY C.year, C.month


INSERT INTO Users(username, email, area, gender, password) VALUES ('abc1', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('xyz1', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('abc2', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('xyz2', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('abc3', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('xyz3', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('abc4', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('xyz4', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('abc5', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('xyz5', 'a', 'a', 'a', 'a');

INSERT INTO Users(username, email, area, gender, password) VALUES ('lol1', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('lol2', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('lol3', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('lol4', 'a', 'a', 'a', 'a');
INSERT INTO Users(username, email, area, gender, password) VALUES ('lol5', 'a', 'a', 'a', 'a');

INSERT INTO PetOwners(username) VALUES ('lol1');
INSERT INTO PetOwners(username) VALUES ('lol2');
INSERT INTO PetOwners(username) VALUES ('lol3');
INSERT INTO PetOwners(username) VALUES ('lol4');
INSERT INTO PetOwners(username) VALUES ('lol5');

INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol1', 'lala1', 'Dog', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol2', 'lala2', 'Dog', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol3', 'lala3', 'Dog', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol4', 'lala4', 'Dog', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol5', 'lala5', 'Dog', 1);

INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol1', 'lala11', 'Cat', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol2', 'lala22', 'Terrapin', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol3', 'lala33', 'Cat', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol4', 'lala44', 'Bird', 1);
INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES ('lol5', 'lala55', 'Bird', 1);



INSERT INTO Caretakers(username) VALUES ('abc1');
INSERT INTO Caretakers(username) VALUES ('abc2');
INSERT INTO Caretakers(username) VALUES ('abc3');
INSERT INTO Caretakers(username) VALUES ('abc4');
INSERT INTO Caretakers(username) VALUES ('abc5');
INSERT INTO Caretakers(username) VALUES ('xyz1');
INSERT INTO Caretakers(username) VALUES ('xyz2');
INSERT INTO Caretakers(username) VALUES ('xyz3');
INSERT INTO Caretakers(username) VALUES ('xyz4');
INSERT INTO Caretakers(username) VALUES ('xyz5');

INSERT INTO FullTime(username) VALUES ('abc1');
INSERT INTO FullTime(username) VALUES ('abc2');
INSERT INTO FullTime(username) VALUES ('abc3');
INSERT INTO FullTime(username) VALUES ('abc4');
INSERT INTO FullTime(username) VALUES ('abc5');

INSERT INTO PartTime(username) VALUES ('xyz1');
INSERT INTO PartTime(username) VALUES ('xyz2');
INSERT INTO PartTime(username) VALUES ('xyz3');
INSERT INTO PartTime(username) VALUES ('xyz4');
INSERT INTO PartTime(username) VALUES ('xyz5');

UPDATE CaretakerSalary SET earnings = 10 WHERE username = 'abc1' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 11 WHERE username = 'abc2' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 12 WHERE username = 'abc3' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 13 WHERE username = 'abc4' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 14 WHERE username = 'abc5' AND year = 2020 AND month = 11;

UPDATE CaretakerSalary SET earnings = 15 WHERE username = 'xyz1' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 16 WHERE username = 'xyz2' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 17 WHERE username = 'xyz3' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 18 WHERE username = 'xyz4' AND year = 2020 AND month = 11;
UPDATE CaretakerSalary SET earnings = 19 WHERE username = 'xyz5' AND year = 2020 AND month = 11;

INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc1', 'lol1', 'lala1', date('2020-11-08'), date('2020-11-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc1', 'lol1', 'lala1', date('2020-11-08'), date('2020-11-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc1', 'lol1', 'lala1', date('2020-11-08'), date('2020-11-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc2', 'lol2', 'lala2', date('2020-11-08'), date('2020-11-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc1', 'lol1', 'lala1', date('2020-11-08'), date('2020-11-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc5', 'lol1', 'lala1', date('2020-11-08'), date('2020-11-09'));


INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc1', 'lol1', 'lala11', date('2020-12-08'), date('2020-12-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc2', 'lol1', 'lala11', date('2020-12-08'), date('2020-12-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc3', 'lol1', 'lala1', date('2020-12-08'), date('2020-12-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc4', 'lol2', 'lala22', date('2020-12-08'), date('2020-12-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc5', 'lol3', 'lala33', date('2020-12-08'), date('2020-12-09'));
INSERT INTO Bids(CTusername, owner, pet_name, start_date, end_date) VALUES ('abc1', 'lol3', 'lala33', date('2020-12-08'), date('2020-12-09'));








INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, 'abc', 8);
INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, '123', 14);
INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, 'xyz', 20);
INSERT INTO CareTakerSalary(year, month, username, petdays) VALUES (2020, 12, '456', 19);


CREATE TABLE users(
    username VARCHAR PRIMARY KEY,
    email VARCHAR NOT NULL,
    area VARCHAR NOT NULL,
    gender VARCHAR NOT NULL,
    password VARCHAR NOT NULL
);

CREATE TABLE PetOwners (
    username VARCHAR PRIMARY KEY REFERENCES users(username) ON DELETE CASCADE
);

CREATE TABLE CareTakers (
    username VARCHAR PRIMARY KEY REFERENCES users(username) ON DELETE CASCADE,
    rating NUMERIC DEFAULT 0
);

CREATE TABLE FullTime (
    username VARCHAR PRIMARY KEY REFERENCES CareTakers(username) ON DELETE CASCADE
);

CREATE TABLE PartTime (
    username VARCHAR PRIMARY KEY REFERENCES CareTakers(username) ON DELETE CASCADE
);

CREATE TABLE OwnedPets (
    owner VARCHAR references PetOwners(username) ON DELETE CASCADE,
    pet_name VARCHAR NOT NULL UNIQUE,
    category VARCHAR NOT NULL,
    age INTEGER NOT NULL,
    Primary Key(owner, pet_name)
);

CREATE TABLE CareTakerSalary (
  year INTEGER,
  month INTEGER,
  username VARCHAR REFERENCES CareTakers(username),
  petdays INTEGER NOT NULL DEFAULT 0,
  earnings NUMERIC NOT NULL DEFAULT 0,
  final_salary NUMERIC NOT NULL DEFAULT 0,
  PRIMARY KEY (year, month, username)
);

CREATE TABLE Bids (
    CTusername VARCHAR,
    owner VARCHAR,
    pet_name VARCHAR,
    FOREIGN KEY(owner, pet_name) REFERENCES OwnedPets(owner, pet_name) ON DELETE CASCADE,
    start_date DATE,
    end_date DATE
);

CREATE OR REPLACE FUNCTION insert_into_salary_after_caretaker_insertion_function() RETURNS trigger AS $$
DECLARE
  current_month INTEGER := EXTRACT(MONTH FROM current_date);
  current_year INTEGER := EXTRACT(YEAR FROM current_date);
BEGIN
  FOR i in current_month..12 LOOP
    INSERT INTO CareTakerSalary(year, month, username) VALUES (current_year, i, NEW.username);
  END LOOP;
  FOR i in 1..12 LOOP
    INSERT INTO CareTakerSalary(year, month, username) VALUES (current_year + 1, i, NEW.username);
  END LOOP;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS insert_into_salary_after_caretaker_insertion_trigger ON CareTakers;
CREATE TRIGGER insert_into_salary_after_caretaker_insertion_trigger
  AFTER INSERT
  ON CareTakers
  FOR EACH ROW
  EXECUTE PROCEDURE insert_into_salary_after_caretaker_insertion_function();




SELECT C1.year, C1.month, C1.username, C1.petdays, C1.final_salary
FROM CareTakerSalary C1
WHERE
((SELECT date_part('year', (SELECT current_timestamp)) > C1.year)
        OR ((SELECT date_part('year', (SELECT current_timestamp)) = C1.year)
        AND (SELECT date_part('month', (SELECT current_timestamp)) > C1.month)))
 AND C1.final_salary >= ALL(SELECT final_salary
 FROM CareTakerSalary C2
 WHERE C2.year = C1.year
 AND C2.month = C1.month)
ORDER BY C1.year DESC, C1.month DESC;


SELECT date_part('year', B.start_date) AS year, date_part('month', B.start_date) AS month, O.category, COUNT(*) AS num
FROM Bids B INNER JOIN OwnedPets O ON (B.owner = O.owner AND B.pet_name = O.pet_name)
GROUP BY date_part('year', B.start_date), date_part('month', B.start_date), O.category
ORDER BY year DESC, month DESC, num DESC;


INSERT INTO bids VALUES (1, 'gkingmann', 'astather2', 'Common wolf', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'rpinkerton8', 'Long-billed cockatoo', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'rpinkerton8', 'Long-billed cockatoo', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'caisman6', 'Dove, galapagos', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'caisman6', 'Dove, galapagos', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'imichelottij', 'Tarantula', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '7/05/2020', '7/05/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'imichelottij', 'Tarantula', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '7/05/2020', '7/05/2020', 100);
INSERT INTO bids VALUES (1, 'gkingmann', 'astather2', 'Common wolf', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '7/05/2020', '7/05/2020', 100);




INSERT INTO CareTakerSalary VALUES (2019, 6, 'ckitleeg', 0, 0, 2000);
INSERT INTO CareTakerSalary VALUES (2019, 6, 'asconesh', 0, 0, 2500);
INSERT INTO CareTakerSalary VALUES (2019, 6, 'sgiacomozzoi', 0, 0, 3000);
INSERT INTO CareTakerSalary VALUES (2019, 6, 'imichelottij', 0, 0, 3500);
INSERT INTO CareTakerSalary VALUES (2019, 6, 'vstonehewerl', 0, 0, 3500);
INSERT INTO CareTakerSalary VALUES (2019, 5, 'asconesh', 0, 0, 3000);
INSERT INTO CareTakerSalary VALUES (2019, 5, 'gkingmann', 0, 0, 2500);
INSERT INTO CareTakerSalary VALUES (2019, 5, 'dblaymiresp', 0, 0, 2500);
INSERT INTO CareTakerSalary VALUES (2019, 3, 'sgiacomozzoi', 0, 0, 5000);
INSERT INTO CareTakerSalary VALUES (2019, 3, 'vstonehewerl', 0, 0, 3000);


WITH cte(year, month, full_time_earnings, part_time_earnings) AS (
    SELECT Dummy1.year, Dummy1.month, Dummy1.full_time_earnings, Dummy2.part_time_earnings
    FROM (SELECT year, month, SUM(earnings) AS full_time_earnings
          FROM CareTakerSalary C
          WHERE C.username in (SELECT username FROM FullTime)
          GROUP BY C.year, C.month) AS Dummy1
          NATURAL JOIN
          (SELECT year, month, SUM(earnings) AS part_time_earnings
          FROM CareTakerSalary C
          WHERE C.username in (SELECT username FROM PartTime)
          GROUP BY C.year, C.month) AS Dummy2
    ORDER BY year, month
)
SELECT month, ROUND(AVG(full_time_earnings),2) AS full_time_earnings_avg,
                ROUND(AVG(part_time_earnings),2) AS part_time_earnings_avg,
                ROUND(AVG(full_time_earnings) + AVG(part_time_earnings), 2) AS total_earnings_avg
FROM cte
GROUP BY month;

WITH cte(year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice) AS ( \
    SELECT Dummy1.year, Dummy1.month, CASE WHEN dog IS NULL THEN 0 ELSE dog END dog, \
                                      CASE WHEN cat IS NULL THEN 0 ELSE cat END cat, \
                                      CASE WHEN bird IS NULL THEN 0 ELSE bird END bird, \
                                      CASE WHEN terrapin IS NULL THEN 0 ELSE terrapin END terrapin, \
                                      CASE WHEN rabbit IS NULL THEN 0 ELSE rabbit END rabbit, \
                                      CASE WHEN hamster IS NULL THEN 0 ELSE hamster END hamster, \
                                      CASE WHEN fish IS NULL THEN 0 ELSE fish END fish, \
                                      CASE WHEN mice IS NULL THEN 0 ELSE mice END mice \
    FROM CareTakerSalary C LEFT JOIN \
    (SELECT (year, month, dog, cat, bird, terrapin, rabbit, hamster, fish , mice) FROM \
    (SELECT C.year, C.month, COUNT(*) AS dog \
    FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Dog' \
    GROUP BY C.year, C.month) AS dummy1  \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS cat \
    FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Cat' \
    GROUP BY C.year, C.month) AS dummy2 ON dummy1.year = dummy2.year AND dummy1.month = dummy2.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS bird \
    FROM CareTakerSalary C JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Bird' \
    GROUP BY C.year, C.month) AS dummy3 ON dummy3.year = dummy1.year AND dummy3.month = dummy1.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS terrapin \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Terrapin' \
    GROUP BY C.year, C.month) AS dummy8 ON C.year = dummy8.year AND C.month = dummy8.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS rabbit \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Rabbit' \
    GROUP BY C.year, C.month) AS dummy4 ON C.year = dummy4.year AND C.month = dummy4.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS hamster \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Hamster' \
    GROUP BY C.year, C.month) AS dummy5 ON C.year = dummy5.year AND C.month = dummy5.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS fish \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Fish' \
    GROUP BY C.year, C.month) AS dummy6 ON C.year = dummy6.year AND C.month = dummy6.month \
    FULL OUTER JOIN \
    (SELECT C.year, C.month, COUNT(*) AS mice \
    FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
    WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
    AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
    AND O.category = 'Mice' \
    GROUP BY C.year, C.month) AS dummy7 ON C.year = dummy7.year AND C.month = dummy7.month \
  ) AS dummyy ) \
  select C.year, C.month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice, \
  (dog + cat + bird + rabbit + hamster + fish + terrapin + mice) AS total \
  FROM cte C \
  ORDER BY C.year, C.month

  @view.route("/admin_view_jobs_by_pet_type_summary", methods = ["POST", "GET"])
  @login_required
  def admin_view_jobs_by_pet_type_summary():
      query = "WITH cte(year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice) AS ( \
          SELECT Dummy1.year, Dummy1.month, CASE WHEN dog IS NULL THEN 0 ELSE dog END dog, \
                                            CASE WHEN cat IS NULL THEN 0 ELSE cat END cat, \
                                            CASE WHEN bird IS NULL THEN 0 ELSE bird END bird, \
                                            CASE WHEN terrapin IS NULL THEN 0 ELSE terrapin END terrapin, \
                                            CASE WHEN rabbit IS NULL THEN 0 ELSE rabbit END rabbit, \
                                            CASE WHEN hamster IS NULL THEN 0 ELSE hamster END hamster, \
                                            CASE WHEN fish IS NULL THEN 0 ELSE fish END fish, \
                                            CASE WHEN mice IS NULL THEN 0 ELSE mice END mice \
          FROM (SELECT C.year, C.month, COUNT(*) AS dog \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername AND C NATURAL JOIN OwnedPets O NATURAL JOIN CareTakerSalary \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Dog' \
          GROUP BY C.year, C.month) AS dummy1 \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS cat \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Cat' \
          GROUP BY C.year, C.month) AS dummy2 ON dummy2.year = dummy1.year AND dummy2.month = dummy1.month \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS bird \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Bird' \
          GROUP BY C.year, C.month) AS dummy3 ON dummy3.year = dummy1.year AND dummy3.month = dummy1.month \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS terrapin \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Terrapin' \
          GROUP BY C.year, C.month) AS dummy8 ON dummy1.year = dummy8.year AND dummy1.month = dummy8.month \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS rabbit \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Rabbit' \
          GROUP BY C.year, C.month) AS dummy4 ON dummy1.year = dummy4.year AND dummy1.month = dummy4.month \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS hamster \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Hamster' \
          GROUP BY C.year, C.month) AS dummy5 ON dummy1.year = dummy5.year AND dummy1.month = dummy5.month \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS fish \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Fish' \
          GROUP BY C.year, C.month) AS dummy6 ON dummy1.year = dummy6.year AND dummy1.month = dummy6.month \
          FULL OUTER JOIN \
          (SELECT C.year, C.month, COUNT(*) AS mice \
          FROM CareTakerSalary C LEFT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
          WHERE (C.year = EXTRACT(YEAR FROM B.start_date) OR C.year = EXTRACT(YEAR FROM B.end_date)) \
          AND (C.month = EXTRACT(MONTH FROM B.start_date) OR C.month = EXTRACT(MONTH FROM B.end_date)) \
          AND O.category = 'Mice' \
          GROUP BY C.year, C.month) AS dummy7 ON dummy1.year = dummy7.year AND dummy1.month = dummy7.month \
        ) \
        select year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice, \
        (dog + cat + bird + rabbit + hamster + fish + terrapin + mice) AS total \
        FROM cte \
        ORDER BY year, month"
      summary = db.session.execute(query)
      summary = list(summary)
      table = NuumberOfJobsByPetTypeTable(summary)
      table.border = True
      return render_template("admin_view_jobs_by_pet_type_summary.html", table=table)
