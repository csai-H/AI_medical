package com.medical.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 患者年龄分布VO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AgeDistributionVO {
    /**
     * 年龄段标签（如"0-18岁"）
     */
    private String range;

    /**
     * 年龄段描述（如"儿童青少年"）
     */
    private String label;

    /**
     * 数量
     */
    private Integer count;
}
