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
DROP DATABASE IF EXISTS ai_medical;

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
    user_id BIGINT COMMENT '关联的用户ID',
    create_by BIGINT,
    deleted INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_patient_no (patient_no),
    INDEX idx_name (name),
    INDEX idx_phone (phone),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
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
    image_urls TEXT COMMENT '皮肤图片URL(JSON格式，存储多个图片URL)',
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
-- Passwords: admin/Admin@2024, doctor/Doctor@2024, user/User@2024
INSERT INTO sys_user (username, password, real_name, role, status, title, specialty) VALUES
('admin', '$2a$10$H9zPs/FPjF/CbmNdvPPxZOEjf5bBH7TIlc0/AuiXdjkKjbs0uzTS6', 'System Administrator', 0, 1, 'System Admin', 'System Management'),
('doctor', '$2a$10$efO8RdeQv4ZDxiZoad15S.hip3C2cPFl1nEvdJiL7WifU1z5NIyGu', 'Dr. Zhang', 1, 1, 'Attending Physician', 'Internal Medicine, Respiratory Medicine'),
('user', '$2a$10$rPEY0qSJvPYQHlzXhEJBxOvPLkAOFd1xNJ3nx9h1JvKROh/xZh10e', 'Test User', 2, 1, 'Regular User', NULL);

-- Insert Test Patients
-- Associated with user account (user id=3, username='user')
INSERT INTO patient (patient_no, name, gender, age, birthday, phone, id_card, address, allergy_history, past_history, family_history, user_id, create_by) VALUES
('P202501001', '王芳', 0, 28, '1996-03-15', '13812345678', '310101199603150012', '上海市浦东新区张江高科技园区', '青霉素过敏', '无', '高血压家族史', 3, 2),
('P202501002', '李明', 1, 35, '1989-07-22', '13923456789', '310101198907220034', '上海市徐汇区漕河泾开发区', '无', '糖尿病', '糖尿病家族史', 3, 2),
('P202501003', '张伟', 1, 42, '1982-11-08', '15034567890', '310101198211080056', '上海市长宁区虹桥开发区', '磺胺类药物过敏', '高血压', '心脏病家族史', 3, 2),
('P202501004', '刘洋', 1, 25, '1999-05-30', '18645678901', '310101199905300078', '上海市静安区南京西路', '无', '无', '无', 3, 2),
('P202501005', '陈静', 0, 31, '1993-09-12', '17756789012', '310101199309120090', '上海市黄浦区人民广场', '海鲜过敏', '哮喘', '哮喘家族史', 3, 2),
('P202501006', '赵强', 1, 55, '1969-02-18', '13367890123', '310101196902180112', '上海市普陀区真北路', '无', '冠心病', '糖尿病、高血压家族史', 3, 2),
('P202501007', '孙丽', 0, 29, '1995-08-25', '18078901234', '310101199508250134', '上海市虹口区四川北路', '花粉过敏', '过敏性鼻炎', '过敏性疾病家族史', 3, 2),
('P202501008', '周杰', 1, 38, '1986-12-05', '15889012345', '310101198612050156', '上海市杨浦区五角场', '无', '慢性胃炎', '胃病家族史', 3, 2),
('P202501009', '吴娟', 0, 45, '1979-06-20', '13790123456', '310101197906200178', '上海市闵行区七宝', '无', '甲状腺结节', '甲状腺疾病家族史', 3, 2),
('P202501010', '郑勇', 1, 50, '1974-04-10', '13601234567', '310101197404100190', '上海市宝山区友谊路', '无', '痛风', '高尿酸血症家族史', 3, 2),
('P202501011', '王秀英', 0, 62, '1962-10-15', '13112345678', '310101196210150022', '上海市嘉定区嘉定镇', '无', '骨质疏松', '骨质疏松家族史', 3, 2),
('P202501012', '李建国', 1, 58, '1966-08-30', '13223456789', '310101196608300044', '上海市松江区中山路', '无', '慢性支气管炎', '呼吸系统疾病家族史', 3, 2),
('P202501013', '黄美玲', 0, 33, '1991-05-18', '15934567890', '310101199105180156', '上海市浦东新区陆家嘴', '无', '高血压', '高血压家族史', 3, 2),
('P202501014', '林涛', 1, 41, '1983-09-25', '18845678901', '310101198309250178', '上海市徐汇区徐家汇', '无', '糖尿病', '糖尿病家族史', 3, 2),
('P202501015', '徐敏', 0, 27, '1997-12-08', '17756789012', '310101199712080190', '上海市长宁区中山公园', '无', '无', '无', 3, 2),
('P202501016', '马强', 1, 48, '1976-03-14', '13667890123', '310101197603140112', '上海市普陀区长寿路', '无', '高血压', '高血压家族史', 3, 2),
('P202501017', '朱丽', 0, 36, '1988-07-30', '15078901234', '310101198807300134', '上海市虹口区北外滩', '海鲜过敏', '糖尿病', '糖尿病家族史', 3, 2),
('P202501018', '郭伟', 1, 52, '1972-11-22', '13389012345', '310101197211220156', '上海市杨浦区新江湾城', '无', '高血压', '冠心病家族史', 3, 2),
('P202501019', '何静', 0, 39, '1985-04-16', '15890123456', '310101198504160178', '上海市闵行区莘庄', '花粉过敏', '过敏性鼻炎', '过敏性疾病家族史', 3, 2),
('P202501020', '高勇', 1, 44, '1980-06-05', '13701234567', '310101198006050190', '上海市宝山区罗店', '无', '糖尿病', '糖尿病家族史', 3, 2);

