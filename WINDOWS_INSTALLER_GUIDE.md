# 📦 Guia de Distribuição - Student Grade Book (Windows)

## Opção 1: Instalador Profissional com InnoSetup (RECOMENDADO)

### O que você vai conseguir:
✅ Instale como qualquer programa normal (clique em .exe)
✅ Atalho automático no Menu Iniciar
✅ Opção de criar atalho na Área de Trabalho
✅ Desinstalador integrado
✅ Interface intuitiva em português

### Passo a Passo:

#### 1️⃣ **Instale o InnoSetup** (uma única vez)

1. Acesse: https://jrsoftware.org/isdl.php
2. Baixe "Inno Setup" (versão atual)
3. Execute o instalador e conclua a instalação
4. Reinicie seu computador (opcional, mas recomendado)

#### 2️⃣ **Crie o Instalador**

1. Abra o arquivo `student_grade_book_installer.iss` com InnoSetup
   - Clique com botão direito → Abrir com → Inno Setup Compiler
   - OU Abra o InnoSetup e vá em File → Open

2. Clique no botão **"Compile"** (ou pressione F9)

3. Aguarde alguns segundos

4. Pronto! O instalador foi criado em `flutter_app\release_installer\StudentGradeBook_Installer_v1.0.0.exe`

#### 3️⃣ **Distribua o Instalador**

Você agora tem um arquivo `.exe` que qualquer pessoa pode baixar e instalar como um programa normal:

```
📦 StudentGradeBook_Installer_v1.0.0.exe
↓
💾 Usuário faz download
↓
🖱️ Duplo clique para instalar
↓
✅ Program fica no Menu Iniciar
```

### Personalizações Opcionais:

Se quiser adicionar um ícone customizado:

1. Crie um arquivo `.ico` (ícone) 
2. Salve como `app_icon.ico` na pasta `flutter_app\`
3. No arquivo `.iss`, altere:
   ```
   SetupIconFile=app_icon.ico
   ```
4. Recompile

---

## Opção 2: Instalador Simples com Batch Script

Para uma solução mais rápida sem extra software:

### 1️⃣ **Execute o script de instalação:**

Crie um arquivo `INSTALL.bat` na pasta raiz:

```batch
@echo off
echo Instalando Student Grade Book...

REM Define a pasta de instalação
set INSTALL_PATH=%ProgramFiles%\Student Grade Book

REM Cria a pasta de instalação
if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"

REM Copia os arquivos
xcopy "flutter_app\build\windows\x64\runner\Release\*" "%INSTALL_PATH%" /E /Y

REM Cria atalho no Menu Iniciar (opcional)
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Student Grade Book.lnk'); $Shortcut.TargetPath = '%INSTALL_PATH%\student_grade_book.exe'; $Shortcut.Save()"

echo.
echo Instalação concluída!
echo Pressione qualquer tecla para abrir o programa...
pause

REM Abre o programa
start "" "%INSTALL_PATH%\student_grade_book.exe"
```

### 2️⃣ **Distribute:**

- Coloque o `INSTALL.bat` junto com a pasta `flutter_app\`
- Os usuários executam o .bat e tudo é instalado automaticamente

---

## Opção 3: Portable (Sem Instalação)

Se quiser que seus usuários usem sem instalação:

1. Copie apenas:
   ```
   flutter_app\build\windows\x64\runner\Release\student_grade_book.exe
   flutter_app\build\windows\x64\runner\Release\*.dll
   flutter_app\build\windows\x64\runner\Release\data\
   ```

2. Coloque tudo em uma pasta `StudentGradeBook_Portable`

3. Os usuários simplesmente copiam essa pasta e clicam em `student_grade_book.exe`

---

## 🎯 Recomendação Final

| Opção | Dificuldade | Profissionalismo | Recomendado Para |
|-------|-------------|------------------|------------------|
| **InnoSetup** | ⭐ Fácil | ⭐⭐⭐ Alto | Distribuição pública |
| **Batch Script** | ⭐⭐ Médio | ⭐⭐ Médio | Usuários técnicos |
| **Portable** | ⭐ Muito Fácil | ⭐ Básico | Distribuição interna |

---

## ❓ Perguntas Frequentes

**P: Qual opção escolher?**
R: Use InnoSetup se quer algo profissional que qualquer um possa instalar.

**P: O usuário precisa de permissão de Administrador?**
R: Sim, para instalar em `Program Files`. Se quiser instalação sem admin, mude `DefaultDirName` para `{userappdata}\Student Grade Book`

**P: Posso vender o programa com o instalador?**
R: Sim! O Flutter é open-source, então você pode distribuir livremente.

**P: Como atualizar para nova versão?**
R: Mude a versão no script.iss ou .bat e recrie o instalador.

**P: Quero um instalador .msi (mais oficial)?**
R: Use Advanced Installer (gratuito em versão community) ou WiX Toolset.

---

## 📝 Checklist para Distribuição

- [ ] Executar `flutter build windows --release`
- [ ] Testar o `.exe` em `build\windows\x64\runner\Release\`
- [ ] Compilar instalador com InnoSetup
- [ ] Testar instalador em outro computador
- [ ] Fazer upload para seu servidor/GitHub Releases
- [ ] Criar página de download com instruções

---

**Last updated:** Fevereiro 2026

