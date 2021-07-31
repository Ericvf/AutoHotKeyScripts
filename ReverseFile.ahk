#include lib\Explorer.ahk

#F2::
  WinGet, active, ID, A
  WinGetClass, class, ahk_id %active%

  If class Not In Progman,WorkerW,ExploreWClass,CabinetWClass
    Return

  SelectedFile := Explorer_GetSelected()

  if (SelectedFile == "")
    Return

  SplitPath, SelectedFile, name, dir, ext, name_no_ext, drive

  NewName := Flip3(name_no_ext)
  NewPath = %dir%\%NewName%.%ext%
  OldPath = %dir%\%name%

  MsgBox, 4,, Would you like to rename:`n`t%OldPath%`nto`n`t%NewPath%
  IfMsgBox Yes
    FileMove, %OldPath%, %NewPath%
Return

Flip3(string)
{
  Loop, Parse, string
    reversed := A_LoopField . reversed
  Return reversed
}