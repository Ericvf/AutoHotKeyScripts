^Volume_Mute::Off()
^Volume_Down::Decrease()
CapsLock & -::Decrease()
CapsLock & =::Increase()
^Volume_Up::Increase()
^Launch_App2::Reset()

getMonitorHandle()
{
  ; Initialize Monitor handle
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

  MonitorHandle := getMonitorHandle()

  setMonitorBrightness(MonitorHandle, Br)
}

setMonitorBrightness(MonitorHandle, brightnessValue)
{
  ; ToolTip, MonitorHandle %MonitorHandle% Value %brightnessValue%
  DllCall("dxva2\SetVCPFeature"
    , "int", MonitorHandle
    , "char", 0x10 ;VCP code for Input Source Select
    , "uint", brightnessValue)
}
