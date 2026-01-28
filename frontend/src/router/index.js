import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/layout/Index.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '工作台', icon: 'Odometer' }
      },
      {
        path: 'patient',
        name: 'Patient',
        component: () => import('@/views/Patient.vue'),
        meta: { title: '患者管理', icon: 'User' }
      },
      {
        path: 'diagnosis',
        name: 'Diagnosis',
        component: () => import('@/views/Diagnosis.vue'),
        meta: { title: 'AI智能问诊', icon: 'ChatLineRound' }
      },
      {
        path: 'diagnosis-record',
        name: 'DiagnosisRecord',
        component: () => import('@/views/DiagnosisRecord.vue'),
        meta: { title: '诊断记录', icon: 'Document' }
      },
      {
        path: 'knowledge',
        name: 'Knowledge',
        component: () => import('@/views/Knowledge.vue'),
        meta: { title: '知识库管理', icon: 'Books' }
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/Statistics.vue'),
        meta: { title: '数据统计', icon: 'DataAnalysis' }
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/Settings.vue'),
        meta: { title: '系统设置', icon: 'Setting' }
      },
      {
        path: 'user-management',
        name: 'UserManagement',
        component: () => import('@/views/UserManagement.vue'),
        meta: { title: '用户管理', icon: 'UserFilled', permission: 'user:list' }
      },
      {
        path: 'change-password',
        name: 'ChangePassword',
        component: () => import('@/views/ChangePassword.vue'),
        meta: { title: '修改密码', icon: 'Lock', hidden: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()

  // 未登录跳转登录页
  if (to.path !== '/login' && !userStore.token) {
    next('/login')
    return
  }

  // 已登录访问登录页，跳转到首页
  if (to.path === '/login' && userStore.token) {
    next('/')
    return
  }

  // 权限验证
  if (to.meta.permission) {
    const permissions = userStore.userInfo?.permissions || []
    if (!permissions.includes(to.meta.permission)) {
      // 显示403错误或跳转到无权限页面
      next('/dashboard')
      return
    }
  }

  next()
})

export default router
