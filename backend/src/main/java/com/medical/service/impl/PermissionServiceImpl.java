package com.medical.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.entity.Permission;
import com.medical.mapper.PermissionMapper;
import com.medical.mapper.RoleMapper;
import com.medical.service.PermissionService;
import com.medical.vo.MenuVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
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

    private final RoleMapper roleMapper;

    @Override
    public List<String> getRolePermissions(Integer roleId) {
        return baseMapper.getPermissionCodesByRoleId(roleId);
    }

    @Override
    public List<String> getUserPermissions(Long userId) {
        // 获取用户的所有角色
        List<com.medical.entity.Role> roles = roleMapper.getRolesByUserId(userId);
        if (roles == null || roles.isEmpty()) {
            return List.of();
        }

        // 获取所有角色的权限编码(去重)
        return roles.stream()
                .flatMap(role -> getRolePermissions(role.getId().intValue()).stream())
                .distinct()
                .toList();
    }

    @Override
    public List<String> getUserAllPermissions(Long userId) {
        return getUserPermissions(userId);
    }

    @Override
    public List<Permission> getUserMenuPermissions(Long userId) {
        // 获取用户的所有角色
        List<com.medical.entity.Role> roles = roleMapper.getRolesByUserId(userId);
        if (roles == null || roles.isEmpty()) {
            return List.of();
        }

        // 获取所有角色的权限ID
        List<Integer> roleIds = roles.stream()
                .map(role -> role.getId().intValue())
                .toList();

        // 查询菜单类型的权限
        LambdaQueryWrapper<Permission> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(Permission::getResourceType, "menu", "directory");
        wrapper.eq(Permission::getStatus, 1);
        wrapper.orderByAsc(Permission::getSortOrder);

        List<Permission> allMenus = this.list(wrapper);

        // 获取用户的所有权限编码
        List<String> userPermissions = getUserPermissions(userId);

        // 过滤出用户有权限的菜单
        return allMenus.stream()
                .filter(menu -> userPermissions.contains(menu.getPermissionCode()))
                .collect(Collectors.toList());
    }

    @Override
    public List<MenuVO> getUserMenuTree(Long userId) {
        List<Permission> menuPermissions = getUserMenuPermissions(userId);
        return buildPermissionTree(menuPermissions);
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
    public List<MenuVO> buildPermissionTree(List<Permission> permissions) {
        // 转换为MenuVO列表
        List<MenuVO> menuVOList = permissions.stream()
                .map(this::convertToMenuVO)
                .collect(Collectors.toList());

        // 构建树形结构
        List<MenuVO> rootMenus = new ArrayList<>();
        for (MenuVO menu : menuVOList) {
            boolean isChild = false;
            for (MenuVO parent : menuVOList) {
                if (parent.getId().equals(menu.getParentId())) {
                    if (parent.getChildren() == null) {
                        parent.setChildren(new ArrayList<>());
                    }
                    parent.getChildren().add(menu);
                    isChild = true;
                    break;
                }
            }
            if (!isChild && (menu.getParentId() == null || menu.getParentId() == 0)) {
                rootMenus.add(menu);
            }
        }

        return rootMenus;
    }

    @Override
    public void refreshUserPermissions(Long userId) {
        // Sa-Token会自动刷新权限，这里可以添加自定义逻辑
        StpUtil.logout(userId);
        log.info("用户ID: {} 的权限已刷新", userId);
    }

    /**
     * 将Permission转换为MenuVO
     */
    private MenuVO convertToMenuVO(Permission permission) {
        MenuVO menuVO = new MenuVO();
        menuVO.setId(permission.getId());
        menuVO.setParentId(permission.getParentId());
        menuVO.setPermissionCode(permission.getPermissionCode());
        menuVO.setPermissionName(permission.getPermissionName());
        menuVO.setMenuType(permission.getMenuType() != null ? permission.getMenuType() : permission.getResourceType());
        menuVO.setPath(permission.getUrl());
        menuVO.setComponent(permission.getComponent());
        menuVO.setIcon(permission.getIcon());
        menuVO.setSortOrder(permission.getSortOrder());
        menuVO.setVisible(permission.getVisible() != null ? permission.getVisible() : 1);
        return menuVO;
    }
}
