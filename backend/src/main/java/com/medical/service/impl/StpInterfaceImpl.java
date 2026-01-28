package com.medical.service.impl;

import cn.dev33.satoken.stp.StpInterface;
import com.medical.mapper.RoleMapper;
import com.medical.service.PermissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Sa-Token权限接口实现
 * 用于Sa-Token框架获取用户权限和角色信息
 *
 * @author AI Medical Team
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class StpInterfaceImpl implements StpInterface {

    private final PermissionService permissionService;
    private final RoleMapper roleMapper;

    @Override
    public List<String> getPermissionList(Object loginId, String loginType) {
        try {
            Long userId = Long.parseLong(loginId.toString());
            List<String> permissions = permissionService.getUserPermissions(userId);
            log.debug("用户ID: {} 的权限列表: {}", userId, permissions);
            return permissions;
        } catch (Exception e) {
            log.error("获取用户权限失败: userId={}", loginId, e);
            return List.of();
        }
    }

    @Override
    public List<String> getRoleList(Object loginId, String loginType) {
        try {
            Long userId = Long.parseLong(loginId.toString());
            List<String> roles = roleMapper.getRoleCodesByUserId(userId);
            log.debug("用户ID: {} 的角色列表: {}", userId, roles);
            return roles;
        } catch (Exception e) {
            log.error("获取用户角色失败: userId={}", loginId, e);
            return List.of();
        }
    }
}
