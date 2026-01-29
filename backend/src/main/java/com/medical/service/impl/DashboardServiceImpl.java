package com.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.entity.DiagnosisRecord;
import com.medical.entity.Patient;
import com.medical.mapper.DiagnosisRecordMapper;
import com.medical.mapper.PatientMapper;
import com.medical.service.DashboardService;
import com.medical.vo.AccuracyDistributionVO;
import com.medical.vo.DashboardStatisticsVO;
import com.medical.vo.DashboardTrendVO;
import com.medical.vo.DiseaseDistributionVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Dashboard服务实现类
 *
 * @author AI Medical Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final PatientMapper patientMapper;
    private final DiagnosisRecordMapper diagnosisRecordMapper;
    private final ObjectMapper objectMapper;

    @Override
    public DashboardStatisticsVO getStatistics() {
        DashboardStatisticsVO vo = new DashboardStatisticsVO();

        // 患者总数
        Long patientCount = patientMapper.selectCount(null);
        vo.setPatientCount(patientCount != null ? patientCount : 0L);

        // 今日问诊数
        LocalDateTime todayStart = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        LocalDateTime todayEnd = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);

        LambdaQueryWrapper<DiagnosisRecord> todayWrapper = new LambdaQueryWrapper<>();
        todayWrapper.between(DiagnosisRecord::getCreateTime, todayStart, todayEnd);
        Long todayCount = diagnosisRecordMapper.selectCount(todayWrapper);
        vo.setTodayDiagnosisCount(todayCount != null ? todayCount.intValue() : 0);

        // AI辅助诊断数（诊断类型为0）
        LambdaQueryWrapper<DiagnosisRecord> aiWrapper = new LambdaQueryWrapper<>();
        aiWrapper.eq(DiagnosisRecord::getDiagnosisType, 0);
        Long aiCount = diagnosisRecordMapper.selectCount(aiWrapper);
        vo.setAiDiagnosisCount(aiCount != null ? aiCount.intValue() : 0);

        // 诊断准确率（计算有医生确认且matchRate不为null的记录的平均matchRate）
        LambdaQueryWrapper<DiagnosisRecord> accuracyWrapper = new LambdaQueryWrapper<>();
        accuracyWrapper.isNotNull(DiagnosisRecord::getMatchRate)
                .eq(DiagnosisRecord::getStatus, 1); // 已确认
        List<DiagnosisRecord> recordsWithMatchRate = diagnosisRecordMapper.selectList(accuracyWrapper);

        if (recordsWithMatchRate != null && !recordsWithMatchRate.isEmpty()) {
            BigDecimal totalRate = recordsWithMatchRate.stream()
                    .map(DiagnosisRecord::getMatchRate)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            BigDecimal averageRate = totalRate.divide(
                    BigDecimal.valueOf(recordsWithMatchRate.size()),
                    2,
                    RoundingMode.HALF_UP
            );
            vo.setAccuracyRate(averageRate);
        } else {
            vo.setAccuracyRate(BigDecimal.ZERO);
        }

        return vo;
    }

    @Override
    public DashboardTrendVO getTrendData(Integer days) {
        if (days == null || days <= 0) {
            days = 7;
        }

        DashboardTrendVO vo = new DashboardTrendVO();
        List<String> dates = new ArrayList<>();
        List<Integer> diagnosisCounts = new ArrayList<>();
        List<Integer> aiDiagnosisCounts = new ArrayList<>();

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd");

        for (int i = days - 1; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            String dateStr = date.format(formatter);
            dates.add(dateStr);

            LocalDateTime dayStart = LocalDateTime.of(date, LocalTime.MIN);
            LocalDateTime dayEnd = LocalDateTime.of(date, LocalTime.MAX);

            // 当天总问诊数
            LambdaQueryWrapper<DiagnosisRecord> totalWrapper = new LambdaQueryWrapper<>();
            totalWrapper.between(DiagnosisRecord::getCreateTime, dayStart, dayEnd);
            Long totalCount = diagnosisRecordMapper.selectCount(totalWrapper);
            diagnosisCounts.add(totalCount != null ? totalCount.intValue() : 0);

            // 当天AI诊断数
            LambdaQueryWrapper<DiagnosisRecord> aiWrapper = new LambdaQueryWrapper<>();
            aiWrapper.between(DiagnosisRecord::getCreateTime, dayStart, dayEnd)
                    .eq(DiagnosisRecord::getDiagnosisType, 0);
            Long aiCount = diagnosisRecordMapper.selectCount(aiWrapper);
            aiDiagnosisCounts.add(aiCount != null ? aiCount.intValue() : 0);
        }

        vo.setDates(dates);
        vo.setDiagnosisCounts(diagnosisCounts);
        vo.setAiDiagnosisCounts(aiDiagnosisCounts);

        return vo;
    }

    @Override
    public List<DiseaseDistributionVO> getDiseaseDistribution() {
        // 查询所有诊断记录
        LambdaQueryWrapper<DiagnosisRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.isNotNull(DiagnosisRecord::getAiDiagnosis);
        List<DiagnosisRecord> records = diagnosisRecordMapper.selectList(wrapper);

        // 统计疾病分布
        Map<String, Integer> diseaseMap = new HashMap<>();

        for (DiagnosisRecord record : records) {
            String aiDiagnosisJson = record.getAiDiagnosis();
            if (aiDiagnosisJson != null && !aiDiagnosisJson.isEmpty()) {
                try {
                    JsonNode rootNode = objectMapper.readTree(aiDiagnosisJson);

                    // 尝试解析不同的JSON格式
                    String diseaseName = null;

                    // 格式1: {"disease": "xxx", ...}
                    if (rootNode.has("disease")) {
                        diseaseName = rootNode.get("disease").asText();
                    }
                    // 格式2: [{"name": "xxx"}, ...]
                    else if (rootNode.isArray() && rootNode.size() > 0) {
                        JsonNode firstItem = rootNode.get(0);
                        if (firstItem.has("name")) {
                            diseaseName = firstItem.get("name").asText();
                        } else if (firstItem.has("disease")) {
                            diseaseName = firstItem.get("disease").asText();
                        }
                    }
                    // 格式3: {"name": "xxx", ...}
                    else if (rootNode.has("name")) {
                        diseaseName = rootNode.get("name").asText();
                    }

                    if (diseaseName != null && !diseaseName.isEmpty()) {
                        diseaseMap.put(diseaseName, diseaseMap.getOrDefault(diseaseName, 0) + 1);
                    }
                } catch (JsonProcessingException e) {
                    log.warn("解析AI诊断结果失败: {}", aiDiagnosisJson, e);
                }
            }
        }

        // 转换为VO列表并按数量降序排序
        List<DiseaseDistributionVO> result = diseaseMap.entrySet().stream()
                .map(entry -> {
                    DiseaseDistributionVO vo = new DiseaseDistributionVO();
                    vo.setName(entry.getKey());
                    vo.setValue(entry.getValue());
                    return vo;
                })
                .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
                .collect(Collectors.toList());

        return result;
    }

    @Override
    public List<DiagnosisRecord> getRecentRecords(Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 5;
        }

        LambdaQueryWrapper<DiagnosisRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(DiagnosisRecord::getCreateTime)
                .last("LIMIT " + limit);

        return diagnosisRecordMapper.selectList(wrapper);
    }

    @Override
    public List<AccuracyDistributionVO> getAccuracyDistribution() {
        // 查询所有已确认且有匹配度的记录
        LambdaQueryWrapper<DiagnosisRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.isNotNull(DiagnosisRecord::getMatchRate)
                .eq(DiagnosisRecord::getStatus, 1); // 已确认
        List<DiagnosisRecord> records = diagnosisRecordMapper.selectList(wrapper);

        // 初始化各个准确率类别的计数
        Map<String, AccuracyDistributionVO> distributionMap = new LinkedHashMap<>();
        distributionMap.put("100", new AccuracyDistributionVO("100%", "完全准确", 0));
        distributionMap.put("90", new AccuracyDistributionVO("90%", "非常准确", 0));
        distributionMap.put("80", new AccuracyDistributionVO("80%", "准确", 0));
        distributionMap.put("70", new AccuracyDistributionVO("70%", "基本准确", 0));
        distributionMap.put("60", new AccuracyDistributionVO("60%", "部分准确", 0));
        distributionMap.put("50", new AccuracyDistributionVO("50%", "不太准确", 0));
        distributionMap.put("30", new AccuracyDistributionVO("30%", "基本不准确", 0));
        distributionMap.put("0", new AccuracyDistributionVO("0%", "完全不准确", 0));

        // 统计各个类别的数量
        for (DiagnosisRecord record : records) {
            BigDecimal matchRate = record.getMatchRate();
            if (matchRate != null) {
                int rate = matchRate.intValue();
                String key = String.valueOf(rate);

                // 只统计预定义的准确率值
                if (distributionMap.containsKey(key)) {
                    AccuracyDistributionVO vo = distributionMap.get(key);
                    vo.setCount(vo.getCount() + 1);
                }
            }
        }

        // 转换为VO列表（过滤掉数量为0的项）
        return distributionMap.values().stream()
                .filter(vo -> vo.getCount() > 0)
                .collect(Collectors.toList());
    }
}
