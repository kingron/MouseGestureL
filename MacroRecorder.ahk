;-----------------------------------
;  Macro Recorder v2.1  By FeiYue
;
;  Description: This script records the mouse
;  and keyboard actions and then plays back.
;
;  F1  -->  Record(Screen) (CoordMode, Mouse, Screen)
;  F2  -->  Record(Window) (CoordMode, Mouse, Window)
;  F3  -->  Stop   Record/Play
;  F4  -->  Play   LogFile
;  F5  -->  Edit   LogFile
;  F6  -->  Pause  Record/Play
;
;  Note:
;  1. press the Ctrl button individually
;     to record the movement of the mouse.
;  2. Shake the mouse on the Pause button,
;     you can pause recording or playback.
;-----------------------------------

#NoEnv
SetBatchLines, -1
Thread, NoTimers
CoordMode, ToolTip
SetTitleMatchMode, 2
DetectHiddenWindows, On
;--------------------------
LogFile:=A_Temp . "\~Record.txt"
UsedKeys:="F1,F2,F3,F4,F5,F6"
Play_Title:=RegExReplace(LogFile,".*\\") " ahk_class AutoHotkey"
;--------------------------
Gui, +AlwaysOnTop -Caption +ToolWindow +E0x08000000 +Hwndgui_id
Gui, Margin, 0, 0
Gui, Font, s12
s:="[F1]Record(Screen),[F2]Record(Window),"
  . "[F3]Stop,[F4]Play,[F5]Edit,[F6] Pause "
For i,v in StrSplit(s, ",")
{
  j:=i=1 ? "":"x+0", j.=InStr(v,"Pause") ? " vPause":""
  Gui, Add, Button, %j% gRun, %v%
}
Gui, Add, Button, x+0 w0 Hidden vMyText
Gui, Show, NA y0, Macro Recorder
OnMessage(0x200,"WM_MOUSEMOVE")
;--------------------------
SetTimer, OnTop, 2000
OnTop:
Gui, +AlwaysOnTop
return

Run:
if IsLabel(k:=RegExReplace(RegExReplace(A_GuiControl,".*]"),"\W"))
  Goto, %k%
return

WM_MOUSEMOVE() {
  static OK_Time
  ListLines, Off
  if (A_Gui=1) and (A_GuiControl="Pause")
    and (t:=A_TickCount)>OK_Time
  {
    OK_Time:=t+500
    Gosub, Pause
  }
}

ShowTip(s:="", pos:="y35", color:="Red|00FFFF") {
  static bak, idx
  if (bak=color "," pos "," s)
    return
  bak:=color "," pos "," s
  SetTimer, ShowTip_ChangeColor, Off
  Gui, ShowTip: Destroy
  if (s="")
    return
  ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
  Gui, ShowTip: +LastFound +AlwaysOnTop +ToolWindow -Caption +E0x08000020
  Gui, ShowTip: Color, FFFFF0
  WinSet, TransColor, FFFFF0 150
  Gui, ShowTip: Margin, 10, 5
  Gui, ShowTip: Font, Q3 s20 bold
  Gui, ShowTip: Add, Text,, %s%
  Gui, ShowTip: Show, NA %pos%, ShowTip
  SetTimer, ShowTip_ChangeColor, 1000
  ShowTip_ChangeColor:
  Gui, ShowTip: +AlwaysOnTop
  r:=StrSplit(SubStr(bak,1,InStr(bak,",")-1),"|")
  Gui, ShowTip: Font, % "Q3 c" r[idx:=Mod(Round(idx),r.length())+1]
  GuiControl, ShowTip: Font, Static1
  return
}


;============ Hotkey =============


F1::
Suspend, Permit
Goto, RecordScreen

F2::
Suspend, Permit
Goto, RecordWindow

RecordScreen:
RecordWindow:
if (Recording or Playing)
  return
Coord:=InStr(A_ThisLabel,"Win") ? "Window":"Screen"
LogArr:=[], oldid:="", Log(), Recording:=1, SetHotkey(1)
ShowTip("Recording")
return


F3::
Stop:
Suspend, Permit
if Recording
{
  if (LogArr.MaxIndex()>0)
  {
    s:="`nLoop, 1`n{`n`nSetTitleMatchMode, 2"
      . "`nCoordMode, Mouse, " Coord "`n"
    For k,v in LogArr
      s.="`n" v "`n"
    s.="`nSleep, 1000`n`n}`n"
    s:=RegExReplace(s,"\R","`n")
    FileDelete, %LogFile%
    FileAppend, %s%, %LogFile%
    s:=""
  }
  SetHotkey(0), Recording:=0, LogArr:=""
}
else if Playing
{
  WinGet, list, List, %Play_Title%
  Loop, % list
    if WinExist("ahk_id " list%A_Index%)!=A_ScriptHwnd
    {
      WinGet, pid, PID
      WinClose,,, 3
      IfWinExist
        Process, Close, %pid%
    }
  SetTimer, CheckPlay, Off
  Playing:=0
}
ShowTip()
Suspend, Off
Pause, Off
GuiControl,, Pause, % "[F6] Pause "
isPaused:=0
return


F4::
Play:
Suspend, Permit
if (Recording or Playing)
  Gosub, Stop
ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe" : A_AhkPath
IfNotExist, %ahk%
{
  MsgBox, 4096, Error, Can't Find %ahk% !
  Exit
}
Run, %ahk% /r "%LogFile%"
SetTimer, CheckPlay, 500
Gosub, CheckPlay
return

CheckPlay:
Check_OK:=0
WinGet, list, List, %Play_Title%
Loop, % list
  if (list%A_Index%!=A_ScriptHwnd)
    Check_OK:=1
