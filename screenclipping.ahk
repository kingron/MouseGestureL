if((A_PtrSize=8&&A_IsCompiled="")||!A_IsUnicode){ ;32 bit=4  ;64 bit=8
    SplitPath,A_AhkPath,,dir
    if(!FileExist(correct:=dir "\AutoHotkeyU32.exe")){
	    MsgBox error
	    ExitApp
    }
    Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
    ExitApp
    return
}
#SingleInstance, Force
#^Lbutton::SCW_ScreenClip2Win(clip:=0,email:=0)  ;Win+Control+Left click- no copy to clipboard
#!Lbutton::SCW_ScreenClip2Win(clip:=0,email:=1) ; Wind+Alt+left click =saves images and attach to email (path of jpg on clipboard)
#Lbutton::SCW_ScreenClip2Win(clip:=1,email:=0) ; Win+left click mouse=auto copy to clipboard

#IfWinActive, ScreenClippingWindow ahk_class AutoHotkeyGUI
^c::SCW_Win2Clipboard(0)      ; copy selected win to clipboard  Change to (1) if want border
^s:: SCW_Win2File(0)  ;save selected clipping on desktop as timestamp named .png  ; this was submited by tervon 
Esc:: winclose, A ;contribued by tervon 
Rbutton:: winclose, A ;contributed by tervon 
#IfWinActive
 

;===Description========================================================================
/*
[module/script] ScreenClip2Win
Author:      Learning one
Thanks:      Tic, HotKeyIt

Creates always on top layered windows from screen clippings. Click in upper right corner to close win. Click and drag to move it.
Uses Gdip.ahk by Tic.

#Include ScreenClip2Win.ahk      ; by Learning one
;=== Short documentation ===
SCW_ScreenClip2Win()          ; creates always on top window from screen clipping. Click and drag to select area.
SCW_DestroyAllClipWins()       ; destroys all screen clipping windows.
SCW_Win2Clipboard()            ; copies window to clipboard. By default, removes borders. To keep borders, specify "SCW_Win2Clipboard(1)"
SCW_SetUp(Options="")         ; you can change some default options in Auto-execute part of script. Syntax: "<option>.<value>"
   StartAfter - module will start to consume GUIs for screen clipping windows after specified GUI number. Default: 80
   MaxGuis - maximum number of screen clipping windows. Default: 6
   BorderAColor - Default: ff6666ff (ARGB format)
   BorderBColor - Default: ffffffff (ARGB format)
   DrawCloseButton - on/off draw "Close Button" on screen clipping windows. Default: 0 (off)
   AutoMonitorWM_LBUTTONDOWN - on/off automatic monitoring of WM_LBUTTONDOWN message. Default: 1 (on)
   SelColor - selection color. Default: Yellow
   SelTrans - selection transparency. Default: 80
   
   Example:   SCW_SetUp("MaxGuis.30 StartAfter.50 BorderAColor.ff000000 BorderBColor.ffffff00")
   
  

;=== Avoid OnMessage(0x201, "WM_LBUTTONDOWN") collision example===
Gui, Show, w200 h200
SCW_SetUp("AutoMonitorWM_LBUTTONDOWN.0")   ; turn off auto monitoring WM_LBUTTONDOWN
OnMessage(0x201, "WM_LBUTTONDOWN")   ; manualy monitor WM_LBUTTONDOWN
Return

^Lbutton::SCW_ScreenClip2Win()   ; click & drag
Esc::ExitApp

#Include ScreenClip2Win.ahk      ; by Learning one
WM_LBUTTONDOWN() {
   if SCW_LBUTTONDOWN()   ; LBUTTONDOWN on module's screen clipping windows - isolate - it's module's buissines
   return
   else   ; LBUTTONDOWN on other windows created by script
   MsgBox,,, You clicked on script's window not created by this module,1
}
*/


;===Functions==========================================================================
SCW_Version() {
   return 1.02
}

