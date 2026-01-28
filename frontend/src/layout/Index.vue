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
                  <el-dropdown-item @click="handleLogout">
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

// 菜单路由
const menuRoutes = computed(() => {
  // 直接从路由配置中获取子路由
  const allRoutes = router.getRoutes()
  const layoutRoute = allRoutes.find(r => r.name === 'Layout')
  
  if (!layoutRoute) {
    console.log('未找到 Layout 路由')
    return []
  }

  // 获取所有以 / 开头的二级路由（这些是 Layout 的子路由）
  const routes = allRoutes
    .filter(r => {
      // 过滤出有 title 且不隐藏的路由
      if (!r.meta || !r.meta.title || r.meta.hidden) return false
      // 路径应该是一级路径（如 /dashboard）且不是根路径
      if (!r.path.match(/^\/[^/]+$/) || r.path === '/') return false
      // 排除静态路由（login, register, 404）
      if (['/login', '/register', '/404'].includes(r.path)) return false
      return true
    })
    .map(r => ({
      ...r,
      path: r.path
    }))
    .sort((a, b) => {
      const order = ['dashboard', 'patient', 'diagnosis', 'diagnosis-record', 'knowledge', 'statistics', 'settings', 'user-management', 'role-management']
      const pathA = a.path.replace('/', '')
      const pathB = b.path.replace('/', '')
      return order.indexOf(pathA) - order.indexOf(pathB)
    })
  
  console.log('菜单路由:', routes)
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