if Check_OK
  Playing:=1, ShowTip("Playing")
else if Playing
{
  SetTimer, CheckPlay, Off
  Playing:=0, ShowTip()
}
return


F5::
Edit:
Suspend, Permit
Gosub, Stop
Run, notepad.exe "%LogFile%"
return


F6::
Pause:
Suspend, Permit
if Recording
{
  Suspend
  Pause, % A_IsSuspended ? "On":"Off", 1
  isPaused:=A_IsSuspended, Log()
}
else if Playing
{
  isPaused:=!isPaused
  WinGet, list, List, %Play_Title%
  Loop, %list%
    if WinExist("ahk_id " list%A_Index%)!=A_ScriptHwnd
      PostMessage, 0x111, 65306
}
else return
if isPaused
  GuiControl,, Pause, [F6]<Pause>
else
  GuiControl,, Pause, % "[F6] Pause "
return


;============ Functions =============


SetHotkey(f:=0) {
  ; These keys are already used as hotkeys
  global UsedKeys
  f:=f ? "On":"Off"
  Loop, 254
  {
    k:=GetKeyName(vk:=Format("vk{:X}", A_Index))
    if k not in ,Control,Alt,Shift,%UsedKeys%
      Hotkey, ~*%vk%, LogKey, %f% UseErrorLevel
  }
  For i,k in StrSplit("NumpadEnter|Home|End|PgUp"
    . "|PgDn|Left|Right|Up|Down|Delete|Insert", "|")
  {
    sc:=Format("sc{:03X}", GetKeySC(k))
    if k not in ,Control,Alt,Shift,%UsedKeys%
      Hotkey, ~*%sc%, LogKey, %f% UseErrorLevel
  }
  SetTimer, LogWindow, %f%
  if (f="On")
    Gosub, LogWindow
}

LogKey:
LogKey()
return

LogWindow:
LogWindow()
return

LogKey() {
  Critical
  k:=GetKeyName(vksc:=SubStr(A_ThisHotkey,3))
  k:=StrReplace(k,"Control","Ctrl"), r:=SubStr(k,2)
  if r in Alt,Ctrl,Shift,Win
    LogKey_Control(k)
  else if k in LButton,RButton,MButton
    LogKey_Mouse(k)
  else
  {
    if (k="NumpadLeft" or k="NumpadRight") and !GetKeyState(k,"P")
      return
    k:=StrLen(k)>1 ? "{" k "}" : k~="\w" ? k : "{" vksc "}"
    Log(k,1)
  }
}

LogKey_Control(key) {
  global LogArr, Coord
  k:=InStr(key,"Win") ? key : SubStr(key,2)
  if (k="Ctrl")
  {
    CoordMode, Mouse, %Coord%
    MouseGetPos, X, Y
  }
  Log("{" k " Down}",1)
  Critical, Off
  KeyWait, %key%
  Critical
  Log("{" k " Up}",1)
  if (k="Ctrl")
  {
    i:=LogArr.MaxIndex(), r:=LogArr[i]
    if InStr(r,"{Blind}{Ctrl Down}{Ctrl Up}")
      LogArr[i]:="MouseMove, " X ", " Y
  }
}

LogKey_Mouse(key) {
  global gui_id, LogArr, Coord
  k:=SubStr(key,1,1)
  CoordMode, Mouse, %Coord%
  MouseGetPos, X, Y, id
  if (id=gui_id)
    return
  Log("MouseClick, " k ", " X ", " Y ",,, D")
  CoordMode, Mouse, Screen
  MouseGetPos, X1, Y1
  t1:=A_TickCount
  Critical, Off
  KeyWait, %key%
  Critical
  t2:=A_TickCount
  if (t2-t1<=200)
    X2:=X1, Y2:=Y1
  else
    MouseGetPos, X2, Y2
  i:=LogArr.MaxIndex(), r:=LogArr[i]
  if InStr(r, ",,, D") and Abs(X2-X1)+Abs(Y2-Y1)<5
    LogArr[i]:=SubStr(r,1,-5), Log()
  else
    Log("MouseClick, " k ", " (X+X2-X1) ", " (Y+Y2-Y1) ",,, U")
}

LogWindow() {
  global oldid, LogArr
  static oldtitle
  id:=WinExist("A")
  WinGetTitle, title
  WinGetClass, class
  if (title="" and class="")
    return
  if (id=oldid and title=oldtitle)
    return
  oldid:=id, oldtitle:=title
  title:=SubStr(title,1,50)
  if (!A_IsUnicode)
  {
    GuiControl,, MyText, %title%
    GuiControlGet, s,, MyText
    if (s!=title)
      title:=SubStr(title,1,-1)
  }
  title.=class ? " ahk_class " class : ""
  title:=RegExReplace(Trim(title), "[``%;]", "``$0")
  s:="tt = " title "`nWinWait, %tt%"
    . "`nIfWinNotActive, %tt%,, WinActivate, %tt%"
  i:=LogArr.MaxIndex(), r:=LogArr[i]
  if InStr(r,"tt = ")=1
    LogArr[i]:=s, Log()
  else
    Log(s)
}

Log(str:="", Keyboard:=0) {
  global LogArr
  static LastTime
  t:=A_TickCount, Delay:=(LastTime ? t-LastTime:0), LastTime:=t
  IfEqual, str,, return
  i:=LogArr.MaxIndex(), r:=LogArr[i]
  if (Keyboard and InStr(r,"Send,") and Delay<1000)
  {
    LogArr[i]:=r . str
    return
  }
  if (Delay>200)
    LogArr.Push("Sleep, " (Delay//2))
  LogArr.Push(Keyboard ? "Send, {Blind}" str : str)
}

;============ The End ============

;
