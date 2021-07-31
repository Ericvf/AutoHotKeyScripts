^!g::
clipback := ClipboardAll
clipboard=
Send ^c
ClipWait, 0
if (clipboard){
   Locale := GetLocale()
   ToolTip, Searching ... (%Locale%)
   FileName = %A_Temp%\SpellingCorrection.ahk.tmp
   UrlDownloadToFile % "https://www.google.com/search?q=" . clipboard . "&hl=" . Locale, %FileName%
   FileRead, contents,  %FileName%
   FileDelete %FileName%
   if (RegExMatch(contents, "(Resultaten voor |Showing results for )<a.*?>(.*?)</a>", match)) {
      clipboard := RegExReplace(match2, "<.+?>" , "")
   }
   Send ^v
   ToolTip,
   Sleep 100
}
clipboard := clipback
return

GetLocale(){
   ; https://autohotkey.com/board/topic/43043-get-current-keyboard-layout/
   ; https://www.autohotkey.com/docs/misc/Languages.htm
   SetFormat, Integer, H
   WinGet, WinID,, A
   ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
   InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
   if (InputLocaleID = 0xF0010413)
      return "nl"
      
   if (InputLocaleID = 0x4090409)
      return "en"
      
   return "en"
}