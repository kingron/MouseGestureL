#SingleInstance Force
;===============================================================================
;
;		MouseGestureL.ahk - Main Script
;														Created by lukewarm
;														Modified by Pyonkichi
;===============================================================================
;-------------------------------------------------------------------------------
; Initialization Process
;-------------------------------------------------------------------------------
MG_Init:
#MaxHotkeysPerInterval 2000
Process, Priority,, High
MG_Icon = %A_ScriptDir%\Components\MouseGestureL.ico
Menu, Tray, Icon, %MG_Icon%, 1
MG_IsEdit  := 0
MG_PluginMenuCount := 0
MG_IsDisableObj := Func("MG_IsDisable")
#Include %A_ScriptDir%\Components\MG_CommonLib.ahk
#Include *i %A_ScriptDir%\Languages\MG_Language.ahk
#Include *i %A_ScriptDir%\Plugins\MG_Plugin.ahk
#Include *i %A_ScriptDir%\Config\MG_Config.ahk
#Include *i %A_ScriptDir%\Config\MG_User.ahk

MG_CheckLanguage()
if (MG_SearchPlugins()) {
	Reload
}
MG_CheckConfigFiles()

;...............................................................................
; Register Menu
if (MG_TraySubmenu) {
	MG_MenuName := "MGMenu"
}
else {
	MG_MenuName := "Tray"
	Menu, StdMenu, Standard
	Menu, Tray, NoStandard
	Menu, Tray, Add, AutoHot&key, :StdMenu
	Menu, Tray, Add,
}
Menu, %MG_MenuName%, Add, %MG_LngMenu001%, MG_ToggleEnable
Menu, %MG_MenuName%, Add, %MG_LngMenu002%, MG_NaviToggleEnable
Menu, %MG_MenuName%, Add,
Menu, %MG_MenuName%, Add, %MG_LngMenu003%, MG_Edit
Menu, %MG_MenuName%, Add, %MG_LngMenu004%, MG_EditUser
if (MG_ShowLogs) {
	Menu, %MG_MenuName%, Add, %MG_LngMenu005%, MG_CopyLogs
}
if (MG_PluginMenuCount)
{
	Loop, %MG_PluginMenuCount% {
		Menu, PluginMenu, Add, % MG_PluginMenu%A_Index%_Name, % MG_PluginMenu%A_Index%_Command
	}
	Menu, PluginMenu, Add,
	Menu, PluginMenu, Add, %MG_LngMenu006%, MG_OpenPluginsFolder
	Menu, %MG_MenuName%, Add, %MG_LngMenu007%, :PluginMenu
}
else
{
	Menu, %MG_MenuName%, Add, %MG_LngMenu006%, MG_OpenPluginsFolder
}
Menu, %MG_MenuName%, Add,
Menu, %MG_MenuName%, Add, %MG_LngMenu008%, MG_ChooseLanguage
Menu, %MG_MenuName%, Add, %MG_LngMenu009%, MG_ShowHelp
Menu, %MG_MenuName%, Add, %MG_LngMenu010%, MG_About
Menu, %MG_MenuName%, Add,
Menu, %MG_MenuName%, Add, %MG_LngMenu011%, MG_Reload
Menu, %MG_MenuName%, Add, %MG_LngMenu012%, MG_Exit
if (MG_TraySubmenu)
{
	if (MG_MenuParent) {
		Menu, %MG_MenuParent%, Add, %MG_LngMenu013%, :MGMenu
	}
	else if (A_ScriptName = "MouseGestureL.ahk") {
		Menu, Tray, NoStandard
		Menu, Tray, Add, %MG_LngMenu013%, :MGMenu
		Menu, Tray, Add,
		Menu, Tray, Standard
	}
}
else {
	Menu, Tray, Default, %MG_LngMenu003%
}
;...............................................................................
; Initialize global variables
MG_ScreenDPI	:= A_ScreenDPI
MG_TriggerCount	= 0
MG_Active		= 0
MG_Executed		= 0
MG_TimedOut		= 0
MG_LastTime		= 0
MG_ORange		= 0.3926990817
MG_ORange1		= 0
MG_ORange2		= 0.2617993878
MG_ORange3		= 0.3926990817
MG_ORange4		= 0.5235987756
MG_ORange5		= 0.7854
MG_NaviPrst		= 0
MG_TrailDrawing	= 0
MG_hPrevActive	= 0
MG_BtnNames		:= MG_Triggers . "_" . MG_SubTriggers
if (MG_NaviInterval <= 0) {
	MG_NaviInterval = 10
}
if (MG_TrailInterval <= 0) {
	MG_TrailInterval = 10
}
;...............................................................................
; Initialize Hints and Trail
GoSub, MG_Enable

if (MG_UseExNavi==4) {
	MG_LoadIniFile()
}
if (MG_UseNavi) {
	MG_NaviEnabled := 1
	Menu, %MG_MenuName%, Check, %MG_LngMenu002%
	if (MG_UseExNavi) {
		MG_CreateExNavi()
	}
}
if (MG_ShowTrail) {
	MG_InitTrail()
}
MG_InitLog()
MG_SetWinEventHook()
MG_DmyObj := Object("base", Object("__Delete", "MG_EndOperation"))
SetTimer, MG_CancelTimer, 1000

;...............................................................................
; End of Initialization Process
if (A_ThisLabel = "MG_Init") {
	return
}
else {
	Goto,MG_End
}

;-------------------------------------------------------------------------------
; Cancel Mode Timer
; * It's for in case of failed in catching the button release events
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CancelTimer:
	MG_CancelMode()
return
MG_CancelMode()
{
	global
	; Check Unpressed Mouse Buttons
	if (MG_TmReleaseTrigger > 0) {
		Loop, Parse, MG_CurTriggers, _
		{
			local szCheckSub := "MG_" .  A_LoopField . "_Check"
			if (IsLabel(szCheckSub)) {
				GoSub, %szCheckSub%
			}
		}
	}
	; Hide Hints and Trail
	if ((!MG_Active && (A_TickCount>(MG_LastTime+MG_DGInterval+MG_WaitNext)))
	||	(MG_Active && MG_TimedOut))
	{
		MG_StopNavi(0)
		MG_StopTrail()
	}
}



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Menu Commands
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Toggle Gesture Enabled and Disabled
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_ToggleEnable:
	if(MG_Enabled){
		Gosub,MG_Disable
		TrayTip, MouseGestureL, %MG_LngTooltip002%
	}else{
		GoSub,MG_Enable
		TrayTip, MouseGestureL, %MG_LngTooltip001%
	}
	SetTimer, MG_HideTrayTip, -1000
return

;-------------------------------------------------------------------------------
; Enable Gesture
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Enable:
	MG_Enabled=1
	Loop,Parse,MG_Triggers,_
		GoSub,MG_%A_LoopField%_Enable
	Menu,%MG_MenuName%,Check,%MG_LngMenu001%
	Menu, Tray, Icon, %MG_Icon%, 1
	if (MG_ShowTrail && MG_DrawTrailWnd) {
		Gui, MGW_Trail:Show, NA
	}
return

;-------------------------------------------------------------------------------
; Disable Gesture
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Disable:
	if(MG_Active){
		SetTimer,MG_Disable,-500
	}else if(MG_Enabled){
		MG_Enabled=0
		Loop,Parse,MG_Triggers,_
			GoSub,MG_%A_LoopField%_Disable
		Menu,%MG_MenuName%,Uncheck,%MG_LngMenu001%
		Menu, Tray, Icon, %A_WinDir%\system32\shell32.dll,110
		if (MG_ShowTrail && MG_DrawTrailWnd) {
			Gui, MGW_Trail:Hide
		}
	}
return

;-------------------------------------------------------------------------------
; Edit Gesture Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Edit:
	MG_Edit()
return

;-------------------------------------------------------------------------------
; Edit User Extension Script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_EditUser:
	MG_EditUser()
return
MG_EditUser()
{
	global
	if(!FileExist(A_ScriptDir . "\Config\MG_User.ahk"))
	{
		local szContents
		szContents=
		(LTrim
		%MG_LngOthers001%
		;----- %MG_LngOthers002%	------------------------------------------------
		if (!MG_IsEdit) {
		; %MG_LngOthers004%





		} else {
		; %MG_LngOthers005%





		}
		; %MG_LngOthers006%






		;-------------------------------------------------------------------------------
		Goto, MG_User_End

		;----- %MG_LngOthers003%	------------------------------------------------










		;-------------------------------------------------------------------------------
		MG_User_End:

		)
		FileAppend, %szContents%, %A_ScriptDir%\Config\MG_User.ahk, UTF-8
	}
	local szEditor
	if (MG_ScriptEditor != "") {
		szEditor := """" . MG_ScriptEditor . """"
	}
	else {
		szEditor := "notepad"
	}
	MG_RunAsUser(szEditor . " " . A_ScriptDir . "\Config\MG_User.ahk")
}

;-------------------------------------------------------------------------------
; Open Plugins Folder
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_OpenPluginsFolder:
	Run, %A_ScriptDir%\Plugins
return

;-------------------------------------------------------------------------------
; Show Choose Language Dialog Box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ChooseLanguage:
	MG_CheckLanguage(1)
return

;-------------------------------------------------------------------------------
; Show Help Document
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ShowHelp:
	MG_ShowHelp()
return

;-------------------------------------------------------------------------------
; Show About Dialog Box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_About:
	MG_ShowAboutDlg()
return
MG_ShowAboutDlg()
{
	global
	Gui, MGW_About:New
	Gui, MGW_About:-MaximizeBox -MinimizeBox +LastFound
	Gui, MGW_About:Margin, , 12
	Gui, MGW_About:Add, Picture, w48 h-1, %MG_Icon%
	Gui, MGW_About:Font, S12
	Gui, MGW_About:Add, Text, x+10 yp+4 vTAppName Section, MouseGestureL.ahk Version %MG_Version%
	Gui, MGW_About:Font
	Gui, MGW_About:Add, Text, xs+8 y+6, [ AutoHotkey Version %A_AhkVersion% ]
	Gui, MGW_About:Add, Text, xs+8 y+10, Copyright (C) 2007-2008 lukewarm
	Gui, MGW_About:Add, Text, xs+8 y+4,  Copyright (C) 2011-2020 Pyonkichi
	Gui, MGW_About:Font, S16 cBlue w1000, Wingdings 3
	Gui, MGW_About:Add, Text, xs+8 y+6 gMGW_AboutWebsite, % Chr(0xC7)
	Gui, MGW_About:Font
	Gui, MGW_About:Font, Underline cBlue
	Gui, MGW_About:Add, Text, x+1 yp+8 vAboutGoWebsite gMGW_AboutWebsite, HomePage
	Gui, MGW_About:Font
	Gui, MGW_About:Font, S12 cBlue, Wingdings
	Gui, MGW_About:Add, Text, x+15 yp-2 gMGW_AboutContact, % Chr(0x2A)
	Gui, MGW_About:Font
	Gui, MGW_About:Font, Underline cBlue
	Gui, MGW_About:Add, Text, x+1 yp+2 vAboutGoForum gMGW_AboutContact, Contact
	Gui, MGW_About:Font

	local Bx, Bw:=80
	GuiControlGet, rcCtrl, MGW_About:Pos, TAppName
	Bx := rcCtrlX + rcCtrlW - Bw
	Gui, MGW_About:Add, Button, x%Bx% y+16 w%Bw% Default gMGW_AboutGuiClose, OK
	Gui, MGW_About:Show, Autosize
	return

 MGW_AboutWebsite:
 MGW_AboutContact:
	local home := "https://hp.vector.co.jp/authors/VA018351/" (MG_Language="Japanese" ? "" : "en/") "mglahk.html"
		, contact := "https://www.autohotkey.com/boards/viewtopic.php?f=6&t=31859"
	Run, % (A_ThisLabel="MGW_AboutWebsite") ? home : contact

 MGW_AboutGuiClose:
 MGW_AboutGuiEscape:
	Gui, MGW_About:Destroy
	return
}

;-------------------------------------------------------------------------------
; Reload Gesture Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Reload:
	MG_Reload()
return

;-------------------------------------------------------------------------------
; Exit Application
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Exit:
	ExitApp



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Recognition
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Get cursor position and target information
; カーソル位置・ターゲットの情報を取得
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetMousePosInfo()
{
	global
	MG_TickCount:=A_TickCount
	CoordMode,Mouse,Screen
	MouseGetPos, MG_X, MG_Y, MG_HWND, MG_HCTL, 3
	SendMessage,0x84,0,% MG_Y<<16|MG_X,,ahk_id %MG_HCTL%
	if (ErrorLevel == 4294967295) {
		MouseGetPos,,,,MG_HCTL, 2
	}
	MG_Cursor := MG_GetCursor()
	if (MG_ActiveAsTarget) {
		WinGet, MG_HWND, ID, A
		MG_HCTL := MG_GetFocus()
	}
	IfWinExist,ahk_id %MG_HWND%,,,,{
		WinGetClass, MG_WClass
		WinGet, MG_PID, PID
		WinGet, MG_Exe, ProcessName
		WinGetTitle, MG_Title
	}
	WinGetClass, MG_CClass, ahk_id %MG_HCTL%
	if (MG_CClass = "Button") {
		MG_CorrectDlgCtrlHandle()
	}
}

;-------------------------------------------------------------------------------
; Correct target control handle in a dialog box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CorrectDlgCtrlHandle()
{
	global MG_X, MG_Y, MG_HCTL, MG_WClass, MG_ActiveAsTarget
	if (MG_WClass!="#32770" || !MG_IsNewOS() || MG_ActiveAsTarget) {
		return
	}
	rc := DllCall("GlobalAlloc", "UInt",0x40, "UInt",16, "Ptr")
	hParent := DllCall("GetParent", "Ptr",MG_HCTL)
	hCtrl := MG_HCTL
	while (hCtrl)
	{
		hCtrl := DllCall("FindWindowEx", "Ptr",hParent, "Ptr",hCtrl, "Ptr",0, "Ptr",0, "Ptr")
		if (!hCtrl) {
			break
		}
		DllCall("GetWindowRect", "Ptr",hCtrl, "Ptr",rc)
		if (DllCall("PtInRect", "Ptr",rc, "Int64",MG_Y<<32|MG_X, "Ptr"))
		{
			WinGet, dwStyle, Style, ahk_id %hCtrl%
			if (dwStyle & 0x10000000) {
				MG_HCTL := hCtrl
			}
		}
	}
	WinGetClass, MG_CClass, ahk_id %MG_HCTL%
	DllCall("GlobalFree", "Ptr",rc)
}

