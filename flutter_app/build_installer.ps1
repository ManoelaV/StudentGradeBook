# Script PowerShell para automatizar criação do instalador Windows
# Uso: powershell -ExecutionPolicy Bypass -File build_installer.ps1

param(
    [switch]$SkipBuildCheck = $false
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Student Grade Book - Build Installer" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Cores para output
$Success = "Green"
$Error = "Red"
$Warning = "Yellow"
$Info = "Cyan"

# Verificar se estamos na pasta correta
if (-not (Test-Path ".\pubspec.yaml")) {
    Write-Host "❌ Erro: Execute este script da pasta flutter_app" -ForegroundColor $Error
    exit 1
}

Write-Host "✓ Você está na pasta correta" -ForegroundColor $Success
Write-Host ""

# Passo 1: Verificar se o build release já existe
if (-not $SkipBuildCheck) {
    Write-Host "Verificando build Windows..." -ForegroundColor $Info
    
    if (Test-Path ".\build\windows\x64\runner\Release\student_grade_book.exe") {
        Write-Host "✓ Build release encontrado" -ForegroundColor $Success
    } else {
        Write-Host "⚠️  Build release não encontrado. Criando..." -ForegroundColor $Warning
        Write-Host "Isso pode levar alguns minutos..." -ForegroundColor $Info
        
        flutter build windows --release
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Erro ao compilar! Verifique os logs acima." -ForegroundColor $Error
            exit 1
        }
    }
    Write-Host ""
}

# Passo 2: Verificar InnoSetup
Write-Host "Procurando InnoSetup..." -ForegroundColor $Info

$InnoSetupPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
)

$InnoSetupPath = $null
foreach ($path in $InnoSetupPaths) {
    if (Test-Path $path) {
        $InnoSetupPath = $path
        break
    }
}

if ($InnoSetupPath -eq $null) {
    Write-Host ""
    Write-Host "❌ InnoSetup não encontrado!" -ForegroundColor $Error
    Write-Host ""
    Write-Host "Para criar um instalador profissional, instale InnoSetup:" -ForegroundColor $Info
    Write-Host "  1. Visite: https://jrsoftware.org/isdl.php" -ForegroundColor $Info
    Write-Host "  2. Baixe e instale 'Inno Setup'" -ForegroundColor $Info
    Write-Host "  3. Execute este script novamente" -ForegroundColor $Info
    Write-Host ""
    Write-Host "OU crie o instalador manualmente:" -ForegroundColor $Warning
    Write-Host "  1. Abra InnoSetup" -ForegroundColor $Warning
    Write-Host "  2. File → Open → $PSScriptRoot\student_grade_book_installer.iss" -ForegroundColor $Warning
    Write-Host "  3. Clique em Compile (ou pressione F9)" -ForegroundColor $Warning
    Write-Host ""
    exit 1
}

Write-Host "✓ InnoSetup encontrado: $InnoSetupPath" -ForegroundColor $Success
Write-Host ""

# Passo 3: Criar pasta de output
Write-Host "Preparando pasta de saída..." -ForegroundColor $Info
$OutputDir = ".\release_installer"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
Write-Host "✓ Pasta criada: $OutputDir" -ForegroundColor $Success
Write-Host ""

# Passo 4: Compilar o instalador
Write-Host "Compilando instalador..." -ForegroundColor $Info
Write-Host "(Isso pode levar um minuto)" -ForegroundColor $Warning
Write-Host ""

& "$InnoSetupPath" ".\student_grade_book_installer.iss"

if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor $Success
    Write-Host "✓ Instalador criado com sucesso!" -ForegroundColor $Success
    Write-Host "================================" -ForegroundColor $Success
    Write-Host ""
    
    $InstallerPath = Get-ChildItem ".\release_installer\StudentGradeBook_Installer*.exe" | Select-Object -First 1
    if ($InstallerPath) {
        $Size = [math]::Round($InstallerPath.Length / 1MB, 2)
        Write-Host "📦 Arquivo: $($InstallerPath.Name)" -ForegroundColor $Success
        Write-Host "📊 Tamanho: $($Size) MB" -ForegroundColor $Success
        Write-Host "📁 Local: $($InstallerPath.FullName)" -ForegroundColor $Success
    }
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor $Info
    Write-Host "  1. Teste o instalador em outro computador" -ForegroundColor $Info
    Write-Host "  2. Distribua para seus usuários" -ForegroundColor $Info
    Write-Host "  3. Você pode hospedar em GitHub Releases ou outro servidor" -ForegroundColor $Info
    Write-Host ""
} else {
    Write-Host "❌ Erro ao compilar o instalador!" -ForegroundColor $Error
    Write-Host "Tente compilar manualmente com InnoSetup" -ForegroundColor $Warning
    exit 1
}
