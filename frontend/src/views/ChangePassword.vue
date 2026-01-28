<template>
  <div class="change-password-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>修改密码</span>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
        style="max-width: 600px"
      >
        <el-form-item label="原密码" prop="oldPassword">
          <el-input
            v-model="formData.oldPassword"
            type="password"
            placeholder="请输入原密码"
            show-password
          />
        </el-form-item>

        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="formData.newPassword"
            type="password"
            placeholder="请输入新密码（8-20位，包含大小写字母、数字和特殊字符）"
            show-password
          />
          <PasswordStrength :password="formData.newPassword" v-if="formData.newPassword" />
        </el-form-item>

        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input
            v-model="formData.confirmPassword"
            type="password"
            placeholder="请再次输入新密码"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="loading">
            提交
          </el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-alert
        title="密码要求"
        type="info"
        :closable="false"
        show-icon
        style="margin-top: 20px"
      >
        <template #default>
          <ul style="margin: 0; padding-left: 20px">
            <li>密码长度为8-20位</li>
            <li>必须包含大小写字母</li>
            <li>必须包含数字</li>
            <li>必须包含特殊字符（@$!%*?&）</li>
          </ul>
        </template>
      </el-alert>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { changePassword } from '@/api/user'
import { ElMessage } from 'element-plus'
import PasswordStrength from '@/components/PasswordStrength.vue'

const router = useRouter()
const loading = ref(false)
const formRef = ref(null)

const formData = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== formData.newPassword) {
    callback(new Error('两次密码不一致'))
  } else {
    callback()
  }
}

const formRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    {
      pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$/,
      message: '密码必须8-20位，包含大小写字母、数字和特殊字符',
      trigger: 'blur'
    }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await changePassword(formData)
    ElMessage.success('修改密码成功，请重新登录')

    // 清除token并跳转到登录页
    setTimeout(() => {
      localStorage.removeItem('token')
      router.push('/login')
    }, 1500)
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '修改密码失败')
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  formRef.value?.resetFields()
  Object.assign(formData, {
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
}
</script>

<style scoped>
.change-password-container {
  padding: 0;
  max-width: 800px;
  margin: 0 auto;
}

.card-header {
  font-size: 18px;
  font-weight: bold;
}
</style>
