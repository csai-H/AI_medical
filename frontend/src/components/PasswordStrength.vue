<template>
  <div class="password-strength" v-if="password">
    <div class="strength-bar">
      <div
        class="strength-bar-fill"
        :class="strengthClass"
        :style="{ width: strengthWidth }"
      ></div>
    </div>
    <div class="strength-text" :class="strengthClass">
      {{ strengthLabel }}
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  password: {
    type: String,
    default: ''
  }
})

const strength = computed(() => {
  const pwd = props.password
  if (!pwd || pwd.length < 8) {
    return { level: 0, label: '弱', class: 'weak', width: '33%' }
  }

  let score = 0

  // 长度检查
  if (pwd.length >= 8) score++
  if (pwd.length >= 12) score++

  // 包含小写字母
  if (/[a-z]/.test(pwd)) score++

  // 包含大写字母
  if (/[A-Z]/.test(pwd)) score++

  // 包含数字
  if (/\d/.test(pwd)) score++

  // 包含特殊字符
  if (/[@$!%*?&]/.test(pwd)) score++

  if (score >= 5) {
    return { level: 2, label: '强', class: 'strong', width: '100%' }
  } else if (score >= 3) {
    return { level: 1, label: '中', class: 'medium', width: '66%' }
  } else {
    return { level: 0, label: '弱', class: 'weak', width: '33%' }
  }
})

const strengthClass = computed(() => strength.value.class)

const strengthLabel = computed(() => `密码强度: ${strength.value.label}`)

const strengthWidth = computed(() => strength.value.width)
</script>

<style scoped>
.password-strength {
  margin-top: 8px;
}

.strength-bar {
  height: 6px;
  background-color: #e0e0e0;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 6px;
}

.strength-bar-fill {
  height: 100%;
  transition: all 0.3s ease;
  border-radius: 3px;
}

.strength-bar-fill.weak {
  background-color: #f56c6c;
}

.strength-bar-fill.medium {
  background-color: #e6a23c;
}

.strength-bar-fill.strong {
  background-color: #67c23a;
}

.strength-text {
  font-size: 12px;
  transition: color 0.3s ease;
}

.strength-text.weak {
  color: #f56c6c;
}

.strength-text.medium {
  color: #e6a23c;
}

.strength-text.strong {
  color: #67c23a;
}
</style>
