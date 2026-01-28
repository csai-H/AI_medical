package com.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 患者实体类
 *
 * @author AI Medical Team
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("patient")
public class Patient {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 患者编号
     */
    private String patientNo;

    /**
     * 姓名
     */
    private String name;

    /**
     * 性别: 0-女, 1-男
     */
    private Integer gender;

    /**
     * 年龄
     */
    private Integer age;

    /**
     * 出生日期
     */
    private LocalDate birthday;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 身份证号
     */
    private String idCard;

    /**
     * 地址
     */
    private String address;

    /**
     * 过敏史
     */
    private String allergyHistory;

    /**
     * 既往病史
     */
    private String pastHistory;

    /**
     * 家族病史
     */
    private String familyHistory;

    /**
     * 备注
     */
    private String remark;

    /**
     * 关联的用户ID
     */
    private Long userId;

    /**
     * 创建人ID
     */
    private Long createBy;

    /**
     * 逻辑删除
     */
    @TableLogic
    private Integer deleted;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

}
