@echo off
REM Script para criar instalador Student Grade Book
REM Execute este arquivo com duplo clique na pasta flutter_app

setlocal enabledelayedexpansion

echo.
echo ================================
echo Student Grade Book - Build Installer
echo ================================
echo.

REM Verificar se estamos na pasta flutter_app
if not exist "pubspec.yaml" (
    echo ERRO: Este script deve ser executado na pasta flutter_app
    pause
    exit /b 1
)

echo Verificando se o Google Flutter esta instalado...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Flutter nao encontrado!
    echo Instale Flutter em: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo Flutter OK
echo.

REM Verificar se o build release existe
if not exist "build\windows\x64\runner\Release\student_grade_book.exe" (
    echo Criando build release... (este processo pode demorar)
    echo.
    call flutter build windows --release
    
    if errorlevel 1 (
        echo ERRO ao compilar!
        pause
        exit /b 1
    )
)

echo.
echo Procurando InnoSetup...

REM Procurar InnoSetup em locais comuns
for %%A in (
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    "C:\Program Files\Inno Setup 6\ISCC.exe"
    "C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
) do (
    if exist %%A (
        set "INNOSETUPING=%%A"
        goto :found
    )
)

REM Se nao encontrou
echo.
echo ERRO: InnoSetup nao foi encontrado!
echo.
echo Para criar um instalador profissional:
echo  1. Acesse: https://jrsoftware.org/isdl.php
echo  2. Instale "Inno Setup"
echo  3. Execute este script novamente
echo.
echo OU crie o instalador manualmente:
echo  1. Abra InnoSetup
echo  2. Abra o arquivo: student_grade_book_installer.iss
echo  3. Clique em Compile
echo.
pause
exit /b 1

:found
echo Encontrado: %INNOSETUPING%
echo.

REM Criar pasta de output
if not exist "release_installer" mkdir release_installer

echo Compilando instalador (pode levar um minuto)...
echo.

"%INNOSETUPING%/" "student_grade_book_installer.iss"

if errorlevel 1 (
    echo.
    echo ERRO ao compilar!
    pause
    exit /b 1
)

echo.
echo ================================
echo Sucesso! Instalador criado!
echo ================================
echo.

dir /b release_installer\StudentGradeBook_Installer*.exe

echo.
echo Arquivo salvo em: release_installer\
echo Agora voce pode distribuir o instalador para seus usuarios!
echo.
pause