;-------------------------------------------------------------------------------
; Compare Strings
;	str1	: First string to be compared. 
;	str2	: Second string to be compared. 
;	method	: Matching rule
;			:	1 = Match Exact Word
;			:	2 = Match Partial Word
;			:	3 = Match Prefix
;			:	4 = Match Suffix
;			:	5 = Use Regular Expression
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StrComp(str1, str2, method=1)
{
	if (method == 2) {
		return (Instr(str1, str2) != 0)
	}
	else if (method == 3) {
		return (Instr(str1, str2) == 1)
	}
	else if (method == 4) {
		start := StrLen(str1) - StrLen(str2) + 1
		return (Instr(str1, str2, false, start) == start)
	}
	else if (method == 5) {
		return (RegExMatch(str1, str2) != 0)
	}
	return (str1 = str2)
}

;-------------------------------------------------------------------------------
; Process trigger-down actions
; トリガー押し下げの報告を受け付け
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_TriggerDown(name)
{
	global
	Critical
	if(!InStr(MG_CurTriggers,name . "_"))
	{
		MG_TriggerCount++
		MG_UnpressCnt%name% := 0
		MG_CurTriggers=%MG_CurTriggers%%name%_
		if (MG_Active && MG_TimedOut)
		{
			GoSub,MG_%name%_Down
		}
		else if (MG_TriggerCount==1)
		{
			; Begin to process gesture at first trigger-down
			; 最初のトリガーの場合、ジェスチャー処理を実行
			if (A_TickCount>(MG_LastTime+MG_DGInterval+MG_WaitNext))
			{
				MG_Gesture = %name%_
				MG_1stTrigger := MG_Gesture
			}
			else
			{
				MG_Gesture = %MG_Gesture%%name%_
			}
			MG_GetMousePosInfo()
			MG_NowX:=MG_PreX:=MG_TX:=MG_TL:=MG_TR:=MG_X
			MG_NowY:=MG_PreY:=MG_TY:=MG_TT:=MG_TB:=MG_Y
			MG_PrevTime	   := A_TickCount
			MG_PrevGesture := ""
			MG_NaviPrstStr := ""
			if (MG_IsDisableObj.()) {
				GoSub,MG_%name%_Down
			}
			else {
				MG_StartNavi()
				MG_StartTrail()
				MG_Aborted:=0
				MG_Check()
				if (MG_Aborted) {
					MG_StopNavi(0)
					MG_StopTrail()
					GoSub,MG_%name%_Down
				} else {
					MG_Recognition(1)
				}
			}
		}
		else
		{
			; Otherwise execute gesture
			; それ以外の場合、ジェスチャーの発動判定
			MG_Recognition()
			MG_Gesture=%MG_Gesture%%name%_
			MG_Check()
			MG_PreX:=MG_NowX, MG_PreY:=MG_NowY, MG_PrevTime:=A_TickCount
		}
	}
}

;-------------------------------------------------------------------------------
; Process trigger-up actions
; トリガー押し上げの報告を受け付け
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_TriggerUp(name)
{
	local px, py
	Critical
	if (!RegExMatch(MG_CurTriggers,"(?<=_|^)" . name . "_")) {
		return
	}
	if (!MG_Aborted) {
		MG_Recognition()
	}
	MG_TriggerCount	:= (MG_TriggerCount>0) ? (MG_TriggerCount-1) : 0
	MG_CurTriggers	:= RegExReplace(MG_CurTriggers,"(?<=_|^)" . name . "_")
	if(!MG_Active || MG_TimedOut)
	{
		GoSub, MG_%name%_Up
	}
	else
	{
		MG_Gesture = %MG_Gesture%_
		if (!MG_Aborted) {
			MG_Check()
		}
		if (MG_TriggerCount < 1)
		{
			if (MG_NaviPrstStr)
			{
				MG_NaviPrst := 1
				SetTimer, MG_NaviPersistTimer, %MG_NaviPersist%
			}
			MG_StopNavi(0)
			MG_StopTrail()
			if ((!MG_Executed)
			&&	(!MG_DisableDefMB  || (name!="MB"))
			&&	(!MG_DisableDefX1B || (name!="X1B"))
			&&	(!MG_DisableDefX2B || (name!="X2B"))
			&&	(!MG_PrvntCtxtMenu || (MG_Gesture==name "__")))
			{
				; Emulate trigger if gesture is not executed
				; ジェスチャー未発動の場合、トリガー操作をエミュレート
				CoordMode,Mouse,Screen
				SetMouseDelay,-1
				BlockInput,On
				MouseGetPos,px,py
				MouseMove,%MG_X%,%MG_Y%,0
				GoSub,MG_%name%_Down
				MouseMove,%px%,%py%,0
				Sleep,1
				GoSub,MG_%name%_Up
				BlockInput,Off
			}
		}
	}
}

;-------------------------------------------------------------------------------
; Process button-press actions
; ボタン操作の報告を受け付け
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_ButtonPress(name)
{
	global
	if (MG_Active && MG_TimedOut)
	{
		Gosub,MG_%name%_Press
	}
	else
	{
		if(!MG_Active && (A_TickCount>(MG_LastTime+MG_DGInterval+MG_WaitNext)))
		{
			MG_GetMousePosInfo()
			if (MG_IsDisableObj.()) {
				Gosub,MG_%name%_Press
			}
			else {
				MG_Gesture=%name%_
				MG_Aborted:=0,MG_WaitNext:=0,MG_Executed:=0,MG_TimedOut:=0
				MG_NowX:=MG_PreX:=MG_X, MG_NowY:=MG_PreY:=MG_Y,MG_PrevTime:=A_TickCount
				if(!MG_Check()){
					Gosub,MG_%name%_Press
				}
			}
		}
		else
		{
			MG_Recognition()
			MG_Gesture=%MG_Gesture%%name%_
			if(!MG_Check()){
				Gosub,MG_%name%_Press
			}
			MG_PreX:=MG_NowX, MG_PreY:=MG_NowY, MG_PrevTime:=A_TickCount
		}
	}
}

;-------------------------------------------------------------------------------
; Check gesture updates
; ジェスチャーが更新される度に実行
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Check(g="")
{
	local ges,ex,tmp
	MG_LastTime:=A_TickCount
	if (StrLen(MG_Gesture)>MG_MaxLength)
	{
		; Gesture is too long
		; ジェスチャーの長さが定義されている最大長を超えた
		MG_Gesture=%MG_CurTriggers%
	}
	else
	{
		if (g) {
			ges:=g
		} else {
			ges:=MG_Gesture
		}
		if (IsLabel("MG_Gesture_" . ges))
		{
			if (MG_NaviPersist > 0) {
				MG_NaviPrstStr := MG_Gesture
			}
			IfWinExist,ahk_id %MG_HWND%,,,,{
			}
			ex := MG_Executed++
			(MG_ShowLogs && !g) ? MG_UpdateLogs(ges) :
			Gosub,MG_Gesture_%ges%
			if (ex != MG_Executed) {
				if (!g) {
					MG_Gesture := MG_CurTriggers
				}
				return 1
			}
			else {
				return (MG_WaitNext != 0)
			}
		}
	}
	MG_ShowLogs ? MG_UpdateLogs() :
	return 0
}

;-------------------------------------------------------------------------------
; Recognition function
; 認識処理の本体
;	fInit : 1 = Initialize recognition process
;			0 = Recognition only
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Recognition(fInit=0)
{
	global
	static px, py, plx, ply, d1, d2, orange, next_timeout
	local powx, powy
	;...........................................................................
	; Initialization of recognition process
	if (fInit)
	{
		MG_Active:=1, MG_Aborted:=0, MG_WaitNext:=0, MG_Executed:=0, MG_TimedOut:=0
		px:=plx:=MG_X, py:=ply:=MG_Y, d1:="", d2:=""
		orange:=MG_ORange%MG_ORangeDefault%, next_timeout:=A_TickCount+MG_Timeout
		MG_ScreenDPI := MG_GetDpiFromPoint(MG_X, MG_Y)
		Loop,Parse,MG_SubTriggers,_
		{
			GoSub,MG_%A_LoopField%_Enable
		}
		SetTimer, MG_RecogTimer, %MG_Interval%
	}
	;...........................................................................
	; Recognition process
	CoordMode,Mouse,Screen
	MouseGetPos,MG_NowX,MG_NowY
	if (MG_TriggerCount < 1)
	{
		; Release all triggers : 全てのトリガが離された
		SetTimer, MG_RecogTimer, Off
		MG_Active:=0,MG_TriggerCount:=0,MG_CurTriggers:=""
		Loop, Parse, MG_SubTriggers, _
		{
			GoSub,MG_%A_LoopField%_Disable
		}
		MG_StopNavi(0)
		MG_StopTrail()
	}
	else if ((MG_X-MG_NowX)**2+(MG_Y-MG_NowY)**2 < MG_TimeoutThreshold**2)
	{
		; Tiny movement : 微小な動き
		next_timeout:=A_TickCount+MG_Timeout
	}
	else if (!MG_TimedOut
	&&		 (MG_Aborted || ((A_TickCount>next_timeout) && (MG_Executed==0))))
	{
		; Time out when moving : 移動中にタイムアウト
		MG_StopNavi(0)
		MG_StopTrail()
		Critical
		SetMouseDelay,-1
		MG_TimedOut=1
		BlockInput,On
		MouseMove,%MG_X%,%MG_Y%,0
		Loop,Parse,MG_CurTriggers,_
		{
			if (A_LoopField) {
				GoSub,MG_%A_LoopField%_Down
			}
		}
		MouseMove,%MG_NowX%,%MG_NowY%,0
		BlockInput,Off
		Critical,Off
	}
	else if(!MG_TimedOut && ((powx:=(MG_NowX-px)**2)+(powy:=(MG_NowY-py)**2) >= MG_Threshold**2))
	{
		; Check Normal Movement : 移動検出
		if (MG_8Dir) {
			if (orange > Abs(0.7853981634-Abs(ATan((MG_NowX-px)/(MG_NowY-py))))) {
				d2 := (MG_NowX>px) ? ((MG_NowY>py) ? 3 : 9) : ((MG_NowY>py) ? 1 : 7)
			} else {
				d2 := (powx>powy) ? ((MG_NowX>px) ? 6 : 4) : ((MG_NowY>py) ? 2 : 8)
			}
		}
		else {
			d2:= (powx>powy) ? ((MG_NowX>px) ? "R":"L") : ((MG_NowY>py) ? "D":"U")
		}
		; Judge Normal Movement
		local fChanged := 0
		if (d1 != d2) {
			fChanged := 1
		}
		else {
			; Check Long Movement
			if (MG_8Dir) {
				fChanged := ((MG_NowX-plx)**2+(MG_NowY-ply)**2 >= MG_LongThreshold**2)
			} else if (powx > powy) {
				fChanged := (Abs(MG_NowX-plx) >= MG_LongThresholdX)
			} else {
				fChanged := (Abs(MG_NowY-ply) >= MG_LongThresholdY)
			}
		}
		; Judge Overall Movement
		if (fChanged)
		{
			MG_Gesture=%MG_Gesture%%d2%
			if (MG_8Dir)
			{
				if (d2 & 1) {
					orange := MG_ORange%MG_ORangeB%
				} else {
					orange := MG_ORange%MG_ORangeA%
				}
			}
			plx:=px, ply:=py
			d1 := MG_Check() ? "" : d2
			;MG_PreX:=MG_NowX, MG_PreY:=MG_NowY, MG_PrevTime:=A_TickCount
		}
		MouseGetPos,px,py
		next_timeout:=A_TickCount+MG_Timeout
		MG_PreX:=px, MG_PreY:=py, MG_PrevTime:=A_TickCount
	}
}

MG_RecogTimer:
	MG_Recognition()
return

;-------------------------------------------------------------------------------
; Emulate the mouse button events
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SendButton(name, btn, mode="")
{
	global
	SetMouseDelay,-1
	if (MG_%name%_Enabled) {
		GoSub,MG_%name%_Disable
		MG_%name%_Disabled := 1
	} else {
		MG_%name%_Disabled := 0
	}
	Send, % "{Blind}{" . btn . (mode ? " "mode : "") . "}"
	if (MG_%name%_Disabled) {
		GoSub,MG_%name%_Enable
	}
}

