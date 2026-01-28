package com.medical.config;

import cn.dev33.satoken.interceptor.SaInterceptor;
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * SaToken配置类
 *
 * @author AI Medical Team
 */
@Configuration
public class SaTokenConfig implements WebMvcConfigurer {

    /**
     * 注册SaToken拦截器
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 注册SaToken拦截器，校验规则为StpUtil.checkLogin()登录校验
        registry.addInterceptor(new SaInterceptor(handle -> StpUtil.checkLogin()))
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/auth/login",
                        "/auth/register",
                        "/diagnosis/chat",  // AI问诊接口不需要登录（仅用于测试）
                        "/ws/**",
                        "/error",
                        "/swagger-resources/**",
                        "/v3/api-docs/**",
                        "/doc.html",
                        "/webjars/**",
                        "/favicon.ico"
                );

        // 注册SaToken权限拦截器，校验规则为StpUtil.checkLogin()登录校验
        // 权限校验在具体业务方法中使用@SaCheckPermission注解
        registry.addInterceptor(new SaInterceptor(handle -> StpUtil.checkLogin()))
                .addPathPatterns(
                        "/user/**",
                        "/patient/**",
                        "/diagnosis/**",
                        "/system/**"
                )
                .excludePathPatterns(
                        "/auth/**",
                        "/diagnosis/chat",  // AI问诊接口不需要权限验证（仅用于测试）
                        "/ws/**"
                );
    }

}
