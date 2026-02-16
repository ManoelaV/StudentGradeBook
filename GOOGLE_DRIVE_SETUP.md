# Configuração do Google Drive Backup

Este guia explica como configurar o backup no Google Drive para o app StudentGradeBook.

## 📋 Pré-requisitos

- Conta Google Cloud Console
- App instalado em um dispositivo Android

## 🔧 Passo a Passo

### 1. Criar Projeto no Google Cloud Console

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Clique em **"Create Project"**
3. Nome do projeto: `StudentGradeBook`
4. Clique em **"Create"**

### 2. Habilitar APIs Necessárias

1. No menu lateral, vá em **"APIs & Services" > "Library"**
2. Procure e habilite as seguintes APIs:
   - **Google Drive API**
   - **Google Sign-In API**

### 3. Configurar OAuth Consent Screen

1. Vá em **"APIs & Services" > "OAuth consent screen"**
2. Escolha **"External"** e clique em **"Create"**
3. Preencha:
   - **App name**: StudentGradeBook
   - **User support email**: Seu email
   - **Developer contact**: Seu email
4. Clique em **"Save and Continue"**
5. Em **"Scopes"**, clique em **"Add or Remove Scopes"**
6. Adicione o scope: `https://www.googleapis.com/auth/drive.file`
7. Clique em **"Save and Continue"**
8. Em **"Test users"**, adicione seu email do Google
9. Clique em **"Save and Continue"**

### 4. Criar Credenciais OAuth 2.0

#### Para Android:

1. Vá em **"APIs & Services" > "Credentials"**
2. Clique em **"Create Credentials" > "OAuth client ID"**
3. Escolha **"Android"**
4. Preencha:
   - **Name**: `StudentGradeBook Android`
   - **Package name**: `com.example.student_grade_book`
   - **SHA-1 certificate fingerprint**: (veja como obter abaixo)

#### Como obter SHA-1:

**Windows (PowerShell):**
```powershell
cd C:\Users\SEU_USUARIO\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Copie o SHA-1** que aparece e cole no Google Cloud Console.

5. Clique em **"Create"**
6. Anote o **Client ID** gerado (algo como `123456789-abc.apps.googleusercontent.com`)

### 5. Configurar o App Flutter

Não é necessário adicionar o Client ID no código, pois o Google Sign-In Android detecta automaticamente usando o SHA-1.

### 6. Testar

1. Compile e instale o app no dispositivo
2. Vá em **Menu > Backup e Sincronização**
3. Clique em **"Conectar"**
4. Faça login com a conta Google que você adicionou como "Test user"
5. Autorize as permissões
6. Clique em **"Fazer Backup Agora"**

## ✅ Funcionamento

- **Backup**: Exporta todos os alunos, notas e observações para um arquivo JSON no Google Drive
- **Restaurar**: Baixa o backup do Google Drive e substitui os dados locais
- **Sincronização**: Pode restaurar o backup em outro dispositivo fazendo login com a mesma conta

## 🔒 Segurança

- Os dados ficam armazenados no Google Drive do próprio usuário
- Apenas o app tem acesso ao arquivo de backup
- Utilize autenticação com conta Google confiável

## ⚠️ Importante

- Faça backups regularmente
- Antes de restaurar, tenha certeza do que está fazendo (os dados atuais serão substituídos)
- Mantenha sua conta Google segura com senha forte e 2FA

## 🐛 Troubleshooting

### Erro "Sign in failed"
- Verifique se adicionou seu email como "Test user" no OAuth consent screen
- Confirme que o SHA-1 está correto
- Reinstale o app após configurar as credenciais

### Erro "API not enabled"
- Verifique se habilitou a Google Drive API no Cloud Console

### Backup não aparece
- Aguarde alguns segundos após fazer backup
- Verifique se está logado com a mesma conta

## 📝 Notas

Para **produção** (publicar na Play Store), você precisará:
1. Criar uma **release keystore** (não usar debug.keystore)
2. Obter SHA-1 da release keystore
3. Criar outro OAuth client ID com esse SHA-1
4. Submeter o app para revisão no Google (sair do modo Test para Production)
