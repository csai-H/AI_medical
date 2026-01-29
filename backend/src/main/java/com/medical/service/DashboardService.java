package com.medical.service;

import com.medical.entity.DiagnosisRecord;
import com.medical.vo.AccuracyDistributionVO;
import com.medical.vo.DashboardStatisticsVO;
import com.medical.vo.DashboardTrendVO;
import com.medical.vo.AgeDistributionVO;
import com.medical.vo.DiseaseDistributionVO;

import java.util.List;

/**
 * Dashboard服务接口
 *
 * @author AI Medical Team
 */
public interface DashboardService {

    /**
     * 获取统计数据
     *
     * @return 统计数据
     */
    DashboardStatisticsVO getStatistics();

    /**
     * 获取问诊趋势数据
     *
     * @param days 天数
     * @return 趋势数据
     */
    DashboardTrendVO getTrendData(Integer days);

    /**
     * 获取疾病分布数据
     *
     * @return 疾病分布列表
     */
    List<DiseaseDistributionVO> getDiseaseDistribution();

    /**
     * 获取最近的诊断记录
     *
     * @param limit 数量限制
     * @return 诊断记录列表
     */
    List<DiagnosisRecord> getRecentRecords(Integer limit);

    /**
     * 获取AI诊断准确性分布数据
     *
     * @return 准确性分布列表
     */
    List<AccuracyDistributionVO> getAccuracyDistribution();


    /**
     * 获取患者年龄分布数据
     *
     * @return 年龄分布列表
     */
    List<AgeDistributionVO> getAgeDistribution();
}