-- Insert Test Diagnosis Records
-- Associated with patients (ids 1-20) and doctor (id=2)
INSERT INTO diagnosis_record (record_no, patient_id, patient_name, doctor_id, doctor_name, chief_complaint, present_illness, symptoms, ai_diagnosis, ai_suggestion, doctor_diagnosis, treatment_plan, diagnosis_type, match_rate, status) VALUES
('D20250128001', 1, '王芳', 2, 'Dr. Zhang', '头痛、发热3天', '患者3天前出现头痛、发热，体温最高达38.5℃，伴有鼻塞、流涕。', '头痛、发热、鼻塞、流涕、咽痛', '{"disease":"急性上呼吸道感染"}', '建议休息、多饮水，可服用退热药物和对症治疗。注意监测体温变化。', '急性上呼吸道感染', '休息、多饮水，布洛芬缓释胶囊0.3g口服，每日2次；连花清瘟胶囊2粒口服，每日3次。', 0, 90, 1),
('D20250128002', 2, '李明', 2, 'Dr. Zhang', '多饮、多尿、消瘦2个月', '患者2个月前开始出现多饮、多尿，伴体重下降约5kg。', '多饮、多尿、体重下降、乏力', '{"disease":"2型糖尿病"}', '建议检测空腹血糖、餐后2小时血糖及糖化血红蛋白。控制饮食，适当运动。', '2型糖尿病', '糖尿病饮食，适当运动。二甲双胍片0.5g口服，每日3次。定期监测血糖。', 0, 100, 1),
('D20250128003', 3, '张伟', 2, 'Dr. Zhang', '反复胸闷、气短1年，加重1周', '患者1年来反复出现胸闷、气短，活动后明显，近1周症状加重。', '胸闷、气短、活动后呼吸困难', '{"disease":"冠心病"}', '建议做心电图、心脏彩超、冠脉CTA检查。注意休息，避免劳累。', '冠心病', '低盐低脂饮食，避免劳累。阿司匹林肠溶片100mg口服，每日1次；阿托伐他汀钙片20mg口服，每晚1次。建议冠脉造影检查。', 0, 90, 1),
('D20250128004', 4, '刘洋', 2, 'Dr. Zhang', '皮肤出现红色皮疹伴瘙痒2天', '患者2天前躯干及四肢出现红色皮疹，伴明显瘙痒。', '红色斑丘疹、瘙痒、无发热', '{"disease":"过敏性皮炎"}', '避免接触过敏原，可口服抗组胺药物，外用止痒药膏。避免搔抓。', '过敏性皮炎', '避免接触过敏原。氯雷他定片10mg口服，每日1次；炉甘石洗剂外用，每日2-3次。', 0, 90, 1),
('D20250128005', 5, '陈静', 2, 'Dr. Zhang', '反复咳嗽、喘息3年，发作1天', '患者3年来反复出现咳嗽、喘息，多接触过敏原后发作，昨天接触花粉后症状再次出现。', '咳嗽、喘息、胸闷、呼吸困难', '{"disease":"支气管哮喘急性发作"}', '立即脱离过敏原，使用支气管舒张剂，必要时使用糖皮质激素。建议肺功能检查。', '支气管哮喘急性发作', '沙丁胺醇气雾剂吸入，必要时；布地奈德福莫特罗粉吸入剂2吸，每日2次。避免接触过敏原。', 0, 100, 1),
('D20250128006', 6, '赵强', 2, 'Dr. Zhang', '胸痛、心悸2小时', '患者2小时前无明显诱因出现胸骨后疼痛，伴心悸、出汗。', '胸骨后疼痛、心悸、出汗、焦虑', '{"disease":"急性冠脉综合征"}', '立即就医，做心电图、心肌酶谱检查。卧床休息，避免活动。', '急性冠脉综合征', '立即住院治疗，急诊冠脉造影。阿司匹林肠溶片300mg嚼服；氯吡格雷片300mg口服。', 0, 90, 1),
('D20250128007', 7, '孙丽', 2, 'Dr. Zhang', '鼻塞、流涕、打喷嚏1周', '患者1周来持续性鼻塞、流清水样鼻涕、频繁打喷嚏，伴眼痒、流泪。', '鼻塞、流涕、打喷嚏、眼痒、流泪', '{"disease":"过敏性鼻炎"}', '避免接触过敏原，使用鼻喷激素和口服抗组胺药物。建议过敏原检测。', '过敏性鼻炎', '避免接触过敏原。糠酸莫米松鼻喷剂2喷，每日1次；氯雷他定片10mg口服，每日1次。', 0, 100, 1),
('D20250128008', 8, '周杰', 2, 'Dr. Zhang', '上腹部不适、反酸、烧心3个月', '患者3个月来反复出现上腹部不适、反酸、烧心，空腹时明显，进食后可缓解。', '上腹部不适、反酸、烧心、嗳气', '{"disease":"慢性胃炎"}', '建议胃镜检查。注意饮食规律，避免辛辣刺激食物。可使用抑酸药和胃黏膜保护剂。', '慢性胃炎', '奥美拉唑肠溶胶囊20mg口服，每日1次；硫糖铝咀嚼片1g口服，每日3次。建议胃镜检查。', 0, 80, 1),
('D20250128009', 9, '吴娟', 2, 'Dr. Zhang', '体检发现甲状腺结节1周', '患者1周前体检B超发现甲状腺结节，无明显不适症状。', '甲状腺结节（体检发现），无自觉症状', '{"disease":"甲状腺结节"}', '建议甲状腺功能检查和甲状腺彩超定期复查。多数良性结节无需特殊治疗。', '甲状腺结节（良性可能）', '暂不需特殊治疗，定期复查甲状腺彩超和甲状腺功能。低碘饮食，避免情绪激动。', 0, 80, 1),
('D20250128010', 10, '郑勇', 2, 'Dr. Zhang', '右足第一跖趾关节红肿热痛2天', '患者2天前出现右足第一跖趾关节红肿热痛，活动受限。', '关节红肿热痛、活动受限', '{"disease":"急性痛风性关节炎"}', '检测血尿酸。低嘌呤饮食，避免饮酒，可使用非甾体抗炎药。', '急性痛风性关节炎', '低嘌呤饮食，禁酒。依托考昔片120mg口服，每日1次；秋水仙碱片0.5mg口服，每日3次。', 0, 90, 1),
('D20250128011', 11, '王秀英', 2, 'Dr. Zhang', '腰背部疼痛2年，加重1个月', '患者2年来反复出现腰背部疼痛，活动后加重，近1个月症状明显。', '腰背部疼痛、活动后加重、驼背', '{"disease":"骨质疏松症"}', '建议骨密度检查。补充钙剂和维生素D，适当运动，防止跌倒。', '骨质疏松症', '碳酸钙D3片1片口服，每日2次；骨化三醇胶丸0.25μg口服，每日1次。适当晒太阳，防止跌倒。', 0, 90, 1),
('D20250128012', 12, '李建国', 2, 'Dr. Zhang', '反复咳嗽、咳痰10年，加重伴气喘1周', '患者10年来反复咳嗽、咳白色泡沫痰，冬春季加重，近1周症状加重伴气喘。', '咳嗽、咳白色泡沫痰、气喘、肺部啰音', '{"disease":"慢性阻塞性肺疾病"}', '吸氧，使用支气管舒张剂和糖皮质激素，抗感染治疗。建议肺功能检查。', '慢性阻塞性肺疾病急性加重', '吸氧。沙美特罗替卡松粉吸入剂1吸，每日2次；甲泼尼龙片40mg口服，每日1次。头孢呋辛酯片0.5g口服，每日2次。', 0, 100, 1),
('D20250127001', 1, '王芳', 2, 'Dr. Zhang', '面部皮肤红肿、脱屑1周', '患者1周前面部出现红斑、脱屑，伴轻度瘙痒，近期使用过新化妆品。', '面部红斑、脱屑、轻度瘙痒', '{"disease":"接触性皮炎"}', '停用可能引起刺激的化妆品，避免使用刺激性护肤品，可使用保湿修复类产品。', '接触性皮炎', '停用可疑化妆品。冷敷面部，每日2次。重组人表皮生长因子凝胶外用，每日2次。', 0, 90, 1),
('D20250127002', 3, '张伟', 2, 'Dr. Zhang', '体检发现血压升高1周', '患者1周前体检发现血压160/100mmHg，无头晕、头痛等症状。', '血压升高，无自觉症状', '{"disease":"高血压病"}', '低盐低脂饮食，适当运动，控制体重。建议监测血压，必要时使用降压药物。', '高血压病（2级，中危组）', '低盐低脂饮食，适当运动。苯磺酸氨氯地平片5mg口服，每日1次。定期监测血压。', 0, 90, 1),
('D20250127003', 5, '陈静', 2, 'Dr. Zhang', '月经紊乱、痛经6个月', '患者6个月来月经周期不规律，经期延长，伴痛经。', '月经周期紊乱、经期延长、痛经', '{"disease":"功能失调性子宫出血"}', '建议妇科检查，包括妇科B超和性激素六项检查。注意休息，避免过度劳累。', '功能失调性子宫出血', '注意休息，避免过度劳累。建议妇科进一步诊治，必要时行内分泌调理治疗。', 0, 80, 1),
('D20250127004', 7, '孙丽', 2, 'Dr. Zhang', '双眼红肿、流泪、异物感3天', '患者3天前出现双眼红肿、流泪、异物感，伴眼分泌物增多。', '眼红、流泪、异物感、分泌物增多', '{"disease":"急性结膜炎"}', '注意眼部卫生，避免揉眼。使用抗生素眼药水，避免交叉感染。', '急性结膜炎', '注意眼部卫生，避免揉眼。左氧氟沙星滴眼液滴眼，每日4-6次。避免交叉感染。', 0, 90, 1),
-- 新增诊断记录，让某些疾病类型有多个案例
('D20250126001', 13, '黄美玲', 2, 'Dr. Zhang', '发热、咳嗽、咽痛2天', '患者2天前受凉后出现发热、咳嗽、咽痛，体温最高37.8℃。', '发热、咳嗽、咽痛、鼻塞', '{"disease":"急性上呼吸道感染"}', '建议休息、多饮水，可服用退热药物和对症治疗。注意监测体温变化。', '急性上呼吸道感染', '休息、多饮水，对乙酰氨基酚片0.5g口服，每日3次；复方甘草片2片口服，每日3次。', 0, 100, 1),
('D20250126002', 15, '徐敏', 2, 'Dr. Zhang', '头痛、鼻塞、流涕1天', '患者1天前出现头痛、鼻塞、流清涕，伴轻度咽痛。', '头痛、鼻塞、流涕、咽痛', '{"disease":"急性上呼吸道感染"}', '建议休息、多饮水，可服用感冒药物。注意保暖。', '急性上呼吸道感染', '休息、多饮水，注意保暖。感冒灵颗粒1袋口服，每日3次。', 0, 90, 1),
('D20250126003', 19, '何静', 2, 'Dr. Zhang', '鼻塞、流涕、打喷嚏3天', '患者3天前出现鼻塞、流涕、频繁打喷嚏，伴咽部不适。', '鼻塞、流涕、打喷嚏、咽痛', '{"disease":"急性上呼吸道感染"}', '建议休息、多饮水，可服用抗病毒药物和感冒药物。', '急性上呼吸道感染', '休息、多饮水。连花清瘟胶囊2粒口服，每日3次；复方氨酚烷胺片1片口服，每日2次。', 0, 90, 1),
('D20250126004', 16, '马强', 2, 'Dr. Zhang', '体检发现血压升高1个月', '患者1个月前体检发现血压155/95mmHg，偶有头晕。', '血压升高，偶有头晕', '{"disease":"高血压病"}', '低盐低脂饮食，适当运动，控制体重。建议监测血压，必要时使用降压药物。', '高血压病（1级，低危组）', '低盐低脂饮食，适当运动。硝苯地平控释片30mg口服，每日1次。定期监测血压。', 0, 80, 1),
('D20250126005', 18, '郭伟', 2, 'Dr. Zhang', '头晕、头痛2周，加重3天', '患者2周来反复头晕、头痛，近3天症状加重，测血压165/105mmHg。', '头晕、头痛、血压升高', '{"disease":"高血压病"}', '低盐低脂饮食，适当运动。建议使用降压药物，定期监测血压。', '高血压病（2级，中危组）', '低盐低脂饮食，适当运动。厄贝沙坦片150mg口服，每日1次；氢氯噻嗪片12.5mg口服，每日1次。', 0, 90, 1),
('D20250126006', 13, '黄美玲', 2, 'Dr. Zhang', '血压控制不佳1个月', '患者有高血压病史2年，近1个月血压控制不佳，波动在150-160/90-100mmHg。', '血压波动、头晕', '{"disease":"高血压病"}', '调整降压药物方案，低盐低脂饮食，规律服药，定期监测血压。', '高血压病（2级，中危组）', '低盐低脂饮食。氨氯地平片5mg口服，每日1次；缬沙坦胶囊80mg口服，每日1次。', 0, 90, 1),
('D20250126007', 14, '林涛', 2, 'Dr. Zhang', '口干、多饮、多尿1个月', '患者1个月来出现口干、多饮、多尿，体重下降3kg。', '口干、多饮、多尿、体重下降', '{"disease":"2型糖尿病"}', '建议检测空腹血糖、餐后2小时血糖及糖化血红蛋白。控制饮食，适当运动。', '2型糖尿病', '糖尿病饮食，适当运动。格列美脲片2mg口服，每日1次；二甲双胍片0.5g口服，每日3次。', 0, 90, 1),
('D20250126008', 17, '朱丽', 2, 'Dr. Zhang', '体检发现血糖升高2周', '患者2周前体检发现空腹血糖8.5mmol/L，无多饮、多尿症状。', '血糖升高，无明显症状', '{"disease":"2型糖尿病"}', '建议复查空腹血糖、餐后2小时血糖及糖化血红蛋白。控制饮食，适当运动。', '2型糖尿病', '糖尿病饮食，适当运动。阿卡波糖片50mg口服，每日3次，随第一口主食服用。', 0, 80, 1),
('D20250126009', 20, '高勇', 2, 'Dr. Zhang', '多饮、多食、消瘦3个月', '患者3个月来出现多饮、多食，体重下降约6kg，伴乏力。', '多饮、多食、体重下降、乏力', '{"disease":"2型糖尿病"}', '建议检测空腹血糖、餐后2小时血糖及糖化血红蛋白。控制饮食，适当运动，必要时使用胰岛素。', '2型糖尿病', '糖尿病饮食，适当运动。西格列汀片100mg口服，每日1次；二甲双胍片0.5g口服，每日3次。', 0, 100, 1),
('D20250126010', 16, '马强', 2, 'Dr. Zhang', '反复胸痛、胸闷半年，加重1周', '患者半年来反复出现胸痛、胸闷，活动后明显，近1周症状加重。', '胸痛、胸闷、活动后加重', '{"disease":"冠心病"}', '建议做心电图、心脏彩超、冠脉CTA检查。注意休息，避免劳累。', '冠心病', '低盐低脂饮食，避免劳累。阿司匹林肠溶片100mg口服，每日1次；单硝酸异山梨酯片20mg口服，每日2次。', 0, 90, 1),
('D20250126011', 18, '郭伟', 2, 'Dr. Zhang', '体检发现心电图异常1周', '患者1周前体检发现心电图ST-T改变，无胸痛症状。', '心电图异常，无自觉症状', '{"disease":"冠心病"}', '建议心脏彩超、冠脉CTA检查。低盐低脂饮食，适当运动。', '冠心病', '低盐低脂饮食，适当运动。阿托伐他汀钙片20mg口服，每晚1次。建议冠脉造影检查。', 0, 80, 1),
('D20250126012', 19, '何静', 2, 'Dr. Zhang', '反复咳嗽、喘息5年，发作2天', '患者5年来反复出现咳嗽、喘息，春秋季节发作，2天前接触尘螨后症状再次出现。', '咳嗽、喘息、胸闷', '{"disease":"支气管哮喘急性发作"}', '立即脱离过敏原，使用支气管舒张剂，必要时使用糖皮质激素。建议肺功能检查。', '支气管哮喘急性发作', '沙丁胺醇气雾剂吸入，必要时；布地奈德吸入粉雾剂200μg吸入，每日2次。避免接触过敏原。', 0, 90, 1),
('D20250126013', 7, '孙丽', 2, 'Dr. Zhang', '接触花粉后鼻塞、流涕1天', '患者昨天接触花粉后出现鼻塞、流清水样鼻涕、频繁打喷嚏。', '鼻塞、流涕、打喷嚏、鼻痒', '{"disease":"过敏性鼻炎"}', '避免接触过敏原，使用鼻喷激素和口服抗组胺药物。', '过敏性鼻炎', '避免接触过敏原。丙酸氟替卡松鼻喷剂2喷，每日1次；西替利嗪片10mg口服，每晚1次。', 0, 100, 1),
('D20250126014', 19, '何静', 2, 'Dr. Zhang', '季节性鼻塞、流涕1周', '患者1周前出现鼻塞、流涕、打喷嚏，伴眼痒、流泪，每年春季发作。', '鼻塞、流涕、打喷嚏、眼痒', '{"disease":"过敏性鼻炎"}', '避免接触过敏原，使用鼻喷激素和口服抗组胺药物。建议过敏原检测。', '过敏性鼻炎', '避免接触过敏原。布地奈德鼻喷剂2喷，每日2次；氯雷他定片10mg口服，每日1次。', 0, 90, 1),
('D20250126015', 4, '刘洋', 2, 'Dr. Zhang', '躯干四肢红斑、丘疹伴瘙痒3天', '患者3天前躯干及四肢出现红斑、丘疹，伴明显瘙痒，无发热。', '红斑、丘疹、瘙痒', '{"disease":"过敏性皮炎"}', '避免接触过敏原，可口服抗组胺药物，外用止痒药膏。避免搔抓。', '过敏性皮炎', '避免接触过敏原。西替利嗪片10mg口服，每晚1次；地奈德乳膏外用，每日2次。', 0, 90, 1),
('D20250126016', 8, '周杰', 2, 'Dr. Zhang', '上腹部饱胀、反酸2个月', '患者2个月来反复出现上腹部饱胀、反酸，餐后明显。', '上腹部饱胀、反酸、嗳气', '{"disease":"慢性胃炎"}', '建议胃镜检查。注意饮食规律，避免辛辣刺激食物。可使用抑酸药和胃黏膜保护剂。', '慢性胃炎', '雷贝拉唑肠溶片10mg口服，每日1次；铝碳酸镁片1g咀嚼，每日3次。建议胃镜检查。', 0, 80, 1),
('D20250126017', 9, '吴娟', 2, 'Dr. Zhang', '上腹部疼痛、恶心1周', '患者1周来出现上腹部疼痛、恶心，进食后加重，伴反酸。', '上腹部疼痛、恶心、反酸', '{"disease":"慢性胃炎"}', '建议胃镜检查查幽门螺杆菌。注意饮食规律，避免刺激性食物。', '慢性胃炎', '泮托拉唑肠溶片40mg口服，每日1次；胶体果胶铋胶囊150mg口服，每日3次。', 0, 90, 1),
('D20250126018', 10, '郑勇', 2, 'Dr. Zhang', '左足第一跖趾关节红肿热痛1天', '患者1天前出现左足第一跖趾关节红肿热痛，活动受限，夜间发作明显。', '关节红肿热痛、活动受限', '{"disease":"急性痛风性关节炎"}', '检测血尿酸。低嘌呤饮食，避免饮酒，可使用非甾体抗炎药。', '急性痛风性关节炎', '低嘌呤饮食，禁酒。双氯芬酸钠缓释片75mg口服，每日2次；碳酸氢钠片1g口服，每日3次。', 0, 90, 1),
('D20250126019', 6, '赵强', 2, 'Dr. Zhang', '反复关节肿痛3年，发作2天', '患者3年来反复出现关节肿痛，多在饮酒或高嘌呤饮食后发作，2天前右踝关节出现红肿热痛。', '关节红肿热痛、活动受限', '{"disease":"急性痛风性关节炎"}', '检测血尿酸。低嘌呤饮食，避免饮酒，使用非甾体抗炎药和秋水仙碱。', '急性痛风性关节炎', '低嘌呤饮食，禁酒。塞来昔布胶囊200mg口服，每日2次；秋水仙碱片0.5mg口服，每日2次。', 0, 100, 1);

