# 📥 Instalador Online - Como Usar

## ⚡ Forma Super Simples (SEM InnoSetup)

### O que você tem agora:

**Instalador Minimalista:**
```
┌─────────────────────────────────────┐
│ setup_online.bat                    │
│ (3 KB - Só clica e instala!)        │
└─────────────────────────────────────┘
         ↓
    Faz download automático
    do executável do GitHub
         ↓
    Instala em Program Files
    Cria atalho no Menu Iniciar
         ↓
    ✅ Pronto!
```

---

## 🚀 Passo 1: Fazer Upload do Executável para GitHub

### 1.1 Abra seu repositório no GitHub

1. Para em: https://github.com/ManoelaV/StudentGradeBook
2. Clique em **"Releases"** (lado direito)
3. Clique em **"Create a new release"**

### 1.2 Crie uma nova Release

Preencha:

| Campo | Valor |
|-------|-------|
| **Tag version** | `v1.0.0` |
| **Release title** | `Student Grade Book v1.0.0` |
| **Description** | Digite: Primeira versão da aplicação |
| **Arquivo** | Arraste `build\windows\x64\runner\Release\student_grade_book.exe` |

### 1.3 Publicar

- Deixe **"Latest release"** marcado
- Clique em **"Publish release"**

✅ Pronto! Agora seu executável está no GitHub!

---

## 📝 Passo 2: Preparar o Instalador Online

O arquivo `setup_online.bat` já está configurado para:
- Versão: `1.0.0`
- Repositório: `ManoelaV/StudentGradeBook`

Se quiser mudar:

```batch
REM Abra setup_online.bat e mude estas linhas:
set "VERSION=1.0.0"                      ← Mude para sua versão
set "GITHUB_REPO=ManoelaV/StudentGradeBook"  ← Seu repositório
```

---

## 🎯 Passo 3: Distribuir

Agora você tem:

### Opção A: Enviar Setup Online (Recomendado)

```
📥 setup_online.bat (3 KB)
   ↓ Usuário duplo clica
   ↓ Baixa 50+ MB do GitHub
   ↓ Instala automaticamente
   ✅ Pronto!
```

**Vantagens:**
- ✅ Arquivo super pequeno (3 KB!)
- ✅ Sempre baixa a versão mais recente
- ✅ Funciona com seu GitHub gratuitamente
- ✅ Usuários veem o progresso de download

### Opção B: Link Direto do GitHub

Seus usuários abrem:
```
https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0/student_grade_book.exe
```

E clicam em "Download"

---

## 📊 Comparação de Métodos

| Método | Tamanho | Fácil? | Prático? |
|--------|---------|--------|----------|
| InnoSetup Instalador | 50+ MB | ⭐⭐ | ⭐⭐ |
| **Setup Online** | **3 KB** | **⭐⭐⭐** | **⭐⭐⭐** |
| Link Direto GitHub | Arquivo grande | ⭐⭐⭐ | ⭐ |

---

## ❓ Perguntas Frequentes

**P: Preciso pagar para usar GitHub Releases?**
R: NÃO! É completamente grátis com limite de 2 GB por arquivo.

**P: O setup funciona sem internet?**
R: NÃO, precisa de internet para fazer download. Se quiser offline, use o InnoSetup tradicional.

**P: Posso hospedar o arquivo em outro lugar?**
R: SIM! Mude a URL em `setup_online.bat`:
```batch
set "RELEASE_URL=https://seu-servidor.com/student_grade_book.exe"
```

**P: E se a versão for atualizada?**
R: Atualize:
1. Faça novo build: `flutter build windows --release`
2. Crie novo release no GitHub (v1.0.1, v1.1.0, etc)
3. Mude `set "VERSION=1.0.1"` no setup_online.bat
4. Distribua o novo setup.bat

**P: Como automatizar isso?**
R: Veja o próximo arquivo: `GITHUB_ACTIONS_SETUP.md`

---

## 🎬 Exemplo Completo

### Seu fluxo de trabalho:

1. **Você faz alterações no código** → commit e push

2. **GitHub Actions compila automaticamente** (se configurado)
   - Cria build Windows `.exe`
   - Faz upload para Releases

3. **Você distribui `setup_online.bat`**
   - E-mail, WhatsApp, Google Drive, etc.

4. **Usuários clicam em setup_online.bat**
   - Ele faz download do GitHub
   - Instala automaticamente
   - Tá pronto pra usar!

5. **Quando tiver update:**
   - Repita o processo
   - Novos usuários sempre pega a versão mais recente!

---

## 💡 Dicas Extras

### Código QR para Download

Crie um QR code que aponta para:
```
https://github.com/ManoelaV/StudentGradeBook/releases
```

Coloque em um papel ou adesivo! 📲

### Arquivo README.txt junto

Crie um `.txt` que explica:
```
Student Grade Book v1.0.0

Para instalar:
1. Duplo clique em setup_online.bat
2. Aguarde o download
3. Pronto!

Requisitos:
- Windows 7+
- Internet para instalação
- 100 MB de espaço livre

Problemas? Contacte: seu-email@gmail.com
```

### Script para atualizar

Crie `update.bat` nos computadores dos usuários:
```batch
@echo off
set "SETUP_URL=https://seu-servidor.com/setup_online.bat"
echo Atualizando Student Grade Book...
powershell -Command "Invoke-WebRequest -Uri '%SETUP_URL%' -OutFile '%TEMP%\setup.bat'; & '%TEMP%\setup.bat'"
```

---

## 📚 Próximos Passos

1. ✅ Crie uma release no GitHub
2. ✅ Envie o setup_online.bat para seus usuários
3. ✅ (Opcional) Configure GitHub Actions para automatizar builds

---

**Última atualização:** Fevereiro 2026

