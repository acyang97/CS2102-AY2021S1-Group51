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

INSERT INTO ModeOfTransport VALUES ('Pet Owner Deliver');
INSERT INTO ModeOfTransport VALUES ('Care Taker Pick Up');
INSERT INTO ModeOfTransport VALUES ('Transfer through PCS Building');

CREATE TABLE PreferredTransport (
    username VARCHAR REFERENCES CareTakers(username) ON DELETE CASCADE,
    transport VARCHAR REFERENCES ModeOfTransport(transport),
    PRIMARY KEY (username, transport)
);

CREATE TABLE ModeOfPayment (
  modeOfPayment VARCHAR PRIMARY KEY
);

INSERT INTO ModeOfPayment VALUES ('Credit Card');
INSERT INTO ModeOfPayment VALUES ('Cash');
INSERT INTO ModeOfPayment VALUES ('Either');


CREATE TABLE PreferredModeOfPayment (
  username VARCHAR REFERENCES CareTakers(username) ON DELETE CASCADE,
  modeOfPayment VARCHAR REFERENCES ModeOfPayment(modeOfPayment),
  PRIMARY KEY (username, modeOfPayment)
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

INSERT INTO Category VALUES ('Dog');
INSERT INTO Category VALUES ('Cat');
INSERT INTO Category VALUES ('Rabbit');
INSERT INTO Category VALUES ('Hamster');
INSERT INTO Category VALUES ('Guinea Pig');
INSERT INTO Category VALUES ('Fish');
INSERT INTO Category VALUES ('Mice');
INSERT INTO Category VALUES ('Terrapin');
INSERT INTO Category VALUES ('Bird');

CREATE TABLE OwnedPets (
    owner VARCHAR references PetOwners(username) ON DELETE CASCADE,
    pet_name VARCHAR NOT NULL UNIQUE,
    category VARCHAR NOT NULL,
    age INTEGER NOT NULL,
    --gender VARCHAR NOT NULL,
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
  PRIMARY KEY (pettype, username, price)
);

CREATE TABLE DefaultPriceList (
  pettype VARCHAR REFERENCES Category(pettype),
  price NUMERIC,
  PRIMARY KEY (pettype, price)
);

INSERT INTO DefaultPriceList VALUES ('Dog', 100);
INSERT INTO DefaultPriceList VALUES ('Cat', 80);
INSERT INTO DefaultPriceList VALUES ('Rabbit', 110);
INSERT INTO DefaultPriceList VALUES ('Hamster', 70);
INSERT INTO DefaultPriceList VALUES ('Guinea Pig', 150);
INSERT INTO DefaultPriceList VALUES ('Fish', 50);
INSERT INTO DefaultPriceList VALUES ('Mice', 50);
INSERT INTO DefaultPriceList VALUES ('Terrapin', 80);
INSERT INTO DefaultPriceList VALUES ('Bird', 80);

CREATE TABLE FullTimePriceList(
  username VARCHAR REFERENCES CareTakers(username) ON DELETE CASCADE,
  price NUMERIC,
  pettype VARCHAR,
  FOREIGN KEY (pettype, price) REFERENCES DefaultPriceList(pettype, price),
  PRIMARY KEY (pettype, username, price)
);

-- THIS TABLE WILL BE USEFUL TO GET SOME OF THE SUMMARY INFORMATION AT POINT 4 OF THE PROJECT REQUIREMENTS.
CREATE TABLE CareTakerSalary (
  year INTEGER,
  month INTEGER,
  username VARCHAR REFERENCES CareTakers(username),
  petdays INTEGER NOT NULL DEFAULT 0,
  earnings NUMERIC NOT NULL DEFAULT 0,
  final_salary NUMERIC NOT NULL DEFAULT 0,
  PRIMARY KEY (year, month, username)
);

-- to obtain statistics for the total number of jobs in each month for the admin
CREATE TABLE TotalJobPerMonthSummary (
  year INTEGER,
  month INTEGER,
  job_count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(year, month)
);

INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2020, 11);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2020, 12);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 1);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 2);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 3);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 4);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 5);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 6);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 7);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 8);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 9);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 10);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 11);
INSERT INTO TotalJobPerMonthSummary(year, month) VALUES (2021, 12);


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

-- trigger that makes use of the function above to update pet count and availbaility
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
BEGIN
  FOR i in 11..12 LOOP
    INSERT INTO CareTakerSalary(year, month, username) VALUES (2020, i, NEW.username);
  END LOOP;
  FOR i in 1..12 LOOP
    INSERT INTO CareTakerSalary(year, month, username) VALUES (2021, i, NEW.username);
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
BEGIN
  --change to 2022-01-01 after finalisation
  WHILE date1 < date('2022-01-01') LOOP
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

-- automates the update of rating in the caretakers table.
CREATE OR REPLACE FUNCTION update_caretaker_rating_after_petowner_give_rating_function() RETURNS trigger AS $$
BEGIN
  UPDATE Caretakers C
    set rating = ROUND((SELECT AVG(B.rating) FROM Bids B WHERE B.CTusername = NEW.CTusername),2)
    WHERE C.username = NEW.CTusername;
  RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS update_caretaker_rating_after_petowner_give_rating_trigger ON Bids;
CREATE TRIGGER update_caretaker_rating_after_petowner_give_rating
  AFTER UPDATE of rating
  ON Bids
  FOR EACH ROW
  EXECUTE PROCEDURE update_caretaker_rating_after_petowner_give_rating_function();

-- trigger to check if the full time can take a leave
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
      IF consecutive = True THEN
        counter := counter + 1;
        date1 := date1 + 150;
        date2 := date2 + 150;
      END IF;
      date1 := date1 + 1;
      date2 := date2 + 1;
    END LOOP;
  END IF;
  IF counter < 2 THEN
    RAISE EXCEPTION 'You cannot take leave on this date';
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
