#SingleInstance, Force
#InstallKeybdHook
#InstallMouseHook

Sleep 1000
#IfWinActive, ahk_exe mstsc.exe
    txt := Clipboard
    len := StrLen(txt)
    txt := StrReplace(txt, "`r", "")
    SendRaw % txt
#IfWinActive
ExitApp