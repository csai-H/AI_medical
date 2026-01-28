<template>
  <el-container class="layout-container">
    <!-- 侧边栏 -->
    <el-aside width="240px">
      <div class="logo">
        <el-icon><Monitor /></el-icon>
        <span>AI医疗助手</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item
          v-for="route in menuRoutes"
          :key="route.path"
          :index="route.path"
        >
          <el-icon><component :is="route.meta.icon" /></el-icon>
          <span>{{ route.meta.title }}</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 主体内容 -->
    <el-container>
      <!-- 顶部导航 -->
      <el-header>
        <div class="header-content">
          <div class="breadcrumb">
            <el-breadcrumb separator="/">
              <el-breadcrumb-item>{{ currentTitle }}</el-breadcrumb-item>
            </el-breadcrumb>
          </div>
          <div class="user-info">
            <el-dropdown>
              <span class="user-name">
                <el-avatar :size="32" :src="userStore.userInfo.avatar" />
                <span style="margin-left: 8px">{{ userStore.userInfo.realName }}</span>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="handleSettings">
                    <el-icon><Setting /></el-icon>
                    个人设置
                  </el-dropdown-item>
                  <el-dropdown-item divided @click="handleLogout">
                    <el-icon><SwitchButton /></el-icon>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </el-header>

      <!-- 主要内容区域 -->
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 菜单路由 - 基于用户权限过滤
const menuRoutes = computed(() => {
  // 如果用户菜单还未加载，返回空数组
  if (!userStore.menus || userStore.menus.length === 0) {
    console.log('用户菜单未加载')
    return []
  }

  // 扁平化菜单树，提取所有菜单项（包括子菜单）
  const flattenMenus = (menus) => {
    const result = []
    menus.forEach(menu => {
      // 只添加可见的菜单项（visible === 1）
      if (menu.visible === 1 || menu.visible === undefined) {
        result.push(menu)
        // 递归处理子菜单
        if (menu.children && menu.children.length > 0) {
          result.push(...flattenMenus(menu.children))
        }
      }
    })
    return result
  }

  // 获取所有扁平化的菜单
  const allMenus = flattenMenus(userStore.menus)
  
  // 提取菜单路径列表
  const menuPaths = allMenus.map(menu => menu.path).filter(Boolean)
  console.log('用户有权限的菜单路径:', menuPaths)

  // 获取所有已注册的路由
  const allRoutes = router.getRoutes()
  
  // 过滤出用户有权限的路由
  const routes = allRoutes
    .filter(r => {
      // 基本过滤条件
      if (!r.meta || !r.meta.title || r.meta.hidden) return false
      // 路径应该是一级路径（如 /dashboard）且不是根路径
      if (!r.path.match(/^\/[^/]+$/) || r.path === '/') return false
      // 排除静态路由
      if (['/login', '/register', '/404'].includes(r.path)) return false
      
      // 关键：只显示用户有权限的菜单
      // 去掉路径开头的斜杠进行匹配
      const routePath = r.path.startsWith('/') ? r.path.slice(1) : r.path
      const hasPermission = menuPaths.some(menuPath => {
        const menuPathWithoutSlash = menuPath.startsWith('/') ? menuPath.slice(1) : menuPath
        return routePath === menuPathWithoutSlash
      })
      
      return hasPermission
    })
    .map(r => ({
      ...r,
      path: r.path
    }))
    .sort((a, b) => {
      // 按照后端返回的菜单顺序排序（使用sortOrder）
      const menuA = allMenus.find(m => {
        const menuPath = m.path.startsWith('/') ? m.path.slice(1) : m.path
        return menuPath === a.path.replace('/', '')
      })
      const menuB = allMenus.find(m => {
        const menuPath = m.path.startsWith('/') ? m.path.slice(1) : m.path
        return menuPath === b.path.replace('/', '')
      })
      
      const orderA = menuA?.sortOrder ?? 999
      const orderB = menuB?.sortOrder ?? 999
      return orderA - orderB
    })
  
  console.log('过滤后的菜单路由:', routes)
  return routes
})

// 当前激活的菜单
const activeMenu = computed(() => route.path)

// 当前页面标题
const currentTitle = computed(() => route.meta?.title || '工作台')

// 退出登录
const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logout()
    router.push('/login')
  }).catch(() => {})
}

// 跳转到个人设置
const handleSettings = () => {
  router.push('/settings')
}
</script>

<style scoped>
.layout-container {
  height: 100%;
}

.el-aside {
  background-color: #304156;
  overflow-x: hidden;
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 60px;
  font-size: 20px;
  font-weight: bold;
  color: #fff;
  background-color: #2b3a4a;
}

.logo .el-icon {
  font-size: 24px;
  margin-right: 8px;
}

.el-menu {
  border-right: none;
}

.el-header {
  background-color: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  padding: 0 20px;
}

.header-content {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-name {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.el-main {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>
