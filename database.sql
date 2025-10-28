-- ======================================
-- 1. 创建并使用新的 schema
-- ======================================
CREATE DATABASE IF NOT EXISTS lms_system;
USE lms_system;

-- ======================================
-- 2. 删除旧表（防止外键冲突）
-- ======================================
DROP TABLE IF EXISTS 
    REALTIME_LOGS, BADGES, POINTS, QUIZZES, QUESTIONS, ATTENDANCE, 
    COURSE_SCHEDULE, COURSES, TEACHERS, STUDENTS, CLASSES;

-- ======================================
-- 3. 创建表结构
-- ======================================

-- CLASSES 表（新增）
CREATE TABLE CLASSES (
    class_id CHAR(10) PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL,
    department VARCHAR(100)
);

-- STUDENTS 表（修改：将 class 拆为 class_id 外键）
CREATE TABLE STUDENTS (
    student_id CHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    class_id CHAR(10),
    FOREIGN KEY (class_id) REFERENCES CLASSES(class_id)
);

-- TEACHERS 表
CREATE TABLE TEACHERS (
    teacher_id CHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    department VARCHAR(100)
);

-- COURSES 表（移除 schedule）
CREATE TABLE COURSES (
    course_id CHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    teacher_id CHAR(10),
    FOREIGN KEY (teacher_id) REFERENCES TEACHERS(teacher_id)
);

-- COURSE_SCHEDULE 表（新增：独立管理上课时间）
CREATE TABLE COURSE_SCHEDULE (
    schedule_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id CHAR(10),
    day_of_week ENUM('Mon','Tue','Wed','Thu','Fri','Sat','Sun'),
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (course_id) REFERENCES COURSES(course_id)
);

-- QUESTIONS 表
CREATE TABLE QUESTIONS (
    question_id CHAR(10) PRIMARY KEY,
    course_id CHAR(10),
    content TEXT NOT NULL,
    type ENUM('single','multiple','true_false','essay') DEFAULT 'single',
    correct_answer VARCHAR(255),
    points SMALLINT DEFAULT 1,
    FOREIGN KEY (course_id) REFERENCES COURSES(course_id)
);

-- QUIZZES 表
CREATE TABLE QUIZZES (
    quiz_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id CHAR(10),
    student_id CHAR(10),
    question_id CHAR(10),
    student_answer VARCHAR(255),
    score SMALLINT,
    submission_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    time_spent SMALLINT,
    FOREIGN KEY (course_id) REFERENCES COURSES(course_id),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (question_id) REFERENCES QUESTIONS(question_id)
);

-- ATTENDANCE 表
CREATE TABLE ATTENDANCE (
    attendance_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id CHAR(10),
    course_id CHAR(10),
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('present','absent','late','excused') DEFAULT 'present',
    method ENUM('manual','qr','rfid','online') DEFAULT 'manual',
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (course_id) REFERENCES COURSES(course_id)
);

-- POINTS 表
CREATE TABLE POINTS (
    points_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id CHAR(10),
    total_points INT DEFAULT 0,
    level ENUM('bronze','silver','gold','platinum') DEFAULT 'bronze',
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id)
);

-- BADGES 表
CREATE TABLE BADGES (
    badge_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id CHAR(10),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    awarded_date DATE,
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id)
);

-- REALTIME_LOGS 表
CREATE TABLE REALTIME_LOGS (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id CHAR(10),
    course_id CHAR(10),
    activity_type VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (course_id) REFERENCES COURSES(course_id)
);