-- Insert Test Medical Knowledge
INSERT INTO medical_knowledge (title, disease_name, category, symptoms, etiology, diagnosis_methods, treatment, medication_advice, precautions, source, audit_status) VALUES
('Hypertension', '高血压病', '心血管系统', '头痛、头晕、心悸、耳鸣，多数患者无症状', '遗传因素、环境因素、生活方式、年龄、肥胖等', '血压测量、心电图、超声心动图、肾功能检查', '低盐低脂饮食、控制体重、规律运动、降压药物治疗', '利尿剂、ACEI、ARB、钙通道阻滞剂、β受体阻滞剂等', '定期监测血压、规律服药、低盐饮食、适量运动', 0, 1),
('Type 2 Diabetes Mellitus', '2型糖尿病', '内分泌代谢系统', '多饮、多尿、多食、体重下降、乏力', '胰岛素抵抗和胰岛素分泌不足，遗传和环境因素', '空腹血糖、餐后2小时血糖、糖化血红蛋白、尿糖', '糖尿病饮食、运动疗法、口服降糖药或胰岛素治疗', '二甲双胍、磺脲类、α-糖苷酶抑制剂、胰岛素等', '控制饮食、规律运动、定期监测血糖、预防并发症', 0, 1),
('Coronary Heart Disease', '冠心病', '心血管系统', '胸痛、胸闷、心悸、气短、乏力', '冠状动脉粥样硬化，血管腔狭窄或闭塞', '心电图、心脏彩超、冠脉造影、冠脉CTA', '低脂饮食、适当运动、药物治疗、介入治疗或外科手术', '阿司匹林、他汀类、硝酸酯类、β受体阻滞剂等', '低盐低脂饮食、规律服药、避免劳累、定期复查', 0, 1),
('Bronchial Asthma', '支气管哮喘', '呼吸系统', '反复发作的喘息、气急、胸闷或咳嗽，夜间及凌晨发作加重', '遗传因素、环境因素、过敏原、呼吸道感染等', '肺功能检查、支气管舒张试验、过敏原检测', '避免接触过敏原、支气管舒张剂、糖皮质激素吸入', '沙丁胺醇、布地奈德、孟鲁司特钠、茶碱类等', '避免接触过敏原、规律用药、定期复查、随身携带急救药物', 0, 1),
('Chronic Obstructive Pulmonary Disease', '慢性阻塞性肺疾病', '呼吸系统', '慢性咳嗽、咳痰、气短或呼吸困难、喘息、胸闷', '吸烟、空气污染、职业粉尘、呼吸道感染等', '肺功能检查、胸部X线或CT、动脉血气分析', '戒烟、支气管舒张剂、糖皮质激素、氧疗、康复训练', '沙美特罗替卡松、噻托溴铵、氨茶碱、糖皮质激素等', '绝对戒烟、避免吸入有害气体、呼吸功能锻炼、预防感冒', 0, 1),
('Acute Gouty Arthritis', '急性痛风性关节炎', '风湿免疫系统', '关节红肿热痛，多见于第一跖趾关节，夜间发作', '高尿酸血症，尿酸盐结晶沉积于关节', '血尿酸、关节滑液检查、X线检查、双能CT', '低嘌呤饮食、多饮水、非甾体抗炎药、秋水仙碱', '依托考昔、塞来昔布、秋水仙碱、别嘌醇、非布司他等', '低嘌呤饮食、禁酒、多饮水、控制体重、规律服药', 0, 1),
('Allergic Rhinitis', '过敏性鼻炎', '耳鼻喉科', '鼻塞、流涕、打喷嚏、鼻痒、眼痒、流泪', '接触过敏原（花粉、尘螨、宠物皮屑等）', '过敏原检测、鼻内镜检查、血清IgE检测', '避免接触过敏原、鼻喷激素、口服抗组胺药', '糠酸莫米松、氯雷他定、西替利嗪、孟鲁司特钠等', '避免接触过敏原、鼻腔冲洗、规律用药、增强体质', 0, 1),
('Osteoporosis', '骨质疏松症', '骨科', '腰背部疼痛、身高缩短、驼背、易骨折', '年龄、绝经、遗传、营养、生活方式等因素', '骨密度检查、X线检查、骨代谢指标检测', '补充钙剂和维生素D、适当运动、防止跌倒、药物治疗', '钙剂、维生素D、双膦酸盐类、降钙素、选择性雌激素受体调节剂等', '适当运动、补充钙和维生素D、防止跌倒、避免吸烟饮酒', 0, 1),
('Contact Dermatitis', '接触性皮炎', '皮肤科', '接触部位红斑、丘疹、水疱、瘙痒、灼热感', '接触刺激性物质或致敏原', '斑贴试验、皮肤检查、过敏原检测', '避免接触致敏原、外用糖皮质激素、口服抗组胺药', '炉甘石洗剂、糠酸莫米松乳膏、氯雷他定、西替利嗪等', '避免接触致敏原、温和清洁、使用温和护肤品、避免搔抓', 0, 1),
('Chronic Gastritis', '慢性胃炎', '消化系统', '上腹部不适、饱胀感、疼痛、反酸、嗳气、恶心', '幽门螺杆菌感染、饮食不当、药物刺激、应激等', '胃镜检查、幽门螺杆菌检测、胃黏膜活检', '规律饮食、避免刺激性食物、根除幽门螺杆菌、对症治疗', '质子泵抑制剂、胃黏膜保护剂、促胃动力药、抗生素等', '规律饮食、避免辛辣刺激食物、戒烟限酒、情绪管理', 0, 1),
('Acute Conjunctivitis', '急性结膜炎', '眼科', '眼红、流泪、异物感、分泌物增多、眼睑肿胀', '细菌感染、病毒感染、过敏反应', '裂隙灯检查、结膜刮片、病原学检查', '注意眼部卫生、抗生素眼药水或抗病毒眼药水', '左氧氟沙星滴眼液、更昔洛韦眼用凝胶、奥洛他定滴眼液等', '注意眼部卫生、避免揉眼、避免交叉感染、充足休息', 0, 1),
('Thyroid Nodule', '甲状腺结节', '内分泌系统', '多数无症状，较大结节可触及颈部肿块', '遗传、碘摄入异常、辐射暴露、甲状腺炎等', '甲状腺超声、甲状腺功能检查、细针穿刺细胞学检查', '定期复查、药物治疗或手术治疗（恶性或有压迫症状）', '左甲状腺素钠片（部分病例）、手术治疗', '定期复查、低碘或适碘饮食、避免过度劳累、情绪管理', 0, 1),
('Dysfunctional Uterine Bleeding', '功能失调性子宫出血', '妇产科', '月经周期紊乱、经期延长或缩短、经量增多或减少', '下丘脑-垂体-卵巢轴功能失调', '妇科检查、妇科B超、性激素六项、诊断性刮宫', '调整周期、止血、促排卵、激素治疗', '雌激素、孕激素、口服避孕药、止血药等', '规律作息、避免过度劳累、情绪管理、定期复查', 0, 1);

