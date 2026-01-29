package com.medical.vo;

import lombok.Data;
import java.math.BigDecimal;

/**
 * Dashboard统计数据VO
 */
@Data
public class DashboardStatisticsVO {
    /**
     * 患者总数
     */
    private Long patientCount;

    /**
     * 今日问诊数
     */
    private Integer todayDiagnosisCount;

    /**
     * AI辅助诊断数
     */
    private Integer aiDiagnosisCount;

    /**
     * 诊断准确率
     */
    private BigDecimal accuracyRate;
}
