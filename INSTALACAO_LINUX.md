# 🐧 Instalação no Linux

Guia completo para instalar o **Student Grade Book** em distribuições Linux.

## 📋 Requisitos

- **Distribuições suportadas:**
  - Ubuntu 20.04 ou superior
  - Debian 11 ou superior
  - Fedora 35 ou superior
  - Arch Linux (atual)
  - Outras distribuições similares

- **Dependências runtime:**
  - GTK 3.0+
  - libstdc++
  - glibc 2.31+

## 🚀 Instalação Rápida

### Método 1: Script Automático (Recomendado)

```bash
# 1. Baixar o instalador
wget https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0/setup_linux.sh

# 2. Tornar executável
chmod +x setup_linux.sh

# 3. Executar
./setup_linux.sh
```

O script:
- ✅ Baixa automaticamente o aplicativo
- ✅ Extrai para `~/.local/share/studentgradebook`
- ✅ Cria atalho no menu de aplicativos
- ✅ Configura permissões corretas

### Método 2: Manual

```bash
# 1. Baixar o tarball
wget https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0/StudentGradeBook_linux.tar.gz

# 2. Criar diretório
mkdir -p ~/.local/share/studentgradebook

# 3. Extrair
tar -xzf StudentGradeBook_linux.tar.gz -C ~/.local/share/studentgradebook

# 4. Tornar executável
chmod +x ~/.local/share/studentgradebook/student_grade_book

# 5. Executar
~/.local/share/studentgradebook/student_grade_book
```

## 🔧 Dependências

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install libgtk-3-0 libstdc++6
```

### Fedora

```bash
sudo dnf install gtk3 libstdc++
```

### Arch Linux

```bash
sudo pacman -S gtk3
```

## 🖥️ Criar Atalho no Menu

Se o instalador automático não criou o atalho, faça manualmente:

```bash
# Criar arquivo .desktop
cat > ~/.local/share/applications/studentgradebook.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Student Grade Book
Comment=Sistema de gestão escolar
Exec=$HOME/.local/share/studentgradebook/student_grade_book
Icon=accessories-text-editor
Terminal=false
Categories=Education;Office;
EOF

# Tornar executável
chmod +x ~/.local/share/applications/studentgradebook.desktop
```

## 🗑️ Desinstalar

```bash
# Remover aplicativo
rm -rf ~/.local/share/studentgradebook

# Remover atalho
rm ~/.local/share/applications/studentgradebook.desktop

# Remover ícone (se existir)
rm ~/.local/share/icons/studentgradebook.png
```

## 📦 Build para Linux (Desenvolvedores)

### 1. Instalar Flutter

```bash
# Baixar Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Adicionar ao PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verificar
flutter doctor
```

### 2. Instalar Dependências de Build

**Ubuntu/Debian:**

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

**Fedora:**

```bash
sudo dnf install clang cmake ninja-build gtk3-devel xz-devel
```

### 3. Build Release

```bash
cd flutter_app

# Instalar dependências Flutter
flutter pub get

# Build Linux
flutter build linux --release
```

Executável gerado em: `build/linux/x64/release/bundle/student_grade_book`

### 4. Criar Tarball

**Opção A: Script automático**

```bash
cd flutter_app
chmod +x build_and_package_linux.sh
./build_and_package_linux.sh
```

**Opção B: Manual**

```bash
cd flutter_app
tar -czf StudentGradeBook_linux.tar.gz -C build/linux/x64/release/bundle .
```

### 5. Upload no GitHub

1. Vá para [GitHub Releases](https://github.com/ManoelaV/StudentGradeBook/releases)
2. Clique em **"Edit"** na release v1.0.0
3. Arraste os arquivos:
   - `StudentGradeBook_linux.tar.gz`
   - `setup_linux.sh`
4. Clique em **"Update release"**

## 🐛 Troubleshooting

| Problema | Solução |
|----------|---------|
| **Erro: libGTK-3.so.0 not found** | Instale GTK3: `sudo apt install libgtk-3-0` |
| **Erro: Permission denied** | Execute `chmod +x setup_linux.sh` |
| **Aplicativo não abre** | Execute via terminal para ver erros: `~/.local/share/studentgradebook/student_grade_book` |
| **Atalho não aparece no menu** | Execute `update-desktop-database ~/.local/share/applications` |
| **Erro de segmentação** | Verifique compatibilidade: `ldd ~/.local/share/studentgradebook/student_grade_book` |

## 📌 Distribuições Específicas

### Pop!_OS / Ubuntu

```bash
sudo apt install libgtk-3-0 libstdc++6
./setup_linux.sh
```

### Linux Mint

```bash
sudo apt install libgtk-3-0
./setup_linux.sh
```

### Manjaro / Arch

```bash
sudo pacman -S gtk3
./setup_linux.sh
```

### Fedora / RHEL

```bash
sudo dnf install gtk3
./setup_linux.sh
```

## 🔒 AppArmor / SELinux

Se usar AppArmor ou SELinux, conceda permissões:

```bash
# AppArmor (Ubuntu)
sudo aa-complain ~/.local/share/studentgradebook/student_grade_book

# SELinux (Fedora)
sudo chcon -t bin_t ~/.local/share/studentgradebook/student_grade_book
```

## 📞 Suporte

- **Issues:** [GitHub Issues](https://github.com/ManoelaV/StudentGradeBook/issues)
- **Documentação:** [README.md](../README.md)

---

**Testado em:**
- ✅ Ubuntu 22.04 LTS
- ✅ Debian 12
- ✅ Fedora 39
- ✅ Pop!_OS 22.04

**Última atualização:** Fevereiro 2026