-- ================================================
-- RBAC PERMISSION DATA
-- ================================================

-- Menu Permissions
INSERT INTO sys_permission (permission_code, permission_name, resource_type, menu_type, url, method, parent_id, sort_order, icon, path, component, visible, status, description) VALUES
('system:dashboard', '工作台', 'menu', 'menu', '/dashboard', NULL, 0, 0, 'Odometer', '/dashboard', 'views/Dashboard.vue', 1, 1, '工作台菜单'),
('system:patient-management', '患者管理', 'menu', 'menu', '/patient', NULL, 0, 1, 'UserFilled', '/patient', 'views/Patient.vue', 1, 1, '患者管理菜单'),
('system:diagnosis', 'AI问诊', 'menu', 'menu', '/diagnosis', NULL, 0, 2, 'ChatLineRound', '/diagnosis', 'views/Diagnosis.vue', 1, 1, 'AI问诊菜单'),
('system:diagnosis-record', '诊断记录', 'menu', 'menu', '/diagnosis-record', NULL, 0, 3, 'Document', '/diagnosis-record', 'views/DiagnosisRecord.vue', 1, 1, '诊断记录菜单'),
('system:skin-analysis', '皮肤图片分析', 'menu', 'menu', '/skin-analysis', NULL, 0, 4, 'Picture', '/skin-analysis', 'views/SkinAnalysis.vue', 1, 1, '皮肤图片分析菜单'),
('system:knowledge', '知识库管理', 'menu', 'menu', '/knowledge', NULL, 0, 5, 'Reading', '/knowledge', 'views/Knowledge.vue', 1, 1, '知识库管理菜单'),
('system:medical-knowledge', '医疗知识库', 'menu', 'menu', '/medical-knowledge', NULL, 0, 5, 'Notebook', '/medical-knowledge', 'views/MedicalKnowledge.vue', 1, 1, '医疗知识库菜单'),
('system:user-management', '用户管理', 'menu', 'menu', '/user-management', NULL, 0, 6, 'User', '/user-management', 'views/UserManagement.vue', 1, 1, '用户管理菜单'),
('system:role-management', '角色管理', 'menu', 'menu', '/role-management', NULL, 0, 7, 'Lock', '/role-management', 'views/RoleManagement.vue', 1, 1, '角色管理菜单'),
('system:settings', '个人设置', 'menu', 'menu', '/settings', NULL, 0, 10, 'Setting', '/settings', 'views/Settings.vue', 1, 1, '个人设置菜单'),
('system:patient-profile', '我的患者信息', 'menu', 'menu', '/patient-profile', NULL, 0, 11, 'UserFilled', '/patient-profile', 'views/PatientProfile.vue', 1, 1, '我的患者信息菜单');

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

