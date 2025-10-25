DELIMITER //

CREATE FUNCTION concat_fields(field1 VARCHAR(255), field2 VARCHAR(255))
RETURNS VARCHAR(511)
DETERMINISTIC
BEGIN
    RETURN CONCAT(field1, ' ', field2);
END;
//

DELIMITER ;

DELIMITER //

CREATE FUNCTION arithmetic_operation(start_time DATETIME, end_time DATETIME)
RETURNS DECIMAL
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(HOUR, start_time, end_time);
END;
//

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE aggregated_with_cursor()
BEGIN
    DECLARE rental_time INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE min_time INT DEFAULT NULL;
    DECLARE max_time INT DEFAULT NULL;
    DECLARE sum_time INT DEFAULT 0;
    DECLARE count_time INT DEFAULT 0;
    DECLARE avg_time DECIMAL(10,2);

    DECLARE cur_rentals CURSOR FOR 
        SELECT TIMESTAMPDIFF(second, start_time, end_time)
        FROM rental
        WHERE end_time IS NOT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_rentals;

    read_loop: LOOP
        FETCH cur_rentals INTO rental_time;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF min_time IS NULL OR rental_time < min_time THEN
            SET min_time = rental_time;
        END IF;

        IF max_time IS NULL OR rental_time > max_time THEN
            SET max_time = rental_time;
        END IF;

        SET sum_time = sum_time + rental_time;
        SET count_time = count_time + 1;
    END LOOP;

    CLOSE cur_rentals;

    IF count_time > 0 THEN
        SET avg_time = sum_time / count_time;
    ELSE
        SET avg_time = NULL;
    END IF;

    SELECT min_time AS min, max_time AS max, avg_time AS avg;
END $$

DELIMITER ;

CALL aggregated_with_cursor();
