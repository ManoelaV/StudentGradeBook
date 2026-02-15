# 🚀 GUIA DE DEPLOYMENT

Instruções detalhadas para publicar o Student Grade Book na Google Play Store e Apple App Store.

---

## 📱 ANDROID - Google Play Store

### 1️⃣ Preparação Inicial

#### Criar Google Play Developer Account

1. Acesse https://play.google.com/console
2. Clique em "Criar conta"
3. Pague a taxa de registro ($25 USD, única vez)
4. Preencha as informações da sua conta

#### Gerar Chave de Assinatura

No seu PC (Windows), abra PowerShell e execute:

```powershell
# Navegar para onde você quer guardar a chave
cd C:\Users\[SeuUsuário]\

# Gerar keystore
keytool -genkey -v -keystore student_grade_book.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias student_grade_book_key
```

**Informações solicitadas:**
- Senha (mínimo 6 caracteres) - **ANOTE E GUARDE!**
- Nome e sobrenome: `Manuela V`
- Unidade organizacional: `StudentGradeBook`
- Organização: Seu nome ou empresa
- Cidade: Sua cidade
- Estado: Seu estado
- Código do país: BR (Brasil)

**Saída esperada:**
```
Keystore foi criado com sucesso em: C:\Users\[SeuUsuário]\student_grade_book.jks
Senha: [sua_senha]
Alias: student_grade_book_key
```

### 2️⃣ Configurar Android Build

Copie o arquivo `student_grade_book.jks` para:
```
flutter_app/android/app/student_grade_book.jks
```

Edite `flutter_app/android/app/build.gradle.kts`:

```kotlin
android {
    // ... código existente ...
    
    signingConfigs {
        create("release") {
            keyAlias = "student_grade_book_key"
            keyPassword = "sua_senha"
            storeFile = file("student_grade_book.jks")
            storePassword = "sua_senha"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            shrinkResources = true
        }
    }
}
```

### 3️⃣ Build do AAB (App Bundle)

No PowerShell, navegue até `flutter_app/` e execute:

```powershell
cd flutter_app
flutter pub get
flutter build appbundle --release
```

**Arquivo gerado:**
```
flutter_app/build/app/outputs/bundle/release/app-release.aab
```

### 4️⃣ Publicar no Google Play Store

1. Acesse https://play.google.com/console
2. Clique em **"Criar novo app"**
3. Preencha:
   - Nome do app: `Student Grade Book`
   - Idioma padrão: `Português (Brasil)`
   - Tipo de app: `App`
   - Categoria: `Educação`
   - Público: Selecion apropriadamente

4. Vá para **"Releases" → "Produção"**

5. Clique em **"Criar nova versão"**

6. Faça upload do arquivo `.aab`:
   - Clique em **"Browse files"**
   - Selecione `app-release.aab`
   - Aguarde o upload

7. Preencha informações da versão:
   - Número da versão: `1`
   - Nome da versão: `1.0.0`
   - Notas da versão: Veja abaixo

8. Clique em **"Revisar"**

9. Complete informações obrigatórias:
   - **Descrição:** "Aplicativo para gerenciamento de notas de alunos. Funciona 100% offline."
   - **Screenshots:** Mínimo 2 (mobile)
   - **Ícone de feature**
   - **Categoria de conteúdo**
   - **Classificação etária**
   - **Permissões**

10. Clique em **"Enviar para revisão"**

**Tempo de revisão:** 24-48 horas

### ✅ Checklist Android

- [ ] Conta Google Play criada
- [ ] Keystore gerado e guardado
- [ ] `build.gradle.kts` configurado
- [ ] AAB criado com sucesso
- [ ] App criado no Play Console
- [ ] Screenshots adicionados (2-8)
- [ ] Descrição preenchida
- [ ] Política de privacidade links adicionados
- [ ] Enviado para revisão

---

## 🍎 iOS - Apple App Store

### 1️⃣ Preparação no Mac

#### Criar Apple Developer Account

1. Acesse https://developer.apple.com
2. Clique em "Account"
3. Crie Apple ID se não tiver
4. Inscreva-se no Apple Developer Program ($99 USD/ano)
5. Aguarde aprovação (geralmente instantâneo)

#### Gerar Certificados

No Mac, abra Xcode:

```bash
# Gerar CSR (Certificate Signing Request)
# Menu: Xcode → Preferences → Accounts
# Selecione sua conta → Manage Certificates
```

Ou via terminal:

```bash
# Abrir login Xcode
xcode-select --install

# Verificar instalação
xcode-select -p
# Saída esperada: /Applications/Xcode.app/Contents/Developer
```

### 2️⃣ Configurar no App Store Connect

