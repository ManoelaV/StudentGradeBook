[app]

# (str) Título do seu aplicativo
title = Student GradeBook

# (str) Nome do pacote
package.name = studentgradebook

# (str) Domínio do pacote (necessário para Android/iOS)
package.domain = org.studentgradebook

# (str) Diretório de origem onde está o main.py
source.dir = .

# (list) Arquivos ou diretórios de código fonte para incluir (deixe vazio para incluir todos)
source.include_exts = py,png,jpg,jpeg,kv,atlas,db

# (list) Lista de inclusões usando padrões
#source.include_patterns = assets/*,images/*.png

# (list) Diretórios ou arquivos de código fonte para excluir
#source.exclude_exts = spec

# (list) Lista de exclusões usando padrões
#source.exclude_patterns = license,images/*/*.jpg

# (str) Versão do aplicativo
version = 1.0

# (list) Permissões do aplicativo
android.permissions = WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE,CAMERA

# (int) Código da versão do Android
android.numeric_version = 1

# (bool) Indica se o aplicativo deve ser exibido em tela cheia ou não
fullscreen = 0

# (string) Nome de exibição do ícone
#android.icon.filename = %(source.dir)s/data/icon.png

# (list) Dependências Python que o aplicativo precisa
requirements = python3,kivy==2.3.0,pillow

# (str) Orientação suportada (landscape, portrait ou all)
orientation = portrait

# (bool) Indica se o aplicativo é um aplicativo de serviço
#android.service = True

# (list) Permissões adicionais
#android.permissions = INTERNET

# (str) SDK mínimo do Android
android.minapi = 21

# (str) SDK do Android usado para compilar
android.sdk = 33

# (str) NDK Android para compilar
android.ndk = 25b

# (bool) Usar o --private data storage
android.private_storage = True

# (str) Android logcat filter
#android.logcat_filters = *:S python:D

[buildozer]

# (int) Log level (0 = error only, 1 = info, 2 = debug)
log_level = 2

# (int) Exibe avisos
warn_on_root = 1
