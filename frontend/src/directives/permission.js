import { useUserStore } from '@/stores/user'

/**
 * 权限指令
 * 用法: v-permission="'user:add'" 或 v-permission="['user:add', 'user:edit']"
 */
export const permission = {
  mounted(el, binding) {
    const { value } = binding
    const userStore = useUserStore()
    const permissions = userStore.permissions || []

    if (value && value instanceof Array && value.length > 0) {
      const hasPermission = value.some(permission => permissions.includes(permission))
      if (!hasPermission) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    } else if (value) {
      if (!permissions.includes(value)) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    }
  }
}
