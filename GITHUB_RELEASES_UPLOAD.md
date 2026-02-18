# 📤 Fazer Upload no GitHub Releases - Passo a Passo

## 1️⃣ Compilar o Executável

Se ainda não tem, execute no terminal dentro de `flutter_app`:

```powershell
flutter build windows --release
```

Vai criar: `build\windows\x64\runner\Release\student_grade_book.exe`

---

## 2️⃣ Abrir GitHub no Navegador

1. Acesse: https://github.com/ManoelaV/StudentGradeBook
2. Clique em **"Releases"** (no lado direito da página)

```
┌─ About          Releases ← Clique aqui
│
│ Student Grade Book
│ Gerenciador de notas de alunos
```

---

## 3️⃣ Criar Nova Release

### Passo 3.1: Clique em "Create a new release"

```
┌────────────────────────────────────────┐
│ Releases (0)                           │
├────────────────────────────────────────┤
│                                        │
│  [Create a new release] ← Clique       │
│                                        │
└────────────────────────────────────────┘
```

### Passo 3.2: Preencha os campos

#### Campo 1: "Choose a tag"
- Digite: `v1.0.0`
- Deixe a opção "Create new tag on publish" selecionada

```
┌─ Choose a tag ───────────────────────┐
│ v1.0.0                               │
└──────────────────────────────────────┘
```

#### Campo 2: "Release title"
- Digite: `Student Grade Book v1.0.0`

```
┌─ Release title ──────────────────────┐
│ Student Grade Book v1.0.0            │
└──────────────────────────────────────┘
```

#### Campo 3: "Describe this release"
- Digite uma descrição (pode ser simples):

```
Primeira versão do Student Grade Book

✨ Features:
- Gerenciamento de notas de alunos
- Registro de frequência
- Geração de relatórios em PDF
- Funciona offline

📱 Plataformas:
- Windows
- Android
- iOS
```

#### Campo 4: Upload do Arquivo

1. Procure a seção "Attach binaries by dropping them here or selecting them"
2. Clique nessa área
3. Selecione o arquivo: `student_grade_book.exe`

OU arraste e solte o arquivo direto!

```
┌─────────────────────────────────────────┐
│ Attach binaries by dropping them here  │
│ or selecting them                       │
├─────────────────────────────────────────┤
│  📄 student_grade_book.exe             │
│     (50.2 MB)                          │
└─────────────────────────────────────────┘
```

---

## 4️⃣ Publicar a Release

Na lateral direita, você verá opções:

```
┌─ Release options ────────┐
│                          │
│ ☑ Latest release        │
│ ☐ Pre-release           │
│ ☐ Set as a draft        │
│                          │
│ [Publish Release]  ← OK! │
│                          │
└──────────────────────────┘
```

1. **Deixe "Latest release" marcado** ✅
2. Clique em **"Publish Release"**

---

## 5️⃣ Pronto! 

Você agora tem:
- Release criada: `v1.0.0`
- Executável no GitHub
- URL para download: 
  ```
  https://github.com/ManoelaV/StudentGradeBook/releases/download/v1.0.0/student_grade_book.exe
  ```

---

## 📋 Para as Próximas Atualizações

Quando fizer uma nova versão:

1. **Compile tudo de novo:**
   ```powershell
   flutter build windows --release
   ```

2. **Crie outra release:**
   - Tag: `v1.0.1` (ou `v1.1.0`)
   - Faça upload do novo `.exe`

3. **Atualize o script (`setup_online.bat`):**
   ```batch
   set "VERSION=1.0.1"  ← Mude aqui
   ```

4. **Distribua o novo `setup_online.bat`**

---

## ✅ Verificar se Funcionou

Após publicar:

1. Abra o link da release no navegador:
   ```
   https://github.com/ManoelaV/StudentGradeBook/releases/tag/v1.0.0
   ```

2. Você deve ver o arquivo listado

3. Teste fazer um duplo clique em `setup_online.bat` em outro computador
   - Ele deve fazer download automaticamente
   - Instalar sem problemas

---

## 🆘 Problemas?

**"Arquivo é muito grande (> 2 GB)"**
- GitHub tem limite de 2 GB por arquivo
- Seu `.exe` é ~50-100 MB, sem problema!

**"Não consigo fazer upload"**
- Verifique se você é o dono do repositório
- Tente em navegador diferente
- Limpe cache do navegador

**"Setup não encontra o arquivo"**
- Confirme que versão está correta em `setup_online.bat`
- Confirme que release foi publicada (não é draft)
- Teste o link manualmente no navegador

---

## 💡 Dica Profissional

Você pode automatizar tudo isso com **GitHub Actions**!

Se quiser que cada vez que você faz `git push`, o executável seja compilado e publicado automaticamente, veja o arquivo:

```
GITHUB_ACTIONS_SETUP.md
```

---

**Pronto! Agora você tem um instalador online de verdade!** 🚀

