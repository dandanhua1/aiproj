@echo off
chcp 65001 >nul 2>&1
title AI 编程环境一键安装
color 0A

echo.
echo  ==========================================
echo    AI 编程环境一键安装
echo    VSCode + Git + Python + Node.js + Codex + CC Switch + Chrome
echo  ==========================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  [提示] 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 运行 PowerShell 安装脚本
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

echo.
echo  按任意键退出...
pause >nul