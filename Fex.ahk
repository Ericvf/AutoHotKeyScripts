
#NoEnv
#SingleInstance force
#WinActivateForce
#InstallKeybdHook

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2
SetCapsLockState, AlwaysOff
SetKeyDelay -1

Menu, Tray, Icon, Shell32.dll, 44, 1

if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
}

OnExit, SaveAndExit

InitScreenDimmer()
Return

SaveAndExit:
  SaveSettings()
  ExitApp
Return

RunAsAdmin:
  Run *RunAs "%A_ScriptFullPath%"
return

#include ScreenDimmer v3.ahk
#include ReverseFile.ahk
#include VolumeControl.ahk
#include SpellingCorrection.ahk
#include BluetoothYouTube.ahk
#include Sleep.ahk
#include ResetWindowPosition.ahk

; Winkey+R resets
#F5::
  SaveSettings()
  Reload
Return

#F6::Edit

SaveSettings() {
  Global Value
  SetWorkingDir, %A_WorkingDir%
  IniWrite,%Value%,Fex.ini,Screendimmer,ScreenDimmer
}