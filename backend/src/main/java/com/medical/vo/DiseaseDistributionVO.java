package com.medical.vo;

import lombok.Data;

/**
 * 疾病分布VO
 */
@Data
public class DiseaseDistributionVO {
    /**
     * 疾病类型
     */
    private String name;

    /**
     * 数量
     */
    private Integer value;
}
