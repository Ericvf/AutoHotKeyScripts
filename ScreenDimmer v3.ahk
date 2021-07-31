; Screendimmer.ahk
;----------------------------------------------------------
; Author    : Appbyfex
; Date      : 2014-11-10
;----------------------------------------------------------

^Volume_Mute::Off()
^Volume_Down::Decrease()
CapsLock & -::Decrease()
CapsLock & =::Increase()
^Volume_Up::Increase()
^Launch_App2::Reset()
InitScreenDimmer()

getMonitorHandle()
{
  ; Initialize Monitor handle

  ;MouseGetPos, xpos, ypos
  ;point := ( ( xpos ) & 0xFFFFFFFF ) | ( ( ypos ) << 32 )
  ; hMon := DllCall("MonitorFromPoint"
  ;   , "int64", point ; point on monitor
  ;   , "uint", 0) ; flag to return primary monitor on failure

  WinGet, winId, ID, A
  if !(hMon := DllCall("User32.dll\MonitorFromWindow", "UInt", winId, "UInt", 2))
	{
		Throw Exception("Error in DllCall - Unable to set monitorHandle.")
	}

  ; Get Physical Monitor from handle
  VarSetCapacity(Physical_Monitor, 8 + 256, 0)
  DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR"
    , "int", hMon   ; monitor handle
    , "uint", 1   ; monitor array size
    , "int", &Physical_Monitor)   ; point to array with monitor

  return hPhysMon := NumGet(Physical_Monitor)
}


InitScreenDimmer()
{
  global MinValue, MaxValue, Value

  MinValue := 0
  MaxValue := 100

  try {
    IniRead,IniValue,Fex.ini,Screendimmer,ScreenDimmer

	If (IniValue >= MinValue and IniValue <= MaxValue) {
	  Value := IniValue
	} Else {
	  Value := 64
	}
  }
  catch {
    Value := 64
  }

  DisplaySetBrightness(Value)
}

Off() {
	global Value
	Value := 0
	UpdateUI()
}

Reset() {
	global Value, MaxValue
	Value := MaxValue
	UpdateUI()
}

Decrease() {
   global Value, MinValue
   Value -= 10

  if (Value < MinValue)
    Value := MinValue

   DisplaySetBrightness(Value)
}

Increase() {
	global Value, MaxValue
        Value += 10

	if (Value > MaxValue)
	  Value := MaxValue

        DisplaySetBrightness(Value)
}

UpdateUI() {
	global Value
	DisplaySetBrightness(Value)
}

DisplaySetBrightness( Br ) {
  global MonitorHandle

 ; if !MonitorHandle
  MonitorHandle := getMonitorHandle()

 setMonitorBrightness(MonitorHandle, Br)
/*
 Loop, % VarSetCapacity( GR,1536 ) / 6
   NumPut((n := (Br+128)*(A_Index-1)) > 65535 ? 65535 : n, GR, 2*(A_Index-1), "UShort")

 DllCall( "RtlMoveMemory", UInt,&GR+512,  UInt,&GR, UInt,512 )
 DllCall( "RtlMoveMemory", UInt,&GR+1024, UInt,&GR, UInt,512 )
 Return DllCall( "SetDeviceGammaRamp", UInt, hDC := DllCall("GetDC", UInt, 0), UInt, &GR),
		DllCall( "ReleaseDC", UInt,0, UInt,hDC )
    */
}

; Set volume 
setMonitorBrightness(MonitorHandle, brightnessValue)
{
  ; ToolTip, MonitorHandle %MonitorHandle% Value %brightnessValue%
  
  ; handle := getMonitorHandle()
  DllCall("dxva2\SetVCPFeature"
    , "int", MonitorHandle
    , "char", 0x10 ;VCP code for Input Source Select
    , "uint", brightnessValue)
  ; destroyMonitorHandle(handle)
}
