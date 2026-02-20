# Como Publicar o Instalador Linux

## 1️⃣ Baixar Artifacts do GitHub Actions

1. Acesse: https://github.com/ManoelaV/StudentGradeBook/actions
2. Clique no workflow **"Build Linux Release"** mais recente (com ✅ verde)
3. Role até o final da página
4. Em **"Artifacts"**, clique em **"linux-release"** para baixar
5. Extraia o arquivo ZIP baixado

Você terá:
- `StudentGradeBook_linux.tar.gz` (~25-35 MB)
- `setup_linux.sh` (~3 KB)

## 2️⃣ Criar Release no GitHub

### Opção A: Pela Interface Web

1. Acesse: https://github.com/ManoelaV/StudentGradeBook/releases
2. Clique em **"Create a new release"** (ou "Draft a new release")
3. Preencha:
   - **Tag:** `v1.0.0-linux` (ou escolha a tag existente)
   - **Title:** `Student Grade Book v1.0.0 - Linux`
   - **Description:**
     ```markdown
     ## 🐧 Versão Linux
     
     ### Instalação Rápida:
     
     ```bash
     wget https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0-linux/setup_linux.sh
     chmod +x setup_linux.sh
     ./setup_linux.sh
     ```
     
     ### O que há de novo:
     - ✅ Gestão de escolas e turmas
     - ✅ Registro de frequência com aulas
     - ✅ Relatórios em PDF
     - ✅ Campo de ano para turmas (2025/2026)
     - ✅ Funciona 100% offline
     
     ### Requisitos:
     - Ubuntu 20.04+ / Debian 11+ / Fedora 35+
     - GTK 3.0+
     ```

4. Arraste os arquivos:
   - `StudentGradeBook_linux.tar.gz`
   - `setup_linux.sh`

5. Clique em **"Publish release"**

### Opção B: Via Linha de Comando (GitHub CLI)

```bash
# Instalar GitHub CLI (se não tiver)
# Windows: winget install GitHub.cli
# Ou baixe: https://cli.github.com/

# Autenticar
gh auth login

# Criar release
gh release create v1.0.0-linux \
  --title "Student Grade Book v1.0.0 - Linux" \
  --notes "Versão Linux com instalador automático" \
  StudentGradeBook_linux.tar.gz \
  setup_linux.sh
```

## 3️⃣ Verificar Links

Após publicar, os links ficam:

**Instalador:**
```
https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0-linux/setup_linux.sh
```

**Tarball:**
```
https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0-linux/StudentGradeBook_linux.tar.gz
```

## 4️⃣ Testar o Instalador

Se tiver WSL ou Linux, teste:

```bash
# Baixar
wget https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0-linux/setup_linux.sh

# Executar
chmod +x setup_linux.sh
./setup_linux.sh
```

## 5️⃣ Compartilhar com Usuários

Envie este comando para usuários Linux:

```bash
wget https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0-linux/setup_linux.sh && chmod +x setup_linux.sh && ./setup_linux.sh
```

Ou compartilhe o link direto:
**https://github.com/ManoelaV/StudentGradeBook/releases**

---

## 🔄 Atualizar Versão Futura

Quando fizer mudanças e quiser nova versão Linux:

```bash
# 1. Commit suas mudanças
git add .
git commit -m "Update: Nova funcionalidade"
git push

# 2. Criar nova tag
git tag v1.1.0-linux
git push origin v1.1.0-linux

# 3. GitHub Actions compila automaticamente
# 4. Baixe o artifact e faça upload na release
```

---

**Pronto!** 🎉 Instalador Linux publicado e funcionando!
