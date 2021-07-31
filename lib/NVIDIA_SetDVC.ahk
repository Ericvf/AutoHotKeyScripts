; ===============================================================================================================================
; Title .........: NvAPI GUI SetDVC
; AHK Version ...: 1.1.16.05 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: NvAPI GUI SetDVC
; Version .......: v1.00
; Modified ......: 2014.11.24-1857
; Author(s) .....: jNizM
; ===============================================================================================================================
;@Ahk2Exe-SetName NvAPI GUI SetDVC
;@Ahk2Exe-SetDescription NvAPI GUI SetDVC
;@Ahk2Exe-SetVersion v1.00
;@Ahk2Exe-SetCopyright Copyright (c) 2014-2014`, jNizM
;@Ahk2Exe-SetOrigFilename NvAPI_GUI_SetDVC.ahk
; ===============================================================================================================================

; GLOBAL SETTINGS ===============================================================================================================

;#Warn
#NoEnv
#SingleInstance Force
SetBatchLines -1

OnExit, EOF
NVIDIA := new NvAPI()

; GUI ===========================================================================================================================

cnt := 0, arrCur := [], arrDef := []

while (NVIDIA.EnumNvidiaDisplayHandle(cnt) != "*-7")
{
    arrCur.Insert(NVIDIA.GetDVCInfoEx(cnt).currentLevel)
    arrDef.Insert(NVIDIA.GetDVCInfoEx(cnt).defaultLevel)
    ++cnt
}

gbh := 93 + 27 * (cnt - 1)

Gui, Margin, 5, 5
Gui, Font, s16 w800 q4 c76B900, MS Shell Dlg 2
Gui, Add, Text, xm ym w240 0x201, % NVIDIA.GPU_GetFullName()

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, GroupBox, xm y+10 w240 h%gbh%, % "Digital Vibrance Control (DVC)"

Gui, Add, Text, xm+11 ym+60 w60 h22 0x0200, % "Display #1"
Gui, Add, Edit, x+10 yp w80 h22 0x2002 vDVCS1, % arrCur[1]
Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
Gui, Add, Text, x+10 yp w60 h22 0x0200, % "(0 - 100)"

loop % arrCur.MaxIndex() - 1
{
    cur := A_Index + 1
    Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
    Gui, Add, Text, xm+11 y+5 w60 h22 0x0200, % "Display #" cur
    Gui, Add, Edit, x+10 yp w80 h22 0x2002 vDVCS%cur%, % arrCur[cur]
    Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
    Gui, Add, Text, x+10 yp w60 h22 0x0200, % "(0 - 100)"
}

Gui, Add, Button, xm+10 y+10 w60 gDVCSet, % "Set"
Gui, Add, Button, x+10 yp w60 gDVCReset, % "Reset"

Gui, Show, AutoSize
return

; UPDATE ========================================================================================================================

DVCSet:
    Gui, Submit, NoHide
    loop % arrCur.MaxIndex()
        NVIDIA.SetDVCLevelEx(DVCS%A_Index%, A_Index - 1)
return

DVCReset:
    loop % arrDef.MaxIndex()
    {
        NVIDIA.SetDVCLevelEx(arrDef[A_Index], A_Index - 1)
        GuiControl,, DVCS%A_Index%, % arrCur[A_Index]
    }
return

; CLASS =========================================================================================================================

class NvAPI
{
    static hmod
    static DllFile := (A_PtrSize = 8) ? "nvapi64.dll" : "nvapi.dll"
    static NVAPI_MAX_PHYSICAL_GPUS := 64
    static NVAPI_SHORT_STRING_MAX  := 64

    __New()
    {
        if !(NvAPI.hmod)
        {
            if !(NvAPI.hmod := DllCall("kernel32.dll\LoadLibrary", "Str", NvAPI.DllFile, "UPtr"))
                MsgBox % "LoadLibrary Error: " DllCall("kernel32.dll\GetLastError")

            if !(NvStatus := DllCall(DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0150E828, "CDECL UPtr"), "CDECL"))
            {
                NvAPI._EnumNvidiaDisplayHandle              := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x9ABDD40D, "CDECL UPtr")
                NvAPI._EnumPhysicalGPUs                     := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xE5AC921F, "CDECL UPtr")
                NvAPI._GetAssociatedNvidiaDisplayHandle     := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x35C29134, "CDECL UPtr")
                NvAPI._GetAssociatedNvidiaDisplayName       := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x22A78B05, "CDECL UPtr")
                NvAPI._GetDVCInfoEx                         := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0E45002D, "CDECL UPtr")
                NvAPI._GPU_GetFullName                      := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xCEEE8E9F, "CDECL UPtr")
                NvAPI._SetDVCLevelEx                        := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x4A82C2B1, "CDECL UPtr")
                NvAPI._Unload                               := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xD22BDD7E, "CDECL UPtr")
            }
            else
                MsgBox % "Initialize Error: " NvStatus
        }
    }

; ###############################################################################################################################

    EnumNvidiaDisplayHandle(thisEnum := 0)
    {
        if !(NvStatus := DllCall(NvAPI._EnumNvidiaDisplayHandle, "UInt", thisEnum, "UInt*", pNvDispHandle, "CDECL"))
            return pNvDispHandle
        return "*" NvStatus
    }

; ###############################################################################################################################

    EnumPhysicalGPUs()
    {
        VarSetCapacity(nvGPUHandle, 4 * NvAPI.NVAPI_MAX_PHYSICAL_GPUS, 0)
        if !(NvStatus := DllCall(NvAPI._EnumPhysicalGPUs, "Ptr", &nvGPUHandle, "UInt*", pGpuCount, "CDECL"))
        {
            GPUH := []
            loop % pGpuCount
                GPUH[A_Index] := NumGet(nvGPUHandle, 4 * (A_Index - 1), "Int")
            return GPUH
        }
        return "*" NvStatus
    }

; ###############################################################################################################################

    GetAssociatedNvidiaDisplayHandle(thisEnum := 0)
    {
        szDisplayName := NvAPI.GetAssociatedNvidiaDisplayName(thisEnum)
        if !(NvStatus := DllCall(NvAPI._GetAssociatedNvidiaDisplayHandle, "AStr", szDisplayName, "Int*", pNvDispHandle, "CDECL"))
            return pNvDispHandle
        return "*" NvStatus
    }

; ###############################################################################################################################

    GetAssociatedNvidiaDisplayName(thisEnum := 0)
    {
        if (InStr(NvDispHandle := NvAPI.EnumNvidiaDisplayHandle(thisEnum), "*-7"))
            return NvDispHandle
        VarSetCapacity(szDisplayName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(NvAPI._GetAssociatedNvidiaDisplayName, "Ptr", NvDispHandle, "Ptr", &szDisplayName, "CDECL"))
            return StrGet(&szDisplayName, "CP0")
        return "*" NvStatus
    }

; ###############################################################################################################################

    GetDVCInfoEx(thisEnum := 0, outputId := 0)
    {
        static NV_DISPLAY_DVC_INFO_EX := 20
        hNvDisplay := NvAPI.GetAssociatedNvidiaDisplayHandle(thisEnum)
        VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX), NumPut(NV_DISPLAY_DVC_INFO_EX | 0x10000, pDVCInfo, 0, "UInt")
        if !(NvStatus := DllCall(NvAPI._GetDVCInfoEx, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pDVCInfo, "CDECL"))
        {
            DVC := {}
            DVC.version      := NumGet(pDVCInfo,  0, "UInt")
            DVC.currentLevel := NumGet(pDVCInfo,  4, "Int")
            DVC.minLevel     := NumGet(pDVCInfo,  8, "Int")
            DVC.maxLevel     := NumGet(pDVCInfo, 12, "Int")
            DVC.defaultLevel := NumGet(pDVCInfo, 16, "Int")
            return DVC
        }
        return "*" NvStatus
    }

; ###############################################################################################################################

    GPU_GetFullName(hPhysicalGpu := 0)
    {
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs().1
        VarSetCapacity(szName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(NvAPI._GPU_GetFullName, "Ptr", hPhysicalGpu, "Ptr", &szName, "CDECL"))
            return StrGet(&szName, "CP0")
        return "*" NvStatus
    }

; ###############################################################################################################################

    SetDVCLevelEx(currentLevel, thisEnum := 0, outputId := 0)
    {
        static NV_DISPLAY_DVC_INFO_EX := 20
        hNvDisplay := NvAPI.GetAssociatedNvidiaDisplayHandle(thisEnum)
        VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX)
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).version,      pDVCInfo,  0, "UInt")
        , NumPut(currentLevel,                              pDVCInfo,  4, "Int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).minLevel,     pDVCInfo,  8, "Int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).maxLevel,     pDVCInfo, 12, "Int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).defaultLevel, pDVCInfo, 16, "Int")
        return DllCall(NvAPI._SetDVCLevelEx, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pDVCInfo, "CDECL")
    }

; ###############################################################################################################################

    __Delete()
    {
        return DllCall(NvAPI._Unload, "CDECL")
    }

    OnExit()
    {
        DllCall("kernel32.dll\FreeLibrary", "Ptr", NvAPI.hmod)
    }
}

; EXIT ==========================================================================================================================

GuiClose:
EOF:
NVIDIA.OnExit()
ExitApp