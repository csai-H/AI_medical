package com.medical.vo;

import lombok.Data;

/**
 * AI诊断准确性分布VO
 */
@Data
public class AccuracyDistributionVO {
    /**
     * 准确率区间（如：90-100%, 80-90%等）
     */
    private String range;

    /**
     * 准确性标签（如：完全准确、非常准确、准确等）
     */
    private String label;

    /**
     * 该区间的诊断数量
     */
    private Integer count;

    public AccuracyDistributionVO(String range, String label, Integer count) {
        this.range = range;
        this.label = label;
        this.count = count;
    }

    public AccuracyDistributionVO() {
    }
}
