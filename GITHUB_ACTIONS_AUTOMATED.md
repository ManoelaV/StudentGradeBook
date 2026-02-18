# 🤖 GitHub Actions - Compilação Automática (AVANÇADO)

## O que é GitHub Actions?

Um **serviço gratuito do GitHub** que:
- 🔄 Compila seu código automaticamente quando você faz `git push`
- 📦 Cria o executável sozinho
- 🚀 Faz upload para Releases automaticamente

**Resultado:** Você não precisa compilar manualmente mais!

---

## ⚡ Como Configurar (5 minutos)

### Passo 1: Arquivo já está pronto!

O arquivo `.github/workflows/build-release.yml` já foi criado.

Ele faz:
```
git push com tag v1.0.0
       ↓
GitHub compila automaticamente
       ↓
Executa flutter build windows --release
       ↓
Faz upload do .exe para Releases
       ↓
✅ Pronto para download!
```

### Passo 2: Usar GitHub Actions

Quando quiser fazer uma nova release:

1. **Faça suas alterações e commit:**
   ```powershell
   git add .
   git commit -m "Nova versão com ano da turma"
   ```

2. **Crie uma tag (versão):**
   ```powershell
   git tag v1.0.1
   ```

3. **Faça push:**
   ```powershell
   git push
   git push origin v1.0.1
   ```

4. **Aguarde ~5-10 minutos** ☕

5. **Pronto!** Novo `.exe` está em:
   ```
   https://github.com/ManoelaV/StudentGradeBook/releases/tag/v1.0.1
   ```

---

## 📊 Versioning Semântico

Use versões assim:

| Versão | Quando Usar | Exemplo |
|--------|------------|---------|
| **v1.0.0** | Primeira release | Inicial |
| **v1.0.1** | Bug fix pequeno | Corrigiu erro de exibição |
| **v1.1.0** | Nova feature | Adicionou ano na turma |
| **v2.0.0** | Mudança grande | Redesign da interface |

---

## 🎯 Exemplo Prático

### Cenário: Você adicionou o campo "Ano" e quer publicar

```powershell
REM 1. Faça suas mudanças (ja feito!)

REM 2. Adicione tudo
git add .

REM 3. Faça commit
git commit -m "Adicionado campo Ano da turma no cadastro"

REM 4. Crie versão
git tag v1.1.0

REM 5. Envie para GitHub
git push
git push origin v1.1.0

REM 6. Aguarde 10 minutos...
REM 7. Pronto! Novo executável está em GitHub Releases!

REM 8. Agora pode distribuir: setup_online.bat com VERSION=1.1.0
```

---

## ✅ Verificar Status da Compilação

1. Abra seu repositório GitHub
2. Clique em **"Actions"** (no menu superior)
3. Você verá suas compilações:

```
✅ Build Windows Release  v1.0.1  10 min ago
✅ Build Windows Release  v1.0.0  20 min ago
```

Se mostrar 🔴 (erro), clique para ver o que aconteceu.

---

## 📋 Workflow Completo

```
VOCÊ (seu PC)          GITHUB (servidor)
    ↓                        ↓
1. Edita código         
2. git commit           
3. git tag v1.1.0       
4. git push             →  Recebe novo código
5.                      →  Vê tag v1.1.0
6.                      →  Dispara Actions
7.                      →  Compila Windows
8.                      →  Build concluído
9.                      →  Faz upload Release
10.                 ←  Release criada!
11. Pega URL
12. Distribui setup.bat com URL
```

---

## 🔄 Próximas Atualizações

**Sempre que quiser publicar:**

```powershell
git add .
git commit -m "Descrição da mudança"
git tag v1.x.x          # Mude versão
git push
git push origin v1.x.x
# Aguarde 10 minutos
# Novo .exe está em Releases!
```

---

## ⚙️ Personalizar o Script

Se quiser mudar algo no build:

Edite: `.github/workflows/build-release.yml`

Exemplos:

**Mudar versão do Flutter:**
```yaml
flutter-version: '3.19.0'  ← Mude aqui
```

**Adicionar mais plataformas:**
```yaml
- uses: actions/setup-java@v3
  with:
    distribution: 'zulu'
    java-version: '11'

- name: Build APK
  run: cd flutter_app && flutter build apk --release
```

---

## 🎁 Bônus: Build Android também

Se quiser gerar APK (para Android) automaticamente:

Adicione ao arquivo `.github/workflows/build-release.yml`:

```yaml
- name: Build APK
  run: |
    cd flutter_app
    flutter build apk --release

- name: Upload APK
  uses: softprops/action-gh-release@v1
  with:
    files: flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

Pronto! Android também será compilado automaticamente!

---

## ❓ Perguntas

**P: Precisa pagar para usar GitHub Actions?**
R: NÃO! Grátis para repositórios públicos. Limite de 2000 min/mês para privados.

**P: Se dar erro na compilação?**
R: GitHub enviará email notificando. Verifique os logs em "Actions".

**P: Quanto tempo leva?**
R: ~5-10 minutos desde o `git push` até Release pronta.

**P: Preciso estar online?**
R: NÃO! GitHub compila sozinho, você pode sair e voltar depois.

---

## 📈 Status Badge (Opcional)

Coloque isto no seu `README.md` para mostrar status:

```markdown
![Build Status](https://github.com/ManoelaV/StudentGradeBook/workflows/Build%20Windows%20Release/badge.svg)
```

Fica assim:

```
✅ Build Status  (verde se passou, vermelho se falhou)
```

---

## 🚀 Resumo

Agora seu fluxo é:

```
1. Edita código
2. git commit & git tag v1.x.x
3. git push
4. GITHUB COMPILA SOZINHO ✨
5. Novo executável em Releases
6. Distribui link do GitHub
```

**Sem fazer nada manualmente!**

---

**Last updated:** Fevereiro 2026

