package com.medical.controller;

import com.medical.common.Result;
import com.medical.entity.DiagnosisRecord;
import com.medical.service.DashboardService;
import com.medical.vo.AccuracyDistributionVO;
import com.medical.vo.DashboardStatisticsVO;
import com.medical.vo.DashboardTrendVO;
import com.medical.vo.DiseaseDistributionVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Dashboard控制器
 *
 * @author AI Medical Team
 */
@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    /**
     * 获取统计数据
     */
    @GetMapping("/statistics")
    public Result<DashboardStatisticsVO> getStatistics() {
        try {
            DashboardStatisticsVO statistics = dashboardService.getStatistics();
            return Result.success(statistics);
        } catch (Exception e) {
            return Result.error("获取统计数据失败: " + e.getMessage());
        }
    }

    /**
     * 获取问诊趋势数据
     */
    @GetMapping("/trend")
    public Result<DashboardTrendVO> getTrendData(
            @RequestParam(defaultValue = "7") Integer days) {
        try {
            DashboardTrendVO trend = dashboardService.getTrendData(days);
            return Result.success(trend);
        } catch (Exception e) {
            return Result.error("获取趋势数据失败: " + e.getMessage());
        }
    }

    /**
     * 获取疾病分布数据
     */
    @GetMapping("/disease-distribution")
    public Result<List<DiseaseDistributionVO>> getDiseaseDistribution() {
        try {
            List<DiseaseDistributionVO> distribution = dashboardService.getDiseaseDistribution();
            return Result.success(distribution);
        } catch (Exception e) {
            return Result.error("获取疾病分布失败: " + e.getMessage());
        }
    }

    /**
     * 获取最近的诊断记录
     */
    @GetMapping("/recent-records")
    public Result<List<DiagnosisRecord>> getRecentRecords(
            @RequestParam(defaultValue = "5") Integer limit) {
        try {
            List<DiagnosisRecord> records = dashboardService.getRecentRecords(limit);
            return Result.success(records);
        } catch (Exception e) {
            return Result.error("获取最近记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取AI诊断准确性分布
     */
    @GetMapping("/accuracy-distribution")
    public Result<List<AccuracyDistributionVO>> getAccuracyDistribution() {
        try {
            List<AccuracyDistributionVO> distribution = dashboardService.getAccuracyDistribution();
            return Result.success(distribution);
        } catch (Exception e) {
            return Result.error("获取准确性分布失败: " + e.getMessage());
        }
    }
}
