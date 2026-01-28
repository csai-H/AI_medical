-- ================================================
-- 添加知识库管理菜单权限
-- Date: 2025-01-28
-- ================================================

USE ai_medical;

-- 添加知识库管理菜单
INSERT INTO sys_permission (permission_code, permission_name, resource_type, menu_type, url, method, parent_id, sort_order, icon, path, component, visible, status, description)
VALUES ('system:knowledge', '知识库管理', 'menu', 'menu', '/knowledge', NULL, 0, 6, 'Reading', '/knowledge', 'views/Knowledge.vue', 1, 1, '知识库管理菜单');

-- 添加知识库相关按钮权限
INSERT INTO sys_permission (permission_code, permission_name, resource_type, menu_type, parent_id, sort_order, visible, status, description)
VALUES
('knowledge:button:add', '新增知识按钮', 'button', 'button', 0, 31, 1, 1, '新增知识按钮'),
('knowledge:button:edit', '编辑知识按钮', 'button', 'button', 0, 32, 1, 1, '编辑知识按钮'),
('knowledge:button:delete', '删除知识按钮', 'button', 'button', 0, 33, 1, 1, '删除知识按钮'),
('knowledge:button:audit', '审核知识按钮', 'button', 'button', 0, 34, 1, 1, '审核知识按钮');

-- 添加知识库API权限
INSERT INTO sys_permission (permission_code, permission_name, resource_type, url, method, parent_id, sort_order, visible, status, description)
VALUES
('knowledge:list', '知识库列表', 'api', '/knowledge/page', 'GET', 0, 41, 1, 1, '查看知识库列表'),
('knowledge:detail', '知识库详情', 'api', '/knowledge/*', 'GET', 0, 42, 1, 1, '查看知识库详情'),
('knowledge:create', '创建知识', 'api', '/knowledge', 'POST', 0, 43, 1, 1, '创建新知识'),
('knowledge:update', '更新知识', 'api', '/knowledge', 'PUT', 0, 44, 1, 1, '更新知识信息'),
('knowledge:delete-api', '删除知识', 'api', '/knowledge/*', 'DELETE', 0, 45, 1, 1, '删除知识'),
('knowledge:audit-api', '审核知识', 'api', '/knowledge/audit/*', 'PUT', 0, 46, 1, 1, '审核知识');

-- 为管理员角色分配知识库权限
-- 注意：你需要根据实际的role_id和permission_id进行调整
-- 这里假设管理员角色是ROLE_ADMIN (id=1)

-- 获取权限ID
SET @menu_id = (SELECT id FROM sys_permission WHERE permission_code = 'system:knowledge');
SET @create_api_id = (SELECT id FROM sys_permission WHERE permission_code = 'knowledge:create');
SET @update_api_id = (SELECT id FROM sys_permission WHERE permission_code = 'knowledge:update');
SET @delete_api_id = (SELECT id FROM sys_permission WHERE permission_code = 'knowledge:delete-api');
SET @audit_api_id = (SELECT id FROM sys_permission WHERE permission_code = 'knowledge:audit-api');

-- 为管理员角色分配权限（假设管理员角色ID为1）
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, @menu_id WHERE NOT EXISTS (SELECT 1 FROM sys_role_permission WHERE role_id = 1 AND permission_id = @menu_id);

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, @create_api_id WHERE NOT EXISTS (SELECT 1 FROM sys_role_permission WHERE role_id = 1 AND permission_id = @create_api_id);

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, @update_api_id WHERE NOT EXISTS (SELECT 1 FROM sys_role_permission WHERE role_id = 1 AND permission_id = @update_api_id);

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, @delete_api_id WHERE NOT EXISTS (SELECT 1 FROM sys_role_permission WHERE role_id = 1 AND permission_id = @delete_api_id);

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, @audit_api_id WHERE NOT EXISTS (SELECT 1 FROM sys_role_permission WHERE role_id = 1 AND permission_id = @audit_api_id);

-- 为医生角色分配知识库查看权限（假设医生角色ID为2）
-- INSERT INTO sys_role_permission (role_id, permission_id)
-- SELECT 2, @menu_id WHERE NOT EXISTS (SELECT 1 FROM sys_role_permission WHERE role_id = 2 AND permission_id = @menu_id);
