package com.medical.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.medical.dto.LoginDTO;
import com.medical.entity.User;

/**
 * 用户Service接口
 *
 * @author AI Medical Team
 */
public interface UserService extends IService<User> {

    /**
     * 用户登录
     *
     * @param loginDTO 登录信息
     * @return token
     */
    String login(LoginDTO loginDTO);

    /**
     * 用户退出
     */
    void logout();

    /**
     * 获取当前登录用户信息
     *
     * @return 用户信息
     */
    User getCurrentUser();

    /**
     * 分页查询用户列表
     *
     * @param page 分页参数
     * @param username 用户名(可选)
     * @param realName 真实姓名(可选)
     * @param role 角色(可选)
     * @return 用户列表
     */
    IPage<User> getUserList(Page<User> page, String username, String realName, Integer role);

    /**
     * 用户注册
     *
     * @param username 用户名
     * @param password 密码（明文，方法内会加密）
     * @param realName 真实姓名
     * @param phone 手机号
     * @param email 邮箱
     * @return 注册成功的用户
     */
    User registerUser(String username, String password, String realName, String phone, String email);

    /**
     * 创建用户（管理员）
     *
     * @param username 用户名
     * @param password 密码（明文，方法内会加密）
     * @param realName 真实姓名
     * @param role 角色
     * @param phone 手机号
     * @param email 邮箱
     * @return 创建的用户
     */
    User createUser(String username, String password, String realName, Integer role, String phone, String email);

    /**
     * 更新用户信息
     *
     * @param userId 用户ID
     * @param realName 真实姓名
     * @param phone 手机号
     * @param email 邮箱
     * @param role 角色
     * @return 是否成功
     */
    boolean updateUser(Long userId, String realName, String phone, String email, Integer role);

    /**
     * 删除用户
     *
     * @param userId 用户ID
     * @return 是否成功
     */
    boolean deleteUser(Long userId);

    /**
     * 重置用户密码（管理员）
     *
     * @param userId 用户ID
     * @param newPassword 新密码（明文，方法内会加密）
     * @return 是否成功
     */
    boolean resetPassword(Long userId, String newPassword);

    /**
     * 修改当前用户密码
     *
     * @param oldPassword 旧密码（明文）
     * @param newPassword 新密码（明文，方法内会加密）
     * @return 是否成功
     */
    boolean changePassword(String oldPassword, String newPassword);

    /**
     * 更新用户状态
     *
     * @param userId 用户ID
     * @param status 状态（0-禁用，1-启用）
     * @return 是否成功
     */
    boolean updateUserStatus(Long userId, Integer status);

}
