package com.medical.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.entity.Permission;
import com.medical.entity.User;
import com.medical.mapper.PermissionMapper;
import com.medical.service.PermissionService;
import com.medical.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 权限服务实现类
 *
 * @author AI Medical Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PermissionServiceImpl extends ServiceImpl<PermissionMapper, Permission> implements PermissionService {

    private final UserService userService;

    @Override
    public List<String> getRolePermissions(Integer roleId) {
        return baseMapper.getPermissionCodesByRoleId(roleId);
    }

    @Override
    public List<String> getUserPermissions(Long userId) {
        User user = userService.getById(userId);
        if (user == null) {
            return List.of();
        }
        return getRolePermissions(user.getRole());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean assignPermissionsToRole(Integer roleId, List<Long> permissionIds) {
        // 先删除角色现有权限
        baseMapper.deleteRolePermissions(roleId);

        // 重新分配权限
        if (permissionIds != null && !permissionIds.isEmpty()) {
            baseMapper.insertRolePermissions(roleId, permissionIds);
        }

        log.info("角色ID: {} 的权限已更新", roleId);
        return true;
    }

    @Override
    public void refreshUserPermissions(Long userId) {
        // Sa-Token会自动刷新权限，这里可以添加自定义逻辑
        StpUtil.logout(userId);
        log.info("用户ID: {} 的权限已刷新", userId);
    }
}
