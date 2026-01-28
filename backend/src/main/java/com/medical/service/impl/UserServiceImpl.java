package com.medical.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.crypto.digest.BCrypt;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.dto.LoginDTO;
import com.medical.entity.Patient;
import com.medical.entity.User;
import com.medical.mapper.UserMapper;
import com.medical.exception.BusinessException;
import com.medical.service.PatientService;
import com.medical.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * 用户Service实现类
 *
 * @author AI Medical Team
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final PatientService patientService;

    @Override
    public String login(LoginDTO loginDTO) {
        // 查询用户
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, loginDTO.getUsername());
        User user = this.getOne(wrapper);

        // 验证用户
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 验证密码（使用BCrypt加密验证）
        if (!BCrypt.checkpw(loginDTO.getPassword(), user.getPassword())) {
            throw new BusinessException("密码错误");
        }

        // 验证状态
        if (user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用");
        }

        // 登录成功，生成token
        StpUtil.login(user.getId());
        return StpUtil.getTokenValue();
    }

    @Override
    public void logout() {
        StpUtil.logout();
    }

    @Override
    public User getCurrentUser() {
        Long userId = StpUtil.getLoginIdAsLong();
        return this.getById(userId);
    }

    @Override
    public IPage<User> getUserList(Page<User> page, String username, String realName, Integer role) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(username)) {
            wrapper.like(User::getUsername, username);
        }

        if (StringUtils.hasText(realName)) {
            wrapper.like(User::getRealName, realName);
        }

        if (role != null) {
            wrapper.eq(User::getRole, role);
        }

        wrapper.orderByDesc(User::getCreateTime);

        return this.page(page, wrapper);
    }

    @Override
    public User registerUser(String username, String password, String realName, String phone, String email) {
        // 检查用户名是否已存在
        LambdaQueryWrapper<User> checkWrapper = new LambdaQueryWrapper<>();
        checkWrapper.eq(User::getUsername, username);
        if (this.getOne(checkWrapper) != null) {
            throw new BusinessException("用户名已存在");
        }

        // 创建新用户
        User user = new User();
        user.setUsername(username);
        // 使用BCrypt加密密码
        user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        user.setRealName(realName);
        user.setPhone(phone);
        user.setEmail(email);
        user.setRole(2); // 默认为普通用户
        user.setStatus(1); // 默认启用

        this.save(user);
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public User registerPatientUser(String username, String password, String realName, String phone, String email, Integer gender, Integer age) {
        // 检查用户名是否已存在
        LambdaQueryWrapper<User> checkWrapper = new LambdaQueryWrapper<>();
        checkWrapper.eq(User::getUsername, username);
        if (this.getOne(checkWrapper) != null) {
            throw new BusinessException("用户名已存在");
        }

        // 创建新用户
        User user = new User();
        user.setUsername(username);
        // 使用BCrypt加密密码
        user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        user.setRealName(realName);
        user.setPhone(phone);
        user.setEmail(email);
        user.setRole(2); // 默认为普通用户（患者）
        user.setStatus(1); // 默认启用

        this.save(user);

        // 同时创建患者记录
        Patient patient = new Patient();
        patient.setPatientNo(generatePatientNo());
        patient.setName(realName);
        patient.setGender(gender);
        patient.setAge(age);
        patient.setPhone(phone);
        patient.setUserId(user.getId()); // 关联用户ID

        patientService.save(patient);

        return user;
    }

    /**
     * 生成患者编号
     */
    private String generatePatientNo() {
        return "P" + System.currentTimeMillis() + IdUtil.randomUUID().substring(0, 4).toUpperCase();
    }

    @Override
    public User createUser(String username, String password, String realName, Integer role, String phone, String email) {
        // 检查用户名是否已存在
        LambdaQueryWrapper<User> checkWrapper = new LambdaQueryWrapper<>();
        checkWrapper.eq(User::getUsername, username);
        if (this.getOne(checkWrapper) != null) {
            throw new BusinessException("用户名已存在");
        }

        // 创建新用户
        User user = new User();
        user.setUsername(username);
        // 使用BCrypt加密密码
        user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        user.setRealName(realName);
        user.setRole(role);
        user.setPhone(phone);
        user.setEmail(email);
        user.setStatus(1); // 默认启用

        this.save(user);
        return user;
    }

    @Override
    public boolean updateUser(Long userId, String realName, String phone, String email, Integer role) {
        User user = this.getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        user.setRealName(realName);
        user.setPhone(phone);
        user.setEmail(email);
        if (role != null) {
            user.setRole(role);
        }

        return this.updateById(user);
    }

    @Override
    public boolean deleteUser(Long userId) {
        // 不能删除自己
        Long currentUserId = StpUtil.getLoginIdAsLong();
        if (currentUserId.equals(userId)) {
            throw new BusinessException("不能删除当前登录用户");
        }

        return this.removeById(userId);
    }

    @Override
    public boolean resetPassword(Long userId, String newPassword) {
        User user = this.getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 使用BCrypt加密新密码
        user.setPassword(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
        return this.updateById(user);
    }

    @Override
    public boolean changePassword(String oldPassword, String newPassword) {
        Long userId = StpUtil.getLoginIdAsLong();
        User user = this.getById(userId);
        
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 验证旧密码
        if (!BCrypt.checkpw(oldPassword, user.getPassword())) {
            throw new BusinessException("原密码错误");
        }

        // 设置新密码（使用BCrypt加密）
        user.setPassword(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
        return this.updateById(user);
    }

    @Override
    public boolean updateUserStatus(Long userId, Integer status) {
        // 不能禁用自己
        Long currentUserId = StpUtil.getLoginIdAsLong();
        if (currentUserId.equals(userId) && status == 0) {
            throw new BusinessException("不能禁用当前登录用户");
        }

        User user = this.getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        user.setStatus(status);
        return this.updateById(user);
    }

    @Override
    public boolean updateProfile(String realName, String phone, String email, String title, String specialty, String avatar) {
        Long userId = StpUtil.getLoginIdAsLong();
        User user = this.getById(userId);
        
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        user.setRealName(realName);
        user.setPhone(phone);
        user.setEmail(email);
        user.setTitle(title);
        user.setSpecialty(specialty);
        user.setAvatar(avatar);

        return this.updateById(user);
    }

}
