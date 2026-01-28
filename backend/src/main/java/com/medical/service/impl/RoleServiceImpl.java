package com.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.entity.Role;
import com.medical.mapper.PermissionMapper;
import com.medical.mapper.RoleMapper;
import com.medical.service.PermissionService;
import com.medical.service.RoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 角色服务实现类
 *
 * @author AI Medical Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RoleServiceImpl extends ServiceImpl<RoleMapper, Role> implements RoleService {

    private static final String ROLE_ADMIN = "ROLE_ADMIN";

    private final PermissionMapper permissionMapper;
    private final PermissionService permissionService;

    @Override
    public Page<Role> getRolePage(Integer current, Integer size, String roleName) {
        Page<Role> page = new Page<>(current, size);
        LambdaQueryWrapper<Role> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(roleName)) {
            wrapper.like(Role::getRoleName, roleName);
        }

        wrapper.orderByAsc(Role::getRoleLevel);

        return this.page(page, wrapper);
    }

    @Override
    public List<Role> getAllRoles() {
        LambdaQueryWrapper<Role> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Role::getStatus, 1);
        return this.list(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createRole(Role role) {
        // 检查角色编码是否已存在
        LambdaQueryWrapper<Role> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Role::getRoleCode, role.getRoleCode());
        if (this.count(wrapper) > 0) {
            throw new RuntimeException("角色编码已存在");
        }

        boolean result = this.save(role);
        log.info("创建角色成功: {}", role.getRoleName());
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateRole(Role role) {
        // 检查是否为 ROLE_ADMIN 角色
        Role existingRole = this.getById(role.getId());
        if (existingRole != null && ROLE_ADMIN.equals(existingRole.getRoleCode())) {
            // 不允许修改 ROLE_ADMIN 的状态
            if (existingRole.getStatus() != role.getStatus()) {
                throw new RuntimeException("不允许修改系统管理员角色的状态");
            }
        }

        // 检查角色编码是否被其他角色使用
        LambdaQueryWrapper<Role> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Role::getRoleCode, role.getRoleCode());
        wrapper.ne(Role::getId, role.getId());
        if (this.count(wrapper) > 0) {
            throw new RuntimeException("角色编码已存在");
        }

        boolean result = this.updateById(role);
        log.info("更新角色成功: {}", role.getRoleName());
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteRole(Long roleId) {
        // 检查是否为 ROLE_ADMIN 角色
        Role role = this.getById(roleId);
        if (role != null && ROLE_ADMIN.equals(role.getRoleCode())) {
            throw new RuntimeException("不允许删除系统管理员角色");
        }

        // 检查角色是否被用户使用
        // TODO: 添加用户角色关联检查

        // 删除角色权限关联
        permissionMapper.deleteRolePermissions(roleId.intValue());

        boolean result = this.removeById(roleId);
        log.info("删除角色成功: roleId={}", roleId);
        return result;
    }

    @Override
    public List<Long> getRolePermissionIds(Long roleId) {
        return permissionMapper.getPermissionIdsByRoleId(roleId.intValue());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean assignPermissions(Long roleId, List<Long> permissionIds) {
        // 检查是否为 ROLE_ADMIN 角色
        Role role = this.getById(roleId);
        if (role != null && ROLE_ADMIN.equals(role.getRoleCode())) {
            throw new RuntimeException("不允许修改系统管理员角色的权限");
        }

        boolean result = permissionService.assignPermissionsToRole(roleId.intValue(), permissionIds);
        log.info("为角色分配权限成功: roleId={}, permissionCount={}", roleId, permissionIds.size());
        return result;
    }
}
