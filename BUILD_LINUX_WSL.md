# 🐧 Build Linux no Windows via WSL

Guia para compilar o Student Grade Book para Linux usando Windows Subsystem for Linux.

## 1️⃣ Instalar WSL

### PowerShell como Administrador:

```powershell
# Instalar WSL com Ubuntu
wsl --install -d Ubuntu

# Reiniciar o computador após a instalação
```

Após reiniciar, o Ubuntu abrirá automaticamente:
- Defina usuário e senha
- Aguarde finalizar instalação

## 2️⃣ Instalar Flutter no WSL

Dentro do Ubuntu (WSL):

```bash
# Atualizar sistema
sudo apt update
sudo apt upgrade -y

# Instalar dependências
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa

# Instalar Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Adicionar ao PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verificar
flutter doctor
```

## 3️⃣ Instalar Dependências de Build Linux

```bash
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

## 4️⃣ Acessar Projeto do Windows

```bash
# WSL acessa arquivos Windows via /mnt/c/
cd /mnt/c/Users/manno/Documents/GitHub/StudentGradeBook/flutter_app

# Instalar dependências Flutter
flutter pub get
```

## 5️⃣ Build Linux

```bash
# Build Release
flutter build linux --release

# Verificar executável
ls -lh build/linux/x64/release/bundle/student_grade_book
```

## 6️⃣ Criar Tarball

```bash
# Empacotar
tar -czf StudentGradeBook_linux.tar.gz -C build/linux/x64/release/bundle .

# Verificar tamanho
ls -lh StudentGradeBook_linux.tar.gz

# Copiar para Windows
cp StudentGradeBook_linux.tar.gz /mnt/c/Users/manno/Downloads/
```

Arquivo estará em: `C:\Users\manno\Downloads\StudentGradeBook_linux.tar.gz`

## 7️⃣ Testar Localmente

```bash
# Extrair em pasta temporária
mkdir /tmp/test
tar -xzf StudentGradeBook_linux.tar.gz -C /tmp/test

# Executar (ERRO: precisa de servidor X)
/tmp/test/student_grade_book
```

**⚠️ Problema:** WSL não tem interface gráfica por padrão.

### Solução: Instalar X Server

**Opção A: VcXsrv (Recomendado)**

1. Baixe: https://sourceforge.net/projects/vcxsrv/
2. Instale no Windows
3. Execute `XLaunch`
4. Configurações: Multiple windows → Display 0 → Disable access control

No WSL:

```bash
# Adicionar ao ~/.bashrc
echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"):0' >> ~/.bashrc
source ~/.bashrc

# Testar
/tmp/test/student_grade_book
```

**Opção B: WSLg (Windows 11)**

No Windows 11, WSL já tem suporte gráfico:

```bash
# Atualizar WSL
wsl --update

# Executar direto
/tmp/test/student_grade_book
```

## 🐛 Troubleshooting

| Problema | Solução |
|----------|---------|
| **wsl: comando não encontrado** | Execute PowerShell como Admin |
| **Flutter não encontrado** | Execute `source ~/.bashrc` |
| **Erro GTK** | Instale: `sudo apt install libgtk-3-dev` |
| **Display não configurado** | Configure DISPLAY ou use WSLg |
| **Arquivo não compila** | Verifique `flutter doctor` |

## 📊 Comparação: GitHub Actions vs WSL

| Item | GitHub Actions | WSL |
|------|----------------|-----|
| **Configuração** | 5 minutos | 30-60 minutos |
| **Build Speed** | ~5-10 min | ~3-5 min |
| **Interface Gráfica** | ❌ Não (só build) | ✅ Sim (VcXsrv/WSLg) |
| **Testes** | ❌ Não interativo | ✅ Pode testar GUI |
| **Manutenção** | ✅ Zero | 🟡 Média |

## 🎯 Recomendação

- **Para distribuição:** Use GitHub Actions (automático)
- **Para testes:** Use WSL com VcXsrv
- **Para desenvolvimento Linux:** WSL completo

---

**Última atualização:** Fevereiro 2026
