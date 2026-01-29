<template>
  <div class="skin-analysis-container">
    <el-alert
      title="AI辅助诊断仅供参考，如有不适请及时就医"
      type="warning"
      :closable="false"
      show-icon
      style="margin-bottom: 20px"
    />

    <el-row :gutter="20">
      <!-- 左侧：上传区域 -->
      <el-col :span="12">
        <el-card v-loading="loading">
          <template #header>
            <div class="card-header">
              <span>上传皮肤图片</span>
            </div>
          </template>

          <el-form :model="form" label-width="100px">
            <el-form-item label="患者姓名">
              <el-input v-model="patientInfo.name" disabled />
            </el-form-item>

            <el-form-item label="症状描述">
              <el-input
                v-model="form.description"
                type="textarea"
                :rows="4"
                placeholder="请描述您的症状，如：瘙痒、疼痛、持续时间等（可选）"
              />
            </el-form-item>

            <el-form-item label="上传图片">
              <el-upload
                v-model:file-list="fileList"
                :action="`${baseUrl}/skin-analysis/upload`"
                list-type="picture-card"
                :on-preview="handlePicturePreview"
                :on-success="handleUploadSuccess"
                :on-remove="handleRemove"
                :before-upload="beforeUpload"
                :limit="5"
                :auto-upload="false"
                accept="image/*"
              >
                <el-icon><Plus /></el-icon>
              </el-upload>

              <el-dialog v-model="previewDialogVisible" title="预览">
                <img :src="previewImage" style="width: 100%" />
              </el-dialog>
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="handleSubmit" :loading="loading">
                开始分析
              </el-button>
              <el-button @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <!-- 右侧：分析结果 -->
      <el-col :span="12">
        <el-card v-if="analysisResult">
          <template #header>
            <div class="card-header">
              <span>AI分析结果</span>
            </div>
          </template>

          <div class="result-section">
            <el-descriptions title="皮肤特征" :column="1" border>
              <el-descriptions-item label="特征描述">
                {{ analysisResult.features }}
              </el-descriptions-item>
              <el-descriptions-item label="严重程度">
                <el-tag :type="getSeverityType(analysisResult.severity)">
                  {{ analysisResult.severity }}
                </el-tag>
              </el-descriptions-item>
            </el-descriptions>
          </div>

          <div class="result-section">
            <h4>可能的疾病</h4>
            <el-table :data="analysisResult.possibleDiseases || []" border>
              <el-table-column prop="name" label="疾病名称" />
              <el-table-column prop="confidence" label="置信度" width="150">
                <template #default="{ row }">
                  <el-progress
                    :percentage="Math.round(row.confidence * 100)"
                    :color="getConfidenceColor(row.confidence)"
                  />
                </template>
              </el-table-column>
            </el-table>
          </div>

          <div class="result-section">
            <h4>治疗建议</h4>
            <el-alert
              :title="analysisResult.suggestion"
              type="info"
              :closable="false"
            />
          </div>

          <div class="result-section">
            <el-descriptions title="就医建议" :column="1" border>
              <el-descriptions-item label="是否需要就医">
                <el-tag :type="analysisResult.needDoctor ? 'warning' : 'success'">
                  {{ analysisResult.needDoctor ? '是' : '否' }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="紧急程度">
                <el-tag :type="getUrgencyType(analysisResult.urgency)">
                  {{ analysisResult.urgency }}
                </el-tag>
              </el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>

        <el-empty v-else description="请上传图片并开始分析" />
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { analyzeSkinImages } from '@/api/skin-analysis'
import { getMyPatientInfo } from '@/api/patient'
import { useUserStore } from '@/stores/user'

const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080'
const userStore = useUserStore()

const form = ref({
  patientId: null,
  description: ''
})

const fileList = ref([])
const patientInfo = ref({
  id: null,
  name: '',
  age: null,
  gender: null
})
const loading = ref(false)
const analysisResult = ref(null)
const previewDialogVisible = ref(false)
const previewImage = ref('')

// 获取当前患者信息
const fetchMyPatientInfo = async () => {
  try {
    const res = await getMyPatientInfo()
    if (res.code === 200 && res.data) {
      patientInfo.value = res.data
      form.value.patientId = res.data.id
    } else {
      ElMessage.warning('未找到患者信息，请先完善个人信息')
    }
  } catch (error) {
    console.error('获取患者信息失败:', error)
    ElMessage.error('获取患者信息失败，请先完善个人信息')
  }
}

// 图片预览
const handlePicturePreview = (file) => {
  previewImage.value = file.url
  previewDialogVisible.value = true
}

// 上传成功
const handleUploadSuccess = (response, file) => {
  console.log('上传成功:', response)
}

// 移除图片
const handleRemove = (file) => {
  console.log('移除图片:', file)
}

// 上传前校验
const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB!')
    return false
  }
  return true
}

// 提交分析
const handleSubmit = async () => {
  if (!form.value.patientId) {
    ElMessage.warning('未找到患者信息，请先完善个人信息')
    return
  }

  if (fileList.value.length === 0) {
    ElMessage.warning('请至少上传一张图片')
    return
  }

  loading.value = true
  try {
    const res = await analyzeSkinImages({
      patientId: form.value.patientId,
      description: form.value.description,
      images: fileList.value
    })

    if (res.code === 200) {
      analysisResult.value = res.data
      ElMessage.success('分析成功')
    } else {
      ElMessage.error(res.message || '分析失败')
    }
  } catch (error) {
    console.error('分析失败:', error)
    ElMessage.error('分析失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  form.value = {
    patientId: null,
    description: ''
  }
  fileList.value = []
  analysisResult.value = null
}

// 获取完整图片URL
const getFullImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return baseUrl + url
}

// 获取严重程度类型
const getSeverityType = (severity) => {
  const map = {
    '轻微': 'success',
    '轻度': 'success',
    '中度': 'warning',
    '严重': 'danger',
    '重度': 'danger',
    '需要关注': 'warning',
    '待进一步评估': 'info'
  }
  return map[severity] || 'info'
}

// 获取置信度颜色
const getConfidenceColor = (confidence) => {
  if (confidence >= 0.8) return '#67c23a'
  if (confidence >= 0.6) return '#e6a23c'
  return '#f56c6c'
}

// 获取紧急程度类型
const getUrgencyType = (urgency) => {
  const map = {
    '不需要': 'success',
    '一般': 'info',
    '建议就医': 'warning',
    '需要观察': 'info',
    '紧急': 'danger',
    '建议咨询医生': 'info'
  }
  return map[urgency] || 'info'
}

onMounted(() => {
  fetchMyPatientInfo()
})
</script>

<style scoped>
.skin-analysis-container {
  padding: 20px;
}

.page-header-content {
  display: flex;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
}

.card-header {
  font-weight: bold;
}

.result-section {
  margin-bottom: 20px;
}

.result-section h4 {
  margin-bottom: 10px;
  color: #333;
}
</style>
