\COPY users FROM 'generate_mock/combine_users.csv' WITH DELIMITER ',' CSV HEADER;

\COPY pcsadmin FROM 'generate_mock/admin_mock.csv' WITH DELIMITER ',' CSV HEADER;

\COPY petowners FROM 'generate_mock/combine_po.csv' WITH DELIMITER ',' CSV HEADER;

\COPY caretakers FROM 'generate_mock/combine_ct.csv' WITH DELIMITER ',' CSV HEADER;

\COPY modeoftransport FROM 'generate_mock/transport_mode.csv' WITH DELIMITER ',' CSV HEADER;

\COPY preferredtransport FROM 'generate_mock/preferred_transport_mock.csv' WITH DELIMITER ',' CSV HEADER;

\COPY modeofpayment FROM 'generate_mock/payment_mode.csv' WITH DELIMITER ',' CSV HEADER;

\COPY preferredmodeofpayment FROM 'generate_mock/preferred_payment_mock.csv' WITH DELIMITER ',' CSV HEADER;

\COPY fulltime FROM 'generate_mock/full_time_mock.csv' WITH DELIMITER ',' CSV HEADER;

\COPY parttime FROM 'generate_mock/part_time_mock.csv' WITH DELIMITER ',' CSV HEADER;

\COPY category FROM 'generate_mock/pet_category.csv' WITH DELIMITER ',' CSV HEADER;

\COPY ownedpets FROM 'generate_mock/pet_owned.csv' WITH DELIMITER ',' CSV HEADER;

\COPY specialcare FROM 'generate_mock/special_care.csv' WITH DELIMITER ',' CSV HEADER;

\COPY requirespecialcare FROM 'generate_mock/require_special_care.csv' WITH DELIMITER ',' CSV HEADER;

\COPY caretakeravailability FROM 'generate_mock/availability.csv' WITH DELIMITER ',' CSV HEADER;

\COPY bids FROM 'generate_mock/bids.csv' WITH DELIMITER ',' CSV HEADER;

\COPY parttimepricelist FROM 'generate_mock/part_time_price.csv' WITH DELIMITER ',' CSV HEADER;

\COPY defaultpricelist FROM 'generate_mock/default_price.csv' WITH DELIMITER ',' CSV HEADER;

\COPY fulltimepricelist FROM 'generate_mock/full_time_price.csv' WITH DELIMITER ',' CSV HEADER;

\COPY caretakersalary FROM 'generate_mock/salary.csv' WITH DELIMITER ',' CSV HEADER;

\COPY totaljobpermonthsummary FROM 'generate_mock/job_summary.csv' WITH DELIMITER ',' CSV HEADER;



/**


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

\COPY bids FROM 'mock_data/bid.csv' WITH DELIMITER ',' CSV HEADER;

**/










-- ANYTHING FROM HERE ONWARDS IS JUST FOR ME TO DEBUG










-- INSERT INTO CareTakerSalary VALUES (2020, 6, 'ckitleeg', 0, 0, 0);

-- INSERT INTO bids VALUES (1, 'ckitleeg', 'astather2', 'Common wolf', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);

-- INSERT INTO CareTakerSalary VALUES (2020, 6, 'gkingmann', 0, 0, 0);

-- INSERT INTO bids VALUES (1, 'gkingmann', 'astather2', 'Common wolf', NULL, NULL, 'Care Taker Pick Up', 'Credit card', '52521', FALSE, '6/25/2020', '6/27/2020', 100);





/**
CREATE OR REPLACE FUNCTION
update_salary() RETURNS trigger AS $$
DECLARE end_of_month date := (SELECT(date_trunc('month', NEW.start_date::date) + interval '1 month' - interval '1 day')::date);
DECLARE start_of_end_date_month date;
BEGIN
IF NEW.end_date > end_of_month THEN
start_of_end_date_month := (SELECT date_trunc('MONTH', NEW.end_date)::DATE);

UPDATE CareTakerSalary 
SET earnings = earnings + ((NEW.end_date - start_of_end_date_month + 1) * NEW.price), petdays = petdays + (NEW.end_date - start_of_end_date_month + 1)
WHERE
username = NEW.ct_username AND 
year = (SELECT date_part('year', start_of_end_date_month)) AND
month = (SELECT date_part('month', start_of_end_date_month));

NEW.end_date := end_of_month;
END IF;
UPDATE CareTakerSalary 
SET earnings = earnings + ((NEW.end_date - NEW.start_date + 1) * NEW.price), petdays = petdays + (NEW.end_date - NEW.start_date + 1)
WHERE
username = NEW.ct_username AND 
year = (SELECT date_part('year', NEW.start_date)) AND
month = (SELECT date_part('month', NEW.start_date)); 
RETURN NEW;
END;
$$
LANGUAGE plpgsql;
**/

/**

INSERT INTO caretakeravailability VALUES ('6/30/2020', 0, False, 'ckitleeg', TRUE);
INSERT INTO caretakeravailability VALUES ('7/01/2020', 0, False, 'ckitleeg', TRUE);
INSERT INTO caretakeravailability VALUES ('7/02/2020', 0, False, 'ckitleeg', TRUE);
INSERT INTO caretakeravailability VALUES ('7/03/2020', 0, False, 'ckitleeg', TRUE);
INSERT INTO caretakeravailability VALUES ('7/04/2020', 0, False, 'ckitleeg', TRUE);
INSERT INTO caretakeravailability VALUES ('7/05/2020', 0, False, 'ckitleeg', TRUE);

INSERT INTO caretakeravailability VALUES ('6/30/2020', 0, False, 'gkingmann', TRUE);
INSERT INTO caretakeravailability VALUES ('7/01/2020', 0, False, 'gkingmann', TRUE);
INSERT INTO caretakeravailability VALUES ('7/02/2020', 0, False, 'gkingmann', TRUE);
INSERT INTO caretakeravailability VALUES ('7/03/2020', 0, False, 'gkingmann', TRUE);
INSERT INTO caretakeravailability VALUES ('7/04/2020', 0, False, 'gkingmann', TRUE);
INSERT INTO caretakeravailability VALUES ('7/05/2020', 0, False, 'gkingmann', TRUE);

**/
