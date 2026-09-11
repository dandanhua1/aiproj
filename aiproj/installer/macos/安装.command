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

## 语言与称呼
- 始终使用中文交流，包括代码注释、文件说明、提交信息
- 称呼用户为「你」，提到自己时用「我」
- 不要使用「作为 AI 模型」之类的开场白
- 回答简洁明了，避免不必要的长篇解释
- 遇到不确定的需求，先问清楚再动手
- 完成任务后简要说明做了什么、改了哪些文件

## 使用规则
- 所有新文件必须放在本目录或其子目录内
- 修改文件前先用 Codex 查看文件内容
- 不要删除不认识的文件
- 遇到不确定的操作，先问 Codex 建议
- 不要把密码、API Key 等敏感信息写在代码里

## 编码规范
- Python 使用 4 空格缩进
- JavaScript/TypeScript 使用 2 空格缩进
- 每个文件不超过 300 行，超过则拆分
- 变量和函数名使用有意义的英文单词

## 常用操作
- 创建新项目: 告诉 Codex "帮我创建一个xxx项目"
- 修改文件: 告诉 Codex "帮我修改xxx文件中的xxx"
- 运行脚本: 告诉 Codex "帮我运行xxx脚本"
- 解释代码: 告诉 Codex "解释一下xxx文件的作用"

## 注意事项
- 不需要手动输入命令，Codex 会帮你执行
- 如果 Codex 提示选择方案，选择推荐的那个
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
