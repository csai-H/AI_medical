package com.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.medical.entity.Permission;
import com.medical.vo.MenuVO;

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
     * 获取用户所有权限(支持多角色)
     *
     * @param userId 用户ID
     * @return 权限编码列表
     */
    List<String> getUserAllPermissions(Long userId);

    /**
     * 获取用户菜单权限
     *
     * @param userId 用户ID
     * @return 菜单权限列表
     */
    List<Permission> getUserMenuPermissions(Long userId);

    /**
     * 获取用户菜单树
     *
     * @param userId 用户ID
     * @return 菜单树
     */
    List<MenuVO> getUserMenuTree(Long userId);

    /**
     * 为角色分配权限
     *
     * @param roleId 角色ID
     * @param permissionIds 权限ID列表
     * @return 是否成功
     */
    boolean assignPermissionsToRole(Integer roleId, List<Long> permissionIds);

    /**
     * 构建权限树
     *
     * @param permissions 权限列表
     * @return 权限树
     */
    List<MenuVO> buildPermissionTree(List<Permission> permissions);

    /**
     * 刷新用户权限缓存
     *
     * @param userId 用户ID
     */
    void refreshUserPermissions(Long userId);
}
