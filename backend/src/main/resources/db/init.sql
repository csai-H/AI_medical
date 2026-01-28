-- ================================================
-- AI Medical Platform - Complete Database Initialization Script
-- Version: 2.1.0 (Complete RBAC System)
-- Last Updated: 2025-01-28
-- ================================================
--
-- This script includes:
-- 1. Database creation
-- 2. All table structures (User, Patient, Diagnosis, Knowledge, RBAC)
-- 3. Complete RBAC v2 system (Role-based access control)
-- 4. Initial data with BCrypt encrypted passwords
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
    deleted INT DEFAULT 0 COMMENT '逻辑删除',
    menu_type VARCHAR(20) COMMENT '菜单类型: directory/menu/button',
    visible INT DEFAULT 1 COMMENT '是否可见: 0-隐藏, 1-显示',
    icon VARCHAR(100) COMMENT '菜单图标',
    component VARCHAR(200) COMMENT '前端组件路径',
    path VARCHAR(200) COMMENT '路由路径',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_permission_code (permission_code),
    INDEX idx_resource_type (resource_type),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限表';

-- Role Table
DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '角色ID',
    role_code VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    role_name VARCHAR(100) NOT NULL COMMENT '角色名称',
    role_level INT DEFAULT 0 COMMENT '角色层级: 0-超级管理员, 1-管理员, 2-普通用户',
    status INT DEFAULT 1 COMMENT '状态: 0-禁用, 1-启用',
    description VARCHAR(500) COMMENT '角色描述',
    deleted INT DEFAULT 0 COMMENT '逻辑删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_role_code (role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- User Role Relation Table
DROP TABLE IF EXISTS sys_user_role;
CREATE TABLE sys_user_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    is_primary INT DEFAULT 0 COMMENT '是否主角色: 0-否, 1-是',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_user_role (user_id, role_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

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
-- Passwords: admin2026, doctor2026
INSERT INTO sys_user (username, password, real_name, role, status, title, specialty) VALUES
('admin', '$2a$10$H9zPs/FPjF/CbmNdvPPxZOEjf5bBH7TIlc0/AuiXdjkKjbs0uzTS6', 'System Administrator', 0, 1, 'System Admin', 'System Management'),
('doctor', '$2a$10$efO8RdeQv4ZDxiZoad15S.hip3C2cPFl1nEvdJiL7WifU1z5NIyGu', 'Dr. Zhang', 1, 1, 'Attending Physician', 'Internal Medicine, Respiratory Medicine');

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

-- Menu Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, menu_type, url, method, parent_id, sort_order, icon, path, component, visible, status, description) VALUES
('system:user-management', '用户管理', 'menu', 'menu', '/user-management', NULL, 0, 1, 'User', '/user-management', 'views/UserManagement.vue', 1, 1, '用户管理菜单'),
('system:patient-management', '患者管理', 'menu', 'menu', '/patient', NULL, 0, 2, 'UserFilled', '/patient', 'views/Patient.vue', 1, 1, '患者管理菜单'),
('system:diagnosis', 'AI问诊', 'menu', 'menu', '/diagnosis', NULL, 0, 3, 'ChatLineRound', '/diagnosis', 'views/Diagnosis.vue', 1, 1, 'AI问诊菜单'),
('system:role-management', '角色管理', 'menu', 'menu', '/role-management', NULL, 0, 4, 'Lock', '/role-management', 'views/RoleManagement.vue', 1, 1, '角色管理菜单');

-- Button Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, menu_type, parent_id, sort_order, visible, status, description) VALUES
('patient:button:add', '新增患者按钮', 'button', 'button', 0, 11, 1, 1, '新增患者按钮'),
('patient:button:edit', '编辑患者按钮', 'button', 'button', 0, 12, 1, 1, '编辑患者按钮'),
('patient:button:delete', '删除患者按钮', 'button', 'button', 0, 13, 1, 1, '删除患者按钮'),
('user:button:add', '新增用户按钮', 'button', 'button', 0, 14, 1, 1, '新增用户按钮'),
('user:button:edit', '编辑用户按钮', 'button', 'button', 0, 15, 1, 1, '编辑用户按钮'),
('user:button:delete', '删除用户按钮', 'button', 'button', 0, 16, 1, 1, '删除用户按钮'),
('user:add', '新增用户', 'button', 'button', 0, 17, 1, 1, '新增用户权限'),
('user:edit', '编辑用户', 'button', 'button', 0, 18, 1, 1, '编辑用户权限'),
('user:delete', '删除用户', 'button', 'button', 0, 19, 1, 1, '删除用户权限'),
('user:reset-password', '重置密码', 'button', 'button', 0, 20, 1, 1, '重置密码权限');

