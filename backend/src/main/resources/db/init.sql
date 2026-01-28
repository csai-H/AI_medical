-- ================================================
-- AI Medical Platform - Complete Database Initialization Script
-- Version: 2.0.0 (Security Enhanced)
-- Last Updated: 2025-01-28
-- ================================================
--
-- This script includes:
-- 1. Database creation
-- 2. All table structures (User, Patient, Diagnosis, Knowledge, RBAC)
-- 3. Initial data with BCrypt encrypted passwords
-- 4. Complete RBAC permission system
-- 5. Test accounts with strong passwords
--
-- Usage: mysql -u root -p < init.sql
-- ================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS ai_medical DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ai_medical;

SET FOREIGN_KEY_CHECKS = 0;

-- ================================================
-- CORE TABLES
-- ================================================

-- User Table
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    real_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    role INT DEFAULT 2 COMMENT '0: Admin, 1: Doctor, 2: User',
    status INT DEFAULT 1 COMMENT '0: Disabled, 1: Enabled',
    dept_id BIGINT,
    title VARCHAR(50),
    specialty VARCHAR(200),
    avatar VARCHAR(500),
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_real_name (real_name),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- Patient Table
DROP TABLE IF EXISTS patient;
CREATE TABLE patient (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_no VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    gender INT COMMENT '0: Female, 1: Male',
    age INT,
    birthday DATE,
    phone VARCHAR(20),
    id_card VARCHAR(18),
    address VARCHAR(500),
    allergy_history TEXT,
    past_history TEXT,
    family_history TEXT,
    remark TEXT,
    create_by BIGINT,
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_patient_no (patient_no),
    INDEX idx_name (name),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者表';

-- Diagnosis Record Table
DROP TABLE IF EXISTS diagnosis_record;
CREATE TABLE diagnosis_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    record_no VARCHAR(50) UNIQUE NOT NULL,
    patient_id BIGINT NOT NULL,
    patient_name VARCHAR(50),
    doctor_id BIGINT,
    doctor_name VARCHAR(50),
    chief_complaint TEXT,
    present_illness TEXT,
    symptoms TEXT,
    ai_diagnosis TEXT,
    ai_suggestion TEXT,
    doctor_diagnosis TEXT,
    treatment_plan TEXT,
    prescription TEXT,
    diagnosis_type INT DEFAULT 0 COMMENT '0: AI, 1: Manual',
    match_rate DECIMAL(5,2),
    status INT DEFAULT 0 COMMENT '0: Pending, 1: Confirmed, 2: Completed',
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_record_no (record_no),
    INDEX idx_patient_id (patient_id),
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_status (status),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='诊断记录表';

-- Medical Knowledge Table
DROP TABLE IF EXISTS medical_knowledge;
CREATE TABLE medical_knowledge (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    disease_name VARCHAR(100),
    category VARCHAR(100),
    symptoms TEXT,
    etiology TEXT,
    diagnosis_methods TEXT,
    treatment TEXT,
    medication_advice TEXT,
    prevention TEXT,
    precautions TEXT,
    `references` TEXT,
    tags VARCHAR(500),
    source INT DEFAULT 0 COMMENT '0: System, 1: Manual',
    audit_status INT DEFAULT 0 COMMENT '0: Pending, 1: Approved',
    auditor_id BIGINT,
    audit_time DATETIME,
    create_by BIGINT,
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_disease_name (disease_name),
    INDEX idx_category (category),
    INDEX idx_tags (tags),
    INDEX idx_audit_status (audit_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医疗知识库表';

-- ================================================
-- RBAC PERMISSION TABLES
-- ================================================

-- Permission Table
DROP TABLE IF EXISTS sys_permission;
CREATE TABLE sys_permission (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '权限ID',
    permission_code VARCHAR(50) NOT NULL UNIQUE COMMENT '权限编码',
    permission_name VARCHAR(100) NOT NULL COMMENT '权限名称',
    resource_type VARCHAR(20) NOT NULL COMMENT '资源类型: menu/button/api',
    url VARCHAR(200) COMMENT 'API路径',
    method VARCHAR(10) COMMENT '请求方法: GET/POST/PUT/DELETE',
    parent_id BIGINT DEFAULT 0 COMMENT '父权限ID',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status INT DEFAULT 1 COMMENT '状态: 0-禁用, 1-启用',
    description VARCHAR(500) COMMENT '权限描述',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_permission_code (permission_code),
    INDEX idx_resource_type (resource_type),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限表';

-- Role Permission Relation Table
DROP TABLE IF EXISTS sys_role_permission;
CREATE TABLE sys_role_permission (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    permission_id BIGINT NOT NULL COMMENT '权限ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限关联表';

-- Audit Log Table
DROP TABLE IF EXISTS sys_audit_log;
CREATE TABLE sys_audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    user_id BIGINT COMMENT '操作用户ID',
    username VARCHAR(50) COMMENT '操作用户名',
    module VARCHAR(50) COMMENT '操作模块',
    operation VARCHAR(100) COMMENT '操作类型',
    method VARCHAR(200) COMMENT '操作方法',
    params TEXT COMMENT '请求参数',
    ip VARCHAR(50) COMMENT 'IP地址',
    status INT DEFAULT 1 COMMENT '操作状态: 0-失败, 1-成功',
    error_msg VARCHAR(500) COMMENT '错误信息',
    execute_time BIGINT COMMENT '执行时长(毫秒)',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    INDEX idx_user_id (user_id),
    INDEX idx_module (module),
    INDEX idx_operation (operation),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审计日志表';

-- ================================================
-- INITIAL DATA
-- ================================================

-- Insert Users with BCrypt encrypted passwords
-- Passwords: Admin@2024, Doctor@2024, User@2024
INSERT INTO sys_user (username, password, real_name, role, status, title, specialty) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'System Administrator', 0, 1, 'System Admin', 'System Management'),
('doctor', '$2a$10$U0W8z9pKJN9qcVBQfpTZXOH8qNv5Q2mPXB5JqZFWNtLGZ8kRqVQ8u', 'Dr. Zhang', 1, 1, 'Attending Physician', 'Internal Medicine, Respiratory Medicine'),
('user', '$2a$10$rVZvQHpKrZVGYVyHKQWwSeORqnHVyVNhQGfFQ4JfPyLGf0lP8aXWu', 'Regular User', 2, 1, NULL, NULL);

-- Insert Test Patients
INSERT INTO patient (patient_no, name, gender, age, birthday, phone, address) VALUES
('P20241201001', 'Zhang San', 1, 35, '1989-05-15', '13800138001', 'Beijing Chaoyang District'),
('P20241201002', 'Li Si', 0, 28, '1996-08-20', '13800138002', 'Beijing Haidian District'),
('P20241201003', 'Wang Wu', 1, 42, '1982-03-10', '13800138003', 'Beijing Xicheng District');

-- Insert Test Medical Knowledge
INSERT INTO medical_knowledge (title, disease_name, category, symptoms, etiology, diagnosis_methods, treatment, medication_advice, precautions, source, audit_status) VALUES
('Acute Upper Respiratory Infection', 'Acute Upper Respiratory Infection', 'Respiratory System', 'Nasal congestion, runny nose, cough, fever, headache, malaise', 'Mainly viral infection, some bacterial infections', 'Blood routine, chest X-ray', 'Rest, drink plenty of water, symptomatic treatment', 'Antipyretics, antihistamines, decongestants', 'Avoid cold, rest, drink plenty of water', 0, 1),
('Acute Gastritis', 'Acute Gastritis', 'Digestive System', 'Epigastric pain, nausea, vomiting, loss of appetite', 'Improper diet, drug irritation, stress response', 'Gastroscopy, blood routine', 'Fasting, fluid replacement, symptomatic treatment', 'Acid suppressants, gastric mucosal protectants', 'Regular diet, avoid irritating food', 0, 1);

-- ================================================
-- RBAC PERMISSION DATA
-- ================================================

-- User Management Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, url, method, parent_id, sort_order, description) VALUES
('user:list', '用户列表', 'api', '/user/list', 'GET', 0, 1, '查看用户列表'),
('user:create', '创建用户', 'api', '/user/create', 'POST', 0, 2, '创建新用户'),
('user:update', '更新用户', 'api', '/user/update', 'PUT', 0, 3, '更新用户信息'),
('user:delete', '删除用户', 'api', '/user/delete', 'DELETE', 0, 4, '删除用户'),
('user:reset-password', '重置密码', 'api', '/user/reset-password', 'POST', 0, 5, '重置用户密码'),
('user:change-password', '修改密码', 'api', '/user/change-password', 'POST', 0, 6, '修改自己的密码'),
('user:status', '用户状态', 'api', '/user/status', 'PUT', 0, 7, '启用/禁用用户');

-- Patient Management Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, url, method, parent_id, sort_order, description) VALUES
('patient:list', '患者列表', 'api', '/patient/list', 'GET', 0, 11, '查看患者列表'),
('patient:create', '创建患者', 'api', '/patient/create', 'POST', 0, 12, '创建新患者'),
('patient:update', '更新患者', 'api', '/patient/update', 'PUT', 0, 13, '更新患者信息'),
('patient:delete', '删除患者', 'api', '/patient/delete', 'DELETE', 0, 14, '删除患者'),
('patient:detail', '患者详情', 'api', '/patient/detail', 'GET', 0, 15, '查看患者详情');

-- Diagnosis Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, url, method, parent_id, sort_order, description) VALUES
('diagnosis:ai', 'AI问诊', 'api', '/diagnosis/ai', 'POST', 0, 21, 'AI智能问诊'),
('diagnosis:record', '诊断记录', 'api', '/diagnosis/record', 'GET', 0, 22, '查看诊断记录'),
('diagnosis:detail', '诊断详情', 'api', '/diagnosis/detail', 'GET', 0, 23, '查看诊断详情');

-- System Management Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, url, method, parent_id, sort_order, description) VALUES
('system:config', '系统配置', 'api', '/system/config', 'GET', 0, 31, '查看系统配置'),
('system:log', '系统日志', 'api', '/system/log', 'GET', 0, 32, '查看系统日志'),
('system:user', '用户管理', 'menu', '/user-management', NULL, 0, 33, '用户管理菜单');

