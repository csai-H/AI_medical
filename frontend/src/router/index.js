import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

// 静态路由(不需要权限)
const staticRoutes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { title: '注册' }
  },
  {
    path: '/404',
    name: 'NotFound',
    component: () => import('@/views/404.vue'),
    meta: { title: '页面不存在' }
  }
]

// 动态路由(需要权限)
const dynamicRoutes = [
  {
    path: '/',
    name: 'Layout',
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
        meta: { title: '患者管理', icon: 'UserFilled' }
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
        path: 'user-management',
        name: 'UserManagement',
        component: () => import('@/views/UserManagement.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: 'role-management',
        name: 'RoleManagement',
        component: () => import('@/views/RoleManagement.vue'),
        meta: { title: '角色管理', icon: 'Lock' }
      },
      {
        path: 'change-password',
        name: 'ChangePassword',
        component: () => import('@/views/ChangePassword.vue'),
        meta: { title: '修改密码', hidden: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes: staticRoutes
})

/**
 * 根据菜单添加动态路由
 * @param {Array} menus 菜单列表
 */
export function addDynamicRoutes(menus) {
  console.log('开始添加动态路由，菜单数据:', menus)
  
  // 查找动态路由中的根路由（即 / 路由）
  const rootRoute = dynamicRoutes.find(r => r.path === '/')

  if (!rootRoute) {
    console.error('未找到根路由')
    return
  }

  // 收集所有需要添加的子路由
  const childrenToAdd = []

  menus.forEach(menu => {
    // 在根路由的子路由中查找匹配的路由
    const matchedChild = rootRoute.children?.find(child => {
      // 去掉开头的斜杠进行匹配（菜单数据可能是 /dashboard，路由子路径是 dashboard）
      const menuPath = menu.path.startsWith('/') ? menu.path.slice(1) : menu.path
      console.log(`匹配菜单: ${menu.permissionName}, menuPath: ${menuPath}, childPath: ${child.path}`)
      return child.path === menuPath
    })

    if (matchedChild) {
      childrenToAdd.push(matchedChild)
      console.log(`添加路由: ${matchedChild.path}`)

      // 递归处理子菜单
      if (menu.children && menu.children.length > 0) {
        // 这里可以扩展支持多层嵌套
      }
    }
  })

  console.log('总共需要添加的路由数量:', childrenToAdd.length)

  // 检查是否已经添加过主路由
  const existingRoute = router.getRoutes().find(r => r.path === '/')
  
  if (existingRoute) {
    console.log('主路由已存在，直接添加子路由')
    // 主路由已存在，直接添加子路由
    childrenToAdd.forEach(child => {
      // 确保子路由使用绝对路径
      const childRoute = {
        ...child,
        path: child.path.startsWith('/') ? child.path : `/${child.path}`
      }
      // 使用父路由的 name 而不是 path
      router.addRoute('Layout', childRoute)
    })
  } else {
    console.log('主路由不存在，添加完整路由结构')
    // 克隆根路由并只添加匹配的子路由
    const routeToAdd = {
      ...rootRoute,
      children: childrenToAdd
    }
    
    router.addRoute(routeToAdd)
  }
  
  console.log('动态路由添加完成，当前所有路由:', router.getRoutes().map(r => r.path))
}

/**
 * 根据路径查找路由
 * @param {Array} routes 路由列表
 * @param {String} path 路径
 * @returns {Object|null}
 */
function findRouteByPath(routes, path) {
  for (const route of routes) {
    if (route.path === path || route.path === '/' + path) {
      return route
    }

    if (route.children) {
      const found = findRouteByPath(route.children, path)
      if (found) {
        return found
      }
    }
  }

  return null
}

// 路由守卫
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()

  // 未登录跳转登录页
  if (to.path !== '/login' && to.path !== '/register' && !userStore.token) {
    next('/login')
    return
  }

  // 已登录访问登录页，跳转到首页
  if ((to.path === '/login' || to.path === '/register') && userStore.token) {
    next('/')
    return
  }

  // 已登录且菜单未加载,加载菜单
  if (userStore.token && !userStore.menusLoaded) {
    try {
      await userStore.fetchMenus()
      // 动态路由添加后,需要重新进入一次
      // 使用 replace: true 避免浏览器后退问题
      next({ ...to, replace: true })
      return
    } catch (error) {
      console.error('加载菜单失败:', error)
      next('/login')
      return
    }
  }

  // 路由不存在,跳转到404（仅在菜单已加载后判断）
  if (to.matched.length === 0) {
    next('/404')
    return
  }

  next()
})

export default router
