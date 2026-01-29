import request from '@/utils/request'

/**
 * 获取统计数据
 */
export const getStatistics = () => {
  return request({
    url: '/dashboard/statistics',
    method: 'get'
  })
}

/**
 * 获取问诊趋势数据
 */
export const getTrendData = (days = 7) => {
  return request({
    url: '/dashboard/trend',
    method: 'get',
    params: { days }
  })
}

/**
 * 获取疾病分布数据
 */
export const getDiseaseDistribution = () => {
  return request({
    url: '/dashboard/disease-distribution',
    method: 'get'
  })
}

/**
 * 获取最近的诊断记录
 */
export const getRecentRecords = (limit = 5) => {
  return request({
    url: '/dashboard/recent-records',
    method: 'get',
    params: { limit }
  })
}

/**
 * 获取AI诊断准确性分布
 */
export const getAccuracyDistribution = () => {
  return request({
    url: '/dashboard/accuracy-distribution',
    method: 'get'
  })
}