-- ================================================
-- ROLE PERMISSION ASSIGNMENTS
-- ================================================

-- Admin Role (role=0) - All Permissions
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 0, id FROM sys_permission;

-- Doctor Role (role=1) - Patient and Diagnosis Permissions
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission 
WHERE permission_code IN (
    'patient:list', 'patient:create', 'patient:update', 'patient:detail',
    'diagnosis:ai', 'diagnosis:record', 'diagnosis:detail',
    'user:change-password'
);

-- User Role (role=2) - Diagnosis and Password Change Only
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 2, id FROM sys_permission 
WHERE permission_code IN (
    'diagnosis:ai', 'diagnosis:record', 'diagnosis:detail',
    'user:change-password'
);

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================
-- VERIFICATION QUERIES
-- ================================================

-- Display all users
SELECT 'Users:' as info;
SELECT id, username, LEFT(password, 30) as password_hash, real_name, 
       CASE role WHEN 0 THEN 'Admin' WHEN 1 THEN 'Doctor' ELSE 'User' END as role,
       CASE status WHEN 0 THEN 'Disabled' ELSE 'Enabled' END as status
FROM sys_user;

-- Display all permissions
SELECT 'Permissions:' as info;
SELECT id, permission_code, permission_name, resource_type
FROM sys_permission
ORDER BY sort_order;

