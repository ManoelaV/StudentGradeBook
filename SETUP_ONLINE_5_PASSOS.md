# ⚡ Setup Online em 5 Passos Rápidos

## Passo 1: Abra o GitHub no navegador
```
https://github.com/ManoelaV/StudentGradeBook/releases
```

---

## Passo 2: Clique em "Create a new release"

```
┌─ Releases ──────────────────────────────┐
│             [Create a new release] ←    │
└─────────────────────────────────────────┘
```

---

## Passo 3: Preencha (leva 1 minuto)

| Campo | Digite |
|-------|--------|
| **Tag** | `v1.0.0` |
| **Título** | `Student Grade Book v1.0.0` |
| **Descrição** | `Primeira versão do aplicativo` |
| **Arquivo** | Arraste `flutter_app/build/windows/x64/runner/Release/student_grade_book.exe` |

---

## Passo 4: Clique em "Publish Release"

```
[Publish Release] ← Clique aqui
```

✅ **Pronto!** Seu arquivo agora está no GitHub.

---

## Passo 5: Distribua `setup_online.bat`

Envie o arquivo `flutter_app/setup_online.bat` para seus usuários.

Eles duplo clicam → **INSTALADO!**

```
Usuário recebe:
📎 setup_online.bat (3 KB)
    ↓
Duplo clique
    ↓
Faz download automático (~50 MB do GitHub)
    ↓
Instala em C:\Program Files\Student Grade Book
    ↓
✅ Pronto pra usar!
```

---

## ✅ PRONTO! Você tem um instalador online!

**Próxima atualização?** Repita os 5 passos com versão v1.0.1

```powershell
# Mude em setup_online.bat:
set "VERSION=1.0.1"
```

---

## 📚 Guias Detalhados

- [Setup Online Completo](INSTALADOR_ONLINE_GUIDE.md)
- [Upload para GitHub (com prints)](GITHUB_RELEASES_UPLOAD.md)
- [Automação com GitHub Actions](GITHUB_ACTIONS_AUTOMATED.md)
- [Comparação de Métodos](INSTALLER_QUICK_CHOICE.md)

---

**Dúvida?** Abra os guias acima para mais detalhes! 📖

