#!/bin/bash
# AI 编程环境一键安装 - macOS
# 使用方式: 双击此文件运行

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

step() { echo -e "\n${CYAN}[安装] $1${NC}"; }
ok() { echo -e "  ${GREEN}[完成] $1${NC}"; }
skip() { echo -e "  ${YELLOW}[跳过] $1 (已安装)${NC}"; }

echo "========================================"
echo "  AI 编程环境一键安装 (macOS)"
echo "========================================"
echo ""

# 1. Homebrew
if ! command -v brew &> /dev/null; then
    step "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
else
    skip "Homebrew"
fi

# 2. Node.js
if ! command -v node &> /dev/null; then
    step "安装 Node.js LTS..."
    brew install node@20
    brew link node@20 2>/dev/null || true
else
    skip "Node.js"
fi

# 3. npm 国内镜像
if command -v npm &> /dev/null; then
    step "配置 npm 国内镜像..."
    npm config set registry https://registry.npmmirror.com
    ok "npm 镜像已配置"
fi

# 4. Git
if ! command -v git &> /dev/null; then
    step "安装 Git..."
    brew install git
else
    skip "Git"
fi

# 5. Python 3
if ! command -v python3 &> /dev/null; then
    step "安装 Python 3..."
    brew install python3
else
    skip "Python 3"
fi

# 6. VS Code
if ! command -v code &> /dev/null; then
    step "安装 Visual Studio Code..."
    brew install --cask visual-studio-code
else
    skip "VS Code"
fi

# 7. Chrome
if ! command -v google-chrome &> /dev/null; then
    step "安装 Google Chrome..."
    brew install --cask google-chrome
else
    skip "Chrome"
fi

# 8. CC Switch
if ! command -v cc-switch &> /dev/null && [ ! -d "/Applications/CC Switch.app" ]; then
    step "安装 CC Switch..."
    brew install --cask cc-switch
else
    skip "CC Switch"
fi

# 9. Codex CLI
if command -v npm &> /dev/null; then
    if ! command -v codex &> /dev/null; then
        step "安装 Codex CLI..."
        npm install -g @openai/codex
        ok "Codex CLI"
    else
        skip "Codex CLI"
    fi
fi

# 10. 工作目录 + AGENTS.md
WORKSPACE="$HOME/AIWorkspace"
if [ ! -d "$WORKSPACE" ]; then
    step "创建工作目录: $WORKSPACE"
    mkdir -p "$WORKSPACE"
fi

step "写入 AGENTS.md..."
cat > "$WORKSPACE/AGENTS.md" << 'AGENTS_EOF'
# AI 编程工作区

## 称呼规则
每次回复前必须使用「____」作为称呼，并且使用中文。

## 决策确认
遇到不确定的操作时，必须先询问「____」，不得直接执行。

## 目录布局

- 本目录是所有代码和文件的存放位置
- 不要把文件放在本目录之外

## 行为准则

### 1. 先想后做

**不要假设。不懂就问。**

- 不确定你的意思时，先问清楚再动手
- 如果有多种做法，列出选项让你选
- 如果有更简单的方案，主动提出来

### 2. 简洁优先

**做最少的事来完成任务。**

- 不加没要求的功能
- 不写多余的代码
- 如果改了太多行，主动检查是否有更简单的写法

### 3. 精准修改

**只改你要求的，不动其他的。**

- 不要「顺手」修改别的文件
- 不要删除你不认识的东西
- 每一个改动都应该和你说的需求有关

### 4. 做完确认

**告诉你改了什么，让你检查。**

- 每次完成任务后，简要说明做了什么、改了哪些文件
- 如果出了问题，告诉你怎么撤销

## 任务模板

把 ____ 替换成你的内容，复制后直接发给 Codex。

### 创建项目
帮我创建一个 ____ 项目，需要实现 ____ 功能。

### 修改代码
帮我修改 ____ 文件，把 ____ 改成 ____。

### 修复错误
运行 ____ 时报错了，错误信息是 ____，帮我修复。

### 添加功能
帮我给 ____ 添加 ____ 功能。

### 解释代码
解释一下 ____ 文件的作用。

### 运行程序
帮我运行 ____ 。

### 格式化
帮我把 ____ 文件格式化一下。

### 删除文件
帮我把 ____ 删掉。

## 安全提醒

- 不要把密码、API Key 写在代码里
- 删除文件前 Codex 会先确认
- 不认识的文件不要随便删
AGENTS_EOF
ok "AGENTS.md 已写入工作目录"

# 11. Git 初始化
if command -v git &> /dev/null; then
    if [ ! -d "$WORKSPACE/.git" ]; then
        step "初始化 Git 仓库..."
        cd "$WORKSPACE" && git init
        ok "Git 仓库已初始化"
    fi
fi

# .gitignore
cat > "$WORKSPACE/.gitignore" << 'GI_EOF'
__pycache__/
*.pyc
node_modules/
.env
*.log
.DS_Store
GI_EOF

# 12. 打开 VS Code
if command -v code &> /dev/null; then
    step "打开 VS Code..."
    open -a "Visual Studio Code" "$WORKSPACE"
fi

# 完成
echo ""
echo "========================================"
echo -e "  ${GREEN}安装完成!${NC}"
echo "========================================"
echo -e "  工作目录: ${CYAN}$WORKSPACE${NC}"
echo -e "  ${YELLOW}下一步: 在 CC Switch 中配置 API Key${NC}"
echo -e "  ${YELLOW}配置完成后在 VS Code 终端中输入 codex 开始使用${NC}"
echo "========================================"
echo ""
echo "安装脚本执行完毕"
