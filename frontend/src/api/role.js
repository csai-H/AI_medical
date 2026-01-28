import request from '@/utils/request'

/**
 * 获取角色列表(分页)
 */
export function getRoleListApi(params) {
  return request({
    url: '/role/page',
    method: 'get',
    params
  })
}

/**
 * 获取所有角色
 */
export function getAllRolesApi() {
  return request({
    url: '/role/list',
    method: 'get'
  })
}

/**
 * 创建角色
 */
export function createRoleApi(data) {
  return request({
    url: '/role/create',
    method: 'post',
    data
  })
}

/**
 * 更新角色
 */
export function updateRoleApi(data) {
  return request({
    url: '/role/update',
    method: 'put',
    data
  })
}

/**
 * 删除角色
 */
export function deleteRoleApi(id) {
  return request({
    url: `/role/delete/${id}`,
    method: 'delete'
  })
}

/**
 * 获取角色权限
 */
export function getRolePermissionsApi(roleId) {
  return request({
    url: `/role/permissions/${roleId}`,
    method: 'get'
  })
}

/**
 * 为角色分配权限
 */
export function assignPermissionsApi(roleId, permissionIds) {
  return request({
    url: '/role/assign-permissions',
    method: 'post',
    params: { roleId },
    data: permissionIds
  })
}
