# 🚀 Quick Start - Student Grade Book Flutter

## O que você ganhou? 📱

✅ App **Android e iOS** que funciona **100% offline**  
✅ Sem necessidade de internet  
✅ Dados salvos localmente no celular  
✅ Interface similar à versão Windows

## Primeiros Passos (5 min)

### 1️⃣ Instale Flutter

**Windows:**
1. Baixe em https://flutter.dev/docs/get-started/install/windows
2. Descompacte em `C:\flutter`
3. Adicione `C:\flutter\bin` ao PATH do Windows
4. Abra PowerShell e teste:
```powershell
flutter doctor
```

**Mac:**
```bash
brew install flutter
```

### 2️⃣ Compile o App

#### Para Android (celular ou emulador)
```bash
cd flutter_app
flutter pub get
flutter build apk --release
```
Resultado: `build/app/outputs/flutter-apk/app-release.apk`

Próximos passos:
- Transfira o `.apk` para o celular
- Clique e instale (pode aparecer aviso de "origem desconhecida" - clique OK)
- Pronto! App disponível

#### Para iOS (só em Mac com Xcode)
```bash
cd flutter_app
flutter pub get
flutter build ios --release
```

### 3️⃣ Testar Localmente (Desenvolvimento)

Precisa de um emulador ou celular conectado:

```bash
cd flutter_app
flutter pub get
flutter run
```

## 📊 Diferenças da Versão Windows

| Recurso | Windows .exe | Flutter Mobile |
|---------|-------------|-----------------|
| Offline | ✅ | ✅ |
| Android | ❌ | ✅ |
| iOS | ❌ | ✅ |
| Pesquisa | ✅ | ✅ |
| Fotos | ✅ | ✅ |
| Notas | ✅ | ✅ |
| Obs. | ✅ | ✅ |

## 📱 Distribuição

### Android - 3 Opções:

**Opção 1: APK direto** (mais fácil)
- Compartilhe o arquivo `.apk` por email/WhatsApp
- Recebedor: abre e instala

**Opção 2: Arquivo no Drive/Dropbox**
- Upload do `.apk`
- Compartilhe link
- Recebedor: baixa e instala

**Opção 3: Google Play Store** (para publicação oficial)
- Custa $25 para criar conta
- Seu app aparece na Play Store

### iOS:

- Precisa de uma conta Apple Developer ($99/ano)
- Publicar na App Store
- OU distribuir via TestFlight (versão de teste)

## 🆘 Troubleshooting

```bash
# Erro de compilação?
flutter clean
flutter pub get
flutter build apk --release

# Arquivo não encontrado?
flutter doctor -v

# Precisa reinstalar dependências?
cd flutter_app
rm -r .packages
flutter pub get
```

## 📂 Arquivos Importantes

```
flutter_app/
├── pubspec.yaml        # Dependências (não modifique!)
├── README.md           # Documentação completa
└── lib/
    ├── database.dart   # Banco de dados local (SQLite)
    ├── main.dart       # Aplicação
    └── screens/        # Telas da app
```

## ✅ Checklist para Deploy

- [ ] Testou em celular Android/iOS?
- [ ] Adicionou e visualizou um aluno?
- [ ] Adicionou uma nota?
- [ ] Tirou uma foto e viu aparecer?
- [ ] Pesquisou um aluno?
- [ ] Dados persistem após fechar o app?

Se tudo passou ✅, está pronto para distribuir!

## 💬 Próximas Otimizações (opcional)

- Ícone customizado
- Splash screen personalizada
- Backup em nuvem
- Sincronização entre múltiplos dispositivos
- Modo escuro

Precisa? Avise! 🚀
