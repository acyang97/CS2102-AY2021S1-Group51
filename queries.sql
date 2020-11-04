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