SCW_DestroyAllClipWins() {
   MaxGuis := SCW_Reg("MaxGuis"), StartAfter := SCW_Reg("StartAfter")
   Loop, %MaxGuis%
   {
      StartAfter++
      Gui %StartAfter%: Destroy
   }
}

SCW_SetUp(Options="") {
   if !(Options = "")
   {
      Loop, Parse, Options, %A_Space%
      {
         Field := A_LoopField
         DotPos := InStr(Field, ".")
         if (DotPos = 0)   
         Continue
         var := SubStr(Field, 1, DotPos-1)
         val := SubStr(Field, DotPos+1)
         if var in StartAfter,MaxGuis,AutoMonitorWM_LBUTTONDOWN,DrawCloseButton,BorderAColor,BorderBColor,SelColor,SelTrans
         %var% := val
      }
   }
   
   SCW_Default(StartAfter,80), SCW_Default(MaxGuis,6)
   SCW_Default(AutoMonitorWM_LBUTTONDOWN,1), SCW_Default(DrawCloseButton,0)
   SCW_Default(BorderAColor,"ff6666ff"), SCW_Default(BorderBColor,"ffffffff")
   SCW_Default(SelColor,"Yellow"), SCW_Default(SelTrans,80)
   
   SCW_Reg("MaxGuis", MaxGuis), SCW_Reg("StartAfter", StartAfter), SCW_Reg("DrawCloseButton", DrawCloseButton)
   SCW_Reg("BorderAColor", BorderAColor), SCW_Reg("BorderBColor", BorderBColor)
   SCW_Reg("SelColor", SelColor), SCW_Reg("SelTrans",SelTrans)
   SCW_Reg("WasSetUp", 1)
   if AutoMonitorWM_LBUTTONDOWN
   OnMessage(0x201, "SCW_LBUTTONDOWN")
}

