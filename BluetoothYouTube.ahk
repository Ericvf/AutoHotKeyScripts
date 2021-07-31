; Bluetooth Headphone buttons :)
Media_Next::MediaToYouTube("l")
Media_Prev::MediaToYouTube("j")

MediaToYouTube(key){
  WinGetTitle, Title, A
  if(InStr(Title, " - YouTube") > 0) {
    Send %key%
  }
}