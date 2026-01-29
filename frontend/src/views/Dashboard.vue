<template>
  <div class="dashboard-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card v-loading="statsLoading" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #409EFF">
              <el-icon :size="30"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.patientCount }}</div>
              <div class="stat-label">患者总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card v-loading="statsLoading" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #67C23A">
              <el-icon :size="30"><DocumentChecked /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.diagnosisCount }}</div>
              <div class="stat-label">今日问诊</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card v-loading="statsLoading" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #E6A23C">
              <el-icon :size="30"><ChatLineRound /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.aiDiagnosisCount }}</div>
              <div class="stat-label">AI辅助诊断</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card v-loading="statsLoading" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #F56C6C">
              <el-icon :size="30"><TrendCharts /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.accuracy }}%</div>
              <div class="stat-label">诊断准确率</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" class="charts-row">
      <el-col :span="12">
        <el-card v-loading="chartsLoading">
          <template #header>
            <div class="card-header">
              <span>AI问诊趋势</span>
              <el-button type="primary" link size="small" :icon="Refresh" @click="refreshTrendChart">
                刷新
              </el-button>
            </div>
          </template>
          <div ref="trendChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card v-loading="chartsLoading">
          <template #header>
            <div class="card-header">
              <span>AI诊断准确性分布</span>
            </div>
          </template>
          <div ref="accuracyChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="charts-row">
      <el-col :span="24">
        <el-card v-loading="chartsLoading">
          <template #header>
            <div class="card-header">
              <span>疾病类型分布</span>
            </div>
          </template>
          <div ref="pieChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近问诊记录 -->
    <el-row :gutter="20" class="recent-row">
      <el-col :span="24">
        <el-card v-loading="recordsLoading">
          <template #header>
            <div class="card-header">
              <span>最近问诊记录</span>
              <div>
                <el-button type="primary" link size="small" :icon="Refresh" @click="refreshRecentRecords">
                  刷新
                </el-button>
                <el-button type="primary" size="small" @click="router.push('/diagnosis-record')">
                  查看全部
                </el-button>
              </div>
            </div>
          </template>
          <el-table :data="recentRecords" stripe>
            <el-table-column prop="recordNo" label="诊断编号" width="180" />
            <el-table-column prop="patientName" label="患者姓名" width="120" />
            <el-table-column prop="chiefComplaint" label="主诉" show-overflow-tooltip />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag v-if="row.status === 0" type="warning">待确认</el-tag>
                <el-tag v-else-if="row.status === 1" type="success">已确认</el-tag>
                <el-tag v-else type="info">已完成</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createTime" label="诊断时间" width="180" />
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="viewDetail(row)">
                  查看详情
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'
import { User, DocumentChecked, ChatLineRound, TrendCharts, Refresh } from '@element-plus/icons-vue'
import {
  getStatistics,
  getTrendData,
  getDiseaseDistribution,
  getRecentRecords,
  getAccuracyDistribution
} from '@/api/dashboard'

const router = useRouter()

// 加载状态
const statsLoading = ref(false)
const chartsLoading = ref(false)
const recordsLoading = ref(false)

// 统计数据
const stats = ref({
  patientCount: 0,
  diagnosisCount: 0,
  aiDiagnosisCount: 0,
  accuracy: 0
})

// 最近记录
const recentRecords = ref([])

// 图表引用
const trendChartRef = ref(null)
const pieChartRef = ref(null)
const accuracyChartRef = ref(null)
let trendChart = null
let pieChart = null
let accuracyChart = null

// 格式化时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return ''
  const date = new Date(dateTime)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

// 获取统计数据
const fetchStatistics = async () => {
  try {
    statsLoading.value = true
    const res = await getStatistics()
    if (res.code === 200) {
      stats.value = {
        patientCount: res.data.patientCount || 0,
        diagnosisCount: res.data.todayDiagnosisCount || 0,
        aiDiagnosisCount: res.data.aiDiagnosisCount || 0,
        accuracy: res.data.accuracyRate ? parseFloat(res.data.accuracyRate).toFixed(1) : '0.0'
      }
    } else {
      ElMessage.error(res.message || '获取统计数据失败')
    }
  } catch (error) {
    console.error('获取统计数据失败:', error)
    ElMessage.error('获取统计数据失败')
  } finally {
    statsLoading.value = false
  }
}

// 初始化趋势图
const initTrendChart = async () => {
  try {
    chartsLoading.value = true
    const res = await getTrendData(7)

    if (res.code === 200 && res.data) {
      const data = res.data

      if (!trendChart) {
        trendChart = echarts.init(trendChartRef.value)
      }

      const option = {
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['AI诊断']
        },
        xAxis: {
          type: 'category',
          data: data.dates || []
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: 'AI诊断',
            type: 'line',
            data: data.aiDiagnosisCounts || [],
            smooth: true,
            itemStyle: {
              color: '#67C23A'
            },
            areaStyle: {
              color: {
                type: 'linear',
                x: 0,
                y: 0,
                x2: 0,
                y2: 1,
                colorStops: [{
                  offset: 0, color: 'rgba(103, 194, 58, 0.3)'
                }, {
                  offset: 1, color: 'rgba(103, 194, 58, 0.05)'
                }]
              }
            }
          }
        ]
      }
      trendChart.setOption(option)
    } else {
      ElMessage.error(res.message || '获取趋势数据失败')
    }
  } catch (error) {
    console.error('获取趋势数据失败:', error)
    ElMessage.error('获取趋势数据失败')
  } finally {
    chartsLoading.value = false
  }
}

