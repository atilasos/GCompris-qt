; SPDX-License-Identifier: GPL-3.0-or-later
Unicode true
!include "MUI2.nsh"
!include "x64.nsh"
Name "GCompris PT-PT — candidato de teste"
OutFile "${OUTPUT}"
InstallDir "$PROGRAMFILES64\GCompris-PT-Teste"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SOURCE}\LICENSES\AGPL-3.0-only.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Portuguese"
Function .onInit
  ${IfNot} ${RunningX64}
    MessageBox MB_ICONSTOP "Este candidato exige Windows de 64 bits."
    Abort
  ${EndIf}
FunctionEnd
Section "Aplicação e recursos offline"
  SetShellVarContext all
  SetOutPath "$INSTDIR"
  File /r "${STAGE}\*"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateDirectory "$SMPROGRAMS\GCompris PT Teste"
  CreateShortCut "$SMPROGRAMS\GCompris PT Teste\GCompris.lnk" "$INSTDIR\bin\GCompris.exe" "--locale pt_PT --window"
  CreateShortCut "$SMPROGRAMS\GCompris PT Teste\GCompris (modo seguro).lnk" "$INSTDIR\bin\GCompris.exe" "--locale pt_PT --window --renderer software"
  CreateShortCut "$DESKTOP\GCompris PT Teste.lnk" "$INSTDIR\bin\GCompris.exe" "--locale pt_PT --window"
SectionEnd
Section "Uninstall"
  SetShellVarContext all
  Delete "$DESKTOP\GCompris PT Teste.lnk"
  RMDir /r "$SMPROGRAMS\GCompris PT Teste"
  RMDir /r "$INSTDIR"
SectionEnd
