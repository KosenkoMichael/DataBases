USE session_results;
-- ALL DB
SELECT 
    s.zach_number AS 'Номер зачётки',
    s.fio AS 'Студент',
    s.birth_date AS 'Дата рождения',
    sub.subject_id AS 'ID предмета',
    sub.subject_name AS 'Предмет',
    sub.semester AS 'Семестр',
    t.teacher_id AS 'ID преподавателя', 
    t.fio AS 'Преподаватель',
    g.grade AS 'Оценка'
FROM students s
JOIN grades g ON s.zach_number = g.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id
JOIN teachers t ON sub.teacher_id = t.teacher_id
ORDER BY s.zach_number, sub.semester, sub.subject_name;


-- Вывод всех предметов
SELECT subject_name FROM subjects;


-- Вывод количества студентов
SELECT COUNT(*) as total_students FROM students;


-- Вывод студентов, чья фамилия начинается на «Ива»
SELECT * FROM students WHERE fio LIKE 'Ива%';


-- Вывод студентов, родившихся позже указанной даты
SELECT * FROM students WHERE birth_date > '2001-01-01' ORDER BY birth_date;


-- Вывод студентов, получивших оценки 5 по указанному предмету
SELECT fio 
FROM students
WHERE zach_number IN (
    SELECT student_id 
    FROM grades
    JOIN subjects sub ON grades.subject_id = sub.subject_id
    WHERE grade = 5 AND subject_name = "Информатика"
);


-- Вывод студентов, получивших оценки только 4 и 5 по всем предметам в указанном семестре, упорядочить по фамилии
SELECT s.fio
FROM students s
WHERE s.zach_number NOT IN (
    SELECT DISTINCT g.student_id
    FROM grades g
    JOIN subjects sub ON g.subject_id = sub.subject_id
    WHERE g.grade < 4 AND sub.semester = 2
)
ORDER BY s.fio;