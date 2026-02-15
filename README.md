# 📚 Student Grade Book

Um aplicativo Flutter completo para gerenciar notas de alunos. Funciona **100% offline** em Android e iOS com suporte a sincronização via Supabase.

## ✨ Funcionalidades

- ✅ **Gestão de Alunos** - Adicionar, visualizar e pesquisar alunos
- ✅ **Notas por Disciplina** - Gerenciar notas de múltiplas disciplinas
- ✅ **Armazenamento Local** - SQLite para funcionamento offline
- ✅ **Sincronização Supabase** - Opcional para sincronizar entre dispositivos
- ✅ **Pesquisa em Tempo Real** - Filtro de alunos durante a digitação
- ✅ **Interface Intuitiva** - Design moderno com Material 3
- ✅ **Multiplataforma** - Android e iOS

## 🏗️ Estrutura do Projeto

```
StudentGradeBook/
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart                 # Ponto de entrada
│   │   ├── screens/                  # Telas da aplicação
│   │   │   ├── home_screen.dart      # Lista de alunos
│   │   │   ├── add_student_screen.dart
│   │   │   └── student_detail_screen.dart
│   │   ├── providers/                # State management
│   │   │   └── student_provider.dart
│   │   └── services/
│   │       └── database_service.dart
│   ├── android/                      # Configurações Android
│   ├── ios/                          # Configurações iOS
│   └── pubspec.yaml                  # Dependências
├── backend/                          # (Futuro) Backend com FastAPI
└── README.md
```

## 📦 Dependências

```yaml
# State Management
provider: ^6.1.0

# Local Database
sqflite: ^2.3.0+1
path_provider: ^2.1.0

# Media
image_picker: ^1.0.4
image: ^4.1.1

# Utilities
intl: ^0.19.0
```

## 🚀 Como Usar

### Pré-requisitos

- Flutter 3.41.1+
- Dart 3.0.0+
- Android SDK (para Android)
- Xcode 15+ (para iOS)

### Executar em Desenvolvimento

```bash
cd flutter_app
flutter pub get
flutter run
```

### Build para Production

**Android:**
```bash
cd flutter_app
flutter build apk --release
# Arquivo: build/app/outputs/apk/release/app-release.apk
```

**iOS:**
```bash
cd flutter_app
flutter build ios --release --no-codesign
# Arquivo gerado em: build/ios/iphoneos/Runner.app
```

## 🧪 Testando

### No Emulador Android

```bash
# Listar emuladores disponíveis
flutter emulators

# Iniciar emulador
flutter emulators --launch Medium_Phone_API_36.1

# Executar app
flutter run
```

### Em Dispositivo Físico

```bash
# Ativar USB Debug no dispositivo
# Conectar via USB

# Listar dispositivos
adb devices

# Executar
flutter run -d <device_id>
```

### Verificação de Funcionalidades

- [ ] Adicionar novo aluno (nome, escola, série)
- [ ] Pesquisar aluno pela barra de busca
- [ ] Visualizar detalhes do aluno
- [ ] Adicionar notas (disciplina + nota)
- [ ] Remover notas
- [ ] Dados persistem após reiniciar app

## 🏪 Distribuição

### Google Play Store (Android)

1. **Gerar chave de assinatura:**
```bash
keytool -genkey -v -keystore student_grade_book.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias student_grade_book_key
```

2. **Configurar assinatura em** `android/app/build.gradle.kts`

3. **Build AAB (App Bundle):**
```bash
flutter build appbundle --release
```

