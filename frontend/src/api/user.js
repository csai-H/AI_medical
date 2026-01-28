import request from '@/utils/request'

/**
 * 用户注册
 */
export const register = (data) => {
  return request({
    url: '/auth/register',
    method: 'post',
    data
  })
}

/**
 * 获取用户列表
 */
export const getUserList = (params) => {
  return request({
    url: '/user/list',
    method: 'get',
    params
  })
}

/**
 * 创建用户
 */
export const createUser = (data) => {
  return request({
    url: '/user/create',
    method: 'post',
    data
  })
}

/**
 * 更新用户
 */
export const updateUser = (data) => {
  return request({
    url: '/user/update',
    method: 'put',
    data
  })
}

/**
 * 删除用户
 */
export const deleteUser = (id) => {
  return request({
    url: `/user/delete/${id}`,
    method: 'delete'
  })
}

/**
 * 重置密码
 */
export const resetPassword = (data) => {
  return request({
    url: '/user/reset-password',
    method: 'post',
    data
  })
}

/**
 * 修改密码
 */
export const changePassword = (data) => {
  return request({
    url: '/user/change-password',
    method: 'post',
    data
  })
}

/**
 * 更新用户状态
 */
export const updateUserStatus = (data) => {
  return request({
    url: '/user/status',
    method: 'put',
    data
  })
}