;-------------------------------------------------------------------------------
; Check unexpected mouse button holding
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckButton(name, btn)
{
	global
	if (MG_Active && MG_TimedOut) {
		MG_UnpressCnt%name%++
		if (MG_UnpressCnt%name% > MG_TmReleaseTrigger) {
			MG_UnpressCnt%name% := 0
			MG_TriggerUp(name)
		}
	} else {
		MG_UnpressCnt%name% := 0
	}
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Script Control Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Abort the gesture
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Abort()
{
	global
	MG_Aborted := 1
}

;-------------------------------------------------------------------------------
; Abort the recognition
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Cancel()
{
	MG_Wait(0)
}

;-------------------------------------------------------------------------------
; Wait for the next gesture
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Wait(ms=0)
{
	global
	MG_Executed--
	MG_WaitNext := ms
}

;-------------------------------------------------------------------------------
; Delayed Execution
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Timer(ms=0)
{
	global
	if(MG_TimerMode==-1){
		MG_TimerMode=0
		return 0
	}
	MG_TimerGesture:=MG_Gesture
	if(ms){
		if(ms>0){
			MG_TimerMode=1
			SetTimer,MG_TimerExecute,% -ms
		}else{
			MG_TimerMode=2
			MG_Executed--
			MG_WaitNext:=-ms
			SetTimer,MG_TimerExecute,% ms
		}
	}else{
		MG_TimerMode=3
		SetTimer,MG_TimerExecute,% -MG_Interval
	}
	return 1
}
MG_TimerExecute:
	if((MG_TimerMode==3) && MG_Active){
		SetTimer,MG_TimerExecute,% -MG_Interval
		return
	}
	if((MG_TimerMode!=2) || (MG_Gesture=MG_TimerGesture)){
		MG_TimerMode=-1
		MG_Check(MG_TimerGesture)
	}else{
		MG_TimerMode=0
	}
return

;-------------------------------------------------------------------------------
; Execute the action when gesture recognition is finished
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Defer()
{
	return !MG_Timer()
}

;-------------------------------------------------------------------------------
; Repeatedly Execution
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_While(ms=20)
{
	global
	if(!MG_WhileState){
		MG_WhileGesture:=MG_Gesture
		MG_WhileTrrigers:=MG_Triggers
		MG_WhileStartTime:=A_TickCount
		if(ms<1){
			MG_WhileInterval:=MG_Interval
			MG_WhileState:=2
		}else{
			MG_WhileInterval:=ms
			MG_WhileState:=1
		}
	}else if(MG_WhileState=-1){
		MG_WhileState:=0
		return 0
	}
	SetTimer,MG_WhileExecute,% -MG_WhileInterval
	return 1
}
MG_WhileExecute:
	if(MG_Active && InStr(MG_Triggers,MG_WhileTrrigers)=1){
		SetTimer,MG_WhileExecute,% -MG_WhileInterval
		if(MG_WhileState=1){
			MG_Check(MG_WhileGesture)
		}
		return
	}else{
		MG_WhileState:=-1
		MG_Check(MG_WhileGesture)
	}
return

;-------------------------------------------------------------------------------
; Execute the action when a button is released
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Hold()
{
	global
	if(MG_HoldState){
		MG_HoldTrrigers=
		return A_TickCount-MG_HoldStart
	}else if(!MG_HoldTrrigers){
		MG_HoldGesture:=MG_Gesture
		MG_HoldTrrigers:=MG_Triggers
		MG_HoldStart:=A_TickCount
		SetTimer,MG_HoldExecute,% -MG_Interval
	}
}
MG_HoldExecute:
	if(MG_Active && InStr(MG_Triggers,MG_HoldTrrigers)=1){
		SetTimer,MG_HoldExecute,% -MG_Interval
	}else{
		MG_HoldState:=1
		MG_Check(MG_HoldGesture)
		MG_HoldState:=0
	}
return

;-------------------------------------------------------------------------------
; Count the calling times
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Counter(name="",count=2)
{
	global
	if(!name){
		name:=MG_Gesture
	}
	if(!MG_Counter_%name%){
		MG_Counter_%name%:=0
	}
	if(count<-1){
		return Mod(MG_Counter_%name%,-count)
	}else if(count=-1){
		return MG_Counter_%name%
	}else if(count=1){
		MG_Counter_%name%:=0
		return 0
	}else if(count=0){
		MG_Counter_%name%++
		return MG_Counter_%name%
	}else{
		MG_Counter_%name%++
		return Mod(MG_Counter_%name%,count)
	}
}

;-------------------------------------------------------------------------------
; Set active window as target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetActiveAsTarget()
{
	global
	WinGet, MG_HWND, ID, A
	IfWinExist, ahk_id %MG_HWND%,,,,{
		WinGetClass, MG_WClass
		WinGet, MG_PID, PID
		WinGet, MG_Exe, ProcessName
		WinGetTitle, MG_Title
	}
	if (MG_HCTL := MG_GetFocus()) {
		WinGetClass, MG_CClass, ahk_id %MG_HCTL%
	}
}



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Retrieving Information of the Target
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Get the handle of control which has focus
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_GetFocus()
{
	size := (4*2 + A_PtrSize*6 + 4*4)
	VarSetCapacity(tmp, size)
	NumPut(size, tmp, 0)
	pos := (4*2 + A_PtrSize)
	return DllCall("GetGUIThreadInfo", "UInt",0, "Str",tmp, "UInt") ? NumGet(tmp, pos) : 0
}

;-------------------------------------------------------------------------------
; Get the specified information of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Win(mode){
	local n
	WinGet,n,%mode%,ahk_id %MG_HWND%
	return n
}

;-------------------------------------------------------------------------------
; Get the X-coordinate of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinX(hwnd=0){
	global MG_HWND
	WinGetPos,X,,,,ahk_id %MG_HWND%
	return X
}

;-------------------------------------------------------------------------------
; Get the Y-coordinate of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinY(hwnd=0){
	global MG_HWND
	WinGetPos,,Y,,,ahk_id %MG_HWND%
	return Y
}

;-------------------------------------------------------------------------------
; Get the width of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinW(hwnd=0){
	global MG_HWND
	WinGetPos,,,W,,ahk_id %MG_HWND%
	return W
}

;-------------------------------------------------------------------------------
; Get the height of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinH(hwnd=0){
	global MG_HWND
	WinGetPos,,,,H,ahk_id %MG_HWND%
	return H
}

;-------------------------------------------------------------------------------
; Get the X-coordinate of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlX(){
	global MG_HCTL
	ControlGetPos,X,,,,,ahk_id %MG_HCTL%
	return X
}

;-------------------------------------------------------------------------------
; Get the Y-coordinate of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlY(){
	global MG_HCTL
	ControlGetPos,,Y,,,,ahk_id %MG_HCTL%
	return Y
}

;-------------------------------------------------------------------------------
; Get the width of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlW(){
	global MG_HCTL
	ControlGetPos,,,W,,,ahk_id %MG_HCTL%
	return W
}

;-------------------------------------------------------------------------------
; Get the height of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlH(){
	global MG_HCTL
	ControlGetPos,,,,H,,ahk_id %MG_HCTL%
	return H
}

;-------------------------------------------------------------------------------
; Hittest the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_HitTest(c=0)
{
	global
	if(c){
		SendMessage,0x84,0,% MG_Y<<16|MG_X,,ahk_id %MG_HCTL%
	}else{
		SendMessage,0x84,0,% MG_Y<<16|MG_X,,ahk_id %MG_HWND%
	}
	return (ErrorLevel<8)
			? ((ErrorLevel<4)
				? ((ErrorLevel<2)
					? (ErrorLevel=0 ? "Nowhere" : (c ? "Client" : MG_HitTest(1)))
					: (ErrorLevel=2 ? "Caption" : "SysMenu"))
				: ((ErrorLevel<6)
					? (ErrorLevel=4 ? "SizeBox" : "Menu")
					: (ErrorLevel=6 ? "HScroll" : "VScroll")))
			: ((ErrorLevel<10)
				? ((ErrorLevel=8) ? "MinButton" : "MaxButton")
				: ((ErrorLevel<18) ? "SizeBorder" : (ErrorLevel= 18 ? "Border" : (ErrorLevel=20 ? "CloseButton" : "HelpButton"))))
}

;-------------------------------------------------------------------------------
; Hittest the target ListView
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_LvHitTest()
{
	global MG_PID, MG_CClass, MG_HCTL, MG_X, MG_Y
	if(MG_CClass="SysListView32" || MG_CClass="TListView")
	{
		pt := DllCall("GlobalAlloc", "UInt",0x40, "UInt",8, "Ptr")
		NumPut(MG_X, pt+0, 0, "Int")
		NumPut(MG_Y, pt+0, 4, "Int")
		DllCall("ScreenToClient", "Ptr",MG_HCTL, "Ptr",pt)
		hp := DllCall("OpenProcess", "UInt",0x001F0FFF, "UInt",0, "UInt",MG_PID, "Ptr")
		size := 8 + A_PtrSize*3
		pi := DllCall("VirtualAllocEx", "Ptr",hp, "Ptr",0, "UInt",size, "UInt",0x1000, "UInt",0x4, "Ptr")
		DllCall("WriteProcessMemory", "Ptr",hp, "Ptr",pi, "Ptr",pt, "Int",8, "Ptr",0)
		SendMessage, 0x1012, 0, %pi%,, ahk_id %MG_HCTL%
		DllCall("ReadProcessMemory", "Ptr",hp, "Ptr",pi+8, "PtrP",flag, "UInt",A_PtrSize, "Ptr",0)
		DllCall("VirtualFreeEx", "Ptr",hp, "Ptr",pi, "UInt",0, "UInt",0x8000)
		DllCall("CloseHandle", Ptr,hp)
		DllCall("GlobalFree", "Ptr",pt)
		flag := flag & 15
		return (flag<4) ? ((flag<2) ? 0 : "ItemIcon") : ((flag<8) ? "ItemLabel" : "ItemState")
	}
	return 0
}

;-------------------------------------------------------------------------------
; Hittest the target TreeView
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_TvHitTest()
{
	global MG_PID, MG_CClass, MG_HCTL, MG_X, MG_Y
	if(MG_CClass="SysTreeView32" || MG_CClass="TTreeView")
	{
		pt := DllCall("GlobalAlloc", "UInt",0x40, "UInt",8, "Ptr")
		NumPut(MG_X, pt+0, 0, "Int")
		NumPut(MG_Y, pt+0, 4, "Int")
		DllCall("ScreenToClient", "Ptr",MG_HCTL, "Ptr",pt)
		hp := DllCall("OpenProcess", "UInt",0x001F0FFF, "UInt",0, "UInt",MG_PID, "Ptr")
		size := 8 + A_PtrSize*2
		pi := DllCall("VirtualAllocEx", "Ptr",hp, "Ptr",0, "UInt",size, "UInt",0x1000, "UInt",0x4, "Ptr")
		DllCall("WriteProcessMemory", "Ptr",hp, "Ptr",pi, "Ptr",pt, "Int",8, "Ptr",0)
		SendMessage, 0x1111, 0, %pi%,, ahk_id %MG_HCTL%
		DllCall("ReadProcessMemory", "Ptr",hp, "Ptr",pi+8, "PtrP",flag, "UInt",A_PtrSize, "Ptr",0)
		DllCall("VirtualFreeEx", "Ptr",hp, "Ptr",pi, "UInt",0, "UInt",0x8000)
		DllCall("CloseHandle", Ptr,hp)
		DllCall("GlobalFree", "Ptr",pt)
		flag := flag & 127
		return (flag<16) ? ((flag<4) ? ((flag<2) ? 0 : "ItemIcon") : ((flag<8) ? "ItemLabel" : "Indent")) : ((flag<32) ? "Button" : ((flag<64) ? "Right" : "ItemState"))
	}
	return 0
}

;-------------------------------------------------------------------------------
; Hittest the DirectUIHWND
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DuiHitTest()
{
	global MG_CClass, MG_X, MG_Y
	if (MG_CClass = "DirectUIHWND")
	{
		uia := ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
		if (uia)
		{
			uia := new MGC_UIAInterface(uia)
			uia.base.base.__UIA := uia
			ele := uia.FromPoint(MG_X, MG_Y)
			return (ele.id==50006 || ele.id==50007) ? "ItemIcon" : (ele.id==50004) ? "ItemLabel" : 0
		}
	}
	return 0
}

class MGC_UIABase
{
	__New(p="", flag=1) {
		ObjInsert(this,"__Value",p), ObjInsert(this,"__Flag",flag)
	}
	__Get(member)
	{
		if member not in base,__UIA
		{
			if (DllCall(this.__Vt(21), "Ptr",this.__Value, "PtrP",out) == 0) {
				return out
			}
		}
	}
	__Delete() {
		this.__Flag ? ObjRelease(this.__Value) :
	}
	__Vt(n) {
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize, "Ptr")
	}
}

class MGC_UIAInterface extends MGC_UIABase
{
	FromPoint(x, y)
	{
		ele := 0
		hr := DllCall(this.__Vt(7), "Ptr",this.__Value, "Int64",y<<32|x, "PtrP",out)
		if (hr == 0) {
			ele := new MGC_UIAElement(out)
		}
		return ele
	}
}

class MGC_UIAElement extends MGC_UIABase
{
	static __IID := "{d22108aa-8ac5-49a5-837b-37bbb3d7591e}"
}

