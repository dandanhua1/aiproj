# AI 编程环境一键安装脚本
# 使用方式: irm https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.ps1 | iex
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 管理员权限检查（一行命令安装时需要自动提权）
$scriptUrl = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.ps1"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[提示] 正在请求管理员权限..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "iex (irm '$scriptUrl')")
    exit
}

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
$agentsContent = @"
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
"@
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