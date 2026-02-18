# Instalador Online Student Grade Book (PowerShell)
# Faz download automático do GitHub e instala
# Uso: powershell -ExecutionPolicy Bypass -File setup_online.ps1

param(
    [string]$Version = "1.0.0",
    [string]$GitHubRepo = "ManoelaV/StudentGradeBook"
)

# Cores
$Success = "Green"
$Error = "Red"
$Warning = "Yellow"
$Info = "Cyan"

# Configuração
$AppName = "Student Grade Book"
$ReleaseUrl = "https://github.com/$GitHubRepo/releases/download/v$Version/student_grade_book.exe"
$InstallPath = "$env:ProgramFiles\$AppName"
$TempPath = "$env:TEMP\StudentGradeBook"

Write-Host ""
Write-Host "================================" -ForegroundColor $Info
Write-Host "$AppName - Instalador Online" -ForegroundColor $Info
Write-Host "================================" -ForegroundColor $Info
Write-Host ""

# Criar pasta temporária
if (-not (Test-Path $TempPath)) {
    New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
}

# Fazer download
Write-Host "Baixando $AppName v$Version..." -ForegroundColor $Info
Write-Host "URL: $ReleaseUrl" -ForegroundColor $Warning
Write-Host ""

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $ReleaseUrl -OutFile "$TempPath\app.exe" -ErrorAction Stop
    
    Write-Host "✓ Download concluído!" -ForegroundColor $Success
}
catch {
    Write-Host ""
    Write-Host "❌ Erro ao baixar arquivo!" -ForegroundColor $Error
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor $Error
    Write-Host ""
    Write-Host "Verifique:" -ForegroundColor $Warning
    Write-Host "  - Sua conexão com internet" -ForegroundColor $Warning
    Write-Host "  - Se a release foi criada no GitHub" -ForegroundColor $Warning
    Write-Host "  - URL da release: $ReleaseUrl" -ForegroundColor $Warning
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "Instalando em $InstallPath..." -ForegroundColor $Info

# Criar pasta de instalação
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# Copiar arquivo
try {
    Copy-Item "$TempPath\app.exe" "$InstallPath\student_grade_book.exe" -Force -ErrorAction Stop
    Write-Host "✓ Arquivo copiado" -ForegroundColor $Success
}
catch {
    Write-Host "❌ Erro ao copiar arquivo!" -ForegroundColor $Error
    pause
    exit 1
}

# Criar atalho no Menu Iniciar
Write-Host "Criando atalhos..." -ForegroundColor $Info

$MenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$MenuPath\$AppName.lnk")
$Shortcut.TargetPath = "$InstallPath\student_grade_book.exe"
$Shortcut.WorkingDirectory = $InstallPath
$Shortcut.Save()

Write-Host "✓ Atalho criado no Menu Iniciar" -ForegroundColor $Success

# Limpar arquivos temporários
Remove-Item $TempPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host ""
Write-Host "================================" -ForegroundColor $Success
Write-Host "✓ Instalação concluída com sucesso!" -ForegroundColor $Success
Write-Host "================================" -ForegroundColor $Success
Write-Host ""
Write-Host "$AppName instalado em:" -ForegroundColor $Info
Write-Host "  $InstallPath" -ForegroundColor $Info
Write-Host ""
Write-Host "Iniciando aplicação..." -ForegroundColor $Info
Write-Host ""

# Executar
& "$InstallPath\student_grade_book.exe"

Read-Host "Pressione Enter para sair"
