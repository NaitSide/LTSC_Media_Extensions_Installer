@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Вшивание расширений в WIM - NaitSide Custom Build

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo =========================================================
    echo    [ОШИБКА] Требуются права администратора!
    echo =========================================================
    echo.
    echo    Запустите скрипт правой кнопкой мыши
    echo    -^> "Запуск от имени администратора"
    echo.
    echo =========================================================
    echo.
    pause
    exit /b
)

cls
echo.
echo =========================================================
echo    Add_Media_Extensions_to_WIM
echo    Вшивание мультимедийных расширений
echo    NaitSide Custom Build
echo =========================================================
echo.
echo    Этот скрипт установит расширения в образ Windows:
echo.
echo    • Выбор буквы диска смонтированного VHD
echo    • Установка всех .AppxBundle из папки Extensions
echo    • Интеграция расширений через DISM
echo.
echo =========================================================
echo    GitHub: github.com/NaitSide
echo =========================================================
echo.
pause

:: Перейти в каталог скрипта
pushd "%~dp0"
SET "ScriptDir=%CD%"

:INPUT_DRIVE
echo.
set /p TargetDrive="Выберите букву диска VHD где развернут Windows (например, G): "

:: Формируем путь ImagePath
SET "ImagePath=%TargetDrive%:"

:: Проверка наличия целевого диска
IF NOT EXIST %ImagePath%\ (
    echo [ОШИБКА] Диск %ImagePath% не найден. Убедитесь, что VHD смонтирован.
    goto INPUT_DRIVE
)

:: Путь к папке с расширениями
SET "EXTENSIONS_DIR=%ScriptDir%\Extensions"

:: Проверка папки Extensions
IF NOT EXIST "%EXTENSIONS_DIR%" (
    echo [ОШИБКА] Папка Extensions не найдена: %EXTENSIONS_DIR%
    echo Создайте папку Extensions и поместите туда файлы .AppxBundle
    pause
    exit /b
)

echo.
echo =========================================================
echo Начинаем установку расширений в %ImagePath%
echo Папка с файлами: %EXTENSIONS_DIR%
echo =========================================================
echo.

:: Счетчик установленных файлов
SET "InstalledCount=0"
SET "ErrorCount=0"

:: Перебор всех .AppxBundle файлов в папке Extensions
for /f "tokens=*" %%F in ('dir /b /a-d "%EXTENSIONS_DIR%\*.AppxBundle" 2^>nul') do (
    echo Установка: %%F
    dism /Image:%ImagePath% /Add-ProvisionedAppxPackage /PackagePath:"%EXTENSIONS_DIR%\%%F" /SkipLicense >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo [OK] %%F установлен
        SET /A InstalledCount+=1
    ) else (
        echo [ОШИБКА] %%F не установлен
        SET /A ErrorCount+=1
    )
    echo.
)

echo.
echo =========================================================
echo Процесс установки завершен
echo Установлено успешно: %InstalledCount%
echo Ошибок: %ErrorCount%
echo =========================================================

pause