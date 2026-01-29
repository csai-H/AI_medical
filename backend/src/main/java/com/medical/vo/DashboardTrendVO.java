package com.medical.vo;

import lombok.Data;
import java.util.List;

/**
 * Dashboard趋势数据VO
 */
@Data
public class DashboardTrendVO {
    /**
     * 日期数组
     */
    private List<String> dates;

    /**
     * 问诊总数
     */
    private List<Integer> diagnosisCounts;

    /**
     * AI诊断数
     */
    private List<Integer> aiDiagnosisCounts;
}
