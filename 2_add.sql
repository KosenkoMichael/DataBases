USE session_results;
INSERT INTO teachers (fio) VALUES 
('Смирнов Алексей Дмитриевич'),
('Петров Михаил Владимирович');

INSERT INTO students (zach_number, fio, birth_date) VALUES 
(12345, 'Иванова Анна Сергеевна', '2000-05-15'),
(67890, 'Козлова Екатерина Игоревна', '2001-03-22');

INSERT INTO subjects (subject_name, semester, teacher_id) VALUES 
('Математика', 1, 1),
('Программирование', 2, 2);

INSERT INTO grades (student_id, subject_id, grade) VALUES 
(12345, 1, 5),
(12345, 2, 4),
(67890, 1, 4),
(67890, 2, 5);