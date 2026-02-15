@echo off
chcp 65001 >nul
title Проверка версий расширений

echo ====================================
echo   Проверка установленных расширений
echo   NaitSide Custom Build
echo ====================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage | Where-Object {$_.Name -match 'AV1|HEIF|HEVC|Raw|VP9|WebMedia|Webp'} | Select-Object Name, Version | Sort-Object Name | Format-Table -AutoSize"

echo.
echo ====================================
pause