4. **Upload:**
   - Acessar [Google Play Console](https://play.google.com/console)
   - Crear nuevo app
   - Upload do arquivo AAB

### Apple App Store (iOS)

1. **Requisitos:**
   - Apple Developer Account
   - macOS com Xcode 15+

2. **Gerar certificados no** [Apple Developer](https://developer.apple.com)

3. **Build IPA:**
```bash
flutter build ios --release
cd ios && xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner -configuration Release -archivePath build/Runner.xcarchive
```

4. **Upload via Transporter App ou Xcode**

## 🔧 Configuração do Banco de Dados

O app usa **SQLite** por padrão (100% offline). Para opcional Supabase:

1. Criar conta em [Supabase](https://supabase.com)
2. Criar tabelas:
   ```sql
   CREATE TABLE students (
     id TEXT PRIMARY KEY,
     name TEXT NOT NULL,
     school TEXT,
     grade TEXT,
     created_at TIMESTAMP
   );
   
   CREATE TABLE grades (
     id TEXT PRIMARY KEY,
     student_id TEXT,
     subject TEXT,
     grade REAL,
     created_at TIMESTAMP
   );
   ```
3. Configurar credenciais em `student_provider.dart`

## 🐛 Troubleshooting

| Problema | Solução |
|----------|---------|
| **Java 11 requerido** | Instalar Java 17+: `java -version` |
| **Build Android falha** | `flutter clean && flutter pub get` |
| **CocoaPods erro (iOS)** | `cd ios && pod install && pod deintegrate` |
| **Emulador não aparece** | Reiniciar: `adb kill-server && adb start-server` |

## 📊 Status dos Builds

- ✅ Android APK - Compilando com sucesso
- ✅ iOS IPA - Compilando com sucesso
- 🔄 CI/CD - GitHub Actions configurado

Ver status em: [GitHub Actions](https://github.com/ManoelaV/StudentGradeBook/actions)

## 📈 Roadmap

- [ ] Cálculo automático de média
- [ ] Exportar dados em PDF/CSV
- [ ] Tema escuro (Dark Mode)
- [ ] Notificações locais
- [ ] Sincronização automática Supabase
- [ ] Integração com Google Drive
- [ ] Multi-idioma (PT, EN, ES)
- [ ] Gráficos de desempenho

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/MelhoriaX`)
3. Commit (`git commit -m 'Add: Melhoria X'`)
4. Push (`git push origin feature/MelhoriaX`)
5. Abra um Pull Request

## 📄 Licença

MIT License - veja [LICENSE](LICENSE)

## 👨‍💼 Autor

**Manuela V**  
- GitHub: [@ManoelaV](https://github.com/ManoelaV)
- Email: seu.email@exemplo.com

---

**Última atualização:** Fevereiro 2026  
**Versão:** 1.0.0  
**Status:** ✅ Em desenvolvimento ativo
buildozer -v android debug
```

O APK será gerado na pasta `bin/`

## 📖 Como Usar

### 1. Adicionar um Aluno
- Na tela inicial, clique no botão **"+ Novo Aluno"**
- Preencha o nome do aluno (obrigatório)
- Adicione o número de matrícula (opcional)
- Selecione uma foto (opcional)
- Clique em **"Salvar Aluno"**

### 2. Adicionar Notas
- Na lista de alunos, clique em **"Ver Detalhes"** no aluno desejado
- Você verá a foto, matrícula e média do aluno exibidas
- Clique em **"+ Adicionar Nota"**
- Preencha a matéria, nota e nota máxima
- A média geral é calculada automaticamente

### 3. Adicionar Observações
- Na tela de detalhes do aluno, role até a seção **"Observações"**
- Digite suas observações no campo de texto (com espaço para mais de 20 linhas)
- Clique em **"Salvar Observação"**
- As observações ficam registradas com data no histórico

### 4. Excluir Aluno
- Entre na tela de detalhes do aluno
- Clique no botão **"🗑 Excluir"** no topo
- Confirme a exclusão

## 🗂️ Estrutura do Projeto

```
StudentGradeBook/
│
├── main.py              # Arquivo principal com interface Tkinter
├── database.py          # Gerenciamento do banco de dados SQLite
├── requirements.txt     # Dependências do projeto
├── README.md           # Este arquivo
├── buildozer.spec      # Configuração para compilar Android
│
├── student_gradebook.db # Banco de dados (criado automaticamente)
└── photos/             # Pasta com fotos dos alunos (criada automaticamente)
```

## 💾 Armazenamento de Dados

Todos os dados são armazenados localmente em:
- **Banco de dados:** `student_gradebook.db` (SQLite)
- **Fotos:** pasta `photos/`

**IMPORTANTE:** Faça backup regular desses arquivos para não perder seus dados!

## 🎨 Capturas de Tela

### Tela Principal
- Lista todos os alunos cadastrados
- Mostra foto, nome, matrícula e média de cada aluno
- Código de cores: verde (média ≥ 6.0), vermelho (média < 6.0)

### Tela de Cadastro
- Formulário simples e intuitivo
- Seletor de fotos integrado
- Validação de dados

### Tela de Detalhes
- Exibe a foto do aluno (se houver cadastrada)
- Mostra matrícula, nome e média geral com código de cores
- Abas para Notas e Observações
- Lista de todas as notas por matéria
- Campo de observações com múltiplas linhas (mínimo 20 linhas)
- Histórico de observações anteriores

## 🛠️ Tecnologias Utilizadas

- **Python 3** - Linguagem de programação
- **Tkinter** - Framework para interface gráfica (nativa do Python)
- **SQLite** - Banco de dados local
- **Pillow** - Processamento e exibição de imagens

## 📝 Licença

Este projeto é livre para uso pessoal e educacional.

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs
- Sugerir novas funcionalidades
- Enviar pull requests

## 📞 Suporte

Se encontrar algum problema ou tiver dúvidas, abra uma issue no repositório.

---