-- API Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, url, method, parent_id, sort_order, visible, status, description) VALUES
-- User Management APIs
('user:list', '用户列表', 'api', '/user/list', 'GET', 0, 21, 1, 1, '查看用户列表'),
('user:create', '创建用户', 'api', '/user/create', 'POST', 0, 22, 1, 1, '创建新用户'),
('user:update', '更新用户', 'api', '/user/update', 'PUT', 0, 23, 1, 1, '更新用户信息'),
('user:delete-api', '删除用户', 'api', '/user/delete', 'DELETE', 0, 24, 1, 1, '删除用户'),
('user:reset-password-api', '重置密码', 'api', '/user/reset-password', 'POST', 0, 25, 1, 1, '重置用户密码'),
('user:change-password', '修改密码', 'api', '/user/change-password', 'POST', 0, 26, 1, 1, '修改自己的密码'),
('user:status', '用户状态', 'api', '/user/status', 'PUT', 0, 27, 1, 1, '启用/禁用用户'),

-- Patient Management APIs
('patient:list', '患者列表', 'api', '/patient/page', 'GET', 0, 31, 1, 1, '查看患者列表'),
('patient:detail', '患者详情', 'api', '/patient/*', 'GET', 0, 32, 1, 1, '查看患者详情'),
('patient:create', '创建患者', 'api', '/patient', 'POST', 0, 33, 1, 1, '创建新患者'),
('patient:update', '更新患者', 'api', '/patient', 'PUT', 0, 34, 1, 1, '更新患者信息'),
('patient:delete-api', '删除患者', 'api', '/patient/*', 'DELETE', 0, 35, 1, 1, '删除患者'),

-- Diagnosis APIs
('diagnosis:ai', 'AI问诊', 'api', '/diagnosis/ai', 'POST', 0, 41, 1, 1, 'AI智能问诊'),
('diagnosis:record', '诊断记录', 'api', '/diagnosis/page', 'GET', 0, 42, 1, 1, '查看诊断记录'),
('diagnosis:detail', '诊断详情', 'api', '/diagnosis/*', 'GET', 0, 43, 1, 1, '查看诊断详情'),

-- System Management APIs
('system:config', '系统配置', 'api', '/system/config', 'GET', 0, 51, 1, 1, '查看系统配置'),
('system:log', '系统日志', 'api', '/system/log', 'GET', 0, 52, 1, 1, '查看系统日志'),

-- Role Management APIs
('role:list', '角色列表', 'api', '/role/page', 'GET', 0, 53, 1, 1, '查看角色列表'),
('role:create', '创建角色', 'api', '/role/create', 'POST', 0, 54, 1, 1, '创建新角色'),
('role:update', '更新角色', 'api', '/role/update', 'PUT', 0, 55, 1, 1, '更新角色信息'),
('role:delete', '删除角色', 'api', '/role/delete/*', 'DELETE', 0, 56, 1, 1, '删除角色'),
('role:detail', '角色详情', 'api', '/role/permissions/*', 'GET', 0, 57, 1, 1, '查看角色详情'),
('role:assign-permissions', '分配权限', 'api', '/role/assign-permissions', 'POST', 0, 58, 1, 1, '为角色分配权限'),

-- Permission Management APIs
('permission:list', '权限列表', 'api', '/permission/list', 'GET', 0, 59, 1, 1, '查看所有权限'),
('permission:tree', '权限树', 'api', '/permission/tree', 'GET', 0, 60, 1, 1, '获取权限树形结构');

-- ================================================
-- RBAC ROLE DATA
-- ================================================

-- Insert Default Roles
INSERT INTO sys_role (role_code, role_name, role_level, status, description) VALUES
('ROLE_ADMIN', '系统管理员', 0, 1, '拥有系统所有权限'),
('ROLE_DOCTOR', '医生', 1, 1, '可以管理患者和进行AI问诊'),
('ROLE_USER', '普通用户', 2, 1, '可以使用AI问诊功能');

-- Assign Roles to Users
INSERT INTO sys_user_role (user_id, role_id, is_primary)
SELECT
    u.id as user_id,
    r.id as role_id,
    1 as is_primary
FROM sys_user u
INNER JOIN sys_role r ON (
    (u.role = 0 AND r.role_code = 'ROLE_ADMIN') OR
    (u.role = 1 AND r.role_code = 'ROLE_DOCTOR') OR
    (u.role = 2 AND r.role_code = 'ROLE_USER')
)
WHERE u.deleted = 0;

-- ================================================
-- ROLE PERMISSION ASSIGNMENTS
-- ================================================

-- Admin Role (id=1) - All Permissions
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission;

-- Doctor Role (id=2) - Patient and Diagnosis Permissions
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 2, id FROM sys_permission
WHERE permission_code IN (
    'patient:list', 'patient:detail', 'patient:create', 'patient:update',
    'patient:button:add', 'patient:button:edit',
    'diagnosis:ai', 'diagnosis:record', 'diagnosis:detail',
    'system:patient-management', 'system:diagnosis',
    'user:change-password'
);

-- User Role (id=3) - Diagnosis and Password Change Only
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 3, id FROM sys_permission
WHERE permission_code IN (
    'diagnosis:ai', 'diagnosis:record', 'diagnosis:detail',
    'system:diagnosis',
    'user:change-password'
);

SET FOREIGN_KEY_CHECKS = 1;