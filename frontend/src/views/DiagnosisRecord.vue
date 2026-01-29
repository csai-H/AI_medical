<template>
  <div class="diagnosis-record-container">
    <el-card>
      <!-- 搜索区域 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="患者姓名">
          <el-input v-model="searchForm.patientName" placeholder="请输入患者姓名" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="待确认" :value="0" />
            <el-option label="已确认" :value="1" />
            <el-option label="已完成" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="recordNo" label="诊断编号" width="180" />
        <el-table-column prop="patientName" label="患者姓名" width="100" />
        <el-table-column prop="chiefComplaint" label="主诉" show-overflow-tooltip />
        <el-table-column prop="diagnosisType" label="诊断类型" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.diagnosisType === 0" type="warning">AI辅助</el-tag>
            <el-tag v-else type="success">人工诊断</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === 0" type="warning">待确认</el-tag>
            <el-tag v-else-if="row.status === 1" type="success">已确认</el-tag>
            <el-tag v-else type="info">已完成</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="诊断时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleView(row)">
              查看详情
            </el-button>
            <el-button
              v-if="row.status === 0"
              type="success"
              link
              size="small"
              @click="handleConfirm(row)"
            >
              确认诊断
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadData"
        @current-change="loadData"
      />
    </el-card>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="诊断详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="诊断编号">{{ currentRecord.recordNo }}</el-descriptions-item>
        <el-descriptions-item label="患者姓名">{{ currentRecord.patientName }}</el-descriptions-item>
        <el-descriptions-item label="主诉" :span="2">{{ currentRecord.chiefComplaint }}</el-descriptions-item>
        <el-descriptions-item label="现病史" :span="2">{{ currentRecord.presentIllness }}</el-descriptions-item>
        <el-descriptions-item label="AI诊断" :span="2">
          <div v-if="isAiDiagnosisJson" class="ai-diagnosis-content">
            <div v-if="getAiDiagnosisData().possibleDiseases && getAiDiagnosisData().possibleDiseases.length">
              <strong>可能的疾病：</strong>
              <ul style="margin: 5px 0; padding-left: 20px;">
                <li v-for="(disease, index) in getAiDiagnosisData().possibleDiseases" :key="index">
                  {{ disease.name }} (置信度: {{ Math.round(disease.confidence * 100) }}%)
                </li>
              </ul>
            </div>
            <div v-if="getAiDiagnosisData().features">
              <strong>皮肤特征：</strong>
              <p style="margin: 5px 0;">{{ getAiDiagnosisData().features }}</p>
            </div>
            <div v-if="getAiDiagnosisData().suggestion">
              <strong>治疗建议：</strong>
              <p style="margin: 5px 0;">{{ getAiDiagnosisData().suggestion }}</p>
            </div>
          </div>
          <div v-else style="white-space: pre-wrap;">{{ currentRecord.aiDiagnosis }}</div>
        </el-descriptions-item>
        <el-descriptions-item label="AI建议" :span="2">{{ currentRecord.aiSuggestion }}</el-descriptions-item>
        <el-descriptions-item label="医生诊断" :span="2">{{ currentRecord.doctorDiagnosis || '待确认' }}</el-descriptions-item>
        <el-descriptions-item label="治疗方案" :span="2">{{ currentRecord.treatmentPlan || '待确认' }}</el-descriptions-item>
        <el-descriptions-item label="皮肤图片" :span="2" v-if="getImageUrls().length > 0">
          <div class="image-container">
            <el-image
              v-for="(url, index) in getImageUrls()"
              :key="index"
              :src="getFullImageUrl(url)"
              :preview-src-list="getImageUrls().map(u => getFullImageUrl(u))"
              fit="cover"
              style="width: 100px; height: 100px; margin-right: 10px; margin-bottom: 10px;"
              :initial-index="index"
            />
          </div>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 确认诊断对话框 -->
    <el-dialog v-model="confirmDialogVisible" title="确认诊断" width="600px">
      <el-form ref="confirmFormRef" :model="confirmForm" label-width="100px">
        <el-form-item label="医生诊断">
          <el-input
            v-model="confirmForm.doctorDiagnosis"
            type="textarea"
            :rows="3"
            placeholder="请输入医生诊断结果"
          />
        </el-form-item>
        <el-form-item label="治疗方案">
          <el-input
            v-model="confirmForm.treatmentPlan"
            type="textarea"
            :rows="4"
            placeholder="请输入治疗方案"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="confirmDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getDiagnosisRecordPage, confirmDiagnosis } from '@/api/diagnosis'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const detailDialogVisible = ref(false)
const confirmDialogVisible = ref(false)
const confirmFormRef = ref(null)

const searchForm = reactive({
  patientName: '',
  status: null
})

const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

const currentRecord = ref({})
const confirmForm = reactive({
  recordId: null,
  doctorDiagnosis: '',
  treatmentPlan: ''
})

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const res = await getDiagnosisRecordPage({
      current: page.current,
      size: page.size,
      ...searchForm
    })
    tableData.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  page.current = 1
  loadData()
}

// 重置
const handleReset = () => {
  searchForm.patientName = ''
  searchForm.status = null
  handleSearch()
}

// 查看详情
const handleView = (row) => {
  currentRecord.value = row
  detailDialogVisible.value = true
}

// 获取图片URL列表
const getImageUrls = () => {
  if (!currentRecord.value.imageUrls) return []
  try {
    return JSON.parse(currentRecord.value.imageUrls)
  } catch {
    return []
  }
}

// 判断AI诊断是否为JSON格式
const isAiDiagnosisJson = () => {
  if (!currentRecord.value.aiDiagnosis) return false
  try {
    const parsed = JSON.parse(currentRecord.value.aiDiagnosis)
    return typeof parsed === 'object' && parsed !== null
  } catch {
    return false
  }
}

// 解析AI诊断数据
const getAiDiagnosisData = () => {
  if (!currentRecord.value.aiDiagnosis) return {}
  try {
    return JSON.parse(currentRecord.value.aiDiagnosis)
  } catch {
    return {}
  }
}

// 获取完整图片URL
const getFullImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080'
  return baseUrl + url
}

// 确认诊断
const handleConfirm = (row) => {
  confirmForm.recordId = row.id
  confirmForm.doctorDiagnosis = ''
  confirmForm.treatmentPlan = ''
  confirmDialogVisible.value = true
}

// 提交确认
const handleConfirmSubmit = async () => {
  try {
    await confirmDiagnosis(confirmForm)
    ElMessage.success('确认成功')
    confirmDialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error('确认失败')
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.diagnosis-record-container {
  padding: 0;
}

.search-form {
  margin-bottom: 20px;
}

.el-pagination {
  margin-top: 20px;
  justify-content: flex-end;
}
</style>
