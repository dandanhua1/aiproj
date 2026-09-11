# AI 编程环境一键安装脚本
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Step($msg) { Write-Host "`n[安装] $msg" -ForegroundColor Cyan }
function Write-OK($msg) { Write-Host "  [完成] $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "  [跳过] $msg (已安装)" -ForegroundColor Yellow }
function Test-Command($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }
function Install-Winget($id, $name, $checkCmd) {
    if (Test-Command $checkCmd) { Write-Skip $name; return }
    Write-Step "安装 $name..."
    winget install --id $id --accept-source-agreements --accept-package-agreements --silent | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "  [警告] $name 安装可能未完成" -ForegroundColor Red }
    else { Write-OK $name }
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "  AI 编程环境一键安装" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 1. Node.js
Write-Step "安装 Node.js LTS (Codex 依赖)..."
Install-Winget "OpenJS.NodeJS.LTS" "Node.js LTS" "node"
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH","User")

# 2. npm 国内镜像
if (Test-Command "npm") {
    Write-Step "配置 npm 国内镜像..."
    npm config set registry https://registry.npmmirror.com 2>$null
    Write-OK "npm 镜像已配置"
}

# 3. Git
Write-Step "安装 Git..."
Install-Winget "Git.Git" "Git" "git"
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH","User")

# 4. Python 3
Write-Step "安装 Python 3..."
Install-Winget "Python.Python.3.12" "Python 3.12" "python"
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH","User")

# 5. VS Code
Write-Step "安装 Visual Studio Code..."
Install-Winget "Microsoft.VisualStudioCode" "VS Code" "code"

# 6. Chrome
Write-Step "安装 Google Chrome..."
Install-Winget "Google.Chrome" "Google Chrome" "chrome"
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH","User")

# 7. CC Switch
Write-Step "安装 CC Switch..."
$msi = "$env:TEMP\CC-Switch-Setup.msi"
try {
    $rel = Invoke-RestMethod "https://api.github.com/repos/farion1231/cc-switch/releases/latest" -UseBasicParsing
    $asset = $rel.assets | Where-Object { $_.name -match "Windows.*\.msi$" -and $_.name -notmatch "arm64" } | Select-Object -First 1
    if ($asset) {
        Invoke-WebRequest $asset.browser_download_url -OutFile $msi -UseBasicParsing
        Start-Process msiexec "/i `"$msi`" /qn /norestart" -Wait
        Write-OK "CC Switch"
    } else { Write-Host "  [警告] 未找到 MSI，请手动下载" -ForegroundColor Red }
} catch { Write-Host "  [警告] CC Switch 下载失败" -ForegroundColor Red }

# 8. Codex CLI
if (Test-Command "npm") {
    Write-Step "安装 Codex CLI..."
    npm install -g @openai/codex 2>$null
    if ($LASTEXITCODE -eq 0) { Write-OK "Codex CLI" }
    else { Write-Host "  [警告] Codex CLI 安装失败" -ForegroundColor Red }
}
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH","User")

# 9. 工作目录
$workspace = "$env:USERPROFILE\AIWorkspace"
if (-not (Test-Path $workspace)) {
    Write-Step "创建工作目录: $workspace"
    New-Item -ItemType Directory $workspace -Force | Out-Null
}

# AGENTS.md
$agentsPath = Join-Path $workspace "AGENTS.md"
$agentsContent = @(
    "# AI 编程工作区"
    ""
    "## 语言与称呼"
    "- 始终使用中文交流，包括代码注释、文件说明、提交信息"
    "- 称呼用户为「你」，提到自己时用「我」"
    "- 不要使用「作为 AI 模型」之类的开场白"
    "- 回答简洁明了，避免不必要的长篇解释"
    "- 遇到不确定的需求，先问清楚再动手"
    "- 完成任务后简要说明做了什么、改了哪些文件"
    ""
    "## 使用规则"
    "- 所有新文件必须放在本目录或其子目录内"
    "- 修改文件前先用 Codex 查看文件内容"
    "- 不要删除不认识的文件"
    "- 遇到不确定的操作，先问 Codex 建议"
    "- 不要把密码、API Key 等敏感信息写在代码里"
    ""
    "## 编码规范"
    "- Python 使用 4 空格缩进"
    "- JavaScript/TypeScript 使用 2 空格缩进"
    "- 每个文件不超过 300 行，超过则拆分"
    "- 变量和函数名使用有意义的英文单词"
    ""
    "## 常用操作"
    "- 创建新项目: 告诉 Codex 帮我创建一个xxx项目"
    "- 修改文件: 告诉 Codex 帮我修改xxx文件中的xxx"
    "- 运行脚本: 告诉 Codex 帮我运行xxx脚本"
    "- 解释代码: 告诉 Codex 解释一下xxx文件的作用"
    ""
    "## 注意事项"
    "- 不需要手动输入命令，Codex 会帮你执行"
    "- 安装软件时 Codex 会自动请求管理员权限"
    "- 如果 Codex 提示选择方案，选择推荐的那个"
) -join "`n"
[System.IO.File]::WriteAllText($agentsPath, $agentsContent, [System.Text.Encoding]::UTF8)
Write-OK "AGENTS.md 已写入工作目录"

# Git 初始化
if (Test-Command "git") {
    if (-not (Test-Path (Join-Path $workspace ".git"))) {
        Push-Location $workspace; git init 2>$null; Pop-Location
        Write-OK "Git 仓库已初始化"
    }
}

# .gitignore
$gi = Join-Path $workspace ".gitignore"
[System.IO.File]::WriteAllText($gi, "__pycache__/`n*.pyc`nnode_modules/`n.env`n*.log`n.DS_Store`nThumbs.db", [System.Text.Encoding]::UTF8)

# 桌面快捷方式
Write-Step "创建桌面快捷方式..."
$desktop = [Environment]::GetFolderPath("Desktop")
$vscode = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
if (Test-Path $vscode) {
    $ws = (New-Object -ComObject WScript.Shell).CreateShortcut("$desktop\AI 工作区.lnk")
    $ws.TargetPath = $vscode; $ws.Arguments = $workspace; $ws.WorkingDirectory = $workspace; $ws.Save()
    Write-OK "桌面快捷方式: AI 工作区"
}

# 完成
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  安装完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  工作目录: $workspace" -ForegroundColor Cyan
Write-Host "  下一步: 双击桌面[AI 工作区]打开 VS Code" -ForegroundColor Yellow
Write-Host "  打开 CC Switch 配置 API Key 后即可使用 codex" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
