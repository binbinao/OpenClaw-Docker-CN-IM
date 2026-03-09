#!/bin/bash
# OpenClaw 预装技能安装脚本
# 从官方技能仓库安装 Top 10 热门技能

set -e

SKILLS_DIR="/home/node/.openclaw/workspace/skills"
mkdir -p "$SKILLS_DIR"

echo "=== 安装 OpenClaw 热门技能 ==="

# 1. PDF 处理技能
echo "📦 安装 pdf 技能..."
if [ ! -d "$SKILLS_DIR/pdf" ]; then
  git clone --depth 1 https://github.com/anthropics/skills.git /tmp/anthropics-skills
  cp -r /tmp/anthropics-skills/skills/pdf "$SKILLS_DIR/"
  cp -r /tmp/anthropics-skills/skills/docx "$SKILLS_DIR/"
  cp -r /tmp/anthropics-skills/skills/pptx "$SKILLS_DIR/"
  cp -r /tmp/anthropics-skills/skills/xlsx "$SKILLS_DIR/"
  cp -r /tmp/anthropics-skills/skills/skill-creator "$SKILLS_DIR/"
  cp -r /tmp/anthropics-skills/skills/mcp-builder "$SKILLS_DIR/"
  cp -r /tmp/anthropics-skills/skills/canvas-design "$SKILLS_DIR/"
  rm -rf /tmp/anthropics-skills
fi

# 2. Superpowers 技能集
echo "📦 安装 superpowers 技能集..."
if [ ! -d "$SKILLS_DIR/brainstorming" ]; then
  git clone --depth 1 https://github.com/obra/superpowers.git /tmp/superpowers
  cp -r /tmp/superpowers/skills/brainstorming "$SKILLS_DIR/"
  cp -r /tmp/superpowers/skills/systematic-debugging "$SKILLS_DIR/"
  cp -r /tmp/superpowers/skills/writing-plans "$SKILLS_DIR/"
  cp -r /tmp/superpowers/skills/test-driven-development "$SKILLS_DIR/"
  cp -r /tmp/superpowers/skills/executing-plans "$SKILLS_DIR/"
  cp -r /tmp/superpowers/skills/verification-before-completion "$SKILLS_DIR/"
  rm -rf /tmp/superpowers
fi

# 3. Web 测试技能
echo "📦 安装 webapp-testing 技能..."
if [ ! -d "$SKILLS_DIR/webapp-testing" ]; then
  git clone --depth 1 https://github.com/anthropics/skills.git /tmp/anthropics-skills-web
  cp -r /tmp/anthropics-skills-web/skills/webapp-testing "$SKILLS_DIR/"
  rm -rf /tmp/anthropics-skills-web
fi

# 清理
rm -rf /tmp/* ~/.npm ~/.cache

echo "✅ 技能安装完成！"
echo "已安装技能列表："
ls -la "$SKILLS_DIR"