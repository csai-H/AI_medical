import { useUserStore } from '@/stores/user'

/**
 * 检查是否有指定权限
 * @param {string} permission 权限编码
 * @returns {boolean}
 */
export function hasPermission(permission) {
  const userStore = useUserStore()
  const permissions = userStore.userInfo?.permissions || []
  return permissions.includes(permission)
}

/**
 * 检查是否有任意一个权限
 * @param {string[]} permissions 权限编码数组
 * @returns {boolean}
 */
export function hasAnyPermission(permissions) {
  if (!permissions || permissions.length === 0) {
    return false
  }
  return permissions.some(permission => hasPermission(permission))
}

/**
 * 检查是否有所有权限
 * @param {string[]} permissions 权限编码数组
 * @returns {boolean}
 */
export function hasAllPermissions(permissions) {
  if (!permissions || permissions.length === 0) {
    return false
  }
  return permissions.every(permission => hasPermission(permission))
}

/**
 * 检查是否有指定角色
 * @param {string} role 角色编码
 * @returns {boolean}
 */
export function hasRole(role) {
  const userStore = useUserStore()
  const roles = userStore.userInfo?.roles || []
  return roles.includes(role)
}

/**
 * 检查是否有任意一个角色
 * @param {string[]} roles 角色编码数组
 * @returns {boolean}
 */
export function hasAnyRole(roles) {
  if (!roles || roles.length === 0) {
    return false
  }
  return roles.some(role => hasRole(role))
}
