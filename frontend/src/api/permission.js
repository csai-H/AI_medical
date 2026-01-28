import request from '@/utils/request'

/**
 * 获取权限树
 */
export function getPermissionTreeApi() {
  return request({
    url: '/permission/tree',
    method: 'get'
  })
}

/**
 * 获取所有权限
 */
export function getAllPermissionsApi() {
  return request({
    url: '/permission/list',
    method: 'get'
  })
}
