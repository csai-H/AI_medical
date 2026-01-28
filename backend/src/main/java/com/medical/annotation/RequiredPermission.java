package com.medical.annotation;

import java.lang.annotation.*;

/**
 * 权限校验注解
 * 
 * @author AI Medical Team
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequiredPermission {
    
    /**
     * 需要的权限编码
     */
    String value();
    
    /**
     * 权限描述
     */
    String description() default "";
}