SCW_ScreenClip2Win(clip=0,email=0) {
   static c
   if !(SCW_Reg("WasSetUp"))
   SCW_SetUp()

   StartAfter := SCW_Reg("StartAfter"), MaxGuis := SCW_Reg("MaxGuis"), SelColor := SCW_Reg("SelColor"), SelTrans := SCW_Reg("SelTrans")
   c++
   if (c > MaxGuis)
   c := 1

   GuiNum := StartAfter + c
   Area := SCW_SelectAreaMod("g" GuiNum " c" SelColor " t" SelTrans)
   StringSplit, v, Area, |
   if (v3 < 10 and v4 < 10)   ; too small area
   return
   
   pToken := Gdip_Startup()
   if pToken =
   {
      MsgBox, 64, GDI+ error, GDI+ failed to start. Please ensure you have GDI+ on your system.
      return
   }
   
   Sleep, 100
   pBitmap := Gdip_BitmapFromScreen(Area)

	if (email=1){
		;**********************Added to automatically save to bmp*********************************
		; File1:=A_ScriptDir . "\capture.BMP" ;path to file to save (make sure uppercase extenstion.  see below for options
		; Gdip_SaveBitmapToFile(pBitmap, File1) ;Exports automatcially to file

		File2:=A_ScriptDir . "\capture.JPG" ;path to file to save (make sure uppercase extenstion.  see below for options
		Gdip_SaveBitmapToFile(pBitmap, File2) ;Exports automatcially to file
		Clipboard:=File2

		;**********************make sure outlook is running so email will be sent*********************************
		Process, Exist, Outlook.exe    ; check to see if Outlook is running. 
		   Outlook_pid=%errorLevel%         ; errorlevel equals the PID if active
		If (Outlook_pid = 0)   { ; 
		run outlook.exe
		WinWait, Microsoft Outlook, ,3
	}
	;~ MsgBox here 1
	;**********************Write email*********************************
	;~ COM_Init()
	olMailItem := 0
	try
		IsObject(MailItem := ComObjActive("Outlook.Application").CreateItem(olMailItem)) ; Get the Outlook application object if Outlook is open
	catch
		MailItem  := ComObjCreate("Outlook.Application").CreateItem(olMailItem) ; Create if Outlook is not open
	;~ MsgBox here 2

	olFormatHTML := 2
	MailItem.BodyFormat := olFormatHTML
	;~ MailItem.TO := (MailTo)
	;~ MailItem.CC :="glines@ti.com"
	;~ TodayDate := A_DDDD . ", " . A_MMM . " " . A_DD . ", " . A_YYYY
	FormatTime, TodayDate , YYYYMMDDHH24MISS, dddd MMMM d, yyyy h:mm:ss tt
	MailItem.Subject :="Screen shot taken : " (TodayDate) ;Subject line of email

	MailItem.HTMLBody := "
<H2 style='BACKGROUND-COLOR: red'><br></H2>
<HTML>Attached you will find the screenshot taken on "(TodayDate)" <br><br>
<span style='color:black'>Please let me know if you have any questions.<br><br><a href='mailto:kingron@163.com'>Kingron Lu</a> <br>
</HTML>"
	; MailItem.Attachments.Add(File1)
	MailItem.Attachments.Add(File2)
	MailItem.Display ;
	Reload
}

;*******************************************************
   SCW_CreateLayeredWinMod(GuiNum,pBitmap,v1,v2, SCW_Reg("DrawCloseButton"))
   Gdip_Shutdown("pToken")
if clip=1
{
 ;********************** added to copy to clipboard by default*********************************
   WinActivate, ScreenClippingWindow ahk_class AutoHotkeyGUI ;activates lat clipped window
   SCW_Win2Clipboard(0)  ;copies to clipboard by default w/o border
;~ MsgBox on clipboard
;*******************************************************
}
}

SCW_SelectAreaMod(Options="") {
   CoordMode, Mouse, Screen
   MouseGetPos, MX, MY
      loop, parse, Options, %A_Space%
   {
      Field := A_LoopField
      FirstChar := SubStr(Field,1,1)
      if FirstChar contains c,t,g,m
      {
         StringTrimLeft, Field, Field, 1
         %FirstChar% := Field
      }
   }
   c := (c = "") ? "Blue" : c, t := (t = "") ? "50" : t, g := (g = "") ? "99" : g
   Gui %g%: Destroy
;   Gui %g%: +AlwaysOnTop -caption +Border +ToolWindow +LastFound
   Gui %g%: +AlwaysOnTop -caption +Border +ToolWindow +LastFound -DPIScale ;provided from rommmcek 10/23/16

   WinSet, Transparent, %t%
   Gui %g%: Color, %c%
   Hotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W*)")
   While, (GetKeyState(Hotkey, "p"))
   {
      Sleep, 10
      MouseGetPos, MXend, MYend
      w := abs(MX - MXend), h := abs(MY - MYend)
      X := (MX < MXend) ? MX : MXend
      Y := (MY < MYend) ? MY : MYend
      Gui %g%: Show, x%X% y%Y% w%w% h%h% NA
   }
   Gui %g%: Destroy
   MouseGetPos, MXend, MYend
   If ( MX > MXend )
   temp := MX, MX := MXend, MXend := temp
   If ( MY > MYend )
   temp := MY, MY := MYend, MYend := temp
   Return MX "|" MY "|" w "|" h
}

SCW_CreateLayeredWinMod(GuiNum,pBitmap,x,y,DrawCloseButton=0) {
   static CloseButton := 16
   BorderAColor := SCW_Reg("BorderAColor"), BorderBColor := SCW_Reg("BorderBColor")
   
   Gui %GuiNum%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs
   Gui %GuiNum%: Show, Na, ScreenClippingWindow
   hwnd := WinExist()

   Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
   hbm := CreateDIBSection(Width+6, Height+6), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
   G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)

   Gdip_DrawImage(G, pBitmap, 3, 3, Width, Height)
   Gdip_DisposeImage(pBitmap)

   pPen1 := Gdip_CreatePen("0x" BorderAColor, 3), pPen2 := Gdip_CreatePen("0x" BorderBColor, 1)
   if DrawCloseButton
   {
      Gdip_DrawRectangle(G, pPen1, 1+Width-CloseButton+3, 1, CloseButton, CloseButton)
      Gdip_DrawRectangle(G, pPen2, 1+Width-CloseButton+3, 1, CloseButton, CloseButton)
   }
   Gdip_DrawRectangle(G, pPen1, 1, 1, Width+3, Height+3)
   Gdip_DrawRectangle(G, pPen2, 1, 1, Width+3, Height+3)
   Gdip_DeletePen(pPen1), Gdip_DeletePen(pPen2)
   
   UpdateLayeredWindow(hwnd, hdc, x-3, y-3, Width+6, Height+6)
   SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
   SCW_Reg("G" GuiNum "#HWND", hwnd)
   SCW_Reg("G" GuiNum "#XClose", Width+6-CloseButton)
   SCW_Reg("G" GuiNum "#YClose", CloseButton)
   Return hwnd
}