-- Skin Analysis APIs
('skin:analyze', '皮肤图片分析', 'api', '/skin-analysis/analyze', 'POST', 0, 44, 1, 1, '上传并分析皮肤图片'),
('skin:upload', '上传图片', 'api', '/skin-analysis/upload', 'POST', 0, 45, 1, 1, '单独上传图片'),
('skin:upload-batch', '批量上传图片', 'api', '/skin-analysis/upload/batch', 'POST', 0, 46, 1, 1, '批量上传图片'),

-- Knowledge APIs
('knowledge:list', '知识库列表', 'api', '/knowledge/page', 'GET', 0, 50, 1, 1, '查看知识库列表'),
('knowledge:detail', '知识库详情', 'api', '/knowledge/*', 'GET', 0, 51, 1, 1, '查看知识库详情'),
('knowledge:create', '创建知识', 'api', '/knowledge', 'POST', 0, 52, 1, 1, '创建新知识'),
('knowledge:update', '更新知识', 'api', '/knowledge', 'PUT', 0, 53, 1, 1, '更新知识信息'),
('knowledge:delete', '删除知识', 'api', '/knowledge/*', 'DELETE', 0, 54, 1, 1, '删除知识'),

-- System Management APIs
('system:config', '系统配置', 'api', '/system/config', 'GET', 0, 60, 1, 1, '查看系统配置'),
('system:log', '系统日志', 'api', '/system/log', 'GET', 0, 61, 1, 1, '查看系统日志'),