1. Acesse https://appstoreconnect.apple.com
2. Clique em **"Meus Apps"**
3. Clique em **"+"** → **"Novo App"**

4. Preencha:
   - Plataforma: `iOS`
   - Nome do app: `Student Grade Book`
   - Idioma principal: `Português (Brasil)`
   - Bundle ID: `com.estudantes.studentgradebook`
   - SKU: `student-grade-book-001`
   - Acesso: `Full Access`

5. Clique em **"Criar"**

### 3️⃣ Build do IPA

No seu Mac (ou via GitHub Actions):

```bash
cd flutter_app

# Limpar e preparar
flutter clean
flutter pub get

# Build para iOS
flutter build ios --release

# Criar arquivo IPA
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive

xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa
```

### 4️⃣ Upload no App Store Connect

**Opção A: Via Transporter (recomendado)**

1. Baixe "Transporter" da App Store
2. Abra Transporter
3. Clique em "+"
4. Selecione o arquivo `.ipa`
5. Clique em "Deliver"
6. Faça login com Apple ID
7. Aguarde confirmação

**Opção B: Via Xcode**

```bash
xcode-select --install
xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Upload via Xcode
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa \
  -allowProvisioningUpdates
```

### 5️⃣ Completar Informações no App Store Connect

1. Vá para **"App Information"**
   - Nome do app: `Student Grade Book`
   - Subtitle: `Gerenciador de Notas`
   - Descrição: "Aplicativo intuitivo para gerenciar notas de alunos. Funciona 100% offline com armazenamento local."
   - Palavras-chave: "notas, alunos, educação, escola"
   - Suporte URL: Seu site ou GitHub
   - Privacidade: Link da política de privacidade

2. **Adicionar Screenshots:**
   - Pelo menos 2 por tamanho de tela
   - Dimensões: 1170x2532 pixels (iPhone)
   - Podem incluir texto explicativo

3. **Pré-visualização:**
   - Adiciona vídeo opcional (15-30s)

4. Clique em **"Pronto para enviar"**

### 6️⃣ Enviar para Revisão

1. Vá para **"Versão"**
2. Verifique todas as informações
3. Clique em **"Enviar para revisão"**

**Tempo de revisão:** 1-3 dias

### ✅ Checklist iOS

- [ ] Apple Developer Account criado
- [ ] App criado no App Store Connect
- [ ] Certificado de distribuição gerado
- [ ] iOS Build (`--release`) criado
- [ ] IPA exportado com sucesso
- [ ] Transporter ou Xcode upload completado
- [ ] Screenshots adicionados (2-8)
- [ ] Descrição e palavras-chave preenchidas
- [ ] Privacidade configurada
- [ ] Enviado para revisão

---

## 🔄 Processo Automático (GitHub Actions)

Os builds já estão sendo feitos automaticamente!

### Visualizar Builds

Acesse: https://github.com/ManoelaV/StudentGradeBook/actions

### Baixar Artefatos

1. Vá para o workflow que completou
2. Clique em **Artifacts**
3. Download dos arquivos:
   - `android-apk` - APK para testes
   - `ios-ipa` - IPA para testes

### Workflow: `.github/workflows/build.yml`

O workflow automático:
- ✅ Testa a build a cada push
- ✅ Gera APK (Android)
- ✅ Gera IPA (iOS)
- ✅ Armazena como artifacts (7 dias)

---

## 📋 Checklist Final

### Antes de Publicar

- [ ] Versão atualizada em `pubspec.yaml`
- [ ] Changelog atualizado
- [ ] Testes finais completos
- [ ] Screenshots prontos
- [ ] Descrição e política de privacidade
- [ ] Nenhuma warning/erro no build

### Depois de Publicar

- [ ] Aguardar aprovação (24-48h Android, 1-3h dias iOS)
- [ ] Verificar página do app na loja
- [ ] Testar download e instalação
- [ ] Monitorar avaliações e comentários
- [ ] Planejar próximas atualizações

---

## 🆘 Troubleshooting

| Problema | Solução |
|----------|---------|
| **Keystore perdido** | Não é possível recuperar. Criar novo e não esquecer de guardar |
| **Certificado expirado** | Gerar novo em Developer Account |
| **Build size grande** | Ativar `shrinkResources = true` no Gradle |
| **Rejeição na Play Store** | Verificar políticas privacidade e permissões |
| **Rejeição App Store** | Melhorar screenshots/descrição, remover erros |

---

## 📞 Recursos Úteis

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect)
- [Flutter Publishing Guide](https://docs.flutter.dev/deployment)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)

---

**Última atualização:** Fevereiro 2026  
**Versão:** 1.0
