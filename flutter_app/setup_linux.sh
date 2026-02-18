#!/bin/bash

# Instalador Student Grade Book - Linux
# Testado em Ubuntu 20.04+, Debian 11+, Fedora 35+

APP_NAME="Student Grade Book"
VERSION="1.0.0"
INSTALL_DIR="$HOME/.local/share/studentgradebook"
DESKTOP_FILE="$HOME/.local/share/applications/studentgradebook.desktop"
ICON_DIR="$HOME/.local/share/icons"
RELEASE_URL="https://github.com/ManoelaV/StudentGradeBook/releases/download/v${VERSION}/StudentGradeBook_linux.tar.gz"

echo "=========================================="
echo "   Instalador $APP_NAME v$VERSION"
echo "=========================================="
echo ""

# Verificar dependências
echo "[1/6] Verificando dependências..."

if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
    echo "❌ ERRO: wget ou curl não encontrado."
    echo "   Instale com: sudo apt install wget   (Ubuntu/Debian)"
    echo "   Ou:          sudo dnf install wget   (Fedora)"
    exit 1
fi

if ! command -v tar &> /dev/null; then
    echo "❌ ERRO: tar não encontrado."
    echo "   Instale com: sudo apt install tar"
    exit 1
fi

echo "✅ Dependências OK"

# Criar pasta temporária
TEMP_DIR="/tmp/studentgradebook_install_$$"
mkdir -p "$TEMP_DIR"

# Download
echo ""
echo "[2/6] Baixando aplicativo..."
echo "   URL: $RELEASE_URL"

if command -v wget &> /dev/null; then
    wget -q --show-progress "$RELEASE_URL" -O "$TEMP_DIR/app.tar.gz"
else
    curl -L "$RELEASE_URL" -o "$TEMP_DIR/app.tar.gz" --progress-bar
fi

if [ $? -ne 0 ]; then
    echo "❌ ERRO: Falha no download."
    echo "   Verifique sua conexão ou se a release existe no GitHub."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✅ Download concluído"

# Criar diretório de instalação
echo ""
echo "[3/6] Criando diretórios..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$HOME/.local/share/applications"

echo "✅ Diretórios criados"

# Extrair
echo ""
echo "[4/6] Extraindo arquivos..."
tar -xzf "$TEMP_DIR/app.tar.gz" -C "$INSTALL_DIR"

if [ $? -ne 0 ]; then
    echo "❌ ERRO: Falha ao extrair arquivos."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✅ Extração concluída"

# Tornar executável
chmod +x "$INSTALL_DIR/student_grade_book"

# Criar atalho no menu
echo ""
echo "[5/6] Criando atalho no menu..."

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Student Grade Book
Comment=Sistema de gestão escolar
Exec=$INSTALL_DIR/student_grade_book
Icon=$ICON_DIR/studentgradebook.png
Terminal=false
Categories=Education;Office;
Keywords=escola;aluno;nota;frequencia;
EOF

# Criar ícone (opcional - se não existir, usar genérico)
if [ ! -f "$ICON_DIR/studentgradebook.png" ]; then
    # Usar ícone genérico do sistema ou baixar
    ln -sf /usr/share/icons/hicolor/48x48/apps/accessories-text-editor.png "$ICON_DIR/studentgradebook.png" 2>/dev/null
fi

chmod +x "$DESKTOP_FILE"

echo "✅ Atalho criado"

# Limpar temporários
echo ""
echo "[6/6] Limpando arquivos temporários..."
rm -rf "$TEMP_DIR"

echo "✅ Limpeza concluída"

# Finalização
echo ""
echo "=========================================="
echo "   ✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "=========================================="
echo ""
echo "📂 Local de instalação:"
echo "   $INSTALL_DIR"
echo ""
echo "🚀 Para executar:"
echo "   - Procure 'Student Grade Book' no menu de aplicativos"
echo "   - Ou execute: $INSTALL_DIR/student_grade_book"
echo ""
echo "🗑️  Para desinstalar:"
echo "   rm -rf $INSTALL_DIR"
echo "   rm $DESKTOP_FILE"
echo "   rm $ICON_DIR/studentgradebook.png"
echo ""

# Perguntar se deseja executar agora
read -p "Deseja executar o aplicativo agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[SsYy]$ ]]; then
    echo ""
    echo "🚀 Iniciando aplicativo..."
    "$INSTALL_DIR/student_grade_book" &
    echo "✅ Aplicativo iniciado!"
fi

exit 0