-- Role Management APIs
('role:list', '角色列表', 'api', '/role/page', 'GET', 0, 62, 1, 1, '查看角色列表'),
('role:create', '创建角色', 'api', '/role/create', 'POST', 0, 63, 1, 1, '创建新角色'),
('role:update', '更新角色', 'api', '/role/update', 'PUT', 0, 64, 1, 1, '更新角色信息'),
('role:delete', '删除角色', 'api', '/role/delete/*', 'DELETE', 0, 65, 1, 1, '删除角色'),
('role:detail', '角色详情', 'api', '/role/permissions/*', 'GET', 0, 66, 1, 1, '查看角色详情'),
('role:assign-permissions', '分配权限', 'api', '/role/assign-permissions', 'POST', 0, 67, 1, 1, '为角色分配权限'),

-- Permission Management APIs
('permission:list', '权限列表', 'api', '/permission/list', 'GET', 0, 68, 1, 1, '查看所有权限'),
('permission:tree', '权限树', 'api', '/permission/tree', 'GET', 0, 69, 1, 1, '获取权限树形结构');

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

-- Admin Role (id=1) - All Permissions except Skin Analysis
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission
WHERE permission_code NOT IN (
    'system:skin-analysis',
    'skin:analyze',
    'skin:upload',
    'skin:upload-batch'
);

