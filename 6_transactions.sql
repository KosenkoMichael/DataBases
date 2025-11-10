# 1

DELIMITER $$
CREATE PROCEDURE add_rental(
    IN p_passport VARCHAR(20),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_serial_number VARCHAR(50),
    IN p_model_id INT,
    IN p_pick_point_id INT,
    IN p_start_time DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Ошибка! Все изменения откатились.' AS message;
    END;

    START TRANSACTION;

    INSERT INTO customers(passport, first_name, last_name, phone)
    VALUES(p_passport, p_first_name, p_last_name, p_phone);

    SET @customer_id = LAST_INSERT_ID();

    INSERT INTO bicycles(serial_number, model_id)
    VALUES(p_serial_number, p_model_id);

    SET @bicycle_id = LAST_INSERT_ID();

    INSERT INTO rental(bicycle_id, customer_id, pick_point_id, start_time)
    VALUES(@bicycle_id, @customer_id, p_pick_point_id, p_start_time);

    COMMIT;

    SELECT 'Данные успешно добавлены!' AS message;
END$$
DELIMITER ;

CALL add_rental(
    'AB1234567',           -- паспорт
    'John',                -- имя
    'Doe',                 -- фамилия
    '+1234567890',         -- телефон
    'SN-1001',             -- серийный номер велосипеда
    1,                     -- model_id
    1,                     -- pick_point_id
    NOW()                  -- start_time
);

# 2

DELIMITER $$
CREATE PROCEDURE add_bicycles_with_limit(
    IN p_model_id INT
)
BEGIN
    DECLARE v_serial VARCHAR(50);
    DECLARE v_counter INT DEFAULT 1;
    DECLARE v_total INT;

    START TRANSACTION;
    
    WHILE v_counter <= 10 DO

        SET v_serial = CONCAT('SN-', p_model_id, '-', v_counter);

        SAVEPOINT before_insert;

        INSERT INTO bicycles(serial_number, model_id)
        VALUES(v_serial, p_model_id);

        SELECT COUNT(*) INTO v_total
        FROM bicycles
        WHERE model_id = p_model_id;

        IF v_total > 5 THEN
            ROLLBACK TO SAVEPOINT before_insert;
            SELECT CONCAT('Вставка велосипеда ', v_serial, ' отменена, превышен лимит') AS message;
        ELSE
            SELECT CONCAT('Вставка велосипеда ', v_serial, ' выполнена') AS message;
        END IF;

        SET v_counter = v_counter + 1;
    END WHILE;

    COMMIT;
END$$
DELIMITER ;

CALL add_bicycles_with_limit(1);

# 3

INSERT INTO bicycles(serial_number, model_id) VALUES('TEST', 1);
SHOW TABLE STATUS LIKE 'bicycles';

# дёрти дёрти 

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE bicycles
SET model_id = 2
WHERE serial_number='TEST';

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT serial_number, model_id
FROM bicycles
WHERE serial_number='TEST';

# read commited

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE bicycles
SET model_id = 3
WHERE serial_number='TEST';

COMMIT;

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT serial_number, model_id
FROM bicycles
WHERE serial_number='TEST';

# 4 

INSERT INTO bicycles(serial_number, model_id) VALUES('TEST4', 1);

# READ COMMITTED

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT serial_number, model_id
FROM bicycles
WHERE serial_number='TEST4';

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE bicycles
SET model_id = 2
WHERE serial_number='TEST4';
COMMIT;

SELECT serial_number, model_id
FROM bicycles
WHERE serial_number='TEST4';

# REPEATABLE READ

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT serial_number, model_id
FROM bicycles
WHERE serial_number='TEST4';

SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
UPDATE bicycles
SET model_id = 3
WHERE serial_number='TEST4';

UPDATE bicycles
SET model_id = 4
WHERE serial_number='TEST4';
COMMIT;