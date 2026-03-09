# OpenClaw Docker 镜像
# 预装中国 IM 平台插件 + Top 10 热门技能
FROM node:22-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV BUN_INSTALL="/usr/local" \
    PATH="/usr/local/bin:$PATH" \
    DEBIAN_FRONTEND=noninteractive

# 1. 合并系统依赖安装与全局工具安装，并清理缓存
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    chromium \
    curl \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    git \
    gosu \
    jq \
    python3 \
    socat \
    tini \
    unzip \
    websockify && \
    # 更新 npm 并安装全局包
    npm install -g npm@latest && \
    npm install -g openclaw@2026.3.2 opencode-ai@latest playwright playwright-extra puppeteer-extra-plugin-stealth @steipete/bird && \
    # 安装 bun 和 qmd
    curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash && \
    /usr/local/bin/bun install -g @tobilu/qmd && \
    # 安装 Playwright 浏览器依赖
    npx playwright install chromium --with-deps && \
    # 清理 apt 缓存
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.npm /root/.cache

# 2. 创建目录结构
RUN mkdir -p /home/node/.openclaw/workspace/skills /home/node/.openclaw/extensions && \
    chown -R node:node /home/node

USER node
ENV HOME=/home/node
WORKDIR /home/node

# 3. 安装 IM 平台插件
RUN cd /home/node/.openclaw/extensions && \
  git clone --depth 1 https://github.com/soimy/openclaw-channel-dingtalk.git dingtalk && \
  cd dingtalk && \
  npm install --omit=dev --legacy-peer-deps && \
  timeout 300 openclaw plugins install -l . || true && \
  cd /home/node/.openclaw/extensions && \
  git clone --depth 1 -b v4.17.25 https://github.com/Daiyimo/openclaw-napcat.git napcat && \
  cd napcat && \
  npm install --production && \
  timeout 300 openclaw plugins install -l . || true && \
  cd /home/node/.openclaw && \
  git clone --depth 1 https://github.com/justlovemaki/qqbot.git && \
  cd qqbot && \
  timeout 300 openclaw plugins install . || true && \
  timeout 300 openclaw plugins install @sunnoy/wecom@v1.5.1 || true && \
  find /home/node/.openclaw/extensions -name ".git" -type d -exec rm -rf {} + && \
  rm -rf /home/node/.openclaw/qqbot/.git && \
  rm -rf /tmp/* /home/node/.npm /home/node/.cache

# 4. 安装热门技能 (Top 10)
# 来源: https://github.com/LeoYeAI/openclaw-master-skills
# 技能列表:
#   - pdf: PDF 文件处理
#   - docx: Word 文档处理
#   - pptx: PowerPoint 演示文稿处理
#   - xlsx: Excel 电子表格处理
#   - skill-creator: 创建新技能
#   - mcp-builder: MCP 服务器构建
#   - brainstorming: 创意头脑风暴
#   - systematic-debugging: 系统化调试
#   - writing-plans: 编写实施计划
#   - test-driven-development: 测试驱动开发
RUN SKILLS_DIR="/home/node/.openclaw/workspace/skills" && \
    # 安装 Anthropic 官方技能
    git clone --depth 1 https://github.com/anthropics/skills.git /tmp/anthropics-skills && \
    cp -r /tmp/anthropics-skills/skills/pdf "$SKILLS_DIR/" && \
    cp -r /tmp/anthropics-skills/skills/docx "$SKILLS_DIR/" && \
    cp -r /tmp/anthropics-skills/skills/pptx "$SKILLS_DIR/" && \
    cp -r /tmp/anthropics-skills/skills/xlsx "$SKILLS_DIR/" && \
    cp -r /tmp/anthropics-skills/skills/skill-creator "$SKILLS_DIR/" && \
    cp -r /tmp/anthropics-skills/skills/mcp-builder "$SKILLS_DIR/" && \
    cp -r /tmp/anthropics-skills/skills/webapp-testing "$SKILLS_DIR/" && \
    rm -rf /tmp/anthropics-skills && \
    # 安装 Superpowers 技能集
    git clone --depth 1 https://github.com/obra/superpowers.git /tmp/superpowers && \
    cp -r /tmp/superpowers/skills/brainstorming "$SKILLS_DIR/" && \
    cp -r /tmp/superpowers/skills/systematic-debugging "$SKILLS_DIR/" && \
    cp -r /tmp/superpowers/skills/writing-plans "$SKILLS_DIR/" && \
    cp -r /tmp/superpowers/skills/test-driven-development "$SKILLS_DIR/" && \
    cp -r /tmp/superpowers/skills/executing-plans "$SKILLS_DIR/" && \
    cp -r /tmp/superpowers/skills/verification-before-completion "$SKILLS_DIR/" && \
    rm -rf /tmp/superpowers && \
    # 清理
    rm -rf /tmp/* /home/node/.npm /home/node/.cache

# 5. 最终配置
USER root

# 复制初始化脚本
COPY ./init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# 设置环境变量
ENV HOME=/home/node \
    TERM=xterm-256color \
    NODE_PATH=/usr/local/lib/node_modules

# 暴露端口
EXPOSE 18789 18790

# 设置工作目录为 home
WORKDIR /home/node

# 使用初始化脚本作为入口点
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]