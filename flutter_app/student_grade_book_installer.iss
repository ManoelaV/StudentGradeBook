; Script InnoSetup para Student Grade Book
; Este script cria um instalador executável profissional
; Para usar: Instale InnoSetup em https://jrsoftware.org/isdl.php
; Depois execute: iscc student_grade_book_installer.iss

[Setup]
AppName=Student Grade Book
AppVersion=1.0.0
DefaultDirName={autopf}\Student Grade Book
DefaultGroupName=Student Grade Book
UninstallDisplayIcon={app}\student_grade_book.exe
Compression=lzma2
SolidCompression=yes
OutputDir=.\release_installer
OutputBaseFilename=StudentGradeBook_Installer_v1.0.0
SetupIconFile={src}\build\windows\x64\runner\Release\student_grade_book.exe

; Configurações de idioma e requisitos
MinVersion=6.1sp1
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\PortugueseBrazilian.isl"

[Messages]
ptButtons=&Avançar,&Voltar,&Cancelar,&Instalar,&Sim,&Não,&Próximo

[Files]
; Copiando o executável e bibliotecas necessárias
Source: "build\windows\x64\runner\Release\student_grade_book.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Incluindo ícone e documentação (opcional)
; Source: "README.md"; DestDir: "{app}"; Filename: "README.txt"

[Icons]
; Atalho no Menu Iniciar
Name: "{group}\Student Grade Book"; Filename: "{app}\student_grade_book.exe"; IconFilename: "{app}\student_grade_book.exe"
Name: "{group}\Desinstalar Student Grade Book"; Filename: "{uninstallexe}"

; Atalho na Área de Trabalho (opcional)
Name: "{userdesktop}\Student Grade Book"; Filename: "{app}\student_grade_book.exe"; Tasks: desktopicon; IconFilename: "{app}\student_grade_book.exe"

[Tasks]
; Tarefa opcional para criar atalho na área de trabalho
Name: "desktopicon"; Description: "Criar atalho na Área de Trabalho"; GroupDescription: "Opções adicionais:"

[Run]
; Executa o programa após a instalação
Filename: "{app}\student_grade_book.exe"; Description: "Iniciar Student Grade Book agora"; Flags: nowait postinstall skipifsilent

[Code]
{ Código personalizado para validar requisitos do sistema (opcional) }
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    MsgBox('Student Grade Book foi instalado com sucesso!' + #13#13 + 'O programa foi adicionado ao seu Menu Iniciar.', mbInformation, MB_OK);
end;
