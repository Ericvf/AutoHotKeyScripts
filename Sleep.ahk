CapsLock & Escape Up::
	WinHide ahk_id %Gui1%
	Send  {LWin down}{Tab}{LWin up}
	SoundBeep
	SoundBeep
	SoundBeep
	SendMessage, 0x112, 0xF170, 2,, Program Manager
return