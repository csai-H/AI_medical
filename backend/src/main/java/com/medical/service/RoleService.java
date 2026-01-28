package com.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.medical.entity.Role;
import com.medical.vo.MenuVO;

import java.util.List;

/**
 * 角色服务接口
 *
 * @author AI Medical Team
 */
public interface RoleService extends IService<Role> {

    /**
     * 分页查询角色列表
     *
     * @param current 当前页
     * @param size 每页大小
     * @param roleName 角色名称(可选)
     * @return 角色分页列表
     */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<Role> getRolePage(Integer current, Integer size, String roleName);

    /**
     * 获取所有启用的角色
     *
     * @return 角色列表
     */
    List<Role> getAllRoles();

    /**
     * 创建角色
     *
     * @param role 角色信息
     * @return 是否成功
     */
    boolean createRole(Role role);

    /**
     * 更新角色
     *
     * @param role 角色信息
     * @return 是否成功
     */
    boolean updateRole(Role role);

    /**
     * 删除角色
     *
     * @param roleId 角色ID
     * @return 是否成功
     */
    boolean deleteRole(Long roleId);

    /**
     * 获取角色的权限ID列表
     *
     * @param roleId 角色ID
     * @return 权限ID列表
     */
    List<Long> getRolePermissionIds(Long roleId);

    /**
     * 为角色分配权限
     *
     * @param roleId 角色ID
     * @param permissionIds 权限ID列表
     * @return 是否成功
     */
    boolean assignPermissions(Long roleId, List<Long> permissionIds);
}
