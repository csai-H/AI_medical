package com.medical.controller;

import cn.dev33.satoken.stp.StpUtil;
import com.medical.common.Result;
import com.medical.dto.LoginDTO;
import com.medical.dto.RegisterDTO;
import com.medical.entity.User;
import com.medical.service.UserService;
import com.medical.util.PasswordValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 *
 * @author AI Medical Team
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<String> login(@RequestBody LoginDTO loginDTO) {
        try {
            String token = userService.login(loginDTO);
            return Result.success("登录成功", token);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<String> register(@RequestBody RegisterDTO registerDTO) {
        try {
            // 验证两次密码是否一致
            if (!PasswordValidator.isPasswordMatch(
                registerDTO.getPassword(),
                registerDTO.getConfirmPassword())) {
                return Result.error("两次密码不一致");
            }

            // 注册用户
            User user = userService.registerUser(
                registerDTO.getUsername(),
                registerDTO.getPassword(),
                registerDTO.getRealName(),
                registerDTO.getPhone(),
                registerDTO.getEmail()
            );

            // 注册成功后自动登录
            StpUtil.login(user.getId());
            String token = StpUtil.getTokenValue();

            return Result.success("注册成功", token);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户退出
     */
    @PostMapping("/logout")
    public Result<Void> logout() {
        userService.logout();
        return Result.success("退出成功", null);
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/user/info")
    public Result<User> getCurrentUser() {
        User user = userService.getCurrentUser();
        // 清除敏感信息
        user.setPassword(null);
        return Result.success(user);
    }

}
