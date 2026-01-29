<template>
  <div class="diagnosis-container">
    <el-row :gutter="20">
      <!-- 对话区域 -->
      <el-col :span="24">
        <el-card class="chat-card">
          <template #header>
            <div class="card-header">
              <el-icon><ChatLineRound /></el-icon>
              <span>AI智能问诊</span>
            </div>
          </template>

          <!-- 对话内容 -->
          <div class="chat-content" ref="chatContentRef">
            <div
              v-for="(msg, index) in chatMessages"
              :key="index"
              :class="['message', msg.role === 'user' ? 'user-message' : 'ai-message']"
            >
              <div class="message-avatar">
                <el-avatar v-if="msg.role === 'user'" :src="userStore.userInfo.avatar" />
                <el-icon v-else :size="30" color="#409EFF"><Robot /></el-icon>
              </div>
              <div class="message-text">
                <div class="message-content" v-if="msg.role === 'user'">{{ msg.content }}</div>
                <div class="message-content markdown-content" v-else v-html="renderMarkdown(msg.content)"></div>
                <div class="message-time">{{ msg.time }}</div>
              </div>
            </div>

            <div v-if="loading" class="message ai-message">
              <div class="message-avatar">
                <el-icon :size="30" color="#409EFF"><Robot /></el-icon>
              </div>
              <div class="message-text">
                <div class="message-content">
                  <span class="loading-text">正在分析中...</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 输入区域 -->
          <div class="chat-input">
            <el-input
              v-model="inputMessage"
              type="textarea"
              :rows="3"
              placeholder="请描述您的症状，例如：头痛、发热、咳嗽等..."
              @keyup.ctrl.enter="sendMessage"
            />
            <div class="input-actions">
              <el-button type="primary" :loading="loading" @click="sendMessage">
                发送 (Ctrl+Enter)
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import { useUserStore } from '@/stores/user'
import { aiChat } from '@/api/diagnosis'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'
import { marked } from 'marked'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'

// 配置marked以支持代码高亮
marked.setOptions({
  highlight: function(code, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(code, { language: lang }).value
      } catch (err) {
        console.error(err)
      }
    }
    return hljs.highlightAuto(code).value
  },
  breaks: true,  // 支持换行
  gfm: true      // GitHub风格markdown
})

// Markdown渲染函数
const renderMarkdown = (content) => {
  if (!content) return ''
  try {
    return marked.parse(content)
  } catch (error) {
    console.error('Markdown解析失败:', error)
    return content
  }
}

const userStore = useUserStore()

const chatContentRef = ref(null)

const inputMessage = ref('')
const loading = ref(false)

const chatMessages = ref([
  {
    role: 'ai',
    content: '您好，我是AI医疗助手。请描述您的症状，我将为您提供专业的医疗建议。',
    time: dayjs().format('HH:mm:ss')
  }
])

// 发送消息
const sendMessage = async () => {
  if (!inputMessage.value.trim()) {
    ElMessage.warning('请输入消息')
    return
  }

  // 添加用户消息
  chatMessages.value.push({
    role: 'user',
    content: inputMessage.value,
    time: dayjs().format('HH:mm:ss')
  })

  const message = inputMessage.value
  inputMessage.value = ''

  // 滚动到底部
  await nextTick()
  scrollToBottom()

  // 调用AI接口
  loading.value = true
  try {
    const res = await aiChat({ message, sessionId: 'session-1' })

    chatMessages.value.push({
      role: 'ai',
      content: res.data || '抱歉，我暂时无法回答您的问题。',
      time: dayjs().format('HH:mm:ss')
    })
  } catch (error) {
    ElMessage.error('AI回复失败')
  } finally {
    loading.value = false
    await nextTick()
    scrollToBottom()
  }
}

// 滚动到底部
const scrollToBottom = () => {
  if (chatContentRef.value) {
    chatContentRef.value.scrollTop = chatContentRef.value.scrollHeight
  }
}
</script>

<style scoped>
.diagnosis-container {
  padding: 0;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: bold;
}

.chat-card {
  height: calc(100vh - 140px);
  display: flex;
  flex-direction: column;
}

.chat-card :deep(.el-card__body) {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.chat-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background-color: #f5f7fa;
}

.message {
  display: flex;
  margin-bottom: 20px;
}

.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  margin: 0 10px;
}

.message-text {
  max-width: 70%;
}

.message-content {
  padding: 12px 16px;
  border-radius: 8px;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  word-wrap: break-word;
}

.user-message .message-content {
  background-color: #409EFF;
  color: #fff;
}

.message-time {
  font-size: 12px;
  color: #999;
  margin-top: 5px;
  padding: 0 4px;
}

.user-message .message-time {
  text-align: right;
}

.loading-text {
  color: #409EFF;
}

.chat-input {
  padding: 15px;
  border-top: 1px solid #eee;
}

.input-actions {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
}

/* Markdown样式 */
.markdown-content {
  line-height: 1.6;
}

.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3),
.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) {
  margin: 16px 0 8px 0;
  font-weight: bold;
  line-height: 1.4;
}

.markdown-content :deep(h1) { font-size: 1.5em; }
.markdown-content :deep(h2) { font-size: 1.3em; }
.markdown-content :deep(h3) { font-size: 1.1em; }

.markdown-content :deep(p) {
  margin: 8px 0;
}

.markdown-content :deep(ul),
.markdown-content :deep(ol) {
  margin: 8px 0;
  padding-left: 20px;
}

.markdown-content :deep(li) {
  margin: 4px 0;
}

.markdown-content :deep(code) {
  background-color: #f5f7fa;
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
  color: #e83e8c;
}

.markdown-content :deep(pre) {
  background-color: #f6f8fa;
  border: 1px solid #e1e4e8;
  border-radius: 6px;
  padding: 12px;
  overflow-x: auto;
  margin: 10px 0;
}

.markdown-content :deep(pre code) {
  background-color: transparent;
  padding: 0;
  color: #24292e;
  font-size: 0.9em;
}

.markdown-content :deep(blockquote) {
  border-left: 4px solid #409EFF;
  padding-left: 12px;
  margin: 10px 0;
  color: #666;
  background-color: #f5f7fa;
  padding: 8px 12px;
  border-radius: 0 4px 4px 0;
}

.markdown-content :deep(table) {
  border-collapse: collapse;
  width: 100%;
  margin: 10px 0;
}

.markdown-content :deep(table th),
.markdown-content :deep(table td) {
  border: 1px solid #e1e4e8;
  padding: 8px 12px;
  text-align: left;
}

.markdown-content :deep(table th) {
  background-color: #f6f8fa;
  font-weight: bold;
}

.markdown-content :deep(a) {
  color: #409EFF;
  text-decoration: none;
}

.markdown-content :deep(a:hover) {
  text-decoration: underline;
}

.markdown-content :deep(img) {
  max-width: 100%;
  height: auto;
}

.markdown-content :deep(hr) {
  border: none;
  border-top: 2px solid #e1e4e8;
  margin: 20px 0;
}

.markdown-content :deep(strong) {
  font-weight: bold;
  color: #000;
}

.markdown-content :deep(em) {
  font-style: italic;
}
</style>
