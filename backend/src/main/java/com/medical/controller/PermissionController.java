package com.medical.controller;

import cn.dev33.satoken.annotation.SaCheckPermission;
import com.medical.common.Result;
import com.medical.entity.Permission;
import com.medical.service.PermissionService;
import com.medical.vo.MenuVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 权限管理控制器
 *
 * @author AI Medical Team
 */
@RestController
@RequestMapping("/permission")
@RequiredArgsConstructor
public class PermissionController {

    private final PermissionService permissionService;

    /**
     * 获取所有权限列表
     */
    @GetMapping("/list")
    @SaCheckPermission("permission:list")
    public Result<List<Permission>> getAllPermissions() {
        List<Permission> permissions = permissionService.list();
        return Result.success(permissions);
    }

    /**
     * 获取权限树形结构
     */
    @GetMapping("/tree")
    @SaCheckPermission("permission:tree")
    public Result<List<MenuVO>> getPermissionTree() {
        List<Permission> permissions = permissionService.list();
        List<MenuVO> tree = permissionService.buildPermissionTree(permissions);
        return Result.success(tree);
    }

    /**
     * 获取当前用户的菜单树
     */
    @GetMapping("/user/menus")
    public Result<List<MenuVO>> getUserMenus() {
        Long userId = Long.valueOf((Integer) cn.dev33.satoken.stp.StpUtil.getLoginId());
        List<MenuVO> menuTree = permissionService.getUserMenuTree(userId);
        return Result.success(menuTree);
    }
}
