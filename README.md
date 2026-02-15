# 📚 Student GradeBook - Caderneta de Notas

Aplicativo completo para gerenciar notas de alunos que funciona **100% offline** em PC e celular (Android).

## ✨ Funcionalidades

- ✅ **Cadastro de Alunos** com foto e número de matrícula
- ✅ **Gerenciamento de Notas** por matéria com cálculo automático de média
- ✅ **Observações detalhadas** com mínimo 20 linhas disponíveis para texto
- ✅ **Funciona 100% OFFLINE** - não precisa de internet
- ✅ **Banco de dados local** SQLite
- ✅ **Interface amigável** e responsiva
- ✅ **Multiplataforma** - Windows, Linux, macOS e Android

## 📋 Requisitos

- Python 3.7 ou superior
- Pillow (para processar imagens)

## 🚀 Instalação e Execução

### No PC (Windows/Linux/macOS)

1. **Clone ou baixe este repositório**

2. **Instale as dependências:**
```bash
pip install -r requirements.txt
```

> **Nota:** Apenas Pillow é necessário! A interface usa Tkinter que já vem nativo do Python.

3. **Execute o aplicativo:**
```bash
python main.py
```

### No Android

Para gerar o APK para Android, você precisa do Buildozer:

1. **Instale o Buildozer** (Linux ou WSL no Windows):
```bash
pip install buildozer
```

2. **Configure o buildozer.spec** (já incluído no projeto)

3. **Gere o APK:**
```bash
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

