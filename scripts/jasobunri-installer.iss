[Setup]
AppId={{D8D9D8F8-C1DF-4B20-A5E0-3EEA0D1772B1}}
AppName=windows-contextmenu-jasobunri
AppVersion=1.0.2
AppPublisher=jasobunri
DefaultDirName={commonappdata}\JasoBunri
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=..\dist
OutputBaseFilename=jasobunri-setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName=windows-contextmenu-jasobunri

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[Files]
Source: "..\dist\nfc_renamer.exe"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
Root: HKCR; Subkey: "*\shell\NormalizeNFC"; ValueType: string; ValueName: ""; ValueData: "한글자모 분리 수정"; Flags: uninsdeletekey
Root: HKCR; Subkey: "*\shell\NormalizeNFC\command"; ValueType: string; ValueName: ""; ValueData: """{app}\nfc_renamer.exe"" ""%1"""; Flags: uninsdeletekey
Root: HKCR; Subkey: "Directory\shell\NormalizeNFC"; ValueType: string; ValueName: ""; ValueData: "한글자모 분리 수정"; Flags: uninsdeletekey
Root: HKCR; Subkey: "Directory\shell\NormalizeNFC\command"; ValueType: string; ValueName: ""; ValueData: """{app}\nfc_renamer.exe"" ""%1"""; Flags: uninsdeletekey

