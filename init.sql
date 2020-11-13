--dbname protest
DROP TABLE IF EXISTS TotalJobPerMonthSummary, CareTakerSalary, FullTimePriceList, PartTimePriceList, DefaultPriceList, Bids, CareTakerAvailability, RequireSpecialCare, SpecialCare, OwnedPets, Category;
DROP TABLE IF EXISTS PreferredModeOfPayment, ModeOfPayment, PreferredTransport, ModeOfTransport, PCSAdmin, PetOwners, PartTime, FullTime, CareTakers, users;

CREATE TABLE users(
    username VARCHAR PRIMARY KEY,
    email VARCHAR NOT NULL,
    area VARCHAR NOT NULL,
    gender VARCHAR NOT NULL,
    password VARCHAR NOT NULL
);

CREATE TABLE PCSAdmin (
    username VARCHAR PRIMARY KEY REFERENCES users(username) ON DELETE CASCADE
);

CREATE TABLE PetOwners (
    username VARCHAR PRIMARY KEY REFERENCES users(username) ON DELETE CASCADE
);

CREATE TABLE CareTakers (
    username VARCHAR PRIMARY KEY REFERENCES users(username) ON DELETE CASCADE,
    rating NUMERIC DEFAULT 0
);

CREATE TABLE ModeOfTransport (
    transport VARCHAR PRIMARY KEY
);

CREATE TABLE PreferredTransport (
    username VARCHAR PRIMARY KEY REFERENCES CareTakers(username) ON DELETE CASCADE,
    transport VARCHAR REFERENCES ModeOfTransport(transport)
);

CREATE TABLE ModeOfPayment (
  modeOfPayment VARCHAR PRIMARY KEY
);

CREATE TABLE PreferredModeOfPayment (
  username VARCHAR PRIMARY KEY REFERENCES CareTakers(username) ON DELETE CASCADE,
  modeOfPayment VARCHAR REFERENCES ModeOfPayment(modeOfPayment)
);

CREATE TABLE FullTime (
    username VARCHAR PRIMARY KEY REFERENCES CareTakers(username) ON DELETE CASCADE
);

CREATE TABLE PartTime (
    username VARCHAR PRIMARY KEY REFERENCES CareTakers(username) ON DELETE CASCADE
);

-- TO INSERT INTO HERE WHENEVER THERE IS A NEW CATEGORY IN OWNED PETS
CREATE TABLE Category (
    pettype VARCHAR PRIMARY KEY
);

CREATE TABLE OwnedPets (
    owner VARCHAR references PetOwners(username) ON DELETE CASCADE,
    pet_name VARCHAR NOT NULL UNIQUE,
    category VARCHAR NOT NULL,
    age INTEGER NOT NULL,
    Primary Key(owner, pet_name)
);

CREATE TABLE SpecialCare(
    care VARCHAR PRIMARY KEY
);

CREATE TABLE RequireSpecialCare(
    owner VARCHAR,
    pet_name VARCHAR,
    care VARCHAR REFERENCES SpecialCare(care),
    FOREIGN KEY(owner, pet_name) REFERENCES OwnedPets(owner, pet_name) ON DELETE CASCADE,
    PRIMARY KEY(owner, pet_name, care)
);

CREATE TABLE CaretakerAvailability(
    date DATE,
    pet_count INTEGER DEFAULT 0,
    leave BOOLEAN DEFAULT False,
    username VARCHAR REFERENCES CareTakers(username) ON DELETE CASCADE,
    available BOOLEAN NOT NULL DEFAULT True,
    PRIMARY KEY(username, date)
);

CREATE TABLE Bids (
    bid_id INTEGER,
    CTusername VARCHAR,
    owner VARCHAR,
    pet_name VARCHAR,
    FOREIGN KEY(owner, pet_name) REFERENCES OwnedPets(owner, pet_name) ON DELETE CASCADE,
    review VARCHAR DEFAULT NULL,
    rating INTEGER DEFAULT NULL, --to be updated after the bid
    mode_of_transport VARCHAR NOT NULL,
    mode_of_payment VARCHAR NOT NULL,
    credit_card VARCHAR,
    completed BOOLEAN DEFAULT FALSE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price_per_day NUMERIC NOT NULL,
    FOREIGN KEY (CTusername, start_date) REFERENCES CareTakerAvailability(username, date) ON DELETE CASCADE ,
    FOREIGN KEY (CTusername, end_date) REFERENCES CaretakerAvailability(username, date) ON DELETE CASCADE
);

