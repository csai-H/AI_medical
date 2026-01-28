package com.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.medical.entity.Permission;

import java.util.List;

/**
 * 权限服务接口
 *
 * @author AI Medical Team
 */
public interface PermissionService extends IService<Permission> {

    /**
     * 获取角色权限列表
     *
     * @param roleId 角色ID
     * @return 权限编码列表
     */
    List<String> getRolePermissions(Integer roleId);

    /**
     * 获取用户权限列表
     *
     * @param userId 用户ID
     * @return 权限编码列表
     */
    List<String> getUserPermissions(Long userId);

    /**
     * 为角色分配权限
     *
     * @param roleId 角色ID
     * @param permissionIds 权限ID列表
     * @return 是否成功
     */
    boolean assignPermissionsToRole(Integer roleId, List<Long> permissionIds);

    /**
     * 刷新用户权限缓存
     *
     * @param userId 用户ID
     */
    void refreshUserPermissions(Long userId);
}