-- Doctor Role (id=2) - Patient, Diagnosis and Knowledge Permissions
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 2, id FROM sys_permission
WHERE permission_code IN (
    -- 菜单权限
    'system:dashboard',
    'system:patient-management',
    'system:diagnosis',
    'system:diagnosis-record',
    'system:knowledge',
    'system:settings',
    -- 患者管理API权限
    'patient:list',
    'patient:detail',
    'patient:create',
    'patient:update',
    'patient:delete-api',
    -- 患者管理按钮权限
    'patient:button:add',
    'patient:button:edit',
    'patient:button:delete',
    -- AI问诊权限
    'diagnosis:ai',
    'diagnosis:record',
    'diagnosis:detail',
    -- 知识库权限（医生可以查看和新增）
    'knowledge:list',
    'knowledge:detail',
    'knowledge:create',
    -- 用户个人权限
    'user:change-password'
);

-- User Role (id=3) - Patient User Only
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 3, id FROM sys_permission
WHERE permission_code IN (
    -- 菜单权限（不包含dashboard）
    'system:diagnosis',
    'system:skin-analysis',
    'system:medical-knowledge',
    'system:settings',
    'system:patient-profile',
    -- AI问诊权限
    'diagnosis:ai',
    'diagnosis:record',
    'diagnosis:detail',
    -- 皮肤图片分析权限（仅患者可用）
    'skin:analyze',
    'skin:upload',
    'skin:upload-batch',
    -- 知识库权限（患者只能查看）
    'knowledge:list',
    'knowledge:detail',
    -- 用户个人权限
    'user:change-password'
);

SET FOREIGN_KEY_CHECKS = 1;