CREATE TABLE PartTimePriceList (
  pettype VARCHAR REFERENCES Category(pettype),
  username VARCHAR REFERENCES CareTakers(username) ON DELETE CASCADE,
  price NUMERIC,
  PRIMARY KEY (pettype, username)
);

CREATE TABLE DefaultPriceList (
  pettype VARCHAR REFERENCES Category(pettype),
  price NUMERIC,
  PRIMARY KEY (pettype)
);

CREATE TABLE FullTimePriceList(
  username VARCHAR REFERENCES CareTakers(username) ON DELETE CASCADE,
  price NUMERIC,
  pettype VARCHAR,
  FOREIGN KEY (pettype) REFERENCES DefaultPriceList(pettype),
  PRIMARY KEY (pettype, username)
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

CREATE TABLE TotalJobPerMonthSummary (
  year INTEGER,
  month INTEGER,
  job_count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(year, month)
);

\i read_data.sql


CREATE OR REPLACE FUNCTION update_caretaker_pet_count_function() RETURNS trigger AS $$
BEGIN
  UPDATE CareTakerAvailability C set pet_count = pet_count + 1
    WHERE C.username = NEW.CTUsername
      AND C.date >= NEW.start_date
      AND C.date <= NEW.end_date;
  UPDATE CareTakerAvailability C set available = FALSE
    WHERE C.username = NEW.CTUsername
    AND (NEW.CTUsername in (SELECT * FROM FullTime))
    AND C.date >= NEW.start_date
    AND C.date <= NEW.end_date
    AND C.pet_count = 5;
  UPDATE CareTakerAvailability C set available = FALSE
    WHERE C.username = NEW.CTUsername
    AND (NEW.CTUsername in (SELECT * FROM PartTime))
    AND ((SELECT rating FROM Caretakers WHERE username = NEW.CTUsername)>=4)
    AND C.date >= NEW.start_date
    AND C.date <= NEW.end_date
    AND C.pet_count = 5;
  UPDATE CareTakerAvailability C set available = FALSE
    WHERE C.username = NEW.CTUsername
    AND (NEW.CTUsername in (SELECT * FROM PartTime))
    AND ((SELECT rating FROM Caretakers WHERE username = NEW.CTUsername)<4)
    AND C.date >= NEW.start_date
    AND C.date <= NEW.end_date
    AND C.pet_count = 2;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS update_caretaker_petcount_after_bid_trigger ON Bids;
CREATE TRIGGER update_caretaker_petcount_after_bid_trigger
  AFTER INSERT
  ON Bids
  FOR EACH ROW
  EXECUTE PROCEDURE update_caretaker_pet_count_function();

CREATE OR REPLACE FUNCTION update_TotalJobPerMonthSummary_function() RETURNS trigger AS $$
BEGIN
  UPDATE TotalJobPerMonthSummary T set job_count = job_count + 1
  WHERE T.year = EXTRACT(YEAR FROM NEW.end_date)
    AND T.month = EXTRACT(MONTH FROM NEW.end_date);
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

--trigger to update the total number of pets by all the caretakers in the pcs app in each month
DROP TRIGGER IF EXISTS update_TotalJobPerMonthSummary_trigger ON Bids;
CREATE TRIGGER update_TotalJobPerMonthSummary_trigger
  AFTER UPDATE of completed
  ON Bids
  FOR EACH ROW
  EXECUTE PROCEDURE update_TotalJobPerMonthSummary_function();

-- function that makes use of the trigger below to automates this process
CREATE OR REPLACE FUNCTION update_caretaker_availability_after_take_leave_function() RETURNS trigger AS $$
BEGIN
  UPDATE CareTakerAvailability C set available = False
    WHERE leave = true;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

-- trigger that automates the changing of availability after user takes a leave
DROP TRIGGER IF EXISTS update_caretaker_availability_after_take_leave_trigger ON CareTakerAvailability;
CREATE TRIGGER update_caretaker_availability_after_take_leave_trigger
  AFTER UPDATE OF leave
  ON CareTakerAvailability
  FOR EACH ROW
  EXECUTE PROCEDURE update_caretaker_availability_after_take_leave_function();

-- automates the insertion into the CaretakerSalaryTable
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

-- automates the insertion into the CareTakerAvailability table, satisfying the total participation constraint
CREATE OR REPLACE FUNCTION insert_into_CareTakerAvailability_after_caretaker_insertion_function() RETURNS trigger AS $$
DECLARE
  date1 DATE = current_date;
  limit_year INTEGER := EXTRACT(YEAR FROM current_date) + 2;
BEGIN
  WHILE EXTRACT(YEAR FROM date1) < limit_year LOOP
    INSERT INTO  CaretakerAvailability(date, username) VALUES (date1, NEW.username);
    date1 := date1 + 1;
  END LOOP;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS insert_into_CareTakerAvailability_after_caretaker_insertion_trigger ON CareTakers;
CREATE TRIGGER insert_into_CareTakerAvailability_after_caretaker_insertion_trigger
  AFTER INSERT
  ON CareTakers
  FOR EACH ROW
  EXECUTE PROCEDURE insert_into_CareTakerAvailability_after_caretaker_insertion_function();

CREATE OR REPLACE FUNCTION update_caretaker_rating_after_petowner_give_rating_function() RETURNS trigger AS $$
DECLARE
  old_rating NUMERIC;
  updated_rating NUMERIC;
  is_part_time BOOLEAN;
BEGIN
  SELECT (NEW.CTusername IN (SELECT username FROM PartTime)) INTO is_part_time;
  SELECT (SELECT SUM(rating) FROM CareTakers WHERE username = NEW.CTusername) INTO old_rating;
  SELECT (ROUND((SELECT AVG(B.rating) FROM Bids B WHERE B.CTusername = NEW.CTusername),2)) INTO updated_rating;
  UPDATE Caretakers C
    SET rating = updated_rating
    WHERE C.username = NEW.CTusername;
  IF is_part_time = true AND updated_rating >= 4 AND old_rating < 4 THEN
    UPDATE CareTakerAvailability CA
      SET available = true
      WHERE CA.username = NEW.CTusername
        AND available = False
        AND pet_count = 2;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS update_caretaker_rating_after_petowner_give_rating_trigger ON Bids;
CREATE TRIGGER update_caretaker_rating_after_petowner_give_rating_trigger
  AFTER UPDATE of rating
  ON Bids
  FOR EACH ROW
  EXECUTE PROCEDURE update_caretaker_rating_after_petowner_give_rating_function();

CREATE OR REPLACE FUNCTION check_if_fulltime_can_take_leave_function() RETURNS trigger AS $$
DECLARE
  counter INTEGER := 0;
  full_time BOOLEAN;
  consecutive BOOLEAN;
  leave_date_in_non_consecutive BOOLEAN := False;
  date1 DATE;
  date2 DATE;
  year_of_new_date INTEGER := EXTRACT(YEAR FROM NEW.date);
BEGIN
  IF EXTRACT(YEAR FROM NEW.date) > (EXTRACT(YEAR FROM current_date) + 1) THEN
    RAISE EXCEPTION 'You cannot take leave on this date';
  END IF;
  SELECT (SELECT MIN(date) FROM CareTakerAvailability CA
          WHERE CA.username = NEW.username
          AND EXTRACT(YEAR from NEW.date) = EXTRACT(year FROM CA.date)) INTO date1;
  date2 := date1 + 149;
  SELECT (NEW.username IN (SELECT username FROM FullTime)) INTO full_time;
  IF (EXTRACT(YEAR FROM NEW.date) = 2020) AND (full_time = TRUE) THEN
    RAISE EXCEPTION 'You cannot take leave on this date';
  END IF;
  IF NEW.date < current_date THEN
    RAISE EXCEPTION 'You cannot take leave on a date that has passed.';
  END IF;
  IF full_time = True THEN
    WHILE EXTRACT(YEAR from date2) < (year_of_new_date + 1) LOOP
      SELECT (150 = (SELECT COUNT(*)
                    FROM CareTakerAvailability
                    WHERE date >= date1
                      AND date <= date2
                      AND NEW.username = CareTakerAvailability.username
                      AND leave is False)) INTO consecutive;
      IF consecutive = True THEN
        counter := counter + 1;
        date1 := date1 + 150;
        date2 := date2 + 150;
      ELSE
        date1 := date1 + 1;
        date2 := date2 + 1;
      END IF;
    END LOOP;
    IF counter < 2 THEN
      RAISE EXCEPTION 'You cannot take leave on this date';
    END IF;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS check_if_fulltime_can_take_leave_trigger ON CareTakerAvailability;
CREATE TRIGGER check_if_fulltime_can_take_leave_trigger
  AFTER UPDATE OF leave
  ON CareTakerAvailability
  FOR EACH ROW
  EXECUTE PROCEDURE check_if_fulltime_can_take_leave_function();

CREATE OR REPLACE FUNCTION check_caretaker_petcount_before_allow_leave_function() RETURNS trigger AS $$
DECLARE
  pet_count_on_selected_date BOOLEAN;
BEGIN
  SELECT (0 < (SELECT SUM(pet_count)
              FROM CareTakerAvailability
              WHERE NEW.username = username
              AND NEW.date = date)) INTO pet_count_on_selected_date;
  IF pet_count_on_selected_date = True THEN
    RAISE EXCEPTION 'You cannot take leave on this date';
  END IF;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS check_caretaker_petcount_before_allow_leave_trigger ON CareTakerAvailability;
CREATE TRIGGER check_caretaker_petcount_before_allow_leave_trigger
  BEFORE UPDATE OF leave
  ON CareTakerAvailability
  FOR EACH ROW
  EXECUTE PROCEDURE check_caretaker_petcount_before_allow_leave_function();

CREATE OR REPLACE FUNCTION insert_more_entries_into_caretakeravailability_and_salary_function() RETURNS trigger AS $$
DECLARE
  current_year INTEGER := EXTRACT(YEAR FROM current_date);
  latest_date DATE;
BEGIN
  SELECT (SELECT MAX(date) FROM CareTakerAvailability WHERE username = NEW.username) INTO latest_date;
  latest_date := latest_date + 1;
  IF current_year = EXTRACT(YEAR FROM (SELECT MAX(date) FROM CareTakerAvailability WHERE username = NEW.username)) THEN
    FOR i in 1..12 LOOP
      INSERT INTO CareTakerSalary(year, month, username) VALUES (current_year + 1, i, NEW.username);
    END LOOP;
    WHILE EXTRACT(year FROM latest_date) < current_year + 2 LOOP
      INSERT INTO CareTakerAvailability(date, username) VALUES (latest_date, NEW.username);
      latest_date := latest_date + 1;
    END LOOP;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS insert_more_entries_into_caretakeravailability_and_salary_trigger ON CareTakerAvailability;
CREATE TRIGGER insert_more_entries_into_caretakeravailability_and_salary_trigger
  AFTER UPDATE
  ON CareTakerAvailability
  FOR EACH ROW
  EXECUTE PROCEDURE insert_more_entries_into_caretakeravailability_and_salary_function();

CREATE OR REPLACE FUNCTION
update_salary() RETURNS trigger AS $$
DECLARE end_of_month date := (SELECT(date_trunc('month', NEW.start_date::date) + interval '1 month' - interval '1 day')::date);
DECLARE start_of_end_date_month date;
DECLARE full_time_count integer := (SELECT COUNT(*) FROM fulltime WHERE username = NEW.ctusername);
DECLARE curr_pet_day integer;
DECLARE num_days_exceed_60 integer;
BEGIN
IF full_time_count > 0 THEN
    IF NEW.end_date > end_of_month THEN
        start_of_end_date_month := (SELECT date_trunc('MONTH', NEW.end_date)::DATE);
        curr_pet_day := (SELECT petdays FROM CareTakerSalary WHERE
            username = NEW.ctusername AND
            year = (SELECT date_part('year', start_of_end_date_month)) AND
            month = (SELECT date_part('month', start_of_end_date_month)));
        IF curr_pet_day >= 60 THEN
            UPDATE CareTakerSalary
            SET earnings = earnings + ((NEW.end_date - start_of_end_date_month + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - start_of_end_date_month + 1),
            final_salary = final_salary + ((NEW.end_date - start_of_end_date_month + 1) * (NEW.price_per_day * 0.8))
            WHERE
            username = NEW.ctusername AND
            year = (SELECT date_part('year', start_of_end_date_month)) AND
            month = (SELECT date_part('month', start_of_end_date_month));
            NEW.end_date := end_of_month;
        ELSE
            num_days_exceed_60 := curr_pet_day + (NEW.end_date - start_of_end_date_month + 1) - 60;
            IF num_days_exceed_60 > 0 THEN
                UPDATE CareTakerSalary
                SET earnings = earnings + ((NEW.end_date - start_of_end_date_month + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - start_of_end_date_month + 1),
                final_salary = final_salary + ((60 - curr_pet_day) * 50) + (num_days_exceed_60 * (NEW.price_per_day * 0.8))
                WHERE
                username = NEW.ctusername AND
                year = (SELECT date_part('year', start_of_end_date_month)) AND
                month = (SELECT date_part('month', start_of_end_date_month));
                NEW.end_date := end_of_month;
            ELSE
                UPDATE CareTakerSalary
                SET earnings = earnings + ((NEW.end_date - start_of_end_date_month + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - start_of_end_date_month + 1),
                final_salary = final_salary + ((NEW.end_date - start_of_end_date_month + 1) * 50)
                WHERE
                username = NEW.ctusername AND
                year = (SELECT date_part('year', start_of_end_date_month)) AND
                month = (SELECT date_part('month', start_of_end_date_month));
                NEW.end_date := end_of_month;
            END IF;
        END IF;
    END IF;
    curr_pet_day := (SELECT petdays FROM CareTakerSalary WHERE
            username = NEW.ctusername AND
            year = (SELECT date_part('year', NEW.start_date)) AND
            month = (SELECT date_part('month', NEW.start_date)));
    IF curr_pet_day >= 60 THEN
        UPDATE CareTakerSalary
        SET earnings = earnings + ((NEW.end_date - NEW.start_date + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - NEW.start_date + 1),
        final_salary = final_salary + ((NEW.end_date - NEW.start_date + 1) * (NEW.price_per_day * 0.8))
        WHERE
        username = NEW.ctusername AND
        year = (SELECT date_part('year', NEW.start_date)) AND
        month = (SELECT date_part('month', NEW.start_date));
    ELSE
        num_days_exceed_60 := curr_pet_day + (NEW.end_date - NEW.start_date + 1) - 60;
        IF num_days_exceed_60 > 0 THEN
            UPDATE CareTakerSalary
            SET earnings = earnings + ((NEW.end_date - NEW.start_date + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - NEW.start_date + 1),
            final_salary = final_salary + ((60 - curr_pet_day) * 50) + (num_days_exceed_60 * (NEW.price_per_day * 0.8))
            WHERE
            username = NEW.ctusername AND
            year = (SELECT date_part('year', NEW.start_date)) AND
            month = (SELECT date_part('month', NEW.start_date));
        ELSE
            UPDATE CareTakerSalary
            SET earnings = earnings + ((NEW.end_date - NEW.start_date + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - NEW.start_date + 1),
            final_salary = final_salary + ((NEW.end_date - NEW.start_date + 1) * 50)
            WHERE
            username = NEW.ctusername AND
            year = (SELECT date_part('year', NEW.start_date)) AND
            month = (SELECT date_part('month', NEW.start_date));
        END IF;
    END IF;
    RETURN NEW;
ELSE
    IF NEW.end_date > end_of_month THEN
    start_of_end_date_month := (SELECT date_trunc('MONTH', NEW.end_date)::DATE);
    UPDATE CareTakerSalary
    SET earnings = earnings + ((NEW.end_date - start_of_end_date_month + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - start_of_end_date_month + 1),
    final_salary = (earnings + ((NEW.end_date - start_of_end_date_month + 1) * NEW.price_per_day)) * 0.75
    WHERE
    username = NEW.ctusername AND
    year = (SELECT date_part('year', start_of_end_date_month)) AND
    month = (SELECT date_part('month', start_of_end_date_month));
    NEW.end_date := end_of_month;
    END IF;
    UPDATE CareTakerSalary
    SET earnings = earnings + ((NEW.end_date - NEW.start_date + 1) * NEW.price_per_day), petdays = petdays + (NEW.end_date - NEW.start_date + 1),
    final_salary = (earnings + ((NEW.end_date - NEW.start_date + 1) * NEW.price_per_day)) * 0.75
    WHERE
    username = NEW.ctusername AND
    year = (SELECT date_part('year', NEW.start_date)) AND
    month = (SELECT date_part('month', NEW.start_date));
    RETURN NEW;
  END IF;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_ct_salary ON bids;
CREATE TRIGGER update_ct_salary
AFTER INSERT
ON "bids"
FOR EACH ROW
EXECUTE PROCEDURE update_salary();
