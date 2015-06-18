; Installer creation script
; Created by Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>

; Modern interface...
!include "MUI2.nsh"
!include "Sections.nsh"
!include "EnvVarUpdate.nsh"

; Request application privileges for Windows Vista...
RequestExecutionLevel admin

; Product settings...
!define COMPANY "ICAI"
!define PRODUCT_NAME "ICAI-RiSC-16 Assembler"
!define PRODUCT_SHORT "icai_risc_as"
!define PRODUCT_VER "v1.3.3"

; Variables...
Var StartMenuFolder

; General settings...
Name "${PRODUCT_NAME} ${PRODUCT_VER}"
OutFile "${PRODUCT_SHORT}_${PRODUCT_VER}.exe"
InstallDir "$PROGRAMFILES\${COMPANY}\${PRODUCT_NAME}"
; Get installation folder from registry if available...
InstallDirRegKey HKCU "Software\${PRODUCT_NAME}" ""
; Interface
!define MUI_ABORTWARNING
!define MUI_ICON icon.ico
!define MUI_INSTFILESPAGE_COLORS "EAAB0D 000000" ;Two colors
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP header.bmp
!define MUI_WELCOMEFINISHPAGE_BITMAP welcome.bmp
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
; Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${PRODUCT_NAME}" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

; Compiler install section...
Section "Compiler" Compiler

  ; Install files...
  SetOutPath "$INSTDIR"
  File "..\${PRODUCT_SHORT}.exe"

  ; Store installation folder...
  WriteRegStr HKCU "Software\${PRODUCT_NAME}" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Add to path
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

  ; Create shortcuts...
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_END

  ; Write uninstall information...
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"

SectionEnd

; Sublime plugins section...
Section "Sublime Text 2 Plugin" Sublime2

  ; Install files...
  SetOutPath "$APPDATA\Sublime Text 2\Packages\User"
  File "..\editors\ICAI-RiSC-16 Assembler.sublime-build"

SectionEnd

; Sublime plugins section...
Section "Sublime Text 3 Plugin" Sublime3

  ; Install files...
  SetOutPath "$APPDATA\Sublime Text 3\Packages\User"
  File "..\editors\ICAI-RiSC-16 Assembler.sublime-build"

SectionEnd

; Section descriptions...
LangString DESC_Compiler ${LANG_ENGLISH} "Compiler binaries. Will be added to PATH environment variable."
LangString DESC_Sublime2 ${LANG_ENGLISH} "Sublime Text 2 build plugin. Requires Sublime Text 2 to be installed in the system."
LangString DESC_Sublime3 ${LANG_ENGLISH} "Sublime Text 3 build plugin. Requires Sublime Text 3 to be installed in the system."
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Compiler} $(DESC_Compiler)
  !insertmacro MUI_DESCRIPTION_TEXT ${Sublime2} $(DESC_Sublime2)
  !insertmacro MUI_DESCRIPTION_TEXT ${Sublime3} $(DESC_Sublime3)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Initial checks...
Function .onInit

  ; Check if already installed...
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString"
  StrCmp $R0 "" uninstalled
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "${PRODUCT_NAME} is already installed. $\n$\nClick `OK` to remove the previous version or `Cancel` to cancel this upgrade." IDOK uninstall

  ; Exit on cancel...
  Abort

  ; Uninstall previous versions...
uninstall:
  ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file

  ; All done continue...
uninstalled:

  ; Check for Sublime Text 2
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sublime Text 2_is1" "UninstallString"
  StrCmp $R0 "" no_sublime2_x86
  ;MessageBox MB_OK "Sublime2: Present x86!"
  goto end_sublime2
no_sublime2_x86:
  SetRegView 64
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sublime Text 2_is1" "UninstallString"
  SetRegView 32
  StrCmp $R0 "" no_sublime2
  ;MessageBox MB_OK "Sublime2: Present x64!"
  goto end_sublime2
no_sublime2:
  ;MessageBox MB_OK "Sublime2: Not resent!"
  !insertmacro UnSelectSection ${Sublime2}
  !insertmacro SetSectionFlag ${Sublime2} ${SF_RO}
end_sublime2:

  ; Check for Sublime Text 3
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sublime Text 3_is1" "UninstallString"
  StrCmp $R0 "" no_sublime3_x86
  ;MessageBox MB_OK "Sublime3: Present x86!"
  goto end_sublime3
no_sublime3_x86:
  SetRegView 64
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sublime Text 3_is1" "UninstallString"
  SetRegView 32
  StrCmp $R0 "" no_sublime3
  ;MessageBox MB_OK "Sublime3: Present x64!"
  goto end_sublime3
no_sublime3:
  ;MessageBox MB_OK "Sublime3: Not resent!"
  !insertmacro UnSelectSection ${Sublime3}
  !insertmacro SetSectionFlag ${Sublime3} ${SF_RO}
end_sublime3:

FunctionEnd

; Uninstaller section...
Section "Uninstall"

  Delete "$INSTDIR\${PRODUCT_SHORT}.exe"
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  ; Remove from path
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder

  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"

  DeleteRegKey /ifempty HKCU "Software\${PRODUCT_NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

SectionEnd
