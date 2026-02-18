@echo off
REM Script para preparar a distribuição
REM Cria um ZIP com tudo que é necessário para instalar

setlocal enabledelayedexpansion

echo.
echo ================================
echo Student Grade Book - Prepare Release
echo ================================
echo.

cd /d "%~dp0"

REM Verificar se build existe
if not exist "build\windows\x64\runner\Release\student_grade_book.exe" (
    echo ERRO: Executavel nao encontrado!
    echo Execute primeiro: flutter build windows --release
    pause
    exit /b 1
)

echo Preparando arquivos para distribuicao...
echo.

REM Criar pasta release
if not exist "release_files" mkdir "release_files"

REM Copiar tudo
echo Copiando executavel e dependencias...
xcopy "build\windows\x64\runner\Release\*" "release_files\" /E /Y /I >nul

if errorlevel 1 (
    echo ERRO ao copiar arquivos!
    pause
    exit /b 1
)

echo OK
echo.

REM Criar ZIP - tentar TAR primeiro (Windows 10+), depois fallback
echo Criando arquivo compactado...
echo.

REM Tentar com TAR (Windows 10+)
tar -czf StudentGradeBook_portable.zip release_files >nul 2>&1

if errorlevel 1 (
    echo.
    echo AVISO: Nao consegui criar ZIP com os metodos padrao do Windows.
    echo.
    echo Solucao: Instale 7-Zip para comprimir
    echo Download: https://www.7-zip.org/download.html
    echo.
    echo OU simplesmente copie a pasta 'release_files' manualmente
    echo e comprima com seu programa de ZIP favorito.
    echo.
    
    REM Criar arquivo de instrucoes
    echo Instrucoes para distribuir manualmente > INSTRUCOES_DISTRIBUICAO.txt
    echo. >> INSTRUCOES_DISTRIBUICAO.txt
    echo 1. Se tem 7-Zip instalado: >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - Clique direito em 'release_files' >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - 7-Zip ^> Add to archive >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - Renomeie o resultado para StudentGradeBook_portable.zip >> INSTRUCOES_DISTRIBUICAO.txt
    echo. >> INSTRUCOES_DISTRIBUICAO.txt
    echo 2. Se tem WinRAR: >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - Clique direito em 'release_files' >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - Add to archive... >> INSTRUCOES_DISTRIBUICAO.txt
    echo. >> INSTRUCOES_DISTRIBUICAO.txt
    echo 3. Se tem Windows 10/11 nativo: >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - Clique direito em 'release_files' >> INSTRUCOES_DISTRIBUICAO.txt
    echo    - Enviar para ^> Pasta compactada >> INSTRUCOES_DISTRIBUICAO.txt
    echo. >> INSTRUCOES_DISTRIBUICAO.txt
    
    echo OK - Foi criada a pasta 'release_files' com os arquivos
    echo Arquivo de instrucoes criado: INSTRUCOES_DISTRIBUICAO.txt
    echo.
    pause
    exit /b 0
)

echo OK - Arquivo criado!

REM Limpar pasta temporaria
rmdir /S /Q "release_files" >nul 2>&1

echo.
echo ================================
echo Sucesso!
echo ================================
echo.
echo Arquivo criado: StudentGradeBook_portable.zip
echo.
echo Proximos passos:
echo  1. Faca upload do ZIP no GitHub Releases
echo  2. Distribua o arquivo setup_online_v2.bat
echo.
pause
