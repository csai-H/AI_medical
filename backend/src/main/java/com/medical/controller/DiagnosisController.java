package com.medical.controller;

import cn.dev33.satoken.annotation.SaCheckPermission;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.medical.common.Result;
import com.medical.dto.AiDiagnosisDTO;
import com.medical.entity.DiagnosisRecord;
import com.medical.service.DiagnosisRecordService;
import com.medical.service.SparkAiService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

/**
 * AI诊断控制器
 *
 * @author AI Medical Team
 */
@RestController
@RequestMapping("/diagnosis")
@RequiredArgsConstructor
public class DiagnosisController {

    private final SparkAiService sparkAiService;
    private final DiagnosisRecordService diagnosisRecordService;

    /**
     * AI智能诊断
     */
    @PostMapping("/ai")
    @SaCheckPermission("diagnosis:ai")
    public Result<Map<String, Object>> aiDiagnosis(@RequestBody AiDiagnosisDTO dto) {
        try {
            Map<String, Object> result = sparkAiService.aiDiagnosis(dto);
            return Result.success("AI诊断完成", result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * AI对话问诊
     */
    @PostMapping("/chat")
    public Result<String> chat(@RequestBody Map<String, String> params) {
        try {
            String message = params.get("message");
            String sessionId = params.get("sessionId");

            if (message == null || message.isEmpty()) {
                return Result.error("消息不能为空");
            }

            // 调用AI服务
            String response = sparkAiService.chat(message, sessionId);
            return Result.success(response);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("AI处理失败: " + e.getMessage());
        }
    }

    /**
     * 分页查询诊断记录
     */
    @GetMapping("/page")
    @SaCheckPermission("diagnosis:record")
    public Result<Page<DiagnosisRecord>> page(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String patientName,
            @RequestParam(required = false) Integer status) {

        Page<DiagnosisRecord> page = new Page<>(current, size);
        LambdaQueryWrapper<DiagnosisRecord> wrapper = new LambdaQueryWrapper<>();

        if (patientName != null && !patientName.isEmpty()) {
            wrapper.like(DiagnosisRecord::getPatientName, patientName);
        }

        if (status != null) {
            wrapper.eq(DiagnosisRecord::getStatus, status);
        }

        wrapper.orderByDesc(DiagnosisRecord::getCreateTime);

        Page<DiagnosisRecord> result = diagnosisRecordService.page(page, wrapper);
        return Result.success(result);
    }

    /**
     * 根据ID查询诊断记录
     */
    @GetMapping("/{id}")
    @SaCheckPermission("diagnosis:detail")
    public Result<DiagnosisRecord> getById(@PathVariable Long id) {
        DiagnosisRecord record = diagnosisRecordService.getById(id);
        if (record == null) {
            return Result.error("记录不存在");
        }
        return Result.success(record);
    }

    /**
     * 医生确认诊断
     */
    @PutMapping("/confirm")
    public Result<Void> confirmDiagnosis(@RequestBody Map<String, Object> params) {
        try {
            Long recordId = Long.parseLong(params.get("recordId").toString());
            String doctorDiagnosis = (String) params.get("doctorDiagnosis");
            String treatmentPlan = (String) params.get("treatmentPlan");
            
            // 获取匹配度（如果提供）
            Object matchRateObj = params.get("matchRate");
            BigDecimal matchRate = null;
            if (matchRateObj != null) {
                if (matchRateObj instanceof Number) {
                    matchRate = new BigDecimal(matchRateObj.toString());
                } else if (matchRateObj instanceof String) {
                    matchRate = new BigDecimal((String) matchRateObj);
                }
            }

            DiagnosisRecord record = diagnosisRecordService.getById(recordId);
            if (record == null) {
                return Result.error("记录不存在");
            }

            record.setDoctorDiagnosis(doctorDiagnosis);
            record.setTreatmentPlan(treatmentPlan);
            record.setMatchRate(matchRate); // 设置匹配度
            record.setStatus(1); // 已确认

            diagnosisRecordService.updateById(record);
            return Result.success("确认成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 完成诊断
     */
    @PutMapping("/complete/{id}")
    public Result<Void> complete(@PathVariable Long id) {
        DiagnosisRecord record = diagnosisRecordService.getById(id);
        if (record == null) {
            return Result.error("记录不存在");
        }

        record.setStatus(2); // 已完成
        diagnosisRecordService.updateById(record);
        return Result.success("诊断已完成", null);
    }

}