// 刷新趋势图
const refreshTrendChart = () => {
  initTrendChart()
}

// 初始化饼图
const initPieChart = async () => {
  try {
    chartsLoading.value = true
    const res = await getDiseaseDistribution()

    if (res.code === 200 && res.data) {
      const data = res.data

      if (!pieChart) {
        pieChart = echarts.init(pieChartRef.value)
      }

      const option = {
        tooltip: {
          trigger: 'item'
        },
        legend: {
          orient: 'vertical',
          left: 'left'
        },
        series: [
          {
            name: '疾病类型',
            type: 'pie',
            radius: '60%',
            data: data.map(item => ({
              value: item.value,
              name: item.name
            }))
          }
        ]
      }
      pieChart.setOption(option)
    } else {
      ElMessage.error(res.message || '获取疾病分布失败')
    }
  } catch (error) {
    console.error('获取疾病分布失败:', error)
    ElMessage.error('获取疾病分布失败')
  } finally {
    chartsLoading.value = false
  }
}

// 初始化准确性分布图
const initAccuracyChart = async () => {
  try {
    chartsLoading.value = true
    const res = await getAccuracyDistribution()

    if (res.code === 200 && res.data) {
      const data = res.data

      if (!accuracyChart) {
        accuracyChart = echarts.init(accuracyChartRef.value)
      }

      const option = {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          },
          formatter: function(params) {
            const item = params[0]
            const data = item.data
            return `${data.name}<br/>${data.label}<br/>数量: ${data.value}`
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: data.map(item => item.range),
          axisLabel: {
            interval: 0,
            rotate: 0
          }
        },
        yAxis: {
          type: 'value',
          name: '诊断数量'
        },
        series: [
          {
            name: '诊断数量',
            type: 'bar',
            data: data.map(item => ({
              value: item.count,
              name: item.range,
              label: item.label
            })),
            itemStyle: {
              color: function(params) {
                const label = params.data.label
                // 为每个准确性等级设置独特且鲜明的颜色
                const colorMap = {
                  '完全准确': '#52c41a',      // 鲜绿色
                  '非常准确': '#1890ff',      // 鲜蓝色
                  '准确': '#13c2c2',         // 青色
                  '基本准确': '#faad14',     // 金橙色
                  '部分准确': '#fa8c16',     // 深橙色
                  '不太准确': '#f5222d',     // 鲜红色
                  '基本不准确': '#eb2f96',    // 粉红色
                  '完全不准确': '#722ed1'    // 紫色
                }
                return colorMap[label] || '#909399'
              },
              borderRadius: [4, 4, 0, 0], // 圆角效果
              borderWidth: 1,
              borderColor: '#fff'
            },
            label: {
              show: true,
              position: 'top',
              formatter: function(params) {
                const data = params.data
                return `${data.label}\n${data.value}例`
              },
              fontSize: 12
            }
          }
        ]
      }
      accuracyChart.setOption(option)
    } else {
      ElMessage.error(res.message || '获取准确性分布失败')
    }
  } catch (error) {
    console.error('获取准确性分布失败:', error)
    ElMessage.error('获取准确性分布失败')
  } finally {
    chartsLoading.value = false
  }
}

// 获取最近记录
const fetchRecentRecords = async () => {
  try {
    recordsLoading.value = true
    const res = await getRecentRecords(5)

    if (res.code === 200 && res.data) {
      recentRecords.value = res.data.map(record => ({
        ...record,
        createTime: formatDateTime(record.createTime)
      }))
    } else {
      ElMessage.error(res.message || '获取最近记录失败')
    }
  } catch (error) {
    console.error('获取最近记录失败:', error)
    ElMessage.error('获取最近记录失败')
  } finally {
    recordsLoading.value = false
  }
}

// 刷新最近记录
const refreshRecentRecords = () => {
  fetchRecentRecords()
}

// 查看详情
const viewDetail = (row) => {
  router.push({
    path: '/diagnosis-record',
    query: { id: row.id }
  })
}

// 窗口大小变化时重新渲染图表
const handleResize = () => {
  trendChart?.resize()
  pieChart?.resize()
  accuracyChart?.resize()
}

onMounted(() => {
  // 获取所有数据
  fetchStatistics()
  initTrendChart()
  initPieChart()
  initAccuracyChart()
  fetchRecentRecords()

  // 监听窗口大小变化
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  // 销毁图表实例
  trendChart?.dispose()
  pieChart?.dispose()
  accuracyChart?.dispose()

  // 移除事件监听
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.dashboard-container {
  padding: 0;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: all 0.3s;
}

.stat-card:hover {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.2);
}

.stat-content {
  display: flex;
  align-items: center;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-right: 20px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #999;
}

.charts-row {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}
</style>
