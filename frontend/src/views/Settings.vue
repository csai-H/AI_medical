<template>
  <div class="settings-container">
    <el-row justify="center">
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>个人信息</span>
              <el-button type="primary" size="small" @click="openEditDialog">编辑</el-button>
            </div>
          </template>
          <div class="user-profile">
            <el-avatar :size="100" :src="userStore.userInfo.avatar" />
            <h3>{{ userStore.userInfo.realName }}</h3>
            <p>{{ userStore.userInfo.title || '暂无职称' }}</p>
            <el-descriptions :column="1" class="user-info" border>
              <el-descriptions-item label="用户名">{{ userStore.userInfo.username }}</el-descriptions-item>
              <el-descriptions-item label="手机号">{{ userStore.userInfo.phone || '暂无' }}</el-descriptions-item>
              <el-descriptions-item label="邮箱">{{ userStore.userInfo.email || '暂无' }}</el-descriptions-item>
              <el-descriptions-item label="专长">{{ userStore.userInfo.specialty || '暂无' }}</el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>

        <!-- 编辑个人信息对话框 -->
        <el-dialog
          v-model="editDialogVisible"
          title="编辑个人信息"
          width="500px"
          :close-on-click-modal="false"
        >
          <el-form :model="profileForm" :rules="profileRules" ref="profileFormRef" label-width="100px">
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="profileForm.realName" placeholder="请输入真实姓名" />
            </el-form-item>
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="profileForm.phone" placeholder="请输入手机号" />
            </el-form-item>
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="profileForm.email" placeholder="请输入邮箱" />
            </el-form-item>
            <el-form-item label="职称" prop="title">
              <el-input v-model="profileForm.title" placeholder="请输入职称" />
            </el-form-item>
            <el-form-item label="专长" prop="specialty">
              <el-input v-model="profileForm.specialty" type="textarea" :rows="3" placeholder="请输入专长" />
            </el-form-item>
            <el-form-item label="头像URL" prop="avatar">
              <el-input v-model="profileForm.avatar" placeholder="请输入头像URL" />
            </el-form-item>
          </el-form>
          <template #footer>
            <el-button @click="editDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleUpdateProfile" :loading="updateLoading">保存</el-button>
          </template>
        </el-dialog>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { updateProfile } from '@/api/user'

const userStore = useUserStore()
const editDialogVisible = ref(false)
const updateLoading = ref(false)
const profileFormRef = ref(null)

// 个人信息表单
const profileForm = reactive({
  realName: '',
  phone: '',
  email: '',
  title: '',
  specialty: '',
  avatar: ''
})

// 表单验证规则
const profileRules = {
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9][0-9]{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

// 打开编辑对话框
const openEditDialog = () => {
  profileForm.realName = userStore.userInfo.realName || ''
  profileForm.phone = userStore.userInfo.phone || ''
  profileForm.email = userStore.userInfo.email || ''
  profileForm.title = userStore.userInfo.title || ''
  profileForm.specialty = userStore.userInfo.specialty || ''
  profileForm.avatar = userStore.userInfo.avatar || ''
  editDialogVisible.value = true
}

// 更新个人信息
const handleUpdateProfile = async () => {
  if (!profileFormRef.value) return

  await profileFormRef.value.validate(async (valid) => {
    if (valid) {
      updateLoading.value = true
      try {
        await updateProfile(profileForm)
        ElMessage.success('更新个人信息成功')
        editDialogVisible.value = false
        // 更新用户信息
        await userStore.getInfo()
      } catch (error) {
        ElMessage.error(error.message || '更新个人信息失败')
      } finally {
        updateLoading.value = false
      }
    }
  })
}
</script>

<style scoped>
.settings-container {
  padding: 20px;
}

.card-header {
  font-weight: bold;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-profile {
  text-align: center;
  padding: 20px 0;
}

.user-profile h3 {
  margin: 15px 0 5px;
  font-size: 20px;
}

.user-profile p {
  color: #999;
  margin-bottom: 20px;
}

.user-info {
  margin-top: 30px;
  text-align: left;
}
</style>
