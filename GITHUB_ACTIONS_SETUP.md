# 📲 GitHub Actions - Build Android & iOS

Seu projeto agora compila **automaticamente** para Android e iOS!

## 🚀 Como Funciona

Toda vez que você faz `git push` para `main` ou `develop`:

1. ✅ GitHub Actions inicia automaticamente
2. ✅ Compila para **Android** (Ubuntu)
3. ✅ Compila para **iOS** (macOS - com seu GitHub Pro!)
4. ✅ Gera: `app-release.apk` e `app.ipa`
5. ✅ Armazena como artefatos para download

## 📋 Pré-requisitos

- ✅ GitHub Pro (você tem!)
- ✅ Repositório público ou privado
- ✅ Arquivo `.github/workflows/build.yml` (já criado!)

## 🔧 Configuração (Feita!)

O arquivo `build.yml` já está configurado com:

```yaml
build-android:    # Compila para Android em Ubuntu
build-ios:        # Compila para iOS em macOS
```

## 📤 Fazer Push e Compilar

### 1. Enviar código para o GitHub

```powershell
cd c:\Users\manno\Documents\GitHub\StudentGradeBook
git add .
git commit -m "Adicionar workflows GitHub Actions"
git push origin main
```

### 2. Ver Compilação

Vá em: `github.com/seu-usuario/StudentGradeBook`
- Clique em **"Actions"**
- Veja o workflow rodando em tempo real
- Aguarde 5-10 minutos

### 3. Baixar APK e IPA

Quando terminar (✅ verde):
1. Clique no workflow completo
2. Scroll down → "Artifacts"
3. Download:
   - `android-apk` → app-release.apk
   - `ios-ipa` → app.ipa

## 📱 Usar o APK (Android)

```powershell
# Copiar para seu celular
adb push app-release.apk /sdcard/

# Ou enviar por email/WhatsApp
```

## 🍎 Usar o IPA (iOS - iPhone 13)

### Opção 1: TestFlight (GRÁTIS)

1. Vá em: https://appstoreconnect.apple.com/
2. Faça login com Apple ID
3. Apps → Criar novo app
4. Faça upload do `.ipa`
5. Envie link TestFlight para seu iPhone

### Opção 2: Instalar via Xcode (em Mac)

```bash
# Num Mac amigo
xcode-select --install
xcodebuild -importArchive -archivePath app.xcarchive -exportOptionsPlist options.plist -exportPath output
```

### Opção 3: App Store (Publicação Oficial)

Custa $99/ano, mas aparece na App Store.

## ⚙️ Customizar Build

Para mudar configurações, edite `.github/workflows/build.yml`:

```yaml
flutter-version: '3.41.1'  # Mude versão do Flutter
branches: [ main ]         # Quais branches compilar
```

## 🆘 Troubleshooting

**Build falhou?**
- Clique no workflow
- Veja o log de erro
- Comum: dependências faltando → `flutter pub get`

**IPA não funciona no iPhone?**
- Precisa de certificados Apple
- Para TestFlight: configure no App Store Connect
- Para oficial: pague $99/ano de desenvolvedor Apple

## 📊 Status do Projeto

| Plataforma | Status | Arquivo |
|-----------|--------|---------|
| Android   | ✅ Automático | `.apk` |
| iOS       | ✅ Automático | `.ipa` |
| Windows   | ✅ Manual | `.exe` |

## 🎯 Próximos Passos

1. **Faça push** do código atualizadocd
   ```powershell
   git add .
   git commit -m "Setup GitHub Actions"
   git push
   ```

2. **Vá em Actions** e veja compilando

3. **Quando terminar**, baixe dos artefatos

4. **Teste no Android** primeiro (mais fácil)

5. **Depois iOS** via TestFlight ou App Store

## 📞 Suporte

Se algum build falhar:
1. Clique no workflow em "Actions"
2. Veja qual step falhou
3. Leia o log de erro
4. Geralmente é: dependência faltando ou config errada

---

**Seu app agora compila automaticamente! 🚀**

Sempre que você `git push`, seu app é compilado para Android e iOS!
