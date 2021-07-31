; Mechanical Keyboard remapper
; Works on Vortex Poker, RK61 and other 60% keyboards

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.


SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetCapsLockState, AlwaysOff
SetWorkingDir, %A_ScriptDir%

Menu, Tray,  Icon, keyboard_on.ico, 1, 1

CapsLock & Tab::
Suspend, Permit
Suspend
If (A_IsSuspended)
{
  TrayTip,, RK61 script disabled
  Menu, Tray,  Icon, keyboard_off.ico, 1, 1

  
} else { 
  TrayTip,, RK61 script enabled
  Menu, Tray,  Icon, keyboard_on.ico, 1, 1

}
Return 

; Permanently map modifiers and '/' to navigator keys
RAlt::Left
RCtrl::Right
/::Up
AppsKey::Down

; Permanently map navigator keys (fn) to the modifiers and '/' 
$Left::RAlt
$Right::RCtrl
$Up::/
$Down::AppsKey

; Override special case for question mark 
RShift & /::Send {?}

; Map AltF4 and CtrlF4 to digits
^4::^F4
!4::!F4

; Home, End, PageUp, PageDown and Delete
CapsLock & RAlt::Send {Home}
CapsLock & RCtrl::Send {End}
CapsLock & /::Send {PgUp}
CapsLock & AppsKey::Send {PgDn}
CapsLock & Backspace::Send {Del}

; Media keys
CapsLock & -::Send {Volume_Down}
CapsLock & =::Send {Volume_Up}

^F5::reload