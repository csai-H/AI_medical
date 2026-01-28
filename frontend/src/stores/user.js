import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login as loginApi, getUserInfo, getMenu } from '@/api/auth'
import { addDynamicRoutes } from '@/router'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || '{}'))
  const menus = ref([])
  const menusLoaded = ref(false)

  // 登录
  const login = async (loginForm) => {
    const res = await loginApi(loginForm)
    token.value = res.data
    localStorage.setItem('token', res.data)
  }

  // 获取用户信息
  const getInfo = async () => {
    const res = await getUserInfo()
    userInfo.value = res.data
    localStorage.setItem('userInfo', JSON.stringify(res.data))
  }

  // 获取用户菜单
  const fetchMenus = async () => {
    const res = await getMenu()
    menus.value = res.data || []
    localStorage.setItem('menus', JSON.stringify(menus.value))
    // 添加动态路由
    addDynamicRoutes(menus.value)
    // 路由添加完成后再标记为已加载
    menusLoaded.value = true
  }

  // 设置菜单
  const setMenus = (menuList) => {
    menus.value = menuList
    menusLoaded.value = true
    localStorage.setItem('menus', JSON.stringify(menus.value))
  }

  // 退出登录
  const logout = () => {
    token.value = ''
    userInfo.value = {}
    menus.value = []
    menusLoaded.value = false
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    localStorage.removeItem('menus')
  }

  return {
    token,
    userInfo,
    menus,
    menusLoaded,
    login,
    getInfo,
    fetchMenus,
    setMenus,
    logout
  }
})
