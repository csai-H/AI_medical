package com.medical.aspect;

import cn.dev33.satoken.stp.StpUtil;
import com.medical.annotation.RequiredPermission;
import com.medical.exception.BusinessException;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * 权限校验AOP切面
 *
 * @author AI Medical Team
 */
@Aspect
@Component
public class RequiredPermissionAspect {

    private static final Logger logger = LoggerFactory.getLogger(RequiredPermissionAspect.class);

    /**
     * 拦截@RequiredPermission注解,进行权限校验
     *
     * @param joinPoint 连接点
     * @param requiredPermission 权限注解
     */
    @Before("@annotation(requiredPermission)")
    public void checkPermission(JoinPoint joinPoint, RequiredPermission requiredPermission) {
        String permission = requiredPermission.value();
        String description = requiredPermission.description();

        // 检查用户是否登录
        if (!StpUtil.isLogin()) {
            logger.warn("用户未登录,尝试访问需要权限的方法: {}", joinPoint.getSignature().toShortString());
            throw new BusinessException("用户未登录,请先登录");
        }

        // 检查权限
        if (!StpUtil.hasPermission(permission)) {
            Long userId = StpUtil.getLoginIdAsLong();
            logger.warn("用户{} 无权限访问 {}, 需要权限: {}",
                userId, joinPoint.getSignature().toShortString(), permission);
            throw new BusinessException("权限不足,无法访问该功能");
        }

        logger.debug("用户{} 通过权限校验: {}", StpUtil.getLoginIdAsLong(), permission);
    }
}
