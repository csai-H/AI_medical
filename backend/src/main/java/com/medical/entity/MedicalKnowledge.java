package com.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 医疗知识库实体类
 *
 * @author AI Medical Team
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("medical_knowledge")
public class MedicalKnowledge {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 知识标题
     */
    private String title;

    /**
     * 疾病名称
     */
    private String diseaseName;

    /**
     * 疾病分类
     */
    private String category;

    /**
     * 症状描述
     */
    private String symptoms;

    /**
     * 病因
     */
    private String etiology;

    /**
     * 诊断方法
     */
    private String diagnosisMethods;

    /**
     * 治疗方案
     */
    private String treatment;

    /**
     * 用药建议
     */
    private String medicationAdvice;

    /**
     * 预防措施
     */
    private String prevention;

    /**
     * 注意事项
     */
    private String precautions;

    /**
     * 参考文献
     */
    @TableField("`references`")
    private String references;

    /**
     * 标签(逗号分隔)
     */
    private String tags;

    /**
     * 知识来源: 0-系统预设, 1-人工录入
     */
    private Integer source;

    /**
     * 审核状态: 0-待审核, 1-已审核
     */
    private Integer auditStatus;

    /**
     * 审核人ID
     */
    private Long auditorId;

    /**
     * 审核时间
     */
    private LocalDateTime auditTime;

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
