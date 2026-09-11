# AGENTS.md — AI 编程环境安装包项目

## 项目说明
这是一个为企业内部非技术人员准备的 AI 编程环境一键安装包。
支持 Windows 和 macOS 两个平台。

## 目录结构
```
aiproj/
├── AGENTS.md                  # 本文件 (Codex 项目说明)
├── README.md                  # 使用说明
├── installer/
│   ├── windows/
│   │   ├── 安装.bat           # Windows 双击安装入口
│   │   └── install.ps1        # Windows 安装逻辑
│   ├── macos/
│   │   └── 安装.command       # macOS 双击安装入口
│   └── shared/
│       └── workspace-AGENTS.md # 部署到用户工作区的 AGENTS.md 模板
```

## 安装内容
| 软件 | Windows 安装方式 | macOS 安装方式 |
|------|-----------------|---------------|
| Node.js LTS | winget | brew install node@20 |
| Git | winget | brew install git |
| Python 3.12 | winget | brew install python3 |
| VS Code | winget | brew install --cask visual-studio-code |
| Chrome | winget | brew install --cask google-chrome |
| CC Switch | GitHub MSI | brew install --cask cc-switch |
| Codex CLI | npm -g @openai/codex | npm -g @openai/codex |

## 修改规范
- 修改安装逻辑时，确保 Windows 和 macOS 两个脚本同步更新
- 保持脚本中的中文注释和提示
- 不要移除 npm 国内镜像配置
- AGENTS.md 模板修改后需同时更新 install.ps1 中的内嵌版本
- 新增软件时在 README.md 的安装内容表格中添加一行

## 测试
- 修改 install.ps1 后运行: `powershell -File installer/windows/install.ps1 -WhatIf`（如果支持）
- 或者在干净的虚拟机中完整测试安装流程
- macOS 脚本需要在 macOS 环境中测试

## 注意事项
- 不要在此目录中安装任何依赖或运行安装脚本
- 安装脚本使用管理员权限，不要在生产环境直接测试
- CC Switch 版本号通过 GitHub API 动态获取，无需手动更新