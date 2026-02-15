# 📱 Como Baixar o IPA para Testar no iPhone

## Método 1: Download via GitHub Actions (RECOMENDADO)

### Passo 1: Acessar GitHub Actions

1. Abra o navegador
2. Vá para: https://github.com/ManoelaV/StudentGradeBook/actions
3. Faça login se necessário

### Passo 2: Encontrar o Último Build

Na página do Actions:

```
┌─────────────────────────────────────────────────────┐
│ All workflows ▼                                      │
├─────────────────────────────────────────────────────┤
│ ✅ Build Android & iOS #8        main    2h ago     │  ← Clique aqui
│ ✅ Build Android & iOS #7        main    3h ago     │
│ ❌ Build Android & iOS #6        main    5h ago     │
└─────────────────────────────────────────────────────┘
```

- Clique no build com **✅** (check verde)
- Deve ser o mais recente

### Passo 3: Baixar o Artefato

Dentro do build:

```
┌─────────────────────────────────────────────────────┐
│ Build Android & iOS #8                               │
├─────────────────────────────────────────────────────┤
│ Summary                                              │
│                                                      │
│ ✅ build-android    3m 45s                          │
│ ✅ build-ios        4m 19s                          │
│                                                      │
│ Artifacts                                            │  ← Role até aqui
│ ┌─────────────────────────────────────────────┐    │
│ │ 📦 android-apk          2.5 MB   Download   │ ← Android
│ │ 📦 ios-ipa             12.3 MB   Download   │ ← iPhone
│ └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

- Role a página até a seção **"Artifacts"**
- Clique em **"Download"** ao lado de **"ios-ipa"**
- Arquivo será baixado como: `ios-ipa.zip`

### Passo 4: Extrair o Arquivo

1. Vá para sua pasta **Downloads**
2. Encontre `ios-ipa.zip`
3. Clique com botão direito → **Extrair tudo**
4. Dentro da pasta extraída, você verá: **`app.ipa`**

---

## ⚠️ PROBLEMA: Artefatos Expiram em 90 Dias

Os artefatos do GitHub Actions são **temporários**. Se não houver nenhum disponível:

### Solução: Fazer um Novo Build

Execute qualquer comando que faça commit e push:

```powershell
cd c:\Users\manno\Documents\GitHub\StudentGradeBook

# Fazer uma mudança simples para triggerar build
git commit --allow-empty -m "Trigger build for iOS testing"
git push
```

Aguarde 5-7 minutos e verifique novamente em:
https://github.com/ManoelaV/StudentGradeBook/actions

---

## Método 2: Verificar Status do Último Build

Se você não vir artifacts, pode ser que o build falhou. Veja o log:

1. Na página Actions, clique no último build
2. Clique em **"build-ios"** (do lado esquerdo)
3. Veja os logs para identificar erros
4. Se tiver ❌, o IPA não foi gerado

---

## 📲 Depois de Baixar o IPA

### Opção A: Instalar via TestFlight (Recomendado)

**PROBLEMA:** Não dá para instalar IPA direto no iPhone sem Mac

**SOLUÇÃO:** Use TestFlight

1. **Criar conta Apple Developer** ($99/ano)
   - Acesse: https://developer.apple.com

2. **Criar app no App Store Connect**
   - Acesse: https://appstoreconnect.apple.com
   - My Apps → + → New App
   - Bundle ID: `com.example.student_grade_book`

3. **Fazer upload do IPA** (PRECISA DE MAC)
   - No Mac, baixe "Transporter" (App Store)
   - Abra Transporter
   - Arraste o arquivo `app.ipa`
   - Clique em "Deliver"

4. **Adicionar TestFlight Testers**
   - App Store Connect → TestFlight
   - Add Internal Testers → Adicione seu email
   - Você receberá convite por email

5. **Instalar no iPhone**
   ```
   iPhone → App Store → Buscar "TestFlight"
   → Instalar TestFlight
   → Abrir TestFlight
   → Aceitar convite
   → Instalar "Student Grade Book"
   ```

### Opção B: Usar Serviço Alternativo (SEM CONTA DEVELOPER)

Se você **não quer pagar** $99/ano:

#### Diawi (Grátis, mas temporário)

1. Acesse: https://www.diawi.com
2. Arraste o arquivo `app.ipa`
3. Clique em "Upload"
4. Copie o link gerado
5. **No iPhone:**
   - Abra Safari
   - Cole o link
   - Toque em "Install"
   - Ajustes → Geral → VPN e Gerenciamento de Dispositivo
   - Confie no desenvolvedor

**⚠️ LIMITAÇÃO:** Link expira em 24 horas

#### App Center (Microsoft - Grátis)

1. Acesse: https://appcenter.ms
2. Crie conta grátis
3. Crie novo app
4. Faça upload do IPA
5. Adicione seu email como tester
6. No iPhone, receba email e instale

---

## 🎯 Resumo - Caminho Mais Fácil

Para você que está no Windows e quer testar no iPhone:

1. ✅ **Baixar IPA** do GitHub Actions (este guia)
2. ✅ **Usar App Center** (grátis, sem precisar Mac)
3. ✅ **Instalar no iPhone** via link

**OU**

1. ✅ **Testar no emulador Android** (que você já tem)
2. ✅ **Quando estiver pronto**, publicar normalmente
3. ✅ **Usuários instalam** via App Store oficial

---

## ❓ Perguntas Frequentes

**P: Preciso de Mac para testar no iPhone?**
R: Para instalar via Xcode, SIM. Mas pode usar TestFlight ou App Center.

**P: Posso usar iPhone sem conta Developer?**
R: Sim! Use App Center ou Diawi (grátis).

**P: O IPA do GitHub Actions funciona no iPhone?**
R: SIM, mas precisa ser assinado. O build do GitHub Actions NÃO é assinado (--no-codesign).

**P: Então o IPA do GitHub não serve?**
R: Serve parcialmente. Para testar de verdade, você precisa:
   - Mac para assinar o IPA, OU
   - Publicar no TestFlight/App Store

---

## 💡 Minha Recomendação

**Para teste rápido:**
```
Teste no emulador Android (você já tem funcionando)
↓
Valide todas as funcionalidades
↓
Publique direto na App Store
↓
Teste via TestFlight (oficial)
```

**Economiza tempo e dinheiro!**

---

## 📞 Precisa de Ajuda?

Se tiver dificuldade:
1. Teste primeiro no Android
2. Verifique se o build iOS passou no GitHub Actions
3. Se precisar de IPA assinado, considere:
   - Pedir ajuda de alguém com Mac
   - Usar serviço cloud Mac (MacStadium)
   - Publicar direto na App Store

---

**Última atualização:** Fevereiro 2026
