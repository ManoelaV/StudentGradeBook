@echo off
REM Instalador Online Student Grade Book
REM Faz download e instalacao automatica

REM Verificar se tem permissao de admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Solicitando permissao de administrador...
    echo.
    
    REM Solicitar elevacao de privilegios
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion

echo.
echo ================================
echo Student Grade Book - Instalador
echo ================================
echo.

REM Configuracao
set "APP_NAME=Student Grade Book"
set "VERSION=1.0.0"
set "GITHUB_REPO=ManoelaV/StudentGradeBook"
set "RELEASE_URL=https://github.com/%GITHUB_REPO%/releases/download/v%VERSION%/StudentGradeBook_portable.zip"
REM Instalar na pasta do usuario (sem precisar admin)
set "INSTALL_PATH=%LOCALAPPDATA%\%APP_NAME%"

echo Baixando %APP_NAME% v%VERSION%...
echo (Tamanho: ~32 MB - pode levar alguns minutos)
echo.

REM Criar pasta temporaria
if not exist "%TEMP%\SGradeBook" mkdir "%TEMP%\SGradeBook"

REM Deletar arquivo antigo
if exist "%TEMP%\SGradeBook\app.zip" del "%TEMP%\SGradeBook\app.zip" /Q 2>nul

REM Fazer download com PowerShell (versao simples)
powershell -NoProfile -Command "try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12'; Invoke-WebRequest -Uri '%RELEASE_URL%' -OutFile '%TEMP%\SGradeBook\app.zip' -UseBasicParsing; Write-Host 'OK - Download concluido' -ForegroundColor Green } catch { Write-Host 'ERRO: Nao consegui baixar!' -ForegroundColor Red; exit 1 }"

if errorlevel 1 (
    echo.
    echo ERRO ao fazer download!
    echo.
    echo Verifique:
    echo  - Sua conexao com internet
    echo  - Se o arquivo StudentGradeBook_portable.zip existe em:
    echo    %RELEASE_URL%
    echo.
    pause
    exit /b 1
)

echo.
echo Preparando instalacao...

REM Deletar pasta antiga se existir
if exist "%INSTALL_PATH%" (
    echo Removendo versao antiga...
    rmdir /S /Q "%INSTALL_PATH%" >nul 2>&1
)

REM Criar pasta nova
mkdir "%INSTALL_PATH%" >nul 2>&1

REM Extrair ZIP
echo Extraindo arquivos...
powershell -NoProfile -Command "Expand-Archive -Path '%TEMP%\SGradeBook\app.zip' -DestinationPath '%INSTALL_PATH%' -Force"

if errorlevel 1 (
    echo ERRO ao extrair!
    pause
    exit /b 1
)

echo OK!
echo.
echo Criando atalho no Menu Iniciar...

REM Criar atalho no Menu Iniciar
set MENU_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs

powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%MENU_PATH%\%APP_NAME%.lnk'); $sc.TargetPath = '%INSTALL_PATH%\student_grade_book.exe'; $sc.WorkingDirectory = '%INSTALL_PATH%'; $sc.Save()"

REM Limpar temporario
del "%TEMP%\SGradeBook\app.zip" /Q 2>nul
rmdir "%TEMP%\SGradeBook" 2>nul

echo.
echo ================================
echo Sucesso! Instalacao Concluida
echo ================================
echo.
echo Aplicacao instalada em:
echo %INSTALL_PATH%
echo.
echo Iniciando %APP_NAME%...
echo.

REM Abrir programa
start "" "%INSTALL_PATH%\student_grade_book.exe"

timeout /t 3 /nobreak >nul