;-------------------------------------------------------------------------------
; Check whether the cursor is on the item of the ListView and TreeView
;	fLvLabel	: 0 = Detect only icon of the ListView
;			: 1 = Include text label of the ListView
;	fTvLabel	: 0 = Detect only icon of the TreeView
;			: 1 = Include text label of the TreeView
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_TreeListHitTest(fLvLabel=1, fTvLabel=1)
{
	lvht := MG_LvHitTest()
	if (!lvht) {
		lvht := MG_DuiHitTest()
	}
	if (lvht) {
		return (fLvLabel ? true : lvht!="ItemLabel")
	}
	else if (tvht := MG_TvHitTest()) {
		if (!fTvLabel && (tvht="ItemLabel")) {
			return false
		} else {
			return InStr(tvht, "Item")
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; Get the EXE file path of the target
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ExePath(pid=0)
{
	global MG_PID
	if(!pid){
		pid:=MG_PID
	}
	len := 260
	VarSetCapacity(s, (len+1)*2, 0)
	hProc := DllCall("OpenProcess", "UInt",0x410, "UInt",0, "UInt",pid, "Ptr")
	if(DllCall("psapi.dll\EnumProcessModules", "Ptr",hProc, "Ptr*",hMod, "Int",4, "Ptr*",nd, "Ptr")<>0) {
		DllCall("psapi.dll\GetModuleFileNameEx", "Ptr",hProc, "Ptr",hMod, "Str",s, "Int",len, "Int")
	}
	DllCall("CloseHandle", Ptr,hProc)
	return s
}

;-------------------------------------------------------------------------------
; Get the command line of the target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_CommandLine(pid=0)
{
	global MG_PID
	if(!pid){
		pid:=MG_PID
	}
	hProc := DllCall("OpenProcess", "UInt",0x001F0FFF, "UInt",0, "UInt",pid, "Ptr")

	size := A_PtrSize*6
	VarSetCapacity(pbi, size, 0)
	DllCall("ntdll\NtQueryInformationProcess", "Ptr",hProc, "Ptr",0, "Ptr",&pbi, "UInt",size, "Ptr",0)
	addr := NumGet(pbi, A_PtrSize, "Ptr")

	size := A_PtrSize*57 + 244
	VarSetCapacity(peb, size, 0)
	DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",addr, "Ptr",&peb, "UInt",size, "Ptr",0)
	addr := NumGet(peb, A_PtrSize*4, "Ptr")

	size := A_PtrSize*13 + 24
	VarSetCapacity(param, size, 0)
	DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",addr, "Ptr",&param, "UInt",size, "Ptr",0)
	length := NumGet(param, A_PtrSize*12+16, "UShort")
	addr   := NumGet(param, A_PtrSize*13+16, "Ptr")

	VarSetCapacity(cmdline, length+2, 0)
	DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",addr, "Ptr",&cmdline, "UInt",length, "Ptr",0)
	return cmdline
}

;-------------------------------------------------------------------------------
; Get an unique number of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_CIndex()
{
	global MG_HCTL,MG_HWND,MG_CClass
	WinGet,hl,ControlListHWND,ahk_id %MG_HWND%
	Loop,Parse,hl,`n
	{
		if(A_LoopField=MG_HCTL){
			idx:=A_Index
			break
		}
	}
	WinGet,cl,ControlList,ahk_id %MG_HWND%
	Loop,Parse,cl,`n
	{
		if(A_Index=idx){
			return RegExReplace(A_LoopField,"^" . MG_CClass,"")*1
		}
	}
}

;-------------------------------------------------------------------------------
; Get the list of the target informations
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_DumpWinInfo()
{
	global MG_HWND, MG_HCTL, MG_Exe, MG_WClass, MG_Title, MG_CClass

	WinGetPos,wx,wy,ww,wh,ahk_id %MG_HWND%
	ControlGetPos,cx,cy,cw,ch,,ahk_id %MG_HCTL%

	return "MG_Exe	" . MG_Exe
		. "`nMG_ExePath()	"	. MG_ExePath()
		. "`nMG_CommandLine()	"	. MG_CommandLine()
		. "`nMG_HitTest()		" . MG_HitTest()
		. "`nMG_LvHitTest()		" . MG_LvHitTest()
		. "`nMG_TvHitTest()		" . MG_TvHitTest()
		. "`nMG_DuiHitTest()	" . MG_DuiHitTest()
		. "`nMG_WClass	" . MG_WClass
		. "`nMG_Title	" . MG_Title
		. "`nMG_WinX()	" . wx
		. "`nMG_WinY()	" . wy
		. "`nMG_WinW()	" . ww
		. "`nMG_WinH()	" . wh
		. "`nMG_CClass	" . MG_CClass
		. "`nMG_CIndex()	" . MG_CIndex()
		. "`nMG_ControlX()	" . cx
		. "`nMG_ControlY()	" . cy
		. "`nMG_ControlW()	" . cw
		. "`nMG_ControlH()	" . ch
}



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Retrieving Information related to the Mouse Cursor
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Get Handle of Current Cursor
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetCursor()
{
	VarSetCapacity(infCur, 16+A_PtrSize, 0)
	NumPut(16+A_PtrSize, infCur, 0, "UInt")
	DllCall("GetCursorInfo", "Ptr",&infCur)
	hCursor := NumGet(infCur, 8, "Ptr")
	return hCursor
}

;-------------------------------------------------------------------------------
; Check whether the cursor is specified one
;	idCursor : Cursor ID to check
;	fMode	 : 0 = Check cursor when Gesture is started
;			 : 1 = Check cursor when Gesture is recognized
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckCursor(idCursor=0, fMode=0)
{
	global MG_Cursor
	hCursor := DllCall("LoadCursor", "Ptr",0, "UInt",idCursor, "Ptr")
	if (fMode==0) {
		return (hCursor == MG_Cursor)
	} else {
		return (hCursor == MG_GetCursor())
	}
}

;-------------------------------------------------------------------------------
; Check whether the cursor is defined by Windows
;	fMatch	: 1 = Check whether the cursor is defined by Windows
;			: 0 = Check whether the cursor is NOT defined by Windows
;	fMode	: 0 = Check cursor when Gesture is started
;			: 1 = Check cursor when Gesture is recognized
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckAllCursor(fMatch=0, fMode=0)
{
	static tblCursorID := "32512,32513,32649,32514,32515,32648,32650,32651,32646,32645,32644,32642,32643,32516"

	Loop, Parse, tblCursorID, `,
	{
		if (MG_CheckCursor(A_LoopField, fMode)) {
			return fMatch ? 1 : 0
		}
	}
	return (fMatch ? 0 : 1)
}

;-------------------------------------------------------------------------------
; Check whether the cursor is in specified rectangular region
;	x, y	: X-Y coordinates of upper left corner
;	width	: Width of rectangular region (0=Use Window Width)
;	height	: Height of rectangular region (0=Use Window Height)
;	target	: 0 = X-Y position is relative coordinates of Target Window
;			  1 = X-Y position is relative coordinates of Target Control
;			  2 = X-Y position is absolute coordinates of Screen
;	origin	: Origin corner	of target window (0=Upper-Left  1=Upper-Right
;			 								  2=Lower-Left  3=Lower-Right)
;	fMode	: 0 = Check cursor coordinates when Gesture is started
;			: 1 = Check cursor coordinates when Gesture is recognized
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CursorInRect(x, y, width, height, target=0, origin=0, fMode=0)
{
	global MG_X, MG_Y, MG_HWND, MG_HCTL
	if (fMode==0)
	{
		mx:=MG_X, my:=MG_Y
	}
	else
	{
		CoordMode, Mouse, Screen
		MouseGetPos, mx, my
	}
	;...........................................................................
	; Get target rectangle
	if (target==0) {
		WinGetPos, winX, winY, winW, winH, ahk_id %MG_HWND%
	}
	else if (target==1) {
		WinGetPos, winX, winY, winW, winH, ahk_id %MG_HCTL%
	}
	else {
		SysGet, winX, 76
		SysGet, winY, 77
		SysGet, winW, 78
		SysGet, winH, 79
	}
	;...........................................................................
	; Convert parameters
	if (x>0 && x<1) {
		x := winW * x
	}
	if (y>0 && y<1) {
		y := winH * y
	}
	if (width <= 0) {
		width := winW + width
	}
	else if (width<1) {
		width := winW * width
	}
	if (height <= 0) {
		height := winH + height
	}
	else if (height<1) {
		height := winH * height
	}
	;...........................................................................
	; Convert coordinates
	if (origin==1) {
		x1 := winX + winW - 1 + x
		y1 := winY + y
	}
	else if	(origin==2) {
		x1 := winX + x
		y1 := winY + winH - 1 + y
	}
	else if	(origin==3) {
		x1 := winX + winW - 1 + x
		y1 := winY + winH - 1 + y
	}
	else {
		x1 := winX + x
		y1 := winY + y
	}
	x2  :=  x1 + width  - 1
	y2  :=  y1 + height - 1
	;...........................................................................
	; Check coordinates
	if (x1<=mx && mx<=x2
	&&	y1<=my && my<=y2)
	{
		return 1
	}
	return 0
}



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Target Control Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Emulate Mouse Button
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Click(btn, mode="", cnt=1)
{
	local back

	if (mode!="" || cnt<1) {
		cnt := 1
	}
	if (IsLabel("MG_" . btn . "_Press"))
	{
		Gosub, MG_%btn%_Press
	}
	else if (IsLabel("MG_" . btn . "_Down"))
	{
		back := MG_DisableDef%btn%
		MG_DisableDef%btn% := 0
		Loop, %cnt%
		{
			if (mode="" || mode="D") {
				GoSub, MG_%btn%_Down
			}
			if (mode="" || mode="U") {
				GoSub, MG_%btn%_Up
			}
		}
		MG_DisableDef%btn% := back
	}
	else
	{
		if (btn = "LB") {
			szButton := "LEFT"
		} else if (btn = "RB") {
			szButton := "RIGHT"
		} else if (btn = "MB") {
			szButton := "MIDDLE"
		} else if (btn = "X1B") {
			szButton := "X1"
		} else if (btn = "X2B") {
			szButton := "X2"
		}
		if (mode="") {
			MouseClick, %szButton%,,, %cnt%
		} else {
			MouseClick, %szButton%,,,,, %mode%
		}
	}
}

;-------------------------------------------------------------------------------
; Move Mouse Cursor
;	x, y	: X-Y coordinates of the cursor
;	origin	: 0 = Origin point is gesture start position
;			  1 = Origin point is action start position
;			  2 = Origin point is current cursor position
;	abs		: 0 = x and y are relative coordinates from the origin point
;			: 1 = x and y are absolute coordinates
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Move(x=0, y=0, origin=0, abs=0)
{
	global
	CoordMode,Mouse,Screen
	SetMouseDelay,-1
	local relative:=""
	if (abs==0)
	{
		if (origin==0) {
			x+=MG_X, y+=MG_Y
		} else if (origin==1) {
			x+=MG_NowX, y+=MG_NowY
		} else {
			relative:="R"
		}
	}
	BlockInput, On
	MouseMove, %x%, %y%, 0, %relative%
	BlockInput, Off
}

;-------------------------------------------------------------------------------
; Scroll
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Scroll(x=0,y=0,hctl=0)
{
	global
	if(!hctl){
		hctl:=MG_HCTL
	}
	Loop,% Abs(x)
		PostMessage,0x114,% x>=0,0,,ahk_id %hctl%
	Loop,% Abs(y)
		PostMessage,0x115,% y>=0,0,,ahk_id %hctl%
}

;-------------------------------------------------------------------------------
; Instant Scroll
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_InstantScroll(stay=1,ppc_x=8,ppc_y=12,hctl=0)
{
	global
	local mx,my,cx,cy
	if(!hctl){
		hctl:=MG_HCTL
	}
	CoordMode,Mouse,Screen
	MouseGetPos,mx,my
	Loop,% Abs(cx:=((mx-MG_X)//ppc_x))
		PostMessage,0x114,% cx>=0,0,,ahk_id %hctl%
	Loop,% Abs(cy:=((my-MG_Y)//ppc_y))
		PostMessage,0x115,% cy>=0,0,,ahk_id %hctl%
	if(stay){
		mx:=mx-cx*ppc_x
		my:=my-cy*ppc_y
		MouseMove,%mx%,%my%,0
	}
}

;-------------------------------------------------------------------------------
; Drag Scroll
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_DragScroll(ppc_x=8,ppc_y=12,hctl=0)
{
	global
	static lx:=0,ly:=0,lmx:=0,lmy:=0,lctl:=0
	if(!hctl){
		hctl:=MG_HCTL
	}
	if(lmx!=MG_X || lmy!=MG_Y || lctl!=hctl){
		lmx:=lx:=MG_X
		lmy:=ly:=MG_Y
		lctl:=hctl
	}
	CoordMode,Mouse,Screen
	MouseGetPos,mx,my
	Loop,% Abs(cx:=(mx-lx)//ppc_x)
		PostMessage,0x114,% cx<0,0,,ahk_id %hctl%
	Loop,% Abs(cy:=(my-ly)//ppc_y)
		PostMessage,0x115,% cy<0,0,,ahk_id %hctl%
	lx:=lx+cx*ppc_x
	ly:=ly+cy*ppc_y
}

;-------------------------------------------------------------------------------
; Scroll Completely
;	dir	  : "V":Vertical Scroll  "H":Horizontal Scroll
;	cnt	  : Scroll Lines or Pages (Negative Value : Scroll Up or Left)
;	fPage : 1=Page Scroll  0=Line Scroll
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_Scroll2(dir, cnt, fPage=0)
{
	global MG_HCTL, MG_X, MG_Y, MG_CtlL, MG_CtlT, MG_CtlW, MG_CtlH, MG_hSB
	static pEnumChildProc := 0
	if (!pEnumChildProc) {
		pEnumChildProc := RegisterCallback("MG_EnumChildProc", "Fast")
	}
	WinGetPos, MG_CtlL, MG_CtlT, MG_CtlW, MG_CtlH, ahk_id %MG_HCTL%
	hWnd := MG_HCTL
	lParam := 0
	MG_hSB := 0
	Loop, 2
	{
		DllCall("EnumChildWindows", "Ptr",hWnd, "Ptr",pEnumChildProc, "Ptr",(dir="V"))
		if (MG_hSB)
		{
			lParam := MG_hSB
			hWnd := DllCall("GetParent", "Ptr",MG_hSB)
			break
		}
		if (A_Index==1)
		{
			hWnd := DllCall("GetParent", "Ptr",MG_HCTL)
		}
	}
	if (!lParam) {
		hWnd := MG_HCTL
	}
	uMsg := (dir="V") ? 0x115 : 0x114
	wParam := (cnt>=0) ? 1 : 0
	if (fPage) {
		wParam += 2
	}
	Loop, % Abs(cnt)
	{
		PostMessage, %uMsg%, %wParam%, %lParam%,, ahk_id %hWnd%
	}
}

;-------------------------------------------------------------------------------
; Enumerate Child Windows Callback Function
;	hWnd   : Handle to Child Window
;	lParam : 1=Vertical Scroll  0=Horizontal Scroll
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_EnumChildProc(hWnd, lParam)
{
	global MG_HCTL, MG_X, MG_Y, MG_CtlL, MG_CtlT, MG_CtlW, MG_CtlH, MG_hSB
	WinGetClass, szClass, ahk_id %hWnd%
	if (!InStr(szClass, "ScrollBar")) {
		return true
	}
	WinGet, dwStyle, Style, ahk_id %hWnd%
	if (!(dwStyle & 0x10000000)) {
		return true
	}
	static prevL, prevT
	WinGetPos, sbL, sbT, sbW, sbH, ahk_id %hWnd%
	if (lParam)
	{
		if (sbW > sbH) {
			return true
		}
		if ((sbL+sbW)<MG_CtlL || sbL>(MG_CtlL+MG_CtlW) || (sbT+sbH)<=MG_CtlT || sbT>=(MG_CtlT+MG_CtlH))
		{
			return true
		}
		if ((MG_Y >= sbT) && (MG_Y < sbT+sbH))
		{
			MG_hSB := hWnd
			return false
		}
		if (MG_hSB && (abs(MG_Y-sbT) > abs(MG_Y-prevT)))
		{
			return true
		}
	}
	else
	{
		if (sbW < sbH) {
			return true
		}
		if ((sbT+sbH)<MG_CtlT || sbT>(MG_CtlT+MG_CtlH) || (sbL+sbW)<=MG_CtlL || sbL>=(MG_CtlL+MG_CtlW))
		{
			return true
		}
		if ((MG_X >= sbL) && (MG_X < sbL+sbW))
		{
			MG_hSB := hWnd
			return false
		}
		if (MG_hSB && (abs(MG_X-sbL) > abs(MG_X-prevL)))
		{
			return true
		}
	}
	MG_hSB:=hWnd, prevL:=sbL, prevT:=sbT
	return true
}

;-------------------------------------------------------------------------------
; Drag Scroll Completely
;	invert : 0=Scroll against the cursor  1=Follow the cursor
;	auto   : 0=Scroll one by one  1=Auto-scrolling
;	resV   : Vertical Resolution
;	resH   : Horizontal Resolution
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DragScroll2(invert=1, auto=0, resV=15, resH=30)
{
	global MG_HCTL, MG_X, MG_Y, MG_hSB
	static lx:=0, ly:=0, lmx:=0, lmy:=0, lctl:=0
	if (lmx!=MG_X || lmy!=MG_Y || lctl!=MG_HCTL)
	{
		lmx:=lx:=MG_X
		lmy:=ly:=MG_Y
		lctl:=MG_HCTL
	}
	CoordMode,Mouse,Screen
	MouseGetPos,mx,my
	if (auto)
	{
		dX := (mx-MG_X) // resH
		dY := (my-MG_Y) // resV
	}
	else
	{
		dX := (mx-lx) // resH
		dY := (my-ly) // resV
		lx += dX*resH
		ly += dY*resV
	}
	dirV := (dY<0 ? -1 : 1) * (invert ? -1 : 1)
	dirH := (dX<0 ? -1 : 1) * (invert ? -1 : 1)
	dY := abs(dY)
	dX := abs(dX)
	while (dX>0 || dY>0)
	{
		if (dY>0) {
			MG_Scroll2("V", dirV)
			dY--
		}
		if (dX>0) {
			MG_Scroll2("H", dirH)
			dX--
		}
	}
}

;-------------------------------------------------------------------------------
; Send Wheel Rotation Message
;	dir		: "U":Rotation Up  "D":Rotation Down
;	counts	: Rotation Distance
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SendWheel(dir, counts=1)
{
	global MG_HCTL, MG_HWND, MG_X, MG_Y
	WinGetClass, MG_WClass
	if (MG_WClass="tooltips_class32")
	{
		SendMessage, 0x041C
		CoordMode,Mouse,Screen
		MouseGetPos, MG_X, MG_Y, MG_HWND, MG_HCTL, 3
	}
	hWnd := MG_HCTL ? MG_HCTL : MG_HWND
	wParam := (dir="U" ? 0x00780000*counts : 0xFF880000*counts)
			| GetKeyState("LButton")
			| GetKeyState("RButton")  << 1
			| GetKeyState("Shift")	  << 2
			| GetKeyState("Ctrl")	  << 3
			| GetKeyState("MButton")  << 4
			| GetKeyState("XButton1") << 5
			| GetKeyState("XButton2") << 6
	lParam := MG_Y<<16 | MG_X
	PostMessage, 0x020A, %wParam%, %lParam%,, ahk_id %hWnd%
}

;-------------------------------------------------------------------------------
; Move and Resize the Window
;	x	    : Left coordinates of the window
;	y	    : Upper coordinates of the window
;	w	    : Width of the window
;	h	    : Height of the window
;	fRel    : Position and Size are (0=Absolute or 1=Relative) Value
;	hWnd    : Handle of the target window
;	ExAreas : Edge areas to exclude from the screen for window arrangement
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_WinMove(x:="", y:="", w:="", h:="", fRel=0, hWnd="", ExAreas:="")
{
	global MG_X, MG_Y, MG_HWND

	if (x="" && y="" && w="" && h="") {
		return
	}
	if (!hWnd) {
		hWnd := MG_HWND
	}
	;...........................................................................
	; Relative
	if (fRel)
	{
		WinGetPos, winX, winY, winW, winH, ahk_id %hWnd%
		; Left Position
		if (RegExMatch(x, "([0-9]+)/([0-9]+)", $)) {
			winX := winX * $1 // $2
		} else if (x<=0 || 1<=x) {
			winX += x
		} else {
			winX *= x
		}
		; Top Position
		if (RegExMatch(y, "([0-9]+)/([0-9]+)", $)) {
			winY := winY * $1 // $2
		} else if (y<=0 || 1<=y) {
			winY += y
		} else {
			winY *= y
		}
		; Width
		if (RegExMatch(w, "([0-9]+)/([0-9]+)", $)) {
			winW := winW * $1 // $2
		} else if (w<=0 || 1<=w) {
			winW += w
		} else {
			winW *= w
		}
		; Height
		if (RegExMatch(h, "([0-9]+)/([0-9]+)", $)) {
			winH := winH * $1 // $2
		} else if (h<=0 || 1<=h) {
			winH += h
		} else {
			winH *= h
		}
	}
	;...........................................................................
	; Absolute
	else
	{
		MG_GetMonitorRect(MG_X, MG_Y, dtL, dtT, dtR, dtB, true)
		dtL := ExAreas[1] ? dtL+ExAreas[1] : dtL
		dtT := ExAreas[2] ? dtT+ExAreas[2] : dtT
		dtR := ExAreas[3] ? dtR-ExAreas[3] : dtR
		dtB := ExAreas[4] ? dtB-ExAreas[4] : dtB
		dtW := dtR - dtL
		dtH := dtB - dtT
		; Left Position
		if (RegExMatch(x, "([0-9]+)/([0-9]+)", $)) {
			winX := dtW * $1 // $2
		} else if (x<=0 || 1<=x) {
			winX := x
		} else {
			winX := dtW * x
		}
		winX += dtL
		; Top Position
		if (RegExMatch(y, "([0-9]+)/([0-9]+)", $)) {
			winY := dtH * $1 // $2
		} else if (y<=0 || 1<=y) {
			winY := y
		} else {
			winY := dtH * y
		}
		winY += dtT
		; Width
		if (RegExMatch(w, "([0-9]+)/([0-9]+)", $)) {
			winW := dtW * $1 // $2
		} else if (w<0 || 1<=w) {
			winW := w
		} else {
			winW := dtW * (w!=0 ? w : 1)
		}
		; Height
		if (RegExMatch(h, "([0-9]+)/([0-9]+)", $)) {
			winH := dtH * $1 // $2
		} else if (h<0 || 1<=h) {
			winH := h
		} else {
			winH := dtH * (h!=0 ? h : 1)
		}
	}
	winX := (x!="") ? winX : ""
	winY := (y!="") ? winY : ""
	winW := (w!="") ? winW : ""
	winH := (h!="") ? winH : ""
	WinMove, ahk_id %hWnd%,, winX, winY, winW, winH
}

;-------------------------------------------------------------------------------
; Activate the Previous Active Window
;	fMin : 0=Ignore minimized window  1=Restore minimized window
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ActivatePrevWin(fMin=1)
{
	global MG_hPrevActive
	WinGet, hActWin, ID, A
	if ((hActWin!=MG_hPrevActive) && WinExist("ahk_id " . MG_hPrevActive))
	{
		if (!fMin) {
			WinGet, dwStyle, Style, ahk_id %MG_hPrevActive%
		} else {
			dwStyle := 0
		}
		if (!(dwStyle & 0x20000000)) {
			WinActivate, ahk_id %MG_hPrevActive%
			return
		}
	}
	Critical
	bDone := false
	szMinWin := ""
	WinGet, winList, List,,,!!!_dummy_dummy_dummy_!!!
	Loop, %winList%
	{
		if (winList%A_Index% == hActWin) {
			continue
		}
		if (!MG_IsActivationTarget(winList%A_Index%)) {
			continue
		}
		szID := "ahk_id " . winList%A_Index%
		WinGetPos,,,w, h, %szID%
		if (w==0 || h==0) {
			continue
		}
		if (!fMin)
		{
			WinGet, dwStyle, Style, %szID%
		 	if (dwStyle & 0x20000000)
		 	{
				if (!szMinWin) {
					szMinWin := szID
				}
				continue
			}
		}
		WinActivate, %szID%
		bDone := true
		break
	}
	if (!bDone && szMinWin) {
		WinActivate, %szMinWin%
	}
	Critical, Off
}

;-------------------------------------------------------------------------------
; Set Window Event Hook
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetWinEventHook()
{
	local funcHook, hWnd

	funcHook := RegisterCallback("MG_EventHookProc", "Fast")
	MG_hEventHook := DllCall("SetWinEventHook", "Ptr",0x0003, "Ptr",0x0003, "Ptr",0
							, "Ptr",funcHook, "Int",0, "Int",0, "Ptr",3, "Ptr")	; EVENT_SYSTEM_FOREGROUND
	WinGet, hWnd, ID, A
	MG_EventHookProc(MG_hEventHook, 0x0003, hWnd, 0, 0, 0, 0)
}

;-------------------------------------------------------------------------------
; Event Hook Function
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_EventHookProc(hWinEventHook, iEvent, hWnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
	local szExe
	static hNowActive:=0
	if (iEvent==0x0003 && idObject==0 && hNowActive!=hWnd) {
		if (MG_IsActivationTarget(hNowActive)) {
			MG_hPrevActive := hNowActive
		}
		hNowActive := hWnd
	}
}

;-------------------------------------------------------------------------------
; Simulate Drop Files
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_DropFiles(szFiles="", szWinTitle="")
{
	global MG_HWND
	if(szFiles = ""){
		szFiles := Clipboard
	}
	if(szWinTitle = ""){
		szWinTitle := "ahk_id " . MG_HWND
	}
	szFiles := RegExReplace(RegExReplace(szFiles,"\n$",""),"\r","")
	size := 4*3 + A_PtrSize*2
	hDrop := DllCall("GlobalAlloc", "UInt",0x42, "UInt",size+(StrLen(szFiles)+2)*2, "Ptr")
	pHDROP := DllCall("GlobalLock", "Ptr",hDrop, "Ptr")
	NumPut(size, pHDROP+0)							;offset
	NumPut(0   , pHDROP+4)							;pt.x
	NumPut(0   , pHDROP+8)							;pt.y
	NumPut(0   , pHDROP+8+A_PtrSize,   0, "Ptr")	;fNC
	NumPut(1   , pHDROP+8+A_PtrSize*2, 0, "Ptr")	;fWide
	pszPath := pHDROP + size
	Loop,Parse,szFiles,`n,`r
	{
		DllCall("RtlMoveMemory", "Ptr",pszPath, "Str",A_LoopField, "UInt",StrLen(A_LoopField)*2)
		pszPath += (StrLen(A_LoopField)+1)*2
	}
	DllCall("GlobalUnlock", "Ptr",hDrop)
	PostMessage, 0x233, %hDrop%, 0,,%szWinTitle%
}

;-------------------------------------------------------------------------------
; Set the files to clipboard to make copying or moving
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_FilesToClipboard(szFiles="", isMove=0)
{
	if (DllCall("OpenClipboard", "Ptr",0))
	{
		szFiles := RegExReplace(RegExReplace(szFiles,"\n$",""),"\r","")
		size := 4*3 + A_PtrSize*2
		hData := DllCall("GlobalAlloc", "UInt",0x2042, "UInt",size+(StrLen(szFiles)+2)*2, "Ptr")
		pHDROP := DllCall("GlobalLock", "Ptr",hData, "Ptr")
		NumPut(size, pHDROP+0)							;offset
		NumPut(0   , pHDROP+4)							;pt.x
		NumPut(0   , pHDROP+8)							;pt.y
		NumPut(0   , pHDROP+8+A_PtrSize,   0, "Ptr")	;fNC
		NumPut(1   , pHDROP+8+A_PtrSize*2, 0, "Ptr")	;fWide
		pszPath := pHDROP + size
		Loop,Parse,szFiles,`n,`r
		{
			DllCall("RtlMoveMemory", "Ptr",pszPath, "Str",A_LoopField, "UInt",StrLen(A_LoopField)*2)
			pszPath += (StrLen(A_LoopField)+1)*2
		}
		DllCall("EmptyClipboard")
		DllCall("SetClipboardData", "Ptr",15, "Ptr",hData)
		DllCall("GlobalUnlock", "Ptr",hData)

		hData := DllCall("GlobalAlloc", "UInt",0x2042, "UInt",A_PtrSize, "Ptr")
		p := DllCall("GlobalLock", "Ptr",hData, "Ptr")
		NumPut(isMove ? 2 : 1 , p+0, 0, "Ptr")
		DllCall("SetClipboardData", "Ptr",DllCall("RegisterClipboardFormat", "Str","Preferred DropEffect"), "Ptr",hData)
		DllCall("GlobalUnlock", "Ptr",hData)
		DllCall("CloseClipboard")
	}
}

;-------------------------------------------------------------------------------
; Activate target window and set focus on target control
;	bCtrl : true=Set focus on target control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_WinActivate(bCtrl:=false)
{
	local hFocusCtrl

	if (WinExist("ahk_class #32768")) {
		Send, {Alt}
		IfWinExist,ahk_id %MG_HWND%,,,,{
		}
	}
	if (!WinActive()) {
		WinActivate
	}
	if (bCtrl) {
		ControlGetFocus, FocusClassNN
		ControlGet, hFocusCtrl, Hwnd,, %FocusClassNN%
		if (hFocusCtrl != MG_HCTL) {
			ControlFocus,, ahk_id %MG_HCTL%
		}
	}
}

;-------------------------------------------------------------------------------
; Minimize / Close all windows of the same class
;	szInTitle : Specify a string to filter by window title
;	szExTitle : Specify a string to exclude by window title
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_OperateSameClass(ope, szInTitle:="", szExTitle:="")
{
	local uMsg, wParam, hWnd, szTitle

	if (ope = "Minimize") {
		uMsg:=0x0112, wParam:=0xF020
	} else if (ope = "Close") {
		uMsg:=0x0010, wParam:=0
	} else {
		return
	}
	WinGet, WndList, list, ahk_class %MG_WClass%
	Loop, %WndList%
	{
	    hWnd := WndList%A_Index% 
		if (szInTitle || szExTitle) {
			WinGetTitle, szTitle, ahk_id %hWnd%
			if ((szInTitle && !InStr(szTitle, szInTitle))
			||	(szExTitle &&  InStr(szTitle, szExTitle))) {
				continue
			}
		}
	    PostMessage, uMsg, wParam, 0,, ahk_id %hWnd%
	}
}

;-------------------------------------------------------------------------------
; Tile all windows of the same class
;	dir : "H"=Tile horizontally  "V"=Tile vertically  Otherwise=Tile as panes
;	exL : Left side excluded area of screen
;	exT : Upper side excluded area of screen
;	exR : Right side excluded area of screen
;	exB : Lower side excluded area of screen
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_TileSameClass(dir:="", exL:=0, exT:=0, exR:=0, exB:=0)
{
	local x, y, w, h, nX, nY, hWnd, dwStyle, aryEx

	WinGet, WndList, list, ahk_class %MG_WClass%
	x:=y:=w:=h:=0, nX:=nY:=1
	if (WndList > 1) {
		if (dir=="H") {
			nX := WndList
		} else if (dir=="V") {
			nY := WndList
		} else {
			nX := Ceil(Sqrt(WndList))
			nY := Ceil(WndList / nX)
		}
		w := nX>1 ? "1/" nX : 0
		h := nY>1 ? "1/" nY : 0
	}
	Loop, %WndList%
	{
	    hWnd := WndList%A_Index%
		WinGet, dwStyle, Style, ahk_id %hWnd%
	 	if (dwStyle & 0x20000000) {
		    WinRestore, ahk_id %hWnd%
		}
	    x := nX>1 ? Mod(A_Index-1, nX) "/" nX : 0
	    y := nY>1 ? (A_Index-1)//nX "/" nY : 0
	    aryEx := [exL, exT, exR, exB]
		MG_WinMove(x, y, w, h,, hWnd, aryEx)
	}
}



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Hints
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Toggle Hints
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_NaviToggleEnable:
	MG_NaviEnabled := !MG_NaviEnabled
	Menu, %MG_MenuName%, % MG_NaviEnabled ? "Check" : "Uncheck", %MG_LngMenu002%
	if (MG_NaviEnabled)
	{
		if (MG_UseExNavi) {
			MG_CreateExNavi()
		}
		TrayTip, MouseGestureL, %MG_LngTooltip003%
	}
	else
	{
		if (MG_UseExNavi) {
			MG_DestroyExNavi()
		}
		TrayTip, MouseGestureL, %MG_LngTooltip004%
	}
	SetTimer, MG_HideTrayTip, -1000
return

MG_HideTrayTip:
	TrayTip
return

;-------------------------------------------------------------------------------
; Update Gesture Hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_NaviUpdate:
	if (MG_UseExNavi==1 || MG_UseExNavi==2) {
		MG_UpdateExNavi()
	}
	else if (MG_UseExNavi==3 || MG_UseExNavi==4) {
		MG_UpdateAdNavi()
	}
	else {
		MG_UpdateNavi()
	}
return

;-------------------------------------------------------------------------------
; Hints Persistence Timer
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_NaviPersistTimer:
	SetTimer, MG_NaviPersistTimer, Off
	MG_StopNavi(1)
return

;-------------------------------------------------------------------------------
; Start Gesture Hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StartNavi()
{
	global
	if (MG_NaviEnabled)
	{
		SetTimer, MG_NaviPersistTimer, Off
		MG_NaviPrst := 0
		MG_SetExNaviBgColor()
		MG_GetTargetMonitorRect()
		GoSub, MG_NaviUpdate
		SetTimer, MG_NaviUpdate, %MG_NaviInterval%
	}
}

;-------------------------------------------------------------------------------
; Stop Gesture Hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StopNavi(fForce=1)
{
	global
	if (MG_NaviEnabled)
	{
		if (fForce)
		{
			SetTimer, MG_NaviPersistTimer, Off
			MG_NaviPrst := 0
		}
		else if (MG_NaviPrst)
		{
			return
		}
		SetTimer, MG_NaviUpdate, Off
		if (MG_UseExNavi)
		{
			Gui, MGW_ExNavi:Show, w1 h1 Hide
		}
		else
		{
			Tooltip
			MG_Tooltip=
		}
	}
}

;-------------------------------------------------------------------------------
; Update Hint Tips
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateNavi()
{
	global
	if (MG_Tooltip) {
		ToolTip,% RegExReplace(MG_Tooltip,"(?<=^|\n)\t+")
	}
	else if (MG_Tooltip_%MG_Gesture%) {
		ToolTip,% MG_Tooltip_%MG_Gesture%
	}
	else if (MG_NaviPrst) {
		Tooltip, %MG_NaviPrstStr%
	}
	else {
		Tooltip, %MG_Gesture%
	}
}

;-------------------------------------------------------------------------------
; Create Gesture Hints Window
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateExNavi()
{
	global
	Gui, MGW_ExNavi:New
	Gui, MGW_ExNavi:+HwndMG_ExNaviHwnd -Caption +ToolWindow +AlwaysOnTop +LastFound -DPIScale
	if (MG_UseExNavi==1 || MG_UseExNavi==2)
	{
		if (MG_ExNaviTransBG) {
			MG_ExNaviBG := MG_MakeTransColor(MG_ExNaviFG)
		}
		else if ((0<MG_ExNaviTranspcy) && (MG_ExNaviTranspcy<255)) {
			WinSet, Transparent, %MG_ExNaviTranspcy%
		}
		MG_ExNaviFG2 := MG_ConvertHex(MG_ExNaviFG)
		MG_ExNaviBG2 := MG_ConvertHex(MG_ExNaviBG)
	}
	else if (MG_UseExNavi==3 || MG_UseExNavi==4)
	{
		MG_AdNaviFG2 := MG_ConvertHex(MG_AdNaviFG)
		MG_AdNaviNI2 := MG_ConvertHex(MG_AdNaviNI)
		MG_AdNaviBG2 := MG_ConvertHex(MG_AdNaviBG)
		MG_AdNaviTransClr := MG_MakeTransColor(MG_AdNaviBG)
		MG_AdNaviTransClr2 := MG_ConvertHex(MG_AdNaviTransClr)
		Gui, MGW_ExNavi:Color, %MG_AdNaviBG%
		local colorBG := MG_AdNaviTransClr
		if (0<MG_AdNaviTranspcy && MG_AdNaviTranspcy<255) {
			colorBG .= " " . MG_AdNaviTranspcy
		}
		WinSet, TransColor, %colorBG%
	}
}

;-------------------------------------------------------------------------------
; Make Transparent Color
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_MakeTransColor(color)
{
	RegExMatch(color, "([a-zA-Z0-9][a-zA-Z0-9])([a-zA-Z0-9][a-zA-Z0-9])([a-zA-Z0-9][a-zA-Z0-9])", $)
	RR := "0x" . $1,	RR += (RR>0) ? -1 : 1
	GG := "0x" . $2,	GG += (GG>0) ? -1 : 1
	BB := "0x" . $3,	BB += (BB>0) ? -1 : 1
	SetFormat, IntegerFast, H
	colTrans := (RR<<16) + (GG<<8) + BB
	colTrans := RegExReplace(colTrans, "^0x")
	SetFormat, IntegerFast, D
	len := StrLen(colTrans)
	Loop, % (6 - len)
	{
		colTrans := "0" . colTrans
	}
	return colTrans
}

;-------------------------------------------------------------------------------
; Convert String Hexadecimal
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ConvertHex(hex)
{
	return RegExReplace(hex
						,"([a-zA-Z0-9][a-zA-Z0-9])([a-zA-Z0-9][a-zA-Z0-9])([a-zA-Z0-9][a-zA-Z0-9])"
						,"0x$3$2$1")
}

;-------------------------------------------------------------------------------
; Destroy Gesture Hints Window
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_DestroyExNavi()
{
	Gui, MGW_ExNavi:Destroy
}

;-------------------------------------------------------------------------------
; Set Arrow Hints Background Color and Transparency
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetExNaviBgColor()
{
	global
	if (MG_UseExNavi!=1 && MG_UseExNavi!=2)
	{
		return
	}
	RegExMatch(MG_Gesture, "(\w+)_", $)
	MG_ExNaviIdvFG := (MG_ExNaviFG_%$1% != "") ? MG_ConvertHex(MG_ExNaviFG_%$1%) : ""
	MG_ExNaviIdvBG := ""
	local colorBG := MG_ExNaviBG
	if (MG_ExNaviTransBG)
	{
		if (MG_ExNaviFG_%$1% != "")
		{
			colorBG := MG_MakeTransColor(MG_ExNaviFG_%$1%)
			MG_ExNaviIdvBG := MG_ConvertHex(colorBG)
		}
		local trans := ""
		if (0<MG_ExNaviTranspcy && MG_ExNaviTranspcy<255) {
			trans := " " . MG_ExNaviTranspcy
		}
		Gui, MGW_ExNavi:+LastFound
		WinSet, TransColor, %colorBG%%trans%
	}
	Gui, MGW_ExNavi:Color, %colorBG%
}

;-------------------------------------------------------------------------------
; Get Work Area of Target Monitor
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetTargetMonitorRect()
{
	global
	if ((MG_UseExNavi==3 || MG_UseExNavi==4)
	&&	(MG_AdNaviPosition > 0))
	{
		MG_GetMonitorRect(MG_X, MG_Y, MG_MonitorL, MG_MonitorT, MG_MonitorR, MG_MonitorB, true)
	}
}

;-------------------------------------------------------------------------------
; Update Arrow Hints
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateExNavi()
{
	global
	static prevX:=0, prevY:=0
	;...........................................................................
	; Critical Section
	static fCritical := 0
	if (fCritical) {
		return
	}
	fCritical := 1
	;...........................................................................
	; Make Arrows String and Check Gesture Conditions
	local szGesture := MG_NaviPrst ? MG_NaviPrstStr : MG_Gesture
	local szArrows := MG_MakeArrowsStr(szGesture)
	if (!szArrows)
	{
		fCritical := 0
		return
	}
	;...........................................................................
	; Decide Drawing Position
	local winX, winY, newDPI, bDpiChanged:=false
	if (MG_ExNaviMargin < 0)
	{
		winX:=MG_X, winY:=MG_Y
	}
	else
	{
		CoordMode, Mouse, Screen
		MouseGetPos, winX, winY
		winX += MG_AdjustToDPI(MG_ExNaviMargin)
		winY += MG_AdjustToDPI(MG_ExNaviMargin)
		if (prevX!=winX || prevY!=winY) {
			newDPI := MG_GetDpiFromPoint(winX, winY)
			if (newDPI != MG_ScreenDPI) {
				MG_ScreenDPI := newDPI
				bDpiChanged := true
			}
		}
	}
	;...........................................................................
	; Draw Arrows
	if ((szArrows!=MG_PrevGesture) || bDpiChanged)
	{
		RegExMatch(szGesture, "(\w+)_", $)
	 	local fgc := (MG_ExNaviFG_%$1% != "") ? MG_ExNaviIdvFG : MG_ExNaviFG2
		local bgc := MG_ExNaviIdvBG ? MG_ExNaviIdvBG : MG_ExNaviBG2
		local hDC := DllCall("GetWindowDC", "Ptr",MG_ExNaviHwnd, "Ptr")
		local hFont := MG_CreateFont("Wingdings", MG_ExNaviSize)
		local hFntOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",hFont, "Ptr")
		DllCall("SetTextColor","Ptr",hDC, "UInt",fgc)
		DllCall("SetBkColor","Ptr",hDC, "UInt",bgc)
		if (MG_UseExNavi==1) {
			MG_UpdateArrowHints1(hDC, szGesture, szArrows, winX, winY, bgc)
		} else if (MG_UseExNavi==2) {
			MG_UpdateArrowHints2(hDC, szGesture, szArrows, winX, winY, bgc)
		}
		DllCall("SelectObject", "Ptr",hDC, "Ptr",hFntOld)
		DllCall("DeleteObject", "Ptr",hFont)
		DllCall("ReleaseDC", "Ptr",MG_ExNaviHwnd, "Ptr",hDC)
	}
	;...........................................................................
	; Only Move Window
	else if (prevX!=winX || prevY!=winY)
	{
		Gui, MGW_ExNavi:Show, x%winX% y%winY% NA
	}
	prevX:=winX, prevY:=winY
	MG_PrevGesture := szArrows
	fCritical := 0
}

;-------------------------------------------------------------------------------
; Update Hint Arrows Type 1
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateArrowHints1(hDC, szGesture, szArrows, winX, winY, clrBG)
{
	global
	DllCall("SetTextCharacterExtra", "Ptr",hDC, "Int",MG_AdjustToDPI(MG_ExNaviSpacing))
	local size
	VarSetCapacity(size, 8, 0)
	DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",szArrows, "Int",StrLen(szArrows), "Ptr",&size)
	local winW := NumGet(size, 0, "UInt") + MG_AdjustToDPI(MG_ExNaviPadding)*2
	local winH := NumGet(size, 4, "UInt") + MG_AdjustToDPI(MG_ExNaviPadding)*2
	if (winW && winH)
	{
		Gui, MGW_ExNavi:Show, x%winX% y%winY% w%winW% h%winH% NA
		MG_EraseArrows(hDC, clrBG)
		DllCall("TextOut", "Ptr",hDC, "Int",MG_AdjustToDPI(MG_ExNaviPadding)
				, "Int",MG_AdjustToDPI(MG_ExNaviPadding), "Str",szArrows, "Int",StrLen(szArrows))
	}
}

;-------------------------------------------------------------------------------
; Update Hint Arrows Type 2
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateArrowHints2(hDC, szGesture, szArrows, winX, winY, clrBG)
{
	global
	local size
	VarSetCapacity(size, 8, 0)
	local OneArrow = SubStr(szArrows, 1, 1)
	DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",OneArrow, "Int",1, "Ptr",&size)
	local w := NumGet(size, 0, "UInt")
	local h := NumGet(size, 4, "UInt")
	local FullW := (w > h) ? w : h
	FullW += MG_AdjustToDPI(MG_ExNaviSpacing)
	local HalfW := FullW
	HalfW /= 2

	local maxX:=0, maxY:=0, minX:=0, minY:=0
	Loop, Parse, szArrows
	{
		local preIdx := A_Index - 1
		if (MG_ArrowPos%A_Index% ==  1) {
			ArrowX%A_Index% := ArrowX%preIdx% - FullW
			ArrowY%A_Index% := ArrowY%preIdx% + FullW
		}
		else if (MG_ArrowPos%A_Index% ==  2) {
			ArrowX%A_Index% := ArrowX%preIdx%
			ArrowY%A_Index% := ArrowY%preIdx% + FullW
		}
		else if (MG_ArrowPos%A_Index% ==  3) {
			ArrowX%A_Index% := ArrowX%preIdx% + FullW
			ArrowY%A_Index% := ArrowY%preIdx% + FullW
		}
		else if (MG_ArrowPos%A_Index% ==  4) {
			ArrowX%A_Index% := ArrowX%preIdx% - FullW
			ArrowY%A_Index% := ArrowY%preIdx%
		}
		else if (MG_ArrowPos%A_Index% ==  6) {
			ArrowX%A_Index% := ArrowX%preIdx% + FullW
			ArrowY%A_Index% := ArrowY%preIdx%
		}
		else if (MG_ArrowPos%A_Index% ==  7) {
			ArrowX%A_Index% := ArrowX%preIdx% - FullW
			ArrowY%A_Index% := ArrowY%preIdx% - FullW
		}
		else if (MG_ArrowPos%A_Index% ==  8) {
			ArrowX%A_Index% := ArrowX%preIdx%
			ArrowY%A_Index% := ArrowY%preIdx% - FullW
		}
		else if (MG_ArrowPos%A_Index% ==  9) {
			ArrowX%A_Index% := ArrowX%preIdx% + FullW
			ArrowY%A_Index% := ArrowY%preIdx% - FullW
		}
		else if (MG_ArrowPos%A_Index% == 10) {
			ArrowX%A_Index% := ArrowX%preIdx% - HalfW
			ArrowY%A_Index% := ArrowY%preIdx% - FullW
		}
		else if (MG_ArrowPos%A_Index% == 11) {
			ArrowX%A_Index% := ArrowX%preIdx% - FullW
			ArrowY%A_Index% := ArrowY%preIdx% - HalfW
		}
		else if (MG_ArrowPos%A_Index% == 12) {
			ArrowX%A_Index% := ArrowX%preIdx% + FullW
			ArrowY%A_Index% := ArrowY%preIdx% - HalfW
		}
		else if (MG_ArrowPos%A_Index% == 13) {
			ArrowX%A_Index% := ArrowX%preIdx% + HalfW
			ArrowY%A_Index% := ArrowY%preIdx% - FullW
		}
		else if (MG_ArrowPos%A_Index% == 14) {
			ArrowX%A_Index% := ArrowX%preIdx% + HalfW
			ArrowY%A_Index% := ArrowY%preIdx% + FullW
		}
		else if (MG_ArrowPos%A_Index% == 15) {
			ArrowX%A_Index% := ArrowX%preIdx% + FullW
			ArrowY%A_Index% := ArrowY%preIdx% + HalfW
		}
		else if (MG_ArrowPos%A_Index% == 16) {
			ArrowX%A_Index% := ArrowX%preIdx% - FullW
			ArrowY%A_Index% := ArrowY%preIdx% + HalfW
		}
		else if (MG_ArrowPos%A_Index% == 17) {
			ArrowX%A_Index% := ArrowX%preIdx% - HalfW
			ArrowY%A_Index% := ArrowY%preIdx% + FullW
		}
		else {
			ArrowX%A_Index% := 0
			ArrowY%A_Index% := 0
		}
		if (maxX < ArrowX%A_Index%) {
			maxX := ArrowX%A_Index%
		}
		if (maxY < ArrowY%A_Index%) {
			maxY := ArrowY%A_Index%
		}
		if (minX > ArrowX%A_Index%) {
			minX := ArrowX%A_Index%
		}
		if (minY > ArrowY%A_Index%) {
			minY := ArrowY%A_Index%
		}
	}
	local winW := maxX - minX + FullW - MG_AdjustToDPI(MG_ExNaviSpacing)
	local winH := maxY - minY + FullW - MG_AdjustToDPI(MG_ExNaviSpacing)
	if (winW && winH)
	{
		Gui, MGW_ExNavi:Show, x%winX% y%winY% w%winW% h%winH% NA
		MG_EraseArrows(hDC, clrBG)
		Loop, Parse, szArrows
		{
			local posX := ArrowX1 + ArrowX%A_Index% - minX
			local posY := ArrowY1 + ArrowY%A_Index% - minY
			DllCall("TextOut", "Ptr",hDC, "Int",posX, "Int",posY, "Str",A_LoopField, "Int",1)
		}
	}
}

;-------------------------------------------------------------------------------
; Erase hint arrows with filling by background color
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_EraseArrows(hDC, clrBG)
{
	local w, h, rc, hBrush
	WinGetPos,,, w, h, ahk_id %MG_ExNaviHwnd%
	VarSetCapacity(rc, 16, 0)
	NumPut(w, rc,  8, "UInt")
	NumPut(h, rc, 12, "UInt")
	hBrush := DllCall("CreateSolidBrush", "UInt",clrBG, "Ptr")
	DllCall("FillRect", "Ptr",hDC, "Ptr",&rc, "Ptr",hBrush)
	DllCall("DeleteObject", "Ptr",hBrush)
}

;-------------------------------------------------------------------------------
; Make Arrows String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_MakeArrowsStr(szGesture)
{
	global
	static DirD=0xEA, DirL=0xE7, DirR=0xE8, DirU=0xE9
	static Dir1=0xED, Dir2=0xEA, Dir3=0xEE, Dir4=0xE7, Dir6=0xE8, Dir7=0xEB, Dir8=0xE9, Dir9=0xEC
	static Next11:=1, Next12:=17, Next13:=2, Next14:=16, Next16:=2, Next17:=4, Next18:=4, Next19:=9
	static Next21:=17, Next22:=2, Next23:=14, Next24:=1, Next26:=3, Next27:=4, Next28:=8, Next29:=6
	static Next31:=2, Next32:=14, Next33:=3, Next34:=2, Next36:=15, Next37:=7, Next38:=6, Next39:=6
	static Next41:=16, Next42:=1, Next43:=2, Next44:=4, Next46:=6, Next47:=11, Next48:=7, Next49:=8
	static Next61:=2, Next62:=3, Next63:=15, Next64:=4, Next66:=6, Next67:=8, Next68:=9, Next69:=12
	static Next71:=4, Next72:=4, Next73:=3, Next74:=11, Next76:=8, Next77:=7, Next78:=10, Next79:=8
	static Next81:=4, Next82:=2, Next83:=6, Next84:=7, Next86:=9, Next87:=10, Next88:=8, Next89:=13
	static Next91:=1, Next92:=6, Next93:=6, Next94:=8, Next96:=12, Next97:=8, Next98:=13, Next99:=9

	Loop, Parse, MG_BtnNames, _
	{
		if (A_LoopField) {
			szGesture := RegExReplace(szGesture, A_LoopField . "_")
		}
	}
	szGesture := RegExReplace(szGesture, "_")
	RegExMatch(szGesture, "[DLRU12346789]*", $)
	if (!StrLen($))
	{
		return
	}
	local szArrows:="", num:=0, dirPrev:=0
	Loop, Parse, $
	{
		szArrows .= Chr(Dir%A_LoopField%)
		if (MG_UseExNavi==2)
		{
			local dirThis:=A_LoopField
			if (dirThis = "L") {
				dirThis:="4"
			}
			else if (dirThis = "R") {
				dirThis:="6"
			}
			else if (dirThis = "U") {
				dirThis:="8"
			}
			else if (dirThis = "D") {
				dirThis:="2"
			}
			num++
			MG_ArrowPos%num% := Next%dirPrev%%dirThis%
			dirPrev := dirThis
		}
	}
	return szArrows
}

;-------------------------------------------------------------------------------
; Update Advanced Gesture Hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateAdNavi()
{
	global
	static prevX:=0, prevY:=0
	;...........................................................................
	; Critical Section
	static fCritical := 0
	if (fCritical) {
		return
	}
	fCritical := 1
	;...........................................................................
	; Check Gesture Conditions
	local szGesture := MG_NaviPrst ? MG_NaviPrstStr : MG_Gesture
	if (!szGesture)
	{
		fCritical := 0
		return
	}
	if (!MG_AdNaviOnClick && (szGesture = MG_1stTrigger))
	{
		Gui, MGW_ExNavi:Hide
		fCritical := 0
		return
	}
	;...........................................................................
	; Decide Drawing Position
	local winX, winY, newDPI, bDpiChanged:=false
	if (MG_AdNaviPosition == 0)
	{
		if (MG_AdNaviMargin < 0)
		{
			winX:=MG_X, winY:=MG_Y
		}
		else
		{
			CoordMode,Mouse,Screen
			MouseGetPos, winX, winY
			winX += MG_AdjustToDPI(MG_AdNaviMargin)
			winY += MG_AdjustToDPI(MG_AdNaviMargin)
			if (prevX!=winX || prevY!=winY) {
				newDPI := MG_GetDpiFromPoint(winX, winY)
				if (newDPI != MG_ScreenDPI) {
					MG_ScreenDPI := newDPI
					bDpiChanged := true
				}
			}
		}
	}
	;...........................................................................
	; Draw Gesture Pattern
	if ((szGesture!=MG_PrevGesture) || bDpiChanged)
	{
		local hDC := DllCall("GetWindowDC", "Ptr",MG_ExNaviHwnd, "Ptr")
		MG_hFntBtn := MG_CreateFont(MG_AdNaviFont, MG_AdNaviSize, 700)
		MG_hFntDir := MG_CreateFont("Wingdings", MG_AdNaviSize)
		MG_hFntAct := MG_CreateFont(MG_AdNaviFont, MG_AdNaviSize)
		DllCall("SetBkColor", "Ptr",hDC, "UInt",MG_AdNaviBG2)
		if (MG_UseExNavi==3) {
			MG_UpdateAdNavi1(hDC, winX, winY, szGesture)
		}
		else if (MG_UseExNavi==4) {
			MG_UpdateAdNavi2(hDC, winX, winY, szGesture)
		}
		DllCall("DeleteObject", "Ptr",MG_hFntBtn)
		DllCall("DeleteObject", "Ptr",MG_hFntDir)
		DllCall("DeleteObject", "Ptr",MG_hFntAct)
		DllCall("ReleaseDC", "Ptr",MG_ExNaviHwnd, "Ptr",hDC)
	}
	;...........................................................................
	; Only Move Window
	else if ((MG_AdNaviPosition==0)
	&&		 (prevX!=winX || prevY!=winY))
	{
		local dwStyle
		WinGet, dwStyle, Style, ahk_id %MG_ExNaviHwnd%
		if (dwStyle & 0x10000000) {
			Gui, MGW_ExNavi:Show, x%winX% y%winY% NA
		}
	}
	prevX:=winX, prevY:=winY
	MG_PrevGesture := szGesture
	fCritical := 0
}

;-------------------------------------------------------------------------------
; Update Advanced Gesture Hints Type 1
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateAdNavi1(hDC, winX, winY, szGesture)
{
	global
	local gesW, gesH
	MG_DrawGesture(hDC, 0, 0, szGesture, gesW, gesH, 1)
	MG_ActionStr := ""
	if (IsLabel("MG_GetAction_" . szGesture . "_")) {
		GoSub, MG_GetAction_%szGesture%_
	}
	local actW:=0, actH:=0
	if (MG_ActionStr)
	{
		MG_ActionStr := " : " . MG_ActionStr
		MG_DrawAction(hDC, 0, 0, MG_ActionStr, 1, actW, actH)
	}
	local winW := gesW + actW + MG_AdjustToDPI(MG_AdNaviPaddingL) + MG_AdjustToDPI(MG_AdNaviPaddingR)
	local winH := (gesH>actH ? gesH : actH) + MG_AdjustToDPI(MG_AdNaviPaddingT) + MG_AdjustToDPI(MG_AdNaviPaddingB)
	if (! winW || !winH) {
		return
	}
	MG_SetAdNaviPos(winX, winY, winW, winH)
	Gui, MGW_ExNavi:Show, x%winX% y%winY% w%winW% h%winH% NA
	MG_RoundWindow(hDC, winW, winH, MG_AdjustToDPI(MG_AdNaviRound), MG_AdNaviBG2, MG_AdNaviTransClr2)
	DllCall("SetTextColor", "Ptr",hDC, "UInt",MG_AdNaviFG2)
	MG_DrawGesture(hDC, MG_AdjustToDPI(MG_AdNaviPaddingL), MG_AdjustToDPI(MG_AdNaviPaddingT), szGesture, gesW, gesH)
	if (actW) {
		MG_DrawAction(hDC, MG_AdjustToDPI(MG_AdNaviPaddingL)+gesW, MG_AdjustToDPI(MG_AdNaviPaddingT), MG_ActionStr)
	}
}

;-------------------------------------------------------------------------------
; Update Advanced Gesture Hints Type 2 (Gesture Navigation)
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateAdNavi2(hDC, winX, winY, szGesture)
{
	global
	local gesW:=0, gesH:=0, actW:=0, nGes:=0, szGes:="", len:=StrLen(szGesture)
	;...........................................................................
	; Compare current gesture to registered gestures
	Loop, %Gesture_Count%
	{
		local idxGes:=A_Index
		Loop, Parse, Gesture_%A_Index%_Patterns, `n
		{
			if (InStr(A_LoopField, szGesture)==1)
			{
				;...............................................................
				; Eliminate the cases matched to part of button names
				local dir1:=A_LoopField, dir2:=szGesture
				Loop, Parse, MG_BtnNames, _
				{
					if (A_LoopField) {
						dir1 := RegExReplace(dir1, A_LoopField . "_")
						dir2 := RegExReplace(dir2, A_LoopField . "_")
					}
				}
				if (InStr(dir1, dir2)!=1) {
					Continue
				}
				;...............................................................
				; Get Bound Action String
				MG_ActionStr := ""
				if (IsLabel("MG_GetAction_" . A_LoopField)) {
					GoSub, MG_GetAction_%A_LoopField%
				}
				if (!MG_ActionStr) {
					Continue
				}
				;...............................................................
				; Update size of area to draw
				local tmpW, tmpH1, tmpH2
				MG_DrawGesture(hDC, 0, 0, A_LoopField, tmpW, tmpH1, 1)
				if (gesW < tmpW) {
					gesW := tmpW
				}
				MG_ActionStr := " : " . MG_ActionStr
				MG_DrawAction(hDC, 0, 0, MG_ActionStr, 1, tmpW, tmpH2)
				if (actW < tmpW) {
					actW := tmpW
				}
				nGes++
				nRowH%nGes% := (tmpH1>=tmpH2) ? tmpH1 : tmpH2
				gesH += nRowH%nGes%
				szAct%nGes% := MG_ActionStr
				szGes .= szGes ? "`," : ""
				szGes .= A_LoopField
			}
		}
	}
	;...........................................................................
	; Draw Gesture Patterns and Bound Actions
	if (nGes)
	{
		local winW := gesW + actW + MG_AdjustToDPI(MG_AdNaviPaddingL) + MG_AdjustToDPI(MG_AdNaviPaddingR)
		local winH := gesH + MG_AdjustToDPI(MG_AdNaviPaddingT) + MG_AdjustToDPI(MG_AdNaviPaddingB)
		if (! winW || !winH) {
			return
		}
		MG_SetAdNaviPos(winX, winY, winW, winH)
		Gui, MGW_ExNavi:Show, x%winX% y%winY% w%winW% h%winH% NA
		MG_RoundWindow(hDC, winW, winH, MG_AdjustToDPI(MG_AdNaviRound), MG_AdNaviBG2, MG_AdNaviTransClr2)
		local ptY := MG_AdjustToDPI(MG_AdNaviPaddingT)
		DllCall("SetTextColor", "Ptr",hDC, "UInt",MG_AdNaviFG2)
		Loop, Parse, szGes, `,
		{
			MG_DrawGesture(hDC, MG_AdjustToDPI(MG_AdNaviPaddingL), ptY, A_LoopField, gesW+actW, nRowH%A_Index%, 0, len)
			DllCall("SetTextColor", "Ptr",hDC, "UInt",MG_AdNaviFG2)
			MG_DrawAction(hDC, MG_AdjustToDPI(MG_AdNaviPaddingL)+gesW, ptY, szAct%A_Index%)
			ptY += nRowH%A_Index%
		}
	}
	else
	{
		Gui, MGW_ExNavi:Hide
	}
}

;-------------------------------------------------------------------------------
; Set Display Position of Advanced Gesture Hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetAdNaviPos(ByRef winX, ByRef winY, winW, winH)
{
	global
	if (MG_AdNaviPosition == 0) {
		return
	}
	else if (MG_AdNaviPosition == 1) {
		winX := MG_MonitorL + MG_AdjustToDPI(MG_AdNaviSpaceX)
		winY := MG_MonitorT + MG_AdjustToDPI(MG_AdNaviSpaceY)
	}
	else if (MG_AdNaviPosition == 2) {
		winX := MG_MonitorR - MG_AdjustToDPI(MG_AdNaviSpaceX) - winW
		winY := MG_MonitorT + MG_AdjustToDPI(MG_AdNaviSpaceY)
	}
	else if (MG_AdNaviPosition == 3) {
		winX := MG_MonitorL + MG_AdjustToDPI(MG_AdNaviSpaceX)
		winY := MG_MonitorB - MG_AdjustToDPI(MG_AdNaviSpaceY) - winH
	}
	else if (MG_AdNaviPosition == 4) {
		winX := MG_MonitorR - MG_AdjustToDPI(MG_AdNaviSpaceX) - winW
		winY := MG_MonitorB - MG_AdjustToDPI(MG_AdNaviSpaceY) - winH
	}
}

;-------------------------------------------------------------------------------
; Round Window Corners
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_RoundWindow(hDC, winW, winH, nRadius, clrBG, clrTrans)
{
	if (nRadius <= 0)
	{
		return
	}
	winW++, winH++
	hBrsB := DllCall("CreateSolidBrush", "UInt",clrBG, "Ptr")
	hBrsT := DllCall("CreateSolidBrush", "UInt",clrTrans, "Ptr")
	hRgn1 := DllCall("CreateRectRgn", "Int",0, "Int",0, "Int",winW, "Int",winH, "Ptr")
	hRgn2 := DllCall("CreateRoundRectRgn", "Int",0, "Int",0, "Int",winW, "Int",winH, "Int",nRadius*2, "Int",nRadius*2, "Ptr")
	DllCall("CombineRgn", "Ptr",hRgn1, "Ptr",hRgn1, "Ptr",hRgn2, "Int",4)
	DllCall("FillRgn", "Ptr",hDC, "Ptr",hRgn1, "Ptr",hBrsT)
	DllCall("FillRgn", "Ptr",hDC, "Ptr",hRgn2, "Ptr",hBrsB)
	DllCall("DeleteObject", "Ptr",hBrsB)
	DllCall("DeleteObject", "Ptr",hBrsT)
	DllCall("DeleteObject", "Ptr",hRgn1)
	DllCall("DeleteObject", "Ptr",hRgn2)
}

;-------------------------------------------------------------------------------
; Draw Action String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DrawAction(hDC, ptX, ptY, szAction, fMeasure=0, ByRef strW=0, ByRef strH=0)
{
	global MG_hFntAct, MG_AdNaviNI2

	hFntOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",MG_hFntAct, "Ptr")
	if (fMeasure)
	{
		VarSetCapacity(size, 8, 0)
		DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",szAction, "Int",StrLen(szAction), "Ptr",&size)
		strW := NumGet(size, 0, "UInt")
		strH := NumGet(size, 4, "UInt")
	}
	else
	{
		DllCall("TextOut", "Ptr",hDC, "Int",ptX, "Int",ptY, "Str",szAction, "Int",StrLen(szAction))
	}
	DllCall("SelectObject", "Ptr",hDC, "Ptr",hFntOld)
}



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Trail
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Start Gesture Trail
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StartTrail()
{
	global
	if (MG_ShowTrail)
	{
		SetTimer, MG_DrawTrail, -1
		SetTimer, MG_DrawTrail, %MG_TrailInterval%
	}
}

;-------------------------------------------------------------------------------
; Stop Gesture Trail
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StopTrail()
{
	global
	if (MG_ShowTrail)
	{
		SetTimer, MG_DrawTrail, Off
		if (MG_TrailDrawing) {
			SetTimer, MG_StopTrail, -100
		} else {
			MG_ClearTrail()
		}
	}
}

;-------------------------------------------------------------------------------
; Initialize Gesture Trail
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InitTrail()
{
	local style, x, y, width, height, trans

	MG_TrailDrawn := 0
	MG_TrailColor2 := MG_ConvertHex(MG_TrailColor)
	MG_TrailTransClr := (MG_TrailColor!="FF00FF") ? "FF00FF" : "FE00FE"
	MG_TrailTransClr2 := MG_ConvertHex(MG_TrailTransClr)
	if (MG_DrawTrailWnd)
	{
		SysGet, x,		76
		SysGet, y,		77
		SysGet, width,  78
		SysGet, height, 79
		x++, y++, width--, height--
		Gui, MGW_Trail:New
		Gui, MGW_Trail:+HwndMG_TrailHwnd -Caption +ToolWindow +E0x08000020 +LastFound
		Gui, MGW_Trail:Color, %MG_TrailTransClr%
		trans := ""
		if (0<MG_TrailTranspcy && MG_TrailTranspcy<255) {
			trans := " " . MG_TrailTranspcy
		}
		WinSet, TransColor, %MG_TrailTransClr%%trans%
		Gui, MGW_Trail:Show, x%x% y%y% w%width% h%height% NA
	}
}

;-------------------------------------------------------------------------------
; Draw Gesture Trail
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DrawTrail()
{
	global
	;...........................................................................
	; Critical Section
	if (!MG_ShowTrail || MG_TrailDrawing) {
		return
	}
	MG_TrailDrawing := 1
	;...........................................................................
	; Check Cursor Movement
	local curX, curY
	CoordMode, Mouse, Screen
	MouseGetPos, curX, curY
	if (!MG_TrailDrawn) {
		if ((MG_X-curX)**2+(MG_Y-curY)**2 < MG_TrailStartMove**2) {
			MG_TrailDrawing := 0
			return
		} else {
			MG_TrailDrawn := 1
			Gui, MGW_Trail:+AlwaysOnTop
		}
	}
	local x1:=MG_TX, y1:=MG_TY, x2:=curX, y2:=curY
	if (MG_DrawTrailWnd)
	{
		Gui, MGW_Trail:+LastFound
		WinGetPos, left, top
		x1-=left, x2-=left, y1-=top, y2-=top
	}
	local hWnd := MG_DrawTrailWnd ? MG_TrailHwnd : 0
	local hDC := DllCall("GetWindowDC", "Ptr",hWnd, "Ptr")
	local hPen := DllCall("CreatePen", "Ptr",0, "Ptr",MG_AdjustToDPI(MG_TrailWidth), "Int",MG_TrailColor2)
	local hPenOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",hPen, "Ptr")
	DllCall("MoveToEx", "Ptr",hDC, "Ptr",x1, "Ptr",y1, "Ptr",0)
	DllCall("LineTo", "Ptr",hDC, "Ptr",x2, "Ptr",y2)
	DllCall("SelectObject", "Ptr",hDC, "Ptr",hPenOld)
	DllCall("DeleteObject", "Ptr",hPen)
	DllCall("ReleaseDC", "Ptr",hWnd, "Ptr",hDC)
	MG_TX:=curX, MG_TY:=curY
	;...........................................................................
	; Update bounding rectangle of Gesture Trail
	if (MG_TL > curX) {
		MG_TL := curX
	}
	if (MG_TR < curX) {
		MG_TR := curX
	}
	if (MG_TT > curY) {
		MG_TT := curY
	}
	if (MG_TB < curY) {
		MG_TB := curY
	}
	MG_TrailDrawing := 0
}

;-------------------------------------------------------------------------------
; Clear Gesture Trail
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ClearTrail()
{
	local l, t, r, b, rc, owL, owT

	if (!MG_ShowTrail || !MG_TrailDrawn)
	{
		return
	}
	MG_TrailDrawn := 0
	;...........................................................................
	; Set Bounding Rectangle of Gesture Trail
	l := MG_TL-MG_AdjustToDPI(MG_TrailWidth)-1
	t := MG_TT-MG_AdjustToDPI(MG_TrailWidth)-1
	r := MG_TR+MG_AdjustToDPI(MG_TrailWidth)+1
	b := MG_TB+MG_AdjustToDPI(MG_TrailWidth)+1
	if (MG_DrawTrailWnd) {
		WinGetPos, owL, owT,,, ahk_id %MG_TrailHwnd%
		l-=owL, t-=owT, r-=owL, b-=owT
	}
	VarSetCapacity(rc, 16, 0)
	NumPut(l, rc,  0, "UInt")
	NumPut(t, rc,  4, "UInt")
	NumPut(r, rc,  8, "UInt")
	NumPut(b, rc, 12, "UInt")
	if (MG_DrawTrailWnd) {
		;.......................................................................
		; Clear Overwrap Window
		local hDC := DllCall("GetWindowDC", "Ptr",MG_TrailHwnd, "Ptr")
		local hBrush := DllCall("CreateSolidBrush", "UInt",MG_TrailTransClr2, "Ptr")
		DllCall("FillRect", "Ptr",hDC, "Ptr",&rc, "Ptr",hBrush)
		DllCall("DeleteObject", "Ptr",hBrush)
		DllCall("ReleaseDC", "Ptr",MG_TrailHwnd, "Ptr",hDC)
		Gui, MGW_Trail:-AlwaysOnTop
		WinSet, Bottom,, ahk_id %MG_TrailHwnd%
	} else {
		;.......................................................................
		; Redraw Screen
		DllCall("RedrawWindow", "Ptr",0, "Ptr",&rc, "Ptr",0, "Ptr",0x0587)
	}
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Log Display
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize Log Display
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InitLog()
{
	global
	if (!MG_ShowLogs) {
		return
	}
	MG_Log := []
	MG_LogPtr := MG_LogMax
	Gui, MGW_LogBG:New, -Caption +LastFound +ToolWindow +E0x08000020
	WinSet, Transparent, %MG_LogTranspcy%
	Gui, MGW_LogBG:Color, %MG_LogBG%

	local color, x, y, w, h, wa, waRight, waBottom
	colorBG := MG_MakeTransColor(MG_LogFG)
	Gui, MGW_Log:New, +OwnerMGW_LogBG -Caption +ToolWindow +LastFound +E0x08000020 +Delimiter`n
	WinSet, TransColor, %colorBG%
	Gui, MGW_Log:Font, s%MG_LogFontSize%, %MG_LogFont%
	Gui, MGW_Log:Color, %colorBG%, %colorBG%
	Gui, MGW_Log:Margin, 10, 0
	Gui, MGW_Log:Add, Edit, y10 w%MG_LogSizeW% r%MG_LogMax% vMG_LogList -VScroll -E0x00000200 c%MG_LogFG%
	Gui, MGW_Log:Show, AutoSize Hide
	WinGetPos,,, w, h
	SysGet, wa, MonitorWorkArea
	if (MG_LogPosition==1) {
		x:=0, y:=0
	} else if (MG_LogPosition==2) {
		x:=waRight-w, y:=0
	} else if (MG_LogPosition==3) {
		x:=0, y:=waBottom-h
	} else if (MG_LogPosition==4) {
		x:=waRight-w, y:=waBottom-h
	} else {
		x:=MG_LogPosX, y:=MG_LogPosY
	}
	Gui, MGW_LogBG:Show, x%x% y%y% w%w% h%h% NA, MouseGestureL.ahk Logs
	Gui, MGW_Log:Show, x%x% y%y% NA, MouseGestureL.ahk Logs
	WinSet, Bottom
	SetTimer, MG_LogTimer, %MG_LogInterval%
}

;-------------------------------------------------------------------------------
; Update Logs
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_UpdateLogs(ges="")
{
	global
	MG_LogPtr := (MG_LogPtr<MG_LogMax) ? MG_LogPtr+1 : 1
	MG_Log[MG_LogPtr] := MG_Gesture . "`t" . A_TickCount-MG_PrevTime . "ms" . "`tdX: " . MG_NowX-MG_PreX . "`tdY: " . MG_NowY-MG_PreY
	if (ges) {
		Gosub, MG_GetAction_%ges%
		MG_Log[MG_LogPtr] .= "`t" . MG_ActionStr
	}
}

;-------------------------------------------------------------------------------
; Update Log Display
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_LogTimer:
	MG_UpdateLogDisplay()
return
MG_UpdateLogDisplay()
{
	global MG_Log, MG_LogPtr, MG_LogMax, MG_LogMax
	static prevPtr := ""
	if (prevPtr == MG_LogPtr) {
		return
	}
	prevPtr := MG_LogPtr
	Loop, %MG_LogMax%
	{
		ptr := MG_LogPtr - MG_LogMax + A_Index
		ptr := ptr<1 ? ptr+MG_LogMax : ptr
		szLog .= MG_Log[ptr] . (A_Index<MG_LogMax ? "`n" : "")
	}
	GuiControl, MGW_Log:, MG_LogList, %szLog%
}

;-------------------------------------------------------------------------------
; Copy Logs to Clipboard
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CopyLogs:
	GuiControlGet, Clipboard, MGW_Log:, MG_LogList
return


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Exit Process
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Exit Operation
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_EndOperation()
{
	global MG_hEventHook
	if (MG_hEventHook) {
		DllCall("UnhookWinEvent", "Ptr",MG_hEventHook)
	}
}

MG_End:
#NoEnv
#Include %A_ScriptDir%\screenclipping.ahk
