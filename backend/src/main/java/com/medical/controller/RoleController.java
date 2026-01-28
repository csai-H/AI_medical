package com.medical.controller;

import cn.dev33.satoken.annotation.SaCheckPermission;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.medical.common.Result;
import com.medical.entity.Role;
import com.medical.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 角色管理控制器
 *
 * @author AI Medical Team
 */
@RestController
@RequestMapping("/role")
@RequiredArgsConstructor
public class RoleController {

    private final RoleService roleService;

    /**
     * 分页查询角色列表
     */
    @GetMapping("/page")
    @SaCheckPermission("role:list")
    public Result<Page<Role>> page(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String roleName) {

        Page<Role> page = roleService.getRolePage(current, size, roleName);
        return Result.success(page);
    }

    /**
     * 获取所有角色
     */
    @GetMapping("/list")
    @SaCheckPermission("role:list")
    public Result<List<Role>> list() {
        List<Role> roles = roleService.getAllRoles();
        return Result.success(roles);
    }

    /**
     * 创建角色
     */
    @PostMapping("/create")
    @SaCheckPermission("role:create")
    public Result<Void> create(@RequestBody Role role) {
        roleService.createRole(role);
        return Result.success();
    }

    /**
     * 更新角色
     */
    @PutMapping("/update")
    @SaCheckPermission("role:update")
    public Result<Void> update(@RequestBody Role role) {
        roleService.updateRole(role);
        return Result.success();
    }

    /**
     * 删除角色
     */
    @DeleteMapping("/delete/{id}")
    @SaCheckPermission("role:delete")
    public Result<Void> delete(@PathVariable Long id) {
        roleService.deleteRole(id);
        return Result.success();
    }

    /**
     * 获取角色的权限ID列表
     */
    @GetMapping("/permissions/{roleId}")
    @SaCheckPermission("role:detail")
    public Result<List<Long>> getPermissions(@PathVariable Long roleId) {
        List<Long> permissionIds = roleService.getRolePermissionIds(roleId);
        return Result.success(permissionIds);
    }

    /**
     * 为角色分配权限
     */
    @PostMapping("/assign-permissions")
    @SaCheckPermission("role:assign-permissions")
    public Result<Void> assignPermissions(
            @RequestParam Long roleId,
            @RequestBody List<Long> permissionIds) {

        roleService.assignPermissions(roleId, permissionIds);
        return Result.success();
    }
}