-- Display role permissions count
SELECT 'Role Permissions Count:' as info;
SELECT 
    role_id,
    CASE role_id
        WHEN 0 THEN 'Admin'
        WHEN 1 THEN 'Doctor'
        WHEN 2 THEN 'User'
    END as role_name,
    COUNT(*) as permission_count
FROM sys_role_permission
GROUP BY role_id
ORDER BY role_id;

-- ================================================
-- COMPLETION MESSAGE
-- ================================================

SELECT '========================================' as '';
SELECT 'Database Initialization Complete!' as '';
SELECT 'Version: 2.0.0 (Security Enhanced)' as '';
SELECT 'Test Accounts:' as '';
SELECT '  Admin:   admin / Admin@2024' as '';
SELECT '  Doctor:  doctor / Doctor@2024' as '';
SELECT '  User:    user / User@2024' as '';
SELECT '========================================' as '';
CREATE DATABASE IF NOT EXISTS ai_medical DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ai_medical;

SET FOREIGN_KEY_CHECKS = 0;

-- User Table
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    real_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    role INT DEFAULT 2 COMMENT '0: Admin, 1: Doctor, 2: User',
    status INT DEFAULT 1 COMMENT '0: Disabled, 1: Enabled',
    dept_id BIGINT,
    title VARCHAR(50),
    specialty VARCHAR(200),
    avatar VARCHAR(500),
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_real_name (real_name),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Patient Table
DROP TABLE IF EXISTS patient;
CREATE TABLE patient (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_no VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    gender INT COMMENT '0: Female, 1: Male',
    age INT,
    birthday DATE,
    phone VARCHAR(20),
    id_card VARCHAR(18),
    address VARCHAR(500),
    allergy_history TEXT,
    past_history TEXT,
    family_history TEXT,
    remark TEXT,
    create_by BIGINT,
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_patient_no (patient_no),
    INDEX idx_name (name),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Diagnosis Record Table
DROP TABLE IF EXISTS diagnosis_record;
CREATE TABLE diagnosis_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    record_no VARCHAR(50) UNIQUE NOT NULL,
    patient_id BIGINT NOT NULL,
    patient_name VARCHAR(50),
    doctor_id BIGINT,
    doctor_name VARCHAR(50),
    chief_complaint TEXT,
    present_illness TEXT,
    symptoms TEXT,
    ai_diagnosis TEXT,
    ai_suggestion TEXT,
    doctor_diagnosis TEXT,
    treatment_plan TEXT,
    prescription TEXT,
    diagnosis_type INT DEFAULT 0 COMMENT '0: AI, 1: Manual',
    match_rate DECIMAL(5,2),
    status INT DEFAULT 0 COMMENT '0: Pending, 1: Confirmed, 2: Completed',
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_record_no (record_no),
    INDEX idx_patient_id (patient_id),
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_status (status),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Medical Knowledge Table
DROP TABLE IF EXISTS medical_knowledge;
CREATE TABLE medical_knowledge (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    disease_name VARCHAR(100),
    category VARCHAR(100),
    symptoms TEXT,
    etiology TEXT,
    diagnosis_methods TEXT,
    treatment TEXT,
    medication_advice TEXT,
    prevention TEXT,
    precautions TEXT,
    `references` TEXT,
    tags VARCHAR(500),
    source INT DEFAULT 0 COMMENT '0: System, 1: Manual',
    audit_status INT DEFAULT 0 COMMENT '0: Pending, 1: Approved',
    auditor_id BIGINT,
    audit_time DATETIME,
    create_by BIGINT,
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_disease_name (disease_name),
    INDEX idx_category (category),
    INDEX idx_tags (tags),
    INDEX idx_audit_status (audit_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Default Admin (password: admin123)
INSERT INTO sys_user (username, password, real_name, role, status)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'System Admin', 0, 1);

-- Insert Test Doctor (password: doctor123)
INSERT INTO sys_user (username, password, real_name, role, status, title, specialty)
VALUES ('doctor', '$2a$10$VBIlJ5oZi3vRH3Pj4GyGXePJHlS4Cq0VHEQf2vZXA7LqP8ZxZzZ5m', 'Dr. Zhang', 1, 1, 'Attending Physician', 'Internal Medicine, Respiratory Medicine');

-- Insert Test Patients
INSERT INTO patient (patient_no, name, gender, age, birthday, phone, address) VALUES
('P20241201001', 'Zhang San', 1, 35, '1989-05-15', '13800138001', 'Beijing Chaoyang District'),
('P20241201002', 'Li Si', 0, 28, '1996-08-20', '13800138002', 'Beijing Haidian District'),
('P20241201003', 'Wang Wu', 1, 42, '1982-03-10', '13800138003', 'Beijing Xicheng District');

-- Insert Test Medical Knowledge
INSERT INTO medical_knowledge (title, disease_name, category, symptoms, etiology, diagnosis_methods, treatment, medication_advice, precautions, source, audit_status) VALUES
('Acute Upper Respiratory Infection', 'Acute Upper Respiratory Infection', 'Respiratory System', 'Nasal congestion, runny nose, cough, fever, headache, malaise', 'Mainly viral infection, some bacterial infections', 'Blood routine, chest X-ray', 'Rest, drink plenty of water, symptomatic treatment', 'Antipyretics, antihistamines, decongestants', 'Avoid cold, rest, drink plenty of water', 0, 1),
('Acute Gastritis', 'Acute Gastritis', 'Digestive System', 'Epigastric pain, nausea, vomiting, loss of appetite', 'Improper diet, drug irritation, stress response', 'Gastroscopy, blood routine', 'Fasting, fluid replacement, symptomatic treatment', 'Acid suppressants, gastric mucosal protectants', 'Regular diet, avoid irritating food', 0, 1);

SET FOREIGN_KEY_CHECKS = 1;
