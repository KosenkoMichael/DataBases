CREATE DATABASE IF NOT EXISTS bike_rental;
USE bike_rental;

CREATE TABLE IF NOT EXISTS models (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_title VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS rental_points (
    point_id INT AUTO_INCREMENT PRIMARY KEY,
    point_title VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lon DECIMAL(11, 8) NOT NULL,
    notes JSON
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    passport VARCHAR(20) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS bicycles (
    bicycle_id INT AUTO_INCREMENT PRIMARY KEY,
    serial_number VARCHAR(50) NOT NULL,
    model_id INT NOT NULL,
    FOREIGN KEY (model_id) REFERENCES models(model_id)
);

CREATE TABLE IF NOT EXISTS rental (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    bicycle_id INT NOT NULL,
    customer_id INT NOT NULL,
    pick_point_id INT NOT NULL,
    return_point_id INT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NULL,
    FOREIGN KEY (bicycle_id) REFERENCES bicycles(bicycle_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (pick_point_id) REFERENCES rental_points(point_id),
    FOREIGN KEY (return_point_id) REFERENCES rental_points(point_id)
);