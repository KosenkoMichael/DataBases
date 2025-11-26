USE bike_rental;

INSERT INTO models (model_title) VALUES 
('Горный велосипед'),
('Городской велосипед'),
('Шоссейный велосипед'),
('Складной велосипед');

INSERT INTO rental_points (point_title, lat, lon, notes) VALUES 
('Центральный парк', 55.755826, 37.617300, '{"work_hours": "09:00-22:00", "capacity": 50}'),
('Вокзальная площадь', 55.728953, 37.655497, '{"work_hours": "08:00-23:00", "capacity": 30}'),
('Набережная реки', 55.747938, 37.621655, '{"work_hours": "10:00-20:00", "capacity": 20}'),
('Отдалённая станция', 55.8, 61, '{"work_hours": "09:00-21:00", "capacity": 10}'),
('Парк Гагарина', 55.700000, 37.600000, '{"work_hours": "08:00-22:00", "capacity": 40, "features": "Прокат электровелосипедов"}'),
('Соседняя площадь', 90.000000, 180.000000, '{"work_hours": "09:00-21:00", "capacity": 25, "description": "район"}');

INSERT INTO customers (passport, first_name, last_name, phone) VALUES 
('4501123456', 'Иван', 'Петров', '+79161234567'),
('4510987654', 'Мария', 'Сидорова', '+79167654321'),
('4520567890', 'Алексей', 'Козлов', '+79169998877');

INSERT INTO bicycles (serial_number, model_id) VALUES 
('MTB0012024', 1),
('CITY0022024', 2),
('ROAD0032024', 3),
('FOLD0042024', 4),
('MTB0052024', 1);

INSERT INTO rental (bicycle_id, customer_id, pick_point_id, return_point_id, start_time, end_time) VALUES 
(1, 1, 1, 1, '2024-01-15 10:00:00', '2024-01-15 14:30:00'),
(2, 2, 2, 3, '2024-01-15 11:00:00', '2024-01-15 15:30:00'),
(2, 2, 2, 3, '2024-01-15 5:00:00', '2024-01-15 11:40:00'),
(3, 3, 1, NULL, '2024-01-16 09:30:00', NULL);

#UPDATE models SET model_title = 'Горный велосипед PRO' WHERE model_id = 1;

#UPDATE customers SET phone = '+79161112233' WHERE customer_id = 1;

#UPDATE rental_points SET lat = 55.750000, lon = 37.620000 WHERE point_id = 1;

#UPDATE rental SET end_time = '2024-01-16 11:00:00', return_point_id = 2 WHERE rental_id = 3;

#DELETE FROM rental WHERE rental_id = 3;

#DELETE FROM bicycles WHERE bicycle_id = 5;

#DELETE FROM customers WHERE customer_id = 3;

#DELETE FROM rental WHERE rental_id > 0;

#DELETE FROM bicycles WHERE bicycle_id > 0;