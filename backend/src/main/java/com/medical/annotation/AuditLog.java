package com.medical.annotation;

import java.lang.annotation.*;

/**
 * 操作日志注解
 * 
 * @author AI Medical Team
 */
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface AuditLog {
    
    /**
     * 操作模块
     */
    String module() default "";
    
    /**
     * 操作类型
     */
    String operation() default "";
    
    /**
     * 是否保存请求参数
     */
    boolean saveParams() default true;
}
