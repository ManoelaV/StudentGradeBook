#!/bin/bash

# Script para compilar e empacotar o Student Grade Book para Linux
# Execute este script no Linux (Ubuntu/Debian recomendado)

echo "=========================================="
echo "   Build e Empacotamento - Linux"
echo "=========================================="
echo ""

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ ERRO: Flutter não encontrado."
    echo "   Instale Flutter: https://docs.flutter.dev/get-started/install/linux"
    exit 1
fi

# Verificar dependências Linux
echo "[1/4] Verificando dependências..."

MISSING_DEPS=""

if ! dpkg -l | grep -q "clang"; then
    MISSING_DEPS="$MISSING_DEPS clang"
fi

if ! dpkg -l | grep -q "cmake"; then
    MISSING_DEPS="$MISSING_DEPS cmake"
fi

if ! dpkg -l | grep -q "ninja-build"; then
    MISSING_DEPS="$MISSING_DEPS ninja-build"
fi

if ! dpkg -l | grep -q "libgtk-3-dev"; then
    MISSING_DEPS="$MISSING_DEPS libgtk-3-dev"
fi

if [ ! -z "$MISSING_DEPS" ]; then
    echo "❌ Dependências faltando: $MISSING_DEPS"
    echo ""
    echo "Instale com:"
    echo "sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev"
    exit 1
fi

echo "✅ Dependências OK"

# Limpar build anterior
echo ""
echo "[2/4] Limpando builds anteriores..."
flutter clean
rm -f StudentGradeBook_linux.tar.gz

# Build Linux
echo ""
echo "[3/4] Compilando para Linux (Release)..."
flutter build linux --release

if [ $? -ne 0 ]; then
    echo "❌ ERRO: Build falhou."
    exit 1
fi

echo "✅ Build concluído"

# Criar tarball
echo ""
echo "[4/4] Criando arquivo .tar.gz..."

BUILD_DIR="build/linux/x64/release/bundle"

if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ ERRO: Diretório de build não encontrado: $BUILD_DIR"
    exit 1
fi

tar -czf StudentGradeBook_linux.tar.gz -C "$BUILD_DIR" .

if [ $? -ne 0 ]; then
    echo "❌ ERRO: Falha ao criar tarball."
    exit 1
fi

# Informações finais
FILE_SIZE=$(du -h StudentGradeBook_linux.tar.gz | cut -f1)

echo "✅ Empacotamento concluído"
echo ""
echo "=========================================="
echo "   ✅ BUILD FINALIZADO COM SUCESSO!"
echo "=========================================="
echo ""
echo "📦 Arquivo gerado:"
echo "   StudentGradeBook_linux.tar.gz ($FILE_SIZE)"
echo ""
echo "📤 Próximos passos:"
echo "   1. Faça upload do .tar.gz no GitHub Releases"
echo "   2. Distribua o setup_linux.sh para usuários"
echo ""
echo "🧪 Para testar localmente:"
echo "   tar -xzf StudentGradeBook_linux.tar.gz -C /tmp/test"
echo "   /tmp/test/student_grade_book"
echo ""

exit 0
