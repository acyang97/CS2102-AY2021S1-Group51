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



DROP TRIGGER IF EXISTS insert_into_dummy1_trigger ON dummy2;
CREATE TRIGGER insert_into_dummy1_trigger
  AFTER INSERT
  ON dummy2
  EXECUTE PROCEDURE insert_into_dummy1_function();



SELECT pettype, ROUND(AVG(price), 2) AS avg_price, COUNT(*) AS numberr
FROM (SELECT price, pettype FROM fulltimepricelist
UNION
SELECT  price, pettype
FROM PARTTIMEPRICELIST) AS dummy
GROUP BY dummy.pettype;
