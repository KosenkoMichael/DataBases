CREATE DATABASE IF NOT EXISTS session_results;
USE session_results;

CREATE TABLE students (
    zach_number INT PRIMARY KEY,
    fio VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    fio VARCHAR(255) NOT NULL
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(255) NOT NULL,
    semester INT NOT NULL,
    teacher_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

CREATE TABLE grades (
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    grade INT NOT NULL,
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES students(zach_number),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);