<template>
  <div class="role-management-container">
    <el-card>
      <!-- 搜索区域 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="角色名称">
          <el-input v-model="searchForm.roleName" placeholder="请输入角色名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="toolbar">
        <el-button v-permission="'role:create'" type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          新增角色
        </el-button>
      </div>

      <!-- 表格 -->
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="roleCode" label="角色编码" width="150" />
        <el-table-column prop="roleName" label="角色名称" width="150" />
        <el-table-column prop="roleLevel" label="角色层级" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.roleLevel === 0" type="danger">超级管理员</el-tag>
            <el-tag v-else-if="row.roleLevel === 1" type="warning">管理员</el-tag>
            <el-tag v-else type="info">普通用户</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              :active-value="1"
              :inactive-value="0"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleAssignPermissions(row)">
              分配权限
            </el-button>
            <el-button v-permission="'role:update'" type="primary" link size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button v-permission="'role:delete'" type="danger" link size="small" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadData"
        @current-change="loadData"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px">
        <el-form-item label="角色编码" prop="roleCode">
          <el-input
            v-model="formData.roleCode"
            placeholder="请输入角色编码"
            :disabled="isEdit"
          />
        </el-form-item>
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="formData.roleName" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="角色层级" prop="roleLevel">
          <el-select v-model="formData.roleLevel" placeholder="请选择角色层级">
            <el-option :value="0" label="超级管理员" />
            <el-option :value="1" label="管理员" />
            <el-option :value="2" label="普通用户" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入角色描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 分配权限对话框 -->
    <el-dialog
      v-model="permissionDialogVisible"
      title="分配权限"
      width="600px"
      @close="handlePermissionDialogClose"
    >
      <el-form>
        <el-form-item label="角色名称">
          <el-input :value="currentRole?.roleName" disabled />
        </el-form-item>
        <el-form-item label="权限列表">
          <el-tree
            ref="permissionTreeRef"
            :data="permissionTree"
            :props="treeProps"
            show-checkbox
            node-key="id"
            :default-checked-keys="checkedPermissions"
            :default-expand-all="true"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="permissionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAssignPermissionsSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import {
  getRoleListApi,
  createRoleApi,
  updateRoleApi,
  deleteRoleApi,
  getRolePermissionsApi,
  assignPermissionsApi
} from '@/api/role'
import { getAllPermissionsApi } from '@/api/permission'

// 搜索表单
const searchForm = reactive({
  roleName: ''
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 分页
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('')
const isEdit = ref(false)
const formRef = ref(null)

// 表单数据
const formData = reactive({
  id: null,
  roleCode: '',
  roleName: '',
  roleLevel: 2,
  status: 1,
  description: ''
})

// 表单验证规则
const formRules = {
  roleCode: [
    { required: true, message: '请输入角色编码', trigger: 'blur' }
  ],
  roleName: [
    { required: true, message: '请输入角色名称', trigger: 'blur' }
  ],
  roleLevel: [
    { required: true, message: '请选择角色层级', trigger: 'change' }
  ]
}

// 权限对话框
const permissionDialogVisible = ref(false)
const currentRole = ref(null)
const permissionTreeRef = ref(null)
const permissionTree = ref([])
const checkedPermissions = ref([])
const treeProps = {
  children: 'children',
  label: 'permissionName'
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const res = await getRoleListApi({
      current: page.current,
      size: page.size,
      roleName: searchForm.roleName
    })
    tableData.value = res.data.records
    page.total = res.data.total
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  page.current = 1
  loadData()
}

// 重置
const handleReset = () => {
  searchForm.roleName = ''
  page.current = 1
  loadData()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增角色'
  isEdit.value = false
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑角色'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 删除
const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该角色吗?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteRoleApi(row.id)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  })
}

// 状态变更
const handleStatusChange = (row) => {
  updateRoleApi(row).then(() => {
    ElMessage.success('状态更新成功')
  }).catch(() => {
    ElMessage.error('状态更新失败')
    loadData()
  })
}

// 提交表单
const handleSubmit = async () => {
  await formRef.value.validate()
  try {
    if (isEdit.value) {
      await updateRoleApi(formData)
      ElMessage.success('更新成功')
    } else {
      await createRoleApi(formData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error(isEdit.value ? '更新失败' : '创建失败')
  }
}

// 对话框关闭
const handleDialogClose = () => {
  formRef.value?.resetFields()
  Object.assign(formData, {
    id: null,
    roleCode: '',
    roleName: '',
    roleLevel: 2,
    status: 1,
    description: ''
  })
}

// 分配权限
const handleAssignPermissions = async (row) => {
  currentRole.value = row
  permissionDialogVisible.value = true

  try {
    // 获取角色权限
    const res = await getRolePermissionsApi(row.id)
    checkedPermissions.value = res.data || []
  } catch (error) {
    ElMessage.error('获取角色权限失败')
  }
}

// 提交分配权限
const handleAssignPermissionsSubmit = async () => {
  const checkedKeys = permissionTreeRef.value.getCheckedKeys()
  try {
    await assignPermissionsApi(currentRole.value.id, checkedKeys)
    ElMessage.success('权限分配成功')
    permissionDialogVisible.value = false
  } catch (error) {
    ElMessage.error('权限分配失败')
  }
}

// 权限对话框关闭
const handlePermissionDialogClose = () => {
  currentRole.value = null
  checkedPermissions.value = []
}

// 加载权限树
const loadPermissionTree = async () => {
  try {
    const res = await getAllPermissionsApi()
    permissionTree.value = buildTree(res.data || [])
  } catch (error) {
    ElMessage.error('加载权限树失败')
  }
}

// 构建树形结构
const buildTree = (permissions) => {
  const map = {}
  const tree = []

  permissions.forEach(permission => {
    map[permission.id] = { ...permission, children: [] }
  })

  permissions.forEach(permission => {
    if (permission.parentId && map[permission.parentId]) {
      map[permission.parentId].children.push(map[permission.id])
    } else {
      tree.push(map[permission.id])
    }
  })

  return tree
}

onMounted(() => {
  loadData()
  loadPermissionTree()
})
</script>

<style scoped>
.role-management-container {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}

.toolbar {
  margin-bottom: 20px;
}
</style>
