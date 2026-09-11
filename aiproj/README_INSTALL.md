# AI 编程环境安装说明

## 一行命令安装（推荐）

### Windows
打开 PowerShell，粘贴以下命令并回车：

```powershell
irm https://raw.githubusercontent.com/dandanhua1/aiproj/main/install.ps1 | iex
```

> 请将 URL 替换为你实际托管的脚本地址（如 GitHub Raw、Gitee 等）。

### macOS
打开终端，粘贴以下命令并回车：

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.command | bash
```

> 请将 URL 替换为你实际托管的脚本地址。

## 安装内容

| 软件 | 说明 |
|------|------|
| Node.js LTS | Codex CLI 运行依赖 |
| Git | 版本控制 |
| Python 3.12 | 编程环境 |
| VS Code | 代码编辑器 |
| Chrome | 浏览器 |
| CC Switch | API Key 管理工具 |
| Codex CLI | AI 编程助手 |

## 手动安装（备选）

如果一行命令不可用，可以下载整个 `installer` 文件夹后：

- **Windows**: 双击 `installer/windows/安装.bat`
- **macOS**: 双击 `installer/macos/安装.command`

## 安装后

1. 双击桌面上的 **AI 工作区** 快捷方式打开 VS Code
2. 打开 **CC Switch** 配置你的 API Key
3. 在 VS Code 终端中输入 `codex` 开始使用

## 托管脚本

要让一行命令生效，需要将 `install.ps1` 托管到一个可通过 HTTPS 访问的地址。

### 使用 GitHub

1. 创建一个 GitHub 仓库（如 `ai-setup`）
2. 将 `installer/windows/install.ps1` 推送到仓库根目录
3. 一行命令 URL 为：
   ```
   https://raw.githubusercontent.com/<用户名>/<仓库名>/main/install.ps1
   ```
4. 同时更新 `install.ps1` 顶部的 `$scriptUrl` 变量为该地址