SCW_LBUTTONDOWN() {
   MouseGetPos,,, WinUMID
    WinGetTitle, Title, ahk_id %WinUMID%
   if Title = ScreenClippingWindow
   {
      PostMessage, 0xA1, 2,,, ahk_id %WinUMID%
      KeyWait, Lbutton
      CoordMode, mouse, Relative
      MouseGetPos, x,y
     XClose := SCW_Reg("G" A_Gui "#XClose"), YClose := SCW_Reg("G" A_Gui "#YClose")
      if (x > XClose and y < YClose)
      Gui %A_Gui%: Destroy
      return 1   ; confirm that click was on module's screen clipping windows
   }
}

SCW_Reg(variable, value="") {
   static
   if (value = "") {
      yaqxswcdevfr := kxucfp%variable%pqzmdk
      Return yaqxswcdevfr
   }
   Else
   kxucfp%variable%pqzmdk = %value%
}

SCW_Default(ByRef Variable,DefaultValue) {
   if (Variable="")
   Variable := DefaultValue
}

SCW_Win2Clipboard(KeepBorders=0) {
   /*   ;   does not work for layered windows
   ActiveWinID := WinExist("A")
   pBitmap := Gdip_BitmapFromHWND(ActiveWinID)
   Gdip_SetBitmapToClipboard(pBitmap)
   */
   Send, !{PrintScreen} ; Active Win's client area to Clipboard
   if !KeepBorders
   {
      pToken := Gdip_Startup()
      pBitmap := Gdip_CreateBitmapFromClipboard()
      Gdip_GetDimensions(pBitmap, w, h)
      pBitmap2 := SCW_CropImage(pBitmap, 3, 3, w-6, h-6)
      Gdip_SetBitmapToClipboard(pBitmap2)
      Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2)
      Gdip_Shutdown("pToken")
   }
}

SCW_CropImage(pBitmap, x, y, w, h) {
   pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
   Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
   Gdip_DeleteGraphics(G2)
   return pBitmap2
}

#include %A_ScriptDir%\gdip.ahk

;***********Function by Tervon******************* 
SCW_Win2File(KeepBorders=0) {
   Send, !{PrintScreen} ; Active Win's client area to Clipboard
   sleep 50
   if !KeepBorders
   {
      pToken := Gdip_Startup()
      pBitmap := Gdip_CreateBitmapFromClipboard()
      Gdip_GetDimensions(pBitmap, w, h)
      pBitmap2 := SCW_CropImage(pBitmap, 3, 3, w-6, h-6)
      ;~ File2:=A_Desktop . "\" . A_Now . ".PNG" ; tervon  time /path to file to save
      FormatTime, TodayDate , YYYYMMDDHH24MISS, MM_dd_yy @h_mm_ss ;This is Joe's time format
      File2:=A_Desktop . "\" . TodayDate . ".PNG" ;path to file to save
      Gdip_SaveBitmapToFile(pBitmap2, File2) ;Exports automatcially to file
      Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2)
      Gdip_Shutdown("pToken")
   }
}