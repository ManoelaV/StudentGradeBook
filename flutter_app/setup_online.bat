@echo off
REM Instalador Online Student Grade Book
REM Faz download automático do GitHub e instala
REM Execute com duplo clique

setlocal enabledelayedexpansion

echo.
echo ================================
echo Student Grade Book - Instalador
echo ================================
echo.

REM Versão atual (atualize quando tiver nova versão no GitHub)
set "APP_NAME=Student Grade Book"
set "VERSION=1.0.0"
set "GITHUB_REPO=ManoelaV/StudentGradeBook"
set "RELEASE_URL=https://github.com/%GITHUB_REPO%/releases/download/v%VERSION%/student_grade_book.exe"

REM Pasta de instalação
set "INSTALL_PATH=%ProgramFiles%\%APP_NAME%"

echo Baixando %APP_NAME% v%VERSION%...
echo.

REM Criar pasta temporária se não existir
if not exist "%TEMP%\StudentGradeBook" mkdir "%TEMP%\StudentGradeBook"

REM Baixar arquivo usando PowerShell (mais confiável)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; ^
   $ProgressPreference = 'SilentlyContinue'; ^
   Write-Host 'Baixando...' -ForegroundColor Cyan; ^
   try { ^
     Invoke-WebRequest -Uri '%RELEASE_URL%' -OutFile '%TEMP%\StudentGradeBook\app.exe' -ErrorAction Stop; ^
     Write-Host 'Download concluído!' -ForegroundColor Green ^
   } catch { ^
     Write-Host 'Erro ao baixar!' -ForegroundColor Red; ^
     Write-Host $_.Exception.Message; ^
     exit 1 ^
   }"

if errorlevel 1 (
    echo.
    echo ERRO: Nao consegui baixar o arquivo!
    echo.
    echo Verificar:
    echo  - Sua conexao com internet
    echo  - Se a release foi criada no GitHub
    echo.
    pause
    exit /b 1
)

echo.
echo Instalando em %INSTALL_PATH%...
echo.

REM Criar pasta de instalação
if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"

REM Copiar arquivo
copy "%TEMP%\StudentGradeBook\app.exe" "%INSTALL_PATH%\student_grade_book.exe" /Y >nul

if errorlevel 1 (
    echo ERRO ao instalar!
    pause
    exit /b 1
)

echo OK!
echo.
echo Criando atalhos...

REM Criar atalho no Menu Iniciar
set MENU_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs

if not exist "%MENU_PATH%" mkdir "%MENU_PATH%"

powershell -NoProfile -Command ^
  "$WshShell = New-Object -ComObject WScript.Shell; ^
   $Shortcut = $WshShell.CreateShortcut('%MENU_PATH%\%APP_NAME%.lnk'); ^
   $Shortcut.TargetPath = '%INSTALL_PATH%\student_grade_book.exe'; ^
   $Shortcut.WorkingDirectory = '%INSTALL_PATH%'; ^
   $Shortcut.Save()"

echo OK!
echo.

REM Limpar temporário
if exist "%TEMP%\StudentGradeBook\app.exe" del "%TEMP%\StudentGradeBook\app.exe" /Q

echo ================================
echo Instalacao concluida com sucesso!
echo ================================
echo.
echo %APP_NAME% foi instalado em:
echo %INSTALL_PATH%
echo.
echo Atalho criado no Menu Iniciar
echo.
echo Iniciando aplicacao...
echo.

REM Executar o programa
start "" "%INSTALL_PATH%\student_grade_book.exe"

pause
