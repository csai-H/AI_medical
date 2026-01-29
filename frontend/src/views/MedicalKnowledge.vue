<template>
  <div class="medical-knowledge-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>医疗知识库</span>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="疾病名称">
          <el-input v-model="searchForm.diseaseName" placeholder="请输入疾病名称" clearable />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="searchForm.category" placeholder="请选择分类" clearable>
            <el-option label="呼吸系统" value="呼吸系统" />
            <el-option label="消化系统" value="消化系统" />
            <el-option label="心血管系统" value="心血管系统" />
            <el-option label="神经系统" value="神经系统" />
            <el-option label="内分泌系统" value="内分泌系统" />
            <el-option label="泌尿系统" value="泌尿系统" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 知识卡片列表 -->
      <div v-loading="loading" class="knowledge-list">
        <el-empty v-if="tableData.length === 0 && !loading" description="暂无数据" />

        <el-row :gutter="20">
          <el-col
            v-for="item in tableData"
            :key="item.id"
            :xs="24"
            :sm="12"
            :md="8"
            :lg="6"
            class="knowledge-col"
          >
            <el-card class="knowledge-card" shadow="hover" @click="handleView(item)">
              <template #header>
                <div class="card-title">
                  <el-tag size="small" type="primary">{{ item.category }}</el-tag>
                </div>
              </template>

              <div class="card-content">
                <h3 class="disease-name">{{ item.diseaseName }}</h3>
                <div class="symptoms">
                  <div class="label">症状：</div>
                  <div class="text">{{ item.symptoms }}</div>
                </div>
                <div class="tags" v-if="item.tags">
                  <el-tag
                    v-for="(tag, index) in item.tags.split(',')"
                    :key="index"
                    size="small"
                    class="tag-item"
                  >
                    {{ tag }}
                  </el-tag>
                </div>
              </div>

              <template #footer>
                <div class="card-footer">
                  <el-button type="primary" link size="small">查看详情</el-button>
                </div>
              </template>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[12, 24, 48]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadData"
        @current-change="loadData"
      />
    </el-card>

    <!-- 查看详情对话框 -->
    <el-dialog v-model="viewDialogVisible" title="医疗知识详情" width="800px">
      <div class="knowledge-detail" v-if="currentKnowledge.id">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="疾病名称">
            <span class="detail-title">{{ currentKnowledge.diseaseName }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="分类">
            <el-tag type="primary">{{ currentKnowledge.category }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="症状">
            <div class="detail-content">{{ currentKnowledge.symptoms }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="病因">
            <div class="detail-content">{{ currentKnowledge.etiology || '暂无' }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="诊断方法">
            <div class="detail-content">{{ currentKnowledge.diagnosisMethods || '暂无' }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="治疗方案">
            <div class="detail-content">{{ currentKnowledge.treatment || '暂无' }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="用药建议">
            <div class="detail-content">{{ currentKnowledge.medicationAdvice || '暂无' }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="预防措施">
            <div class="detail-content">{{ currentKnowledge.prevention || '暂无' }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="注意事项">
            <div class="detail-content warning-text">{{ currentKnowledge.precautions || '暂无' }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="标签" v-if="currentKnowledge.tags">
            <div class="tags-list">
              <el-tag
                v-for="(tag, index) in currentKnowledge.tags.split(',')"
                :key="index"
                size="small"
                class="tag-item"
              >
                {{ tag }}
              </el-tag>
            </div>
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getKnowledgePage
} from '@/api/knowledge'

const loading = ref(false)
const tableData = ref([])

const searchForm = reactive({
  diseaseName: '',
  category: ''
})

const page = reactive({
  current: 1,
  size: 12,
  total: 0
})

// 查看详情对话框
const viewDialogVisible = ref(false)
const currentKnowledge = ref({})

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const params = {
      current: page.current,
      size: page.size,
      diseaseName: searchForm.diseaseName || undefined,
      category: searchForm.category || undefined
    }
    const res = await getKnowledgePage(params)
    tableData.value = res.data.records
    page.total = res.data.total
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
  searchForm.diseaseName = ''
  searchForm.category = ''
  page.current = 1
  loadData()
}

// 查看详情
const handleView = (item) => {
  currentKnowledge.value = item
  viewDialogVisible.value = true
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.medical-knowledge-container {
  padding: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
  font-size: 18px;
}

.search-form {
  margin-bottom: 20px;
}

.knowledge-list {
  min-height: 400px;
  margin-bottom: 20px;
}

.knowledge-col {
  margin-bottom: 20px;
}

.knowledge-card {
  cursor: pointer;
  transition: all 0.3s;
  height: 100%;
}

.knowledge-card:hover {
  transform: translateY(-5px);
}

.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-content {
  padding: 10px 0;
}

.disease-name {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
  margin: 0 0 10px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.symptoms {
  margin-bottom: 10px;
  font-size: 14px;
}

.symptoms .label {
  font-weight: bold;
  color: #606266;
  margin-bottom: 5px;
}

.symptoms .text {
  color: #909399;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-top: 10px;
}

.tag-item {
  margin: 0;
}

.card-footer {
  text-align: center;
}

.knowledge-detail {
  padding: 10px 0;
}

.detail-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.detail-content {
  line-height: 1.8;
  color: #606266;
  white-space: pre-wrap;
  word-break: break-word;
}

.warning-text {
  color: #E6A23C;
  font-weight: 500;
}

.tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.el-pagination {
  margin-top: 20px;
  justify-content: center;
}
</style>
