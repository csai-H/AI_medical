package com.medical.controller;

import cn.dev33.satoken.annotation.SaCheckPermission;
import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.medical.annotation.RequiredPermission;
import com.medical.common.Result;
import com.medical.dto.ChangePasswordDTO;
import com.medical.dto.ResetPasswordDTO;
import com.medical.dto.UserDTO;
import com.medical.dto.UserStatusDTO;
import com.medical.entity.User;
import com.medical.service.UserService;
import com.medical.util.PasswordValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户管理控制器
 *
 * @author AI Medical Team
 */
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * 分页查询用户列表
     */
    @GetMapping("/list")
    @RequiredPermission("user:list")
    public Result<IPage<User>> getUserList(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String realName,
            @RequestParam(required = false) Integer role) {
        
        Page<User> page = new Page<>(current, size);
        IPage<User> userPage = userService.getUserList(page, username, realName, role);
        
        // 清除敏感信息
        userPage.getRecords().forEach(user -> user.setPassword(null));
        
        return Result.success(userPage);
    }

    /**
     * 创建用户
     */
    @PostMapping("/create")
    @RequiredPermission("user:create")
    public Result<Void> createUser(@RequestBody UserDTO userDTO) {
        // 验证密码强度
        if (!PasswordValidator.isValid(userDTO.getPassword())) {
            return Result.error("密码必须8-20位，包含大小写字母、数字和特殊字符");
        }

        userService.createUser(
            userDTO.getUsername(),
            userDTO.getPassword(),
            userDTO.getRealName(),
            userDTO.getRole(),
            userDTO.getPhone(),
            userDTO.getEmail()
        );

        return Result.success("创建用户成功", null);
    }

    /**
     * 更新用户
     */
    @PutMapping("/update")
    @RequiredPermission("user:update")
    public Result<Void> updateUser(@RequestBody UserDTO userDTO) {
        if (userDTO.getId() == null) {
            return Result.error("用户ID不能为空");
        }

        userService.updateUser(
            userDTO.getId(),
            userDTO.getRealName(),
            userDTO.getPhone(),
            userDTO.getEmail(),
            userDTO.getRole()
        );

        return Result.success("更新用户成功", null);
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/delete/{id}")
    @RequiredPermission("user:delete")
    public Result<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success("删除用户成功", null);
    }

    /**
     * 重置用户密码
     */
    @PostMapping("/reset-password")
    @RequiredPermission("user:reset-password")
    public Result<Void> resetPassword(@RequestBody ResetPasswordDTO resetPasswordDTO) {
        // 验证两次密码是否一致
        if (!PasswordValidator.isPasswordMatch(
            resetPasswordDTO.getNewPassword(),
            resetPasswordDTO.getConfirmPassword())) {
            return Result.error("两次密码不一致");
        }

        // 验证密码强度
        if (!PasswordValidator.isValid(resetPasswordDTO.getNewPassword())) {
            return Result.error("密码必须8-20位，包含大小写字母、数字和特殊字符");
        }

        userService.resetPassword(
            resetPasswordDTO.getUserId(),
            resetPasswordDTO.getNewPassword()
        );

        return Result.success("重置密码成功", null);
    }

    /**
     * 修改当前用户密码
     */
    @PostMapping("/change-password")
    public Result<Void> changePassword(@RequestBody ChangePasswordDTO changePasswordDTO) {
        // 验证两次密码是否一致
        if (!PasswordValidator.isPasswordMatch(
            changePasswordDTO.getNewPassword(),
            changePasswordDTO.getConfirmPassword())) {
            return Result.error("两次密码不一致");
        }

        // 验证密码强度
        if (!PasswordValidator.isValid(changePasswordDTO.getNewPassword())) {
            return Result.error("密码必须8-20位，包含大小写字母、数字和特殊字符");
        }

        userService.changePassword(
            changePasswordDTO.getOldPassword(),
            changePasswordDTO.getNewPassword()
        );

        // 修改密码后强制退出登录
        StpUtil.logout();

        return Result.success("修改密码成功，请重新登录", null);
    }

    /**
     * 更新用户状态
     */
    @PutMapping("/status")
    @RequiredPermission("user:status")
    public Result<Void> updateUserStatus(@RequestBody UserStatusDTO userStatusDTO) {
        userService.updateUserStatus(userStatusDTO.getUserId(), userStatusDTO.getStatus());
        return Result.success("更新用户状态成功", null);
    }
}
