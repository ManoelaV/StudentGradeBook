# 📚 Student Grade Book - Flutter Version

Versão Flutter do app de gerenciamento de notas de alunos. **Funciona 100% offline em Android e iOS.**

## 🚀 Requisitos

- **Flutter SDK** 3.0.0 ou superior
- **Android Studio** (para compilar para Android) OU **Xcode** (para compilar para iOS)
- **Java JDK** 11+ (para Android)

## 📥 Instalação do Flutter

### Windows

1. Baixe o Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Extraia em uma pasta (ex: `C:\flutter`)
3. Adicione ao PATH do Windows:
   - Painel de Controle → Variáveis de Ambiente
   - Nome: `FLUTTER_HOME`, Valor: `C:\flutter`
   - Adicione `%FLUTTER_HOME%\bin` ao PATH
   
4. Abra PowerShell e execute:
```powershell
flutter doctor
```

### macOS (para iOS/Android no Mac)

```bash
brew install flutter
```

Ou baixe em: https://flutter.dev/docs/get-started/install/macos

### Linux

```bash
sudo snap install flutter --classic
```

## 💻 Como Compilar

### Para Android (APK)

```bash
cd flutter_app
flutter pub get
flutter build apk --release
```

O arquivo `.apk` estará em: `build/app/outputs/flutter-apk/app-release.apk`

Você pode:
- ✅ Transferir para o celular e instalar
- ✅ Publicar na Google Play Store
- ✅ Compartilhar com outras pessoas

### Para iOS (IPA)

```bash
cd flutter_app
flutter pub get
flutter build ios --release
```

Depois empacote em Xcode (requer Mac).

## 🎮 Usar em Desenvolvimento

```bash
cd flutter_app
flutter pub get
flutter run
```

## 📱 Recursos

✅ **100% Offline** - Funciona sem internet  
✅ **SQLite Local** - Banco de dados armazenado no celular  
✅ **Fotos** - Suporta upload e exibição de fotos  
✅ **Pesquisa** - Busca por nome, matrícula, escola, turma  
✅ **Organização Hierárquica** - Escola → Turma → Aluno  
✅ **Notas** - Registro de grades por disciplina  
✅ **Observações** - Histórico de observações dos alunos  

## 📂 Estrutura

```
flutter_app/
├── lib/
│   ├── main.dart              # Entrada da aplicação
│   ├── database.dart          # Banco de dados SQLite
│   ├── providers/
│   │   └── student_provider.dart  # Provider de estado
│   └── screens/
│       ├── home_screen.dart   # Lista de alunos
│       ├── add_student_screen.dart    # Adicionar/Editar
│       └── student_detail_screen.dart # Detalhes
└── pubspec.yaml               # Dependências
```

## 🔧 Troubleshooting

**Erro: "flutter is not recognized"**
- Adicione Flutter ao PATH (veja instruções acima)
- Reinicie o terminal/PowerShell

**Erro ao compilar para Android**
- Execute: `flutter doctor -v` para diagnosticar
- Instale Android SDK: `flutter config --android-sdk-root [caminho]`

**Erro ao compilar para iOS** (só em Mac)
- Execute: `pod install` na pasta `ios`
- Abra `ios/Runner.xcworkspace` no Xcode

## 📝 Primeiros Passos

1. Clone/copie a pasta `flutter_app`
2. Execute `flutter pub get`
3. Execute `flutter run` (precisa de emulador ou celular conectado)
4. Clique em "+" para adicionar primeiro aluno
5. Organize por escola e turma

## 📦 Dependências

- `sqflite` - Banco de dados SQLite
- `path_provider` - Acesso às pastas do celular
- `image_picker` - Selecionar fotos
- `image` - Manipular imagens
- `provider` - Gerenciamento de estado
- `intl` - Formatação de datas

## 🆘 Suporte

Se encontrar problemas, execute:
```bash
flutter clean
flutter pub get
flutter run
```

## 📄 Licença

Este projeto é de código aberto e pode ser usado livremente.
