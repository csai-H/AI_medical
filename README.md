# AI智能问诊医疗辅助平台

基于Spring Boot 3 + Vue 3 + Sa-Token + 智谱AI大模型开发的智能医疗辅助系统。

**版本**: v2.0.0 (Security Enhanced)  
**最后更新**: 2025-01-28

---

## 📋 目录

- [技术栈](#技术栈)
- [功能模块](#功能模块)
- [快速开始](#快速开始)
- [测试账号](#测试账号)
- [项目结构](#项目结构)
- [安全更新说明](#安全更新说明-v200)
- [API接口](#api接口)
- [常见问题](#常见问题)
- [开发说明](#开发说明)

---

## 技术栈

### 后端
- **Spring Boot 3.2.0** - Web框架
- **MyBatis-Plus 3.5.5** - ORM框架
- **Sa-Token 1.37.0** - 权限认证
- **MySQL 8.0** - 数据库
- **Hutool 5.8.24** - 工具类（含BCrypt密码加密）

### 前端
- **Vue 3.4** - 前端框架
- **Element Plus 2.7** - UI组件库
- **Pinia** - 状态管理
- **Axios** - HTTP请求
- **Vue Router 4** - 路由管理
- **ECharts 5.5** - 数据可视化

### AI能力
- **智谱AI GLM-4** - 大语言模型

---

## 功能模块

### 核心功能
1. **工作台** - 数据统计、问诊趋势、疾病分布
2. **患者管理** - 患者信息CRUD、档案管理、病史记录
3. **AI智能问诊** - 实时对话、症状分析、诊断建议
4. **诊断记录** - 诊断查询、医生确认、历史追溯
5. **知识库管理** - 医疗知识录入、审核、检索
6. **数据统计** - 多维度数据分析、图表展示
7. **用户管理** - 用户CRUD、角色权限、密码管理
8. **系统设置** - 个人信息、安全设置

### 权限系统
- **RBAC权限控制** - 基于角色的访问控制
- **用户管理** - 创建、编辑、删除用户
- **权限分配** - 细粒度权限控制
- **审计日志** - 操作日志记录

---

## 快速开始

### 环境要求
- **JDK 17+**
- **Node.js 16+**
- **MySQL 8.0+**
- **Maven 3.6+**

### 1. 克隆项目
```bash
git clone <repository-url>
cd AI_medical
```

### 2. 数据库初始化（一键完成）

```bash
# Windows
mysql -u root -p < backend\src\main\resources\db\init.sql

# Linux/Mac
mysql -u root -p < backend/src/main/resources/db/init.sql
```

**这将自动创建：**
- 数据库 `ai_medical`
- 7个数据表（用户、患者、诊断、知识库、权限等）
- 3个测试账号（admin/doctor/user）
- 17个权限配置
- 完整的RBAC权限系统

### 3. 配置环境变量

创建 `.env` 文件（参考 `.env.example`）：

```bash
# 数据库密码
DB_PASSWORD=your_mysql_password

# JWT密钥（生产环境必须修改为随机字符串）
SA_TOKEN_JWT_SECRET=kP8fD2hL5mN9qR3tV6wY4zB7xC0vF1sG4hJ2kM5nP8q

# CORS允许的域名
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### 4. 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端服务运行在: **http://localhost:8080**

### 5. 启动前端

```bash
cd frontend
npm install
npm run dev
```

前端服务运行在: **http://localhost:5173**

### 6. 访问系统

打开浏览器访问: **http://localhost:5173**

使用测试账号登录（见下方）

---

## 测试账号

⚠️ **重要提示**: 
- 密码已使用BCrypt加密，符合安全标准
- 首次登录后请立即修改密码
- 生产环境请删除或禁用测试账号

| 角色   | 用户名 | 密码         | 权限范围                     |
|--------|--------|--------------|------------------------------|
| 管理员 | admin  | Admin@2024   | 全部功能（17个权限）         |
| 医生   | doctor | Doctor@2024  | 患者管理 + AI问诊（8个权限） |
| 普通用户 | user  | User@2024    | AI问诊（4个权限）            |

---

## 项目结构

```
AI_medical/
├── backend/                          # 后端项目
│   ├── src/main/java/com/medical/
│   │   ├── annotation/               # 注解（权限、审计日志）
│   │   ├── config/                   # 配置类
│   │   ├── controller/              # 控制器
│   │   ├── dto/                     # 数据传输对象
│   │   ├── entity/                  # 实体类
│   │   ├── exception/               # 异常处理
│   │   ├── mapper/                  # MyBatis Mapper
│   │   ├── service/                 # 服务层
│   │   └── util/                    # 工具类
│   ├── src/main/resources/
│   │   ├── application.yml          # 应用配置
│   │   └── db/
│   │       └── init.sql            # 数据库初始化（完整版）
│   └── pom.xml
│
└── frontend/                         # 前端项目
    ├── src/
    │   ├── api/                     # API接口
    │   ├── components/              # 组件
    │   ├── layout/                  # 布局组件
    │   ├── router/                  # 路由
    │   ├── stores/                  # Pinia状态
    │   ├── views/                   # 页面
    │   ├── App.vue
    │   └── main.js
    ├── package.json
    └── vite.config.js
```

**⭐ v2.0.0新增/修复的主要文件**：

**后端**:
- `UserController.java` - 用户管理控制器
- `PermissionService.java` - 权限服务
- `UserServiceImpl.java` - BCrypt密码加密
- `StpInterfaceImpl.java` - Sa-Token权限接口
- `GlobalExceptionHandler.java` - 全局异常处理
- `PasswordValidator.java` - 密码强度验证
- `Permission.java` / `AuditLog.java` - 权限实体

**前端**:
- `UserManagement.vue` - 用户管理页面
- `ChangePassword.vue` - 修改密码页面
- `PasswordStrength.vue` - 密码强度组件
- `user.js` - 用户API

---

## 安全更新说明 (v2.0.0)

### 🔒 安全修复

| 问题 | 修复前 | 修复后 | 状态 |
|------|--------|--------|------|
| 密码存储 | 明文比较 | BCrypt加密 | ✅ |
| JWT密钥 | 简单字符串 | 环境变量 | ✅ |
| CORS配置 | 允许所有(*) | 指定域名 | ✅ |
| 数据库密码 | 硬编码 | 环境变量 | ✅ |
| 异常处理 | 无 | 全局处理 | ✅ |

### ✨ 新功能

**用户管理**
- ✅ 用户注册（用户名、密码验证）
- ✅ 用户列表（分页、搜索、筛选）
- ✅ 创建用户（管理员）
- ✅ 编辑用户信息
- ✅ 删除用户
- ✅ 启用/禁用用户
- ✅ 重置密码（管理员）
- ✅ 修改密码（用户自己）

**权限系统**
- ✅ RBAC权限表设计
- ✅ 角色权限关联
- ✅ 权限注解 `@RequiredPermission`
- ✅ 权限切面检查
- ✅ Sa-Token权限接口实现
- ✅ 前端路由权限守卫

**密码安全**
- ✅ 密码强度验证器（弱/中/强）
- ✅ 密码强度可视化组件
- ✅ BCrypt加密存储
- ✅ 密码复杂度要求（6-20位，必须包含字母和数字）

---

## API接口

### 认证接口
```
POST /auth/login          - 用户登录
POST /auth/register       - 用户注册 ⭐新增
POST /auth/logout         - 用户退出
GET  /auth/user/info      - 获取当前用户信息
```

### 用户管理接口
```
GET    /user/list              - 用户列表（分页）⭐新增
POST   /user/create            - 创建用户 ⭐新增
PUT    /user/update            - 更新用户 ⭐新增
DELETE /user/delete/{id}       - 删除用户 ⭐新增
POST   /user/reset-password    - 重置密码 ⭐新增
POST   /user/change-password   - 修改密码 ⭐新增
PUT    /user/status            - 启用/禁用用户 ⭐新增
```

### 患者管理接口
```
GET    /patient/list      - 患者列表
POST   /patient/create    - 创建患者
PUT    /patient/update    - 更新患者
DELETE /patient/delete/{id} - 删除患者
```

### 诊断接口
```
POST /diagnosis/ai        - AI智能问诊
GET  /diagnosis/record    - 诊断记录
GET  /diagnosis/detail    - 诊断详情
```

---

## 常见问题

### Q1: 登录失败，提示"密码错误"？
**A**: 
1. 确认已执行 `init.sql` 初始化数据库
2. 使用新密码：`admin2026`（admin账号）
3. 检查用户状态是否被禁用

### Q2: 提示"权限不足"？
**A**: 
1. 使用管理员账号登录（admin/admin2026）
2. 检查权限数据是否正确初始化
3. 确认路由守卫配置正确

### Q3: CORS跨域错误？
**A**: 
1. 检查 `.env` 文件中的 `ALLOWED_ORIGINS` 配置
2. 确保前端地址在允许列表中
3. 重启后端应用

### Q4: JWT验证失败？
**A**: 
1. 确保 `.env` 文件中的 `SA_TOKEN_JWT_SECRET` 已配置
2. 前后端必须使用相同的JWT密钥
3. 清除浏览器缓存和localStorage

### Q5: 数据库连接失败？
**A**: 
1. 检查MySQL服务是否运行
2. 确认 `.env` 文件中的 `DB_PASSWORD` 正确
3. 检查 `application.yml` 中的数据库配置

### Q6: 如何生成BCrypt密码？
**A**: 
- 在线工具：https://bcrypt-generator.com/
- 或使用项目中的 `PasswordValidator` 工具类
- 工作因子（Work Factor）建议：10

### Q7: 忘记管理员密码怎么办？
**A**: 
```sql
-- 重置admin密码为 admin2026
UPDATE sys_user 
SET password = '$2a$10$H9zPs/FPjF/CbmNdvPPxZOEjf5bBH7TIlc0/AuiXdjkKjbs0uzTS6' 
WHERE username = 'admin';
```

---

## 开发说明

### 后端开发规范
- 遵循RESTful API设计规范
- 使用Sa-Token进行权限认证
- MyBatis Plus简化数据库操作
- 统一异常处理（GlobalExceptionHandler）
- 所有密码使用BCrypt加密

### 前端开发规范
- 组件化开发
- 响应式设计
- 状态管理使用Pinia
- Axios拦截器统一处理请求和错误
- 路由守卫进行权限验证

### 数据库表结构

**核心业务表**（4个）
- `sys_user` - 用户表
- `patient` - 患者表
- `diagnosis_record` - 诊断记录表
- `medical_knowledge` - 医疗知识表

**RBAC权限表**（3个）
- `sys_permission` - 权限表
- `sys_role_permission` - 角色权限关联表
- `sys_audit_log` - 审计日志表

### 密码强度规则

**密码要求**：
- 长度：6-20位
- 必须包含：字母和数字
- 示例：`admin2026` ✅

### 权限配置

**角色权限对应关系**：
- 管理员（role=0）：全部17个权限
- 医生（role=1）：8个权限（患者管理+诊断）
- 普通用户（role=2）：4个权限（诊断相关）

---

## 部署注意事项

### 生产环境检查清单

- [ ] 修改 `.env` 文件中的数据库密码
- [ ] 修改 `SA_TOKEN_JWT_SECRET` 为随机32位字符串
- [ ] 配置 `ALLOWED_ORIGINS` 为实际前端域名
- [ ] 修改或删除测试账号
- [ ] 启用HTTPS（生产环境必须）
- [ ] 配置防火墙规则
- [ ] 启用数据库备份
- [ ] 配置日志监控

### 安全建议

1. **定期备份数据库**（每日）
2. **监控异常登录**（日志分析）
3. **定期更新依赖**（安全补丁）
4. **限制API访问频率**（防暴力破解）
5. **启用操作审计**（关键操作记录）

---

## 智谱AI配置

系统使用智谱AI GLM-4模型进行智能问诊。

### 申请API Key
1. 访问 [智谱AI开放平台](https://open.bigmodel.cn/)
2. 注册并登录
3. 创建API Key
4. 配置到 `application.yml`:

```yaml
zhipu:
  api:
    key: your_api_key_here
    model: glm-4
    url: https://open.bigmodel.cn/api/paas/v4/chat/completions
```

---

## 注意事项

1. ⚠️ 本系统仅供学习参考，不得用于实际医疗诊断
2. ⚠️ AI诊断结果仅供参考，不能替代专业医生诊断
3. ⚠️ 请妥善保管API密钥和数据库密码
4. ⚠️ 生产环境必须修改所有默认密码和密钥
5. ⚠️ 定期备份数据库和重要配置文件

---

## License

MIT License

---

**版本**: v2.0.0 (Security Enhanced)  
**最后更新**: 2025-01-28  
**状态**: ✅ 生产就绪
