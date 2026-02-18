# 🚀 Criar Instalador Windows - Guia Rápido

## ⚡ Forma Mais Rápida

### Antes de começar:

1. **Instale InnoSetup** (uma única vez)
   - Acesse: https://jrsoftware.org/isdl.php
   - Baixe e instale "Inno Setup"

### Criar o instalador:

1. **Abra a pasta `flutter_app` no computador**

2. **Execute `build_installer.bat`**
   - Duplo clique no arquivo `build_installer.bat`
   - Pronto! O instalador será criado automaticamente

3. **Encontre o instalador em `release_installer/`**
   ```
   StudentGradeBook_Installer_v1.0.0.exe
   ```

4. **Distribua!**
   - Sends para seus usuários
   - Eles clicam para instalar
   - Programa fica no Menu Iniciar automaticamente

---

## 📋 O que foi criado para você:

| Arquivo | Descrição | Como Usar |
|---------|-----------|-----------|
| `build_installer.bat` | Script automático | Duplo clique |
| `build_installer.ps1` | Versão PowerShell | `powershell -ExecutionPolicy Bypass -File build_installer.ps1` |
| `student_grade_book_installer.iss` | Configuração InnoSetup | Abra no InnoSetup e clique Compile |
| `sqlite3.dll` | Banco de dados | Copia automaticamente |

---

## ❓ Problemas?

**"InnoSetup não encontrado"**
- Instale em: https://jrsoftware.org/isdl.php
- Reinicie o computador depois

**"Erro ao compilar"**
- Verifique se `build\windows\x64\runner\Release\student_grade_book.exe` existe
- Se não existe, execute: `flutter build windows --release`

**"Não consigo executar .ps1 ou .bat"**
- Copie a pasta inteira do projeto para Desktop
- Execute de novo

---

## 📦 Resultado Final

Você tem um arquivo `.exe` profissional que:
- ✅ Qualquer pessoa pode instalar
- ✅ Funciona como um programa normal
- ✅ Cria atalho no Menu Iniciar
- ✅ Tem desinstalador integrado
- ✅ Interface em Português

---

## 🎯 Próximos Passos

1. **Teste** em outro computador
2. **Renomeie** se quiser (ex: `StudentGradeBook_Installer_2025_v1.exe`)
3. **Distribua** por link, email ou USB
4. **Hospede** em GitHub Releases ou servidor web

---

**Pronto!** 🎉

