;===============================================================================
;
;		MouseGestureL.ahk - Configuration Module
;														Created by lukewarm
;														Modified by Pyonkichi
;===============================================================================
Critical
Menu, Tray, Icon, %A_WinDir%\System32\shell32.dll, 22
MG_IsEdit	  = 1
ME_CmdLineArg = %1%
ME_DmyObj := Object("base", Object("__Delete", "ME_Exit"))
#Include %A_ScriptDir%\Components\MG_CommonLib.ahk
#Include *i %A_ScriptDir%\Languages\MG_Language.ahk
MG_CheckLanguage()
if ((ME_CmdLineArg != "/ini2ahk")
&&	MG_SearchPlugins())
{
	Reload
}
InitConstants()
#Include *i %A_ScriptDir%\Config\MG_User.ahk
InitConfigurations()
AddCustomConditions()
CreateGui()
InitActionTemplates()
#Include *i %A_ScriptDir%\Plugins\MG_Plugin.ahk
MG_AddActionCategory("Others", ActionType100)
CloseActionTemplateReg()
GuiControl, MEW_Main:Choose, DDLActionCategory, `n1

ShowConfig()
ShowTargets(true)
ShowGestures()
GuiControl, MEW_Main:Choose, LBGesture, `n1

EnableGestureControls()
On8DirChange(false)
Gosub, OnNaviChange
Gosub, OnNaviPosChange
Gosub, OnShowTrailChange
Gosub, OnShowLogsChange
Gui, MEW_Main:Show, Hide Autosize, %ME_LngCapt002%
AdjustDialogHeight(true)

Critical,Off
Gui, MEW_Main:Show
GuiControl, MEW_Main:Focus, TVTarget1
AdjustTextPos()
return

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Exit Process
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
MEW_MainGuiClose:
MEW_MainGuiEscape:
ME_Exit:
	ExitApp

;-------------------------------------------------------------------------------
; Terminal Operation
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_Exit()
{
	global
	IL_Destroy(MG_hImageList)
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Hotkeys
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#If WinActive("ahk_id " ME_hWndMain)
~^1::	SwitchTab(1)
~^2::	SwitchTab(2)
~^3::	SwitchTab(3)
~^4::	SwitchTab(4)
~^5::	SwitchTab(5)
~^6::	SwitchTab(6)
~^7::	SwitchTab(7)
~^E::	EditAction()
~^F::	SwitchTargetFolding(true)
~^N::	OnNewItemKeyPress()
~^C::	OnCopyKeyPress()
~^V::	OnPasteKeyPress()
~Del::	OnDeleteKeyPress()
~F1::	MG_ShowHelp()
#If

#If (WinActive("ahk_id " ME_hWndMain) && IsAnyListActive())
+Up::	OnMoveUpKeyPress()
+Down::	OnMoveDownKeyPress()
#If


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Initialize Configurations
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize Constants
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConstants()
{
	local type

	; Size of lists
	ME_ListH	:= 460		; Height of Lists
	ME_TListW1	:= 200		; [P.1] Width  of Target List
	ME_GListW1	:= 500		; [P.1] Width  of Gesture List
	ME_GListH	:= 187		; [P.1] Height of Gesture List
	ME_GListR	:= 35		; [P.1] Ratio  of Gesture Column Width of Gesture List (%)
	ME_TListW2	:= 200		; [P.2] Width  of Target List
	ME_RListR	:= 35		; [P.2] Ratio  of Type Column Width of Rule List (%)
	ME_GListW2	:= 150		; [P.3] Width  of Gesture List
	ME_GListW3	:= 250		; [P.3] Width  of Gesture Pattern List
	ME_AListR	:= 50		; [P.3] Ratio  of Target Column Width of Action List (%)
	ME_ListPad	:= 8		; Padding

	; Rule Types
	RuleType_1 = WClass
	RuleType_2 = CClass
	RuleType_3 = Exe
	RuleType_4 = Title
	RuleType_5 = Custom
	RuleType_6 = Include

	Loop, Parse, ME_LngDropDown002, `n
	{
		type := RuleType_%A_Index%
		RuleType_%type% := A_Index
		RuleDisp_%type% := A_LoopField
	}

	; Flags
	ME_bTvRenaming := false

	; for Display of Gestures Patterns
	MG_ScreenDPI := A_ScreenDPI
	MG_AdNaviSize := 9
}
;-------------------------------------------------------------------------------
; Initialize Configurations
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
InitConfigurations()
{
	InitConfRecognition()
	InitConfNavi()
	InitConfAdNavi()
	InitConfTrail()
	InitConfLogs()
	InitConfOthers()
	LoadConfigurations()
}
;-------------------------------------------------------------------------------
; Initialize Configurations of Recognition Process
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConfRecognition()
{
	global
	ConfRecognition =
	(LTrim
		IniFileVersion
		8Dir
		ActiveAsTarget
		Interval
		PrvntCtxtMenu
		Threshold
		LongThresholdX
		LongThresholdY
		LongThreshold
		TimeoutThreshold
		Timeout
		DGInterval
		TmReleaseTrigger
		ORangeDefault
		ORangeA
		ORangeB
		EdgeInterval
		EdgeIndiv
		CornerX
		CornerY
		DisableDefMB
		DisableDefX1B
		DisableDefX2B
	)
	InitConfigs(ConfRecognition)
	Config_8Dir				= 0
	Config_ActiveAsTarget	= 0
	Config_Interval			= 20
	Config_PrvntCtxtMenu	= 0
	Config_Threshold		= 60
	Config_LongThresholdX	= 800
	Config_LongThresholdY	= 600
	Config_LongThreshold	= 700
	Config_TimeoutThreshold	= 12
	Config_Timeout			= 400
	Config_DGInterval		= 0
	Config_TmReleaseTrigger	= 3
	Config_ORangeDefault	= 3
	Config_ORangeA			= 3
	Config_ORangeB			= 3
	Config_EdgeInterval		= 20
	Config_EdgeIndiv		= 0
	Config_CornerX			= 1
	Config_CornerY			= 1
	Config_DisableDefMB		= 0
	Config_DisableDefX1B	= 0
	Config_DisableDefX2B	= 0
}
;-------------------------------------------------------------------------------
; Initialize Configurations of Gesture Hints
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConfNavi()
{
	global
	ConfNavi =
	(LTrim
		UseNavi
		UseExNavi
		NaviInterval
		NaviPersist
		ExNaviTransBG
		ExNaviFG
		ExNaviBG
		ExNaviTranspcy
		ExNaviSize
		ExNaviSpacing
		ExNaviPadding
		ExNaviMargin
	)
	InitConfigs(ConfNavi)
	Config_UseNavi			= 1
	Config_UseExNavi		= 3
	Config_NaviInterval		= 10
	Config_NaviPersist		= 0
	Config_ExNaviTransBG	= 1
	Config_ExNaviFG			= 000000
	Config_ExNaviBG			= FFFFFF
	Config_ExNaviTranspcy	= 255
	Config_ExNaviSize		= 24
	Config_ExNaviSpacing	= 2
	Config_ExNaviPadding	= 4
	Config_ExNaviMargin		= 8
}
;-------------------------------------------------------------------------------
; Initialize Configurations of Advanced Gesture Hints
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConfAdNavi()
{
	global
	ConfAdNavi =
	(LTrim
		AdNaviFG
		AdNaviNI
		AdNaviBG
		AdNaviTranspcy
		AdNaviSize
		AdNaviFont
		AdNaviPosition
		AdNaviPaddingL
		AdNaviPaddingR
		AdNaviPaddingT
		AdNaviPaddingB
		AdNaviRound
		AdNaviMargin
		AdNaviSpaceX
		AdNaviSpaceY
		AdNaviOnClick
	)
	InitConfigs(ConfAdNavi)
	Config_AdNaviFG			= FFFFFF
	Config_AdNaviNI			= 7F7F7F
	Config_AdNaviBG			= 000000
	Config_AdNaviTranspcy	= 220
	Config_AdNaviSize		= 11
	Config_AdNaviPosition	= 0
	Config_AdNaviPaddingL	= 6
	Config_AdNaviPaddingR	= 6
	Config_AdNaviPaddingT	= 3
	Config_AdNaviPaddingB	= 3
	Config_AdNaviRound		= 2
	Config_AdNaviMargin		= 14
	Config_AdNaviSpaceX		= 2
	Config_AdNaviSpaceY		= 2
	Config_AdNaviOnClick	= 0
	if (MG_IsNewOS()) {
		Config_AdNaviFont := ME_AdNaviFont
	} else {
		Config_AdNaviFont := "Tahoma"
	}
}
;-------------------------------------------------------------------------------
; Initialize Configurations of Gesture Trail
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConfTrail()
{
	global
	ConfTrail =
	(LTrim
		ShowTrail
		DrawTrailWnd
		TrailColor
		TrailTranspcy
		TrailWidth
		TrailStartMove
		TrailInterval
	)
	InitConfigs(ConfTrail)
	Config_ShowTrail		= 0
	Config_DrawTrailWnd		= 1
	Config_TrailColor		= 0000FF
	Config_TrailTranspcy	= 255
	Config_TrailWidth		= 3
	Config_TrailStartMove	= 3
	Config_TrailInterval	= 10
}
;-------------------------------------------------------------------------------
; Initialize Configurations of Log Display
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConfLogs()
{
	global
	ConfLogs =
	(LTrim
		ShowLogs
		LogPosition
		LogPosX
		LogPosY
		LogMax
		LogSizeW
		LogInterval
		LogFG
		LogBG
		LogTranspcy
		LogFontSize
		LogFont
	)
	InitConfigs(ConfLogs)
	Config_ShowLogs			= 0
	Config_LogPosition		= 4
	Config_LogPosX			= 0
	Config_LogPosY			= 0
	Config_LogMax			= 20
	Config_LogSizeW			= 400
	Config_LogInterval		= 500
	Config_LogFG			= FFFFFF
	Config_LogBG			= 000000
	Config_LogTranspcy		= 100
	Config_LogFontSize		= 10
	Config_LogFont			= MS UI Gothic
}
;-------------------------------------------------------------------------------
; Initialize Other Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitConfOthers()
{
	global
	ConfOthers =
	(LTrim
		EditCommand
		HotkeyEnable
		HotkeyNavi
		HotkeyReload
		ScriptEditor
		TraySubmenu
		AdjustDlg
		DlgHeightLimit
		FoldTarget
	)
	InitConfigs(ConfOthers)
	Config_TraySubmenu		= 0
	Config_AdjustDlg	 	= 0
	Config_DlgHeightLimit	= 800
	Config_FoldTarget		= 0
}
;-------------------------------------------------------------------------------
; Load Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
LoadConfigurations()
{
	global
	MG_hImageList := IL_Create()
	MG_LoadIniFile(MG_CheckConfigFiles() ? "" : MC_PresetItems)
	GetSystemIcons()
	MG_DefButtons := "LB`nRB`nMB`nX1B`nX2B`nWU`nWD`nLT`nRT"
	LoadButtons()
	if (ME_CmdLineArg = "/ini2ahk") {
		FileDelete, %A_ScriptDir%\Config\MG_Config.ahk
		FileAppend, % ToAhk(), %A_ScriptDir%\Config\MG_Config.ahk, UTF-8
		ExitApp
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Create and Initialize Configuration Dialog Box
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize Custom Conditions
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
AddCustomConditions()
{
	global
	MG_AddConditionCategory("HitTest", ME_LngMenu001)
	MG_AddCustomCondition("HitTest", ME_LngMenu002, "MG_HitTest()=""Caption""")
	MG_AddCustomCondition("HitTest", ME_LngMenu003, "MG_HitTest()=""SysMenu""")
	MG_AddCustomCondition("HitTest", ME_LngMenu004, "MG_HitTest()=""MinButton""")
	MG_AddCustomCondition("HitTest", ME_LngMenu005, "MG_HitTest()=""MaxButton""")
	MG_AddCustomCondition("HitTest", ME_LngMenu006, "MG_HitTest()=""CloseButton""")
	MG_AddCustomCondition("HitTest", ME_LngMenu007, "MG_HitTest()=""HelpButton""")
	MG_AddCustomCondition("HitTest", "", "")
	MG_AddCustomCondition("HitTest", ME_LngMenu008, "MG_HitTest()=""Menu""")
	MG_AddCustomCondition("HitTest", ME_LngMenu009, "MG_HitTest()=""VScroll""")
	MG_AddCustomCondition("HitTest", ME_LngMenu010, "MG_HitTest()=""HScroll""")
	MG_AddCustomCondition("HitTest", ME_LngMenu011, "MG_HitTest()=""Border""")
	MG_AddCustomCondition("HitTest", ME_LngMenu012, "MG_HitTest()=""SizeBorder""")
	MG_AddCustomCondition("HitTest", ME_LngMenu013, "MG_HitTest()=""Client""")
	MG_AddCustomCondition("HitTest", "", "")
	MG_AddCustomCondition("HitTest", ME_LngMenu014, "MG_TreeListHitTest()")

	MG_AddConditionCategory("Cursor", ME_LngMenu015)
	MG_AddCustomCondition("Cursor", ME_LngMenu016, "MG_CheckCursor(32512, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu017, "MG_CheckCursor(32513, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu018, "MG_CheckCursor(32649, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu019, "MG_CheckCursor(32514, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu020, "MG_CheckCursor(32515, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu021, "MG_CheckCursor(32648, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu022, "MG_CheckCursor(32650, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu023, "MG_CheckCursor(32651, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu024, "MG_CheckCursor(32646, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu025, "MG_CheckCursor(32645, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu026, "MG_CheckCursor(32644, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu027, "MG_CheckCursor(32642, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu028, "MG_CheckCursor(32643, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu029, "MG_CheckCursor(32516, 0)")
	MG_AddCustomCondition("Cursor", "", "")
	MG_AddCustomCondition("Cursor", ME_LngMenu030, "MG_CheckAllCursor(1, 0)")
	MG_AddCustomCondition("Cursor", ME_LngMenu031, "MG_CheckAllCursor(0, 0)")

	MG_AddConditionCategory("WinStat", ME_LngMenu032)
	MG_AddCustomCondition("WinStat", ME_LngMenu033, "MG_Win(""MinMax"")==1")
	MG_AddCustomCondition("WinStat", ME_LngMenu034, "MG_Win(""MinMax"")==0")
	MG_AddCustomCondition("WinStat", ME_LngMenu035, "MG_Win(""Transparent"")<255")
	MG_AddCustomCondition("WinStat", ME_LngMenu036, "MG_Win(""Transparent"")=""""")
	MG_AddCustomCondition("WinStat", ME_LngMenu037, "MG_Win(""ExStyle"")&0x08")
	MG_AddCustomCondition("WinStat", ME_LngMenu038, "!(MG_Win(""ExStyle"")&0x08)")

	MG_AddConditionCategory("KeyStat", ME_LngMenu039)
	MG_AddCustomCondition("KeyStat", ME_LngMenu040, "GetKeyState(""Shift"")")
	MG_AddCustomCondition("KeyStat", ME_LngMenu041, "!GetKeyState(""Shift"")")
	MG_AddCustomCondition("KeyStat", ME_LngMenu042, "GetKeyState(""Ctrl"")")
	MG_AddCustomCondition("KeyStat", ME_LngMenu043, "!GetKeyState(""Ctrl"")")
	MG_AddCustomCondition("KeyStat", ME_LngMenu044, "GetKeyState(""Alt"")")
	MG_AddCustomCondition("KeyStat", ME_LngMenu045, "!GetKeyState(""Alt"")")

	MG_AddConditionCategory("Rect", ME_LngMenu046)
	MG_AddCustomCondition("Rect", ME_LngMenu047, "GetRectRelative")
	MG_AddCustomCondition("Rect", ME_LngMenu048, "GetRectAbsolute")
}
;-------------------------------------------------------------------------------
; Create Configuration Dialog Box
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
CreateGui()
{
	global
	wTab := ME_TListW1 + ME_ListPad + ME_GListW1 + 42
	hTab := ME_ListH + 65
	wAvlbl := wTab - 26
	Gui, MEW_Main:New, +HwndME_hWndMain +Delimiter`n
	Gui, MEW_Main:Add, Tab2, x8 y2 w%wTab% h%hTab% vMainTab gOnTabChange AltSubmit, %ME_LngTab001%
	MainTabIdx := 1
	MG_DDLHeight := GetDesktopHeight()
	CreateMainTab()
	CreateTargetsTab()
	CreateGesturesTab()
	CreateRecognitionTab()
	CreateHintsTab()
	CreateTrailTab()
	CreateOthersTab()
	PutCommonButtons()
	;AdjustTextPos()
	GuiControl, MEW_Main:, LBButtons, `n%LBButtons%
	Gui, MEW_Main:Default

	OnMessage(0x0111, "OnCommand")
	OnMessage(0x004E, "OnNotify")
	OnMessage(0x0205, "OnRButtonUp")
	OnMessage(0x0100, "OnKeyDown")
	OnMessage(0x000F, "OnPaint")
}
;-------------------------------------------------------------------------------
; Main : メイン
;-------------------------------------------------------------------------------
CreateMainTab()
{
	local width, width2, height, top, left, tblText
	Gui, MEW_Main:Tab, 1

	; Target list
	Gui, MEW_Main:Add, Text, Section y+8 h16 vLabel1, %ME_LngText001%
	Gui, MEW_Main:Add, TreeView, xs y+6 w%ME_TListW1% h%ME_ListH% vTVTarget1 gTVTargetSelect HwndME_hTVTarget1 -Lines -ReadOnly 0x1000 ImageList%MG_hImageList% AltSubmit

	; Gesture list
	Gui, MEW_Main:Add, Text, Section x+%ME_ListPad% ys h16 vLabel2, %ME_LngText002%
	Gui, MEW_Main:Add, ListView,xs y+6 w%ME_GListW1% h%ME_GListH% Section Grid vLVGesture gLVGestureSelect -Multi NoSortHdr AltSubmit, % ME_LngListView002 "`n "
	width := ME_GListW1 - 22
	width2 := width * ME_GListR // 100
	LV_ModifyCol(1, width2)
	LV_ModifyCol(2, width - width2)
	LV_ModifyCol(3, 0)
	Gui, MEW_Main:Add, Button, x+1 w20 h20 vBReleaseGesture gOnReleaseGesturePress Disabled, %ME_LngButton012%

	; Script editor
	top := ME_GListH+7
	Gui, MEW_Main:Add, Text, xs ys+%top% h16 vLabel3, %ME_LngText004%
	left := ME_GListW1 - 142
	Gui, MEW_Main:Add, Button,	xs+%left% yp-4 w70 h22 vBAddAction	gBAddActionPress, %ME_LngButton014%
	Gui, MEW_Main:Add, Button,	x+2		 w70 h22 vBUpdateAction	gBUpdateActionPress	Disabled, %ME_LngButton015%
	EnblAddAction := "Enable"
	EnblUpdateAction := "Disable"

	height := ME_ListH - ME_GListH - 84
	Gui, MEW_Main:Font, %ME_ScriptSize%, %ME_ScriptFont%
	Gui, MEW_Main:Add, Edit,   xs y+3 w%ME_GListW1% h%height% Section vEAction	gOnActionEditModify -Wrap WantTab T12 +0x00100000 Disabled
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Button, x+1	   w20 h20	vBEditAction	gOnEditActionPress	Disabled, %ME_LngButton016%
	Gui, MEW_Main:Add, Button, xp y+4 w20 h20	vBClearAction	gOnClearActionPress	Disabled, %ME_LngButton012%

	tblText := Array(ME_LngText005)
	width := ME_GListW1 - 8 - GetMaxTextLength(tblText)
	top := height + 8
	Gui, MEW_Main:Add, Text,	xs ys+%top% vLabel4, %ME_LngText005%
	Gui, MEW_Main:Add, DropDownList, x+8  w%width% h%MG_DDLHeight% vDDLActionCategory gOnActionCategoryChange AltSubmit

	width := ME_GListW1 - 61
	Gui, MEW_Main:Add, DropDownList, xs y+8 w%width% h%MG_DDLHeight% vDDLActionTemplate AltSubmit
	Gui, MEW_Main:Add, Button,	x+2 yp-1 w60 h22 vBAddActionLine	gBAddActionLinePress Disabled, %ME_LngButton014%
}
;-------------------------------------------------------------------------------
; Targets : ターゲット
;-------------------------------------------------------------------------------
CreateTargetsTab()
{
	local width, width2, height, tblText
	Gui, MEW_Main:Tab, 2

	; Target list
	Gui, MEW_Main:Add, Button, Section w25 h22 gTargetNew, %ME_LngButton005%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 gTargetDelete vBTargetDelete Disabled, %ME_LngButton006%
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 vBTargetUp	 gTargetUp	 Disabled %ME_ArrowAlignUp%, %ME_LngButton007%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 vBTargetDown gTargetDown Disabled %ME_ArrowAlignDn%, %ME_LngButton008%
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 gTargetSort, %ME_LngButton009%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 gCopyTarget vBCopyTarget Disabled, %ME_LngButton010%
	Gui, MEW_Main:Add, CheckBox,	x+0 w25 h22 0x1000 vConfig_FoldTarget gOnTargetFoldChange, %ME_LngButton011%
	Gui, MEW_Main:Add, TreeView, xs y+2 w%ME_TListW2% h%ME_ListH% vTVTarget2 gTVTargetSelect -Lines -ReadOnly 0x1000 ImageList%MG_hImageList% AltSubmit

	; Target name editor
	ME_RListW := wTab - ME_TListW2 - ME_ListPad - 42
	tblText := Array(ME_LngText051)
	width := ME_RListW - 69 - GetMaxTextLength(tblText)
	Gui, MEW_Main:Add, Text,	x+%ME_ListPad% ys+1 vLabel11 Section, %ME_LngText051%
	Gui, MEW_Main:Add, Edit,	x+8	w%width% vETargetName   gETargetNameChange
	Gui, MEW_Main:Add, Button,	x+2	yp-1 w60 h22 vBTargetRename gTargetRename Disabled, %ME_LngButton013%

	; Rule list
	height	:= ME_ListH - 213
	Gui, MEW_Main:Add, ListView, xs y+2 w%ME_RListW% h%height% Section -Multi NoSortHdr Grid vLVRule gLVRuleSelect AltSubmit, %ME_LngListView001%
	width := ME_RListW - 4
	width2 := width * ME_RListR // 100
	LV_ModifyCol(1, width2)
	LV_ModifyCol(2, width - width2)
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button,	x+1 yp+23 w20 h20 vBRuleUp	gRuleUp		Disabled %ME_ArrowAlignUp%, %ME_LngButton007%
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Button,	y+20 w20 h20 vBRuleDelete	gRuleDelete Disabled, %ME_LngButton012%
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button,	y+20 w20 h20 vBRuleDown		gRuleDown	Disabled %ME_ArrowAlignDn%, %ME_LngButton008%
	Gui, MEW_Main:Font

	GuiControlGet, rcCtrl, MEW_Main:Pos, LVRule
	rcCtrlY += (rcCtrlH + 4)
	width := ME_RListW - 123
	Gui, MEW_Main:Add, DropDownList, xs y%rcCtrlY% w%width% vDDLLogic gDDLLogicChoose	Choose1	AltSubmit Disabled, %ME_LngDropDown001%
	Gui, MEW_Main:Add, Button,	x+2 yp-1 w60 h22 vBAddRule	  gBAddRulePress	Disabled, %ME_LngButton014%
	Gui, MEW_Main:Add, Button,	x+2		 w60 h22 vBUpdateRule gBUpdateRulePress Disabled, %ME_LngButton015%
	EnblAddRule := EnblUpdateRule := "Disable"

	; Rule type
	tblText := Array(ME_LngText052, ME_LngText053, ME_LngText054)
	width := GetMaxTextLength(tblText)
	Gui, MEW_Main:Add, Text,	xs y+6 w%width% vLabel12 Disabled, %ME_LngText052%
	width2 := ME_RListW - 69 - width
	Gui, MEW_Main:Add, DropDownList,x+8 w%width2% vDDLRuleType gOnRuleTypeChange Choose1 AltSubmit Disabled, %ME_LngDropDown002%
	Gui, MEW_Main:Add, Button,	x+2 yp-1 w60 h22 vBRulePicker gBRulePickerPressed Disabled, %ME_LngButton017%

	; Rule value
	Gui, MEW_Main:Add, Text,	xs y+6 w%width% vLabel13 Disabled, %ME_LngText053%
	width2 := ME_RListW - 29 - width
	Gui, MEW_Main:Add, Edit,	x+8 w%width2% vERuleValue gOnRuleEditModify Disabled
	Gui, MEW_Main:Add, Button,	x+0	yp-1 w22 h22 vBClearRule gClearRulePress Disabled, %ME_LngButton012%

	; Matching method
	Gui, MEW_Main:Add, Text,	xs y+8 w%width% vLabel14 Disabled, %ME_LngText054%
	width2 := ME_RListW - 8 - width
	Gui, MEW_Main:Add, DropDownList,x+8 w%width2% vDDLMatchRule gOnRuleTypeChange Choose1 AltSubmit Disabled, %ME_LngDropDown003%

	Gui, MEW_Main:Add, CheckBox, xp+0 y+8 vChkNotMatch gOnRuleTypeChange Disabled, %ME_LngCheckBox001%
	Gui, MEW_Main:Add, CheckBox, x+20 vChkNotInhRules gOnNotInhRulesChange Disabled, %ME_LngCheckBox002%

	; Icon
	width2 := ME_RListW-4
	Gui, MEW_Main:Add, GroupBox, xs+4 w%width2% h80 Section vGroupIcon, %ME_LngGroupBox017%
	width2 := ME_RListW - 97
	Gui, MEW_Main:Add, Edit, xs+16 yp+18 w%width2% Section vEIconFile gOnIconChange
	Gui, MEW_Main:Add, Button,x+2 yp-1 w60 h22 vBBrowseIcon gOnBrowseIcon, %ME_LngButton027%

	Gui, MEW_Main:Add, Picture, xs+20 y+12 w16 h16 Section vPicIcon AltSubmit
	Gui, MEW_Main:Add, Edit, x+20 yp-2 w48 vEIconIndex gOnIconChange
	Gui, MEW_Main:Add, UpDown, Range1-1000 128 vUDIconIndex
	Gui, MEW_Main:Add, Button,	x+10 yp-2 w120 h24 vBApplyIcon gOnApplyIcon Disabled, %ME_LngButton028%
}
;-------------------------------------------------------------------------------
; Gestures : ジェスチャー
;-------------------------------------------------------------------------------
CreateGesturesTab()
{
	local width, width2, height, top, left, tblText, hBaseBox

	Gui, MEW_Main:Tab, 3

	; Gesture list
	Gui, MEW_Main:Add, Button, Section w25 h22 gGestureNew, %ME_LngButton005%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 vBGestureDelete1 gGestureDelete Disabled, %ME_LngButton006%
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 vBGestureUp1   gGestureUp   Disabled %ME_ArrowAlignUp%, %ME_LngButton007%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 vBGestureDown1 gGestureDown Disabled %ME_ArrowAlignDn%, %ME_LngButton008%
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 gGestureSort, %ME_LngButton009%
	Gui, MEW_Main:Add, Button,		x+0 w25 h22 gCopyGesture vBCopyGesture1 Disabled, %ME_LngButton010%
	Gui, MEW_Main:Add, ListBox,xs y+2 w%ME_GListW2% h%ME_ListH% vLBGesture gLBGestureSelect AltSubmit
	Gui, MEW_Main:-DPIScale
	GuiControlGet, rcCtrl, MEW_Main:Pos, LBGesture
	Gui, MEW_Main:+DPIScale
	DefListHeight := rcCtrlH

	; Pattern list
	tblText := Array(ME_LngText051)
	width := ME_GListW3 - 69 - GetMaxTextLength(tblText)
	Gui, MEW_Main:Add, Text,	x+%ME_ListPad% ys+1 vLabel21 Section, %ME_LngText051%
	Gui, MEW_Main:Add, Edit,	x+8 w%width% vEGestureName gEGestureNameChange
	Gui, MEW_Main:Add, Button,	x+2 yp-1 w60 h22 vBGestureRename gGestureRename Disabled, %ME_LngButton013%

	width := ME_GListW3 - 21
	height	:= ME_ListH - 360
	Gui, MEW_Main:Add, ListBox,	xs y+2 w%width% h%height% vLBGesturePattern	gLBGesturePatternSelect Section AltSubmit

	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button,	x+1	ys w20  h20	vBGesturePatternUp		gGesturePatternUp		Disabled %ME_ArrowAlignUp%, %ME_LngButton007%
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Button,	y+20 w20  h20	vBGesturePatternDelete	gGesturePatternDelete	Disabled, %ME_LngButton012%
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button,	y+20 w20  h20	vBGesturePatternDown	gGesturePatternDown		Disabled %ME_ArrowAlignDn%, %ME_LngButton008%
	Gui, MEW_Main:Font

	; Gesture pattern editor
	top := height + 3
	width := ME_GListW3 - 103
	Gui, MEW_Main:Add, Edit,	xs ys+%top% w%width% vEGesture				gEGestureChange			Disabled
	Gui, MEW_Main:Add, Button,	x+2	yp-1 w50 h22 vBAddGesturePattern		gAddGesturePattern		Disabled, %ME_LngButton014%
	Gui, MEW_Main:Add, Button,	x+2		 w50 h22 vBUpdateGesturePattern		gUpdateGesturePattern	Disabled, %ME_LngButton015%
	EnblAddGesturePattern := EnblUpdateGesturePattern := "Disable"

	; Gesture pattern display
	width := ME_GListW3 - 22 + 1
	Gui, MEW_Main:Add, Edit,	xs y+2 w%width%  h20 vGesturePatternBox -Tabstop Disabled
	Gui, MEW_Main:Add, Button,	x+0	yp-1 w22 h22 vBClearGesture				gClearGesturePress		Disabled, %ME_LngButton012%
	Gui, MGW_GPBox:New
	GuiControlGet, hBaseBox, MEW_Main:HWND, GesturePatternBox
	Gui, MGW_GPBox:+HwndME_hGesPatBox -Caption +Parent%hBaseBox% +0x40000000 +E0x08000020 +LastFound
	GuiControlGet, ME_GPBoxSize, MEW_Main:Pos, GesturePatternBox
	Gui, MGW_GPBox:Show, x0 y0 w%ME_GPBoxSizeW% h%ME_GPBoxSizeH% NA
	Gui, MEW_Main:Default

	; Trigger list
	Gui, MEW_Main:Add, Text,	xs y+10 vLabel22 Section, %ME_LngText021%
	Gui, MEW_Main:Add, ListBox,xs y+8 w%ME_GListW3% h136 vLBButtons gLBButtons AltSubmit
	left := ME_GListW3 - 129
	Gui, MEW_Main:Add, Button,	xs+%left% y+2 w130 vBAddTrigger gOnAddTriggerPress, %ME_LngButton019%

	; Buttons
	Gui, MEW_Main:Add, Text,	xs y+3 vLabel23 Section, %ME_LngText022%
	Gui, MEW_Main:Font, S14, Wingdings
	Gui, MEW_Main:Add, Button, xs	  ys+20	w32 h32 vBStrokeUL	gDir7 Disabled,			% Chr(0xEB)
	Gui, MEW_Main:Add, Button, x+1			w32	h32 vBStrokeU	gDir8 Disabled +0x0400,	% Chr(0xE9)
	Gui, MEW_Main:Add, Button, x+1			w32	h32 vBStrokeUR	gDir9 Disabled,			% Chr(0xEC)
	Gui, MEW_Main:Add, Button, xs	  y+2	w32 h32 vBStrokeL	gDir4 Disabled,			% Chr(0xE7)
	Gui, MEW_Main:Add, Button, x+34			w32	h32 vBStrokeR	gDir6 Disabled,			% Chr(0xE8)
	Gui, MEW_Main:Add, Button, xs	  y+2	w32 h32 vBStrokeDL	gDir1 Disabled,			% Chr(0xED)
	Gui, MEW_Main:Add, Button, x+1			w32	h32 vBStrokeD	gDir2 Disabled +0x0800, % Chr(0xEA)
	Gui, MEW_Main:Add, Button, x+1			w32	h32 vBStrokeDR	gDir3 Disabled,			% Chr(0xEE)
	Gui, MEW_Main:Font

	Gui, MEW_Main:Add, Button,	x+10  ys+20	w142 h45 vBButtonUp	gBButtonUp Disabled, %ME_LngButton020%
	Gui, MEW_Main:Add, Button,		   y+10 w142 h45 vBGesturePatternBS gGesturePatternBS Disabled, %ME_LngButton021%

	; Default Action
	GuiControlGet, rcCtrl, MEW_Main:Pos, BGestureDelete1
	rcCtrlY += 2
	width := wTab - ME_GListW2 - ME_GListW3 - ME_ListPad*2 - 42
	Gui, MEW_Main:Add, Picture, Section x+%ME_ListPad% y%rcCtrlY% w16 h16 vDefIcon Icon16 AltSubmit, % A_WinDir "\System32\shell32.dll"
	Gui, MEW_Main:Add, Text, x+2 yp h16 vLabel24, %ME_LngText025%
	Gui, MEW_Main:Add, ListBox, xs y+6 w%width% h16 vLBDefAction gLBDefActionSelect AltSubmit

	; Target prioritie list
	height := ME_ListH - 46
	Gui, MEW_Main:Add, Text, xs y+8 h16 vLabel25, %ME_LngText003%
	Gui, MEW_Main:Add, ListView,xs y+6 w%width% h%height% Grid vLVAction gLVActionSelect -Multi NoSortHdr AltSubmit, % ME_LngListView003 "`n "
	LV_SetImageList(MG_hImageList)

	width -= 4
	width2 := width * ME_AListR // 100
	LV_ModifyCol(1, width2)
	LV_ModifyCol(2, width - width2)
	LV_ModifyCol(3, 0)
	Gui, MEW_Main:Add, Text, x+1 yp+8 w20 Center, %ME_LngText026%
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button, y+2 w20 h20 vBActionUp gActionUp	  Disabled %ME_ArrowAlignUp%, %ME_LngButton007%
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Button, y+20 w20 h20 vBActionDelete	gActionDelete Disabled, %ME_LngButton012%
	Gui, MEW_Main:Font, %ME_ArrowSize%, %ME_ArrowFont%
	Gui, MEW_Main:Add, Button, y+20 w20 h20 vBActionDown	gActionDown	  Disabled %ME_ArrowAlignDn%, %ME_LngButton008%
	Gui, MEW_Main:Font
	Gui, MEW_Main:Add, Text, y+2 w20 Center, %ME_LngText027%
}
;-------------------------------------------------------------------------------
; Recognition : 認識設定
;-------------------------------------------------------------------------------
CreateRecognitionTab()
{
	local width, width2, top, left, tblText
	Gui, MEW_Main:Tab, 4

	Gui, MEW_Main:Add, GroupBox,xm+10 y+8 w%wAvlbl% h84 Section, %ME_LngGroupBox001%
	Gui, MEW_Main:Add, CheckBox,xs+12 ys+20 vConfig_8Dir gOn8DirChange, %ME_LngCheckBox003%
	Gui, MEW_Main:Add, CheckBox,xs+12 y+8 vConfig_ActiveAsTarget, %ME_LngCheckBox004%
	Gui, MEW_Main:Add, CheckBox,xs+12 y+8 vConfig_PrvntCtxtMenu, %ME_LngCheckBox017%

	Gui, MEW_Main:Add, Text,xs+370 ys+20 vLabel31, %ME_LngText100%
	Gui, MEW_Main:Add, Edit,x+8 w48 vConfig_Interval
	Gui, MEW_Main:Add, UpDown, Range0-10000 128


	tblText := Array(ME_LngText101, ME_LngText102, ME_LngText103, ME_LngText104)
	width := GetMaxTextLength(tblText)+8
	width2 := wAvlbl - 320 - 12
	Gui, MEW_Main:Add, GroupBox,xm+10 ys+92 w%width2% h124 Section, %ME_LngGroupBox002%
	Gui, MEW_Main:Add, Text,xs+12 yp+18 w%width%  vLabel32, %ME_LngText101%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_Threshold
	Gui, MEW_Main:Add, UpDown, Range0-1000 128

	Gui, MEW_Main:Add, Text,xs+12 y+6 w%width%  vLabel33, %ME_LngText102%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_LongThresholdX
	Gui, MEW_Main:Add, UpDown, Range0-10000 128

	Gui, MEW_Main:Add, Text,xs+12 y+6 w%width%  vLabel34, %ME_LngText103%
	Gui, MEW_Main:Add, Edit,x+2 w48  vConfig_LongThresholdY
	Gui, MEW_Main:Add, UpDown, Range0-10000 128

	Gui, MEW_Main:Add, Text,xs+12 y+6 w%width%  vLabel35,%ME_LngText104%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_LongThreshold
	Gui, MEW_Main:Add, UpDown, Range0-10000 128 vUDLongThreshold


	left := width2+12
	width2 := wAvlbl - left
	Gui, MEW_Main:Add, GroupBox,xs+%left% ys w%width2% h124 Section, %ME_LngGroupBox003%
	Gui, MEW_Main:Add, Text,xs+12 yp+22 w96 vLabel36,%ME_LngText105%
	Gui, MEW_Main:Add, DropDownList,x+0 w41 vConfig_ORangeDefault Choose%Config_ORangeDefault% AltSubmit,0`n30`n45`n60`n90
	Config_ORangeDefault:=""

	Gui, MEW_Main:Add, Text,xs+12 y+12 w96 vLabel37,%ME_LngText106%
	Gui, MEW_Main:Add, DropDownList,x+0 w41 vConfig_ORangeA Choose%Config_ORangeA% AltSubmit,0`n30`n45`n60`n90
	Config_ORangeA:=""

	Gui, MEW_Main:Add, Text,xs+12 y+12 w96 vLabel38,%ME_LngText107%
	Gui, MEW_Main:Add, DropDownList,x+0 w41 vConfig_ORangeB Choose%Config_ORangeB% AltSubmit,0`n30`n45`n60`n90
	Config_ORangeB:=""


	tblText := Array(ME_LngText108, ME_LngText109, ME_LngText110, ME_LngText115)
	width := GetMaxTextLength(tblText)+8
	Gui, MEW_Main:Add, GroupBox, xm+10 ys+132 w%wAvlbl% h136 Section, %ME_LngGroupBox004%
	Gui, MEW_Main:Add, Text,xs+12 yp+18 w%width% vLabel39,%ME_LngText108%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_TimeoutThreshold
	Gui, MEW_Main:Add, UpDown, Range0-1000 128

	Gui, MEW_Main:Add, Text, xs+12 y+6 w%width% vLabel40,%ME_LngText109%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_Timeout
	Gui, MEW_Main:Add, UpDown, Range0-10000 128

	Gui, MEW_Main:Add, Text, xs+12 y+6 w%width% vLabel41,%ME_LngText110%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_DGInterval
	Gui, MEW_Main:Add, UpDown, Range0-10000 128

	Gui, MEW_Main:Add, Text, xs+12 y+6 w%width% vLabel42,%ME_LngText115%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_TmReleaseTrigger
	Gui, MEW_Main:Add, UpDown, Range0-10000 128


	width2 := wAvlbl - 320 - 12
	Gui, MEW_Main:Add, GroupBox, xm+10 ys+144 w%width2% h116 Section, %ME_LngGroupBox005%
	Gui, MEW_Main:Add, Text,xs+12 yp+18 vLabel43, %ME_LngText111%
	Gui, MEW_Main:Add, Edit,x+16 w48 vConfig_EdgeInterval
	Gui, MEW_Main:Add, UpDown, Range0-10000 128

	Gui, MEW_Main:Add, Text,xs+12 y+2 w140  vLabel44, %ME_LngText112%
	Gui, MEW_Main:Add, Text,xs+12 y+10 w65 Right vLabel45, %ME_LngText113%
	Gui, MEW_Main:Add, Edit,x+6 w48 vConfig_CornerX
	Gui, MEW_Main:Add, UpDown, Range1-10000 128

	Gui, MEW_Main:Add, Text,x+12 yp Right vLabel46, %ME_LngText114%
	Gui, MEW_Main:Add, Edit,x+6 w48 vConfig_CornerY
	Gui, MEW_Main:Add, UpDown, Range1-10000 128

	Gui, MEW_Main:Add, CheckBox,xs+12 y+10 vConfig_EdgeIndiv, %ME_LngCheckBox005%

	left := width2+12
	width2 := wAvlbl - left
	Gui, MEW_Main:Add, GroupBox,xs+%left% ys w%width2% h116 Section,%ME_LngGroupBox006%
	width2 -= 24
	Gui, MEW_Main:Add, CheckBox,xp+12 yp+20 w%width2% vConfig_DisableDefMB,  %ME_LngCheckBox006%
	Gui, MEW_Main:Add, CheckBox,      y+12   w%width2% vConfig_DisableDefX1B, %ME_LngCheckBox007%
	Gui, MEW_Main:Add, CheckBox,      y+12   w%width2% vConfig_DisableDefX2B, %ME_LngCheckBox008%
}
;-------------------------------------------------------------------------------
; Hints : ナビ
;-------------------------------------------------------------------------------
CreateHintsTab()
{
	global
	Gui, MEW_Main:Tab, 5

	Gui, MEW_Main:Add, GroupBox,y+8 w%wAvlbl% h70 Section, %ME_LngGroupBox007%
	Gui, MEW_Main:Add, CheckBox,xs+12 yp+20 vConfig_UseNavi, %ME_LngCheckBox009%

	Gui, MEW_Main:Add, Text,xs+12 y+10 vLabel61, %ME_LngText200%
	Gui, MEW_Main:Add, DropDownList,x+10 w126 vConfig_UseExNavi gOnNaviChange AltSubmit, %ME_LngDropDown004%
	GuiControl, MEW_Main:Choose, Config_UseExNavi, % Config_UseExNavi+1
	Config_UseExNavi:=""

	Gui, MEW_Main:Add, Text,xs+229 ys+16 w155 vLabel62, %ME_LngText201%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_NaviInterval
	Gui, MEW_Main:Add, UpDown, Range0-10000 128

	Gui, MEW_Main:Add, Text,xs+229 y+6 w155  vLabel63, %ME_LngText202%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_NaviPersist
	Gui, MEW_Main:Add, UpDown, Range0-10000 128


	Gui, MEW_Main:Add, GroupBox, xs y+16 w%wAvlbl% h155 Section, %ME_LngGroupBox008%
	Gui, MEW_Main:Add, CheckBox,xs+12 yp+20 vConfig_ExNaviTransBG gOnExNaviTransBGChange, %ME_LngCheckBox010%

	Gui, MEW_Main:Add, Text,xs+12 y+10 w160 vLabel64, %ME_LngText203%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_ExNaviFG gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorExNaviFG

	Gui, MEW_Main:Add, Text,xs+12 y+6 w160 vLabel65, %ME_LngText204%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_ExNaviBG gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorExNaviBG

	Gui, MEW_Main:Add, Button,xs+20 y+16 w202 h24 vExNaviIdvClr gOnExNaviIdvClr, %ME_LngButton024%

	Gui, MEW_Main:Add, Text,xs+273 ys+18 w132 vLabel66, %ME_LngText205%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_ExNaviTranspcy
	Gui, MEW_Main:Add, UpDown, Range0-255 128 vUDExNaviTranspcy

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel67, %ME_LngText206%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_ExNaviSize
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDExNaviSize

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel68, %ME_LngText207%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_ExNaviSpacing
	Gui, MEW_Main:Add, UpDown, Range-1000-1000 128 vUDExNaviSpacing

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel69, %ME_LngText208%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_ExNaviPadding
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDExNaviPadding

	Gui, MEW_Main:Add, Text,xs+273 y+1 w132 vLabel70, %ME_LngText209%
	Gui, MEW_Main:Add, Edit,x+0 yp+5 w48 vConfig_ExNaviMargin
	Gui, MEW_Main:Add, UpDown, Range-1-1000 128 vUDExNaviMargin


	Gui, MEW_Main:Add, GroupBox, xs y+21 w%wAvlbl% h228 Section, %ME_LngGroupBox009%
	Gui, MEW_Main:Add, Text,xs+12 yp+18 w160 vLabel71, %ME_LngText300%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_AdNaviFG gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorAdNaviFG

	Gui, MEW_Main:Add, Text,xs+12 y+6 w160 vLabel72, %ME_LngText301%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_AdNaviNI gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorAdNaviNI

	Gui, MEW_Main:Add, Text,xs+12 y+6 w160 vLabel73, %ME_LngText302%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_AdNaviBG gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorAdNaviBG

	Gui, MEW_Main:Add, Text,xs+12 y+6 w191 vLabel74, %ME_LngText303%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviTranspcy
	Gui, MEW_Main:Add, UpDown, Range0-255 128 vUDAdNaviTranspcy

	Gui, MEW_Main:Add, Text,xs+12 y+6 w191 vLabel75, %ME_LngText304%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviSize
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDAdNaviSize

	Gui, MEW_Main:Add, Text,xs+12 y+6 w89 vLabel76, %ME_LngText305%
	Gui, MEW_Main:Add, Edit,x+0 w150 vConfig_AdNaviFont

	Gui, MEW_Main:Add, Text,xs+12 y+6 w88 vLabel77, %ME_LngText306%
	Gui, MEW_Main:Add, DropDownList,x+0 w150 vConfig_AdNaviPosition gOnNaviPosChange AltSubmit, %ME_LngDropDown005%
	GuiControl, MEW_Main:Choose, Config_AdNaviPosition, % Config_AdNaviPosition+1
	Config_AdNaviPosition:=""

	Gui, MEW_Main:Add, CheckBox,xs+12 y+10 vConfig_AdNaviOnClick, %ME_LngCheckBox011%

	Gui, MEW_Main:Add, Text,xs+273 ys+18 w132 vLabel78, %ME_LngText307%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviPaddingL
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDAdNaviPaddingL

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel79, %ME_LngText308%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviPaddingR
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDAdNaviPaddingR

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel80, %ME_LngText309%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviPaddingT
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDAdNaviPaddingT

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel81, %ME_LngText310%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviPaddingB
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDAdNaviPaddingB

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel82, %ME_LngText311%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviRound
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDAdNaviRound

	Gui, MEW_Main:Add, Text,xs+273 y+1 w132 vLabel83, %ME_LngText312%
	Gui, MEW_Main:Add, Edit,x+0 yp+5 w48 vConfig_AdNaviMargin
	Gui, MEW_Main:Add, UpDown, Range-1-1000 128 vUDAdNaviMargin

	Gui, MEW_Main:Add, Text,xs+273 yp w132 vLabel84, %ME_LngText313%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviSpaceX
	Gui, MEW_Main:Add, UpDown, Range-10000-10000 128 vUDAdNaviSpaceX

	Gui, MEW_Main:Add, Text,xs+273 y+6 w132 vLabel85, %ME_LngText314%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_AdNaviSpaceY
	Gui, MEW_Main:Add, UpDown, Range-10000-10000 128 vUDAdNaviSpaceY
}
;-------------------------------------------------------------------------------
; Trail and Logs : 軌跡・ログ
;-------------------------------------------------------------------------------
CreateTrailTab()
{
	local width, tblText
	Gui, MEW_Main:Tab, 6

	; Trail
	Gui, MEW_Main:Add, GroupBox,y+8 w%wAvlbl% h230 Section, %ME_LngGroupBox010%
	Gui, MEW_Main:Add, CheckBox,xs+12 yp+20 vConfig_ShowTrail gOnShowTrailChange, %ME_LngCheckBox012%
	Gui, MEW_Main:Add, CheckBox,xs+24 y+14	 vConfig_DrawTrailWnd, %ME_LngCheckBox014%

	Gui, MEW_Main:Add, Text,xs+24 y+12 w189 vLabel101, %ME_LngText400%
	Gui, MEW_Main:Add, Edit,x+0 w58 vConfig_TrailColor gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorTrailColor

	Gui, MEW_Main:Add, Text,xs+24 y+12 w220 vLabel102, %ME_LngText401%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_TrailTranspcy
	Gui, MEW_Main:Add, UpDown, Range0-255 128 vUDTrailTranspcy

	Gui, MEW_Main:Add, Text,xs+24 y+12 w220 vLabel103, %ME_LngText402%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_TrailWidth
	Gui, MEW_Main:Add, UpDown, Range0-100 128 vUDTrailWidth

	Gui, MEW_Main:Add, Text,xs+24 y+12 w220 vLabel104, %ME_LngText403%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_TrailStartMove
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDTrailStartMove

	Gui, MEW_Main:Add, Text,xs+24 y+12 w220 vLabel105, %ME_LngText404%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_TrailInterval
	Gui, MEW_Main:Add, UpDown, Range0-10000 128 vUDTrailInterval

	; Logs
	Gui, MEW_Main:Add, GroupBox,xs y+20 w%wAvlbl% h240 Section, %ME_LngGroupBox011%
	Gui, MEW_Main:Add, CheckBox,xs+12 yp+20 vConfig_ShowLogs gOnShowLogsChange, %ME_LngCheckBox013%

	Gui, MEW_Main:Add, Text,xs+24 y+10 vLabel106, %ME_LngText306%
	Gui, MEW_Main:Add, DropDownList,x+10 w150 vConfig_LogPosition gOnNaviChange AltSubmit, %ME_LngDropDown006%
	GuiControl, MEW_Main:Choose, Config_LogPosition, % Config_LogPosition
	Config_LogPosition:=""

	Gui, MEW_Main:Add, Text,xs+14 y+6 w60 Right vLabel107, %ME_LngText421%
	Gui, MEW_Main:Add, Edit,x+10 w48 vConfig_LogPosX
	Gui, MEW_Main:Add, UpDown, Range1-10000 128 vUDLogPosX

	Gui, MEW_Main:Add, Text,x+11 yp Right vLabel108, %ME_LngText422%
	Gui, MEW_Main:Add, Edit,x+10 w48 vConfig_LogPosY
	Gui, MEW_Main:Add, UpDown, Range1-10000 128 vUDLogPosY

	tblText := Array(ME_LngText423, ME_LngText424, ME_LngText201)
	width := GetMaxTextLength(tblText)+8
	Gui, MEW_Main:Add, Text,xs+255 ys+17 w%width% vLabel109, %ME_LngText423%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_LogMax
	Gui, MEW_Main:Add, UpDown, Range0-10000 128 vUDLogMax

	Gui, MEW_Main:Add, Text,xs+255 y+6 w%width%  vLabel110, %ME_LngText424%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_LogSizeW
	Gui, MEW_Main:Add, UpDown, Range0-10000 128 vUDLogSizeW

	Gui, MEW_Main:Add, Text,xs+255 y+6 w%width%  vLabel111, %ME_LngText201%
	Gui, MEW_Main:Add, Edit,x+2 w48 vConfig_LogInterval
	Gui, MEW_Main:Add, UpDown, Range0-10000 128 vUDLogInterval

	Gui, MEW_Main:Add, Text,xs+24 yp+34 w160 vLabel112, %ME_LngText300%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_LogFG gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorLogFG

	Gui, MEW_Main:Add, Text,xs+24 y+6 w160 vLabel113, %ME_LngText302%
	Gui, MEW_Main:Add, Edit,x+0 w58 Limit6 vConfig_LogBG gOnColorChange
	Gui, MEW_Main:Add, TreeView, x+1 w20 h20 vColorLogBG

	Gui, MEW_Main:Add, Text,xs+24 y+6 w191 vLabel114, %ME_LngText303%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_LogTranspcy
	Gui, MEW_Main:Add, UpDown, Range0-255 128 vUDLogTranspcy

	Gui, MEW_Main:Add, Text,xs+24 y+6 w191 vLabel115, %ME_LngText304%
	Gui, MEW_Main:Add, Edit,x+0 w48 vConfig_LogFontSize
	Gui, MEW_Main:Add, UpDown, Range0-1000 128 vUDLogFontSize

	Gui, MEW_Main:Add, Text,xs+24 y+6 w89 vLabel116, %ME_LngText305%
	Gui, MEW_Main:Add, Edit,x+0 w150 vConfig_LogFont
}
;-------------------------------------------------------------------------------
; Others : その他
;-------------------------------------------------------------------------------
CreateOthersTab()
{
	local width, width2, tblText
	Gui, MEW_Main:Tab, 7
	tblText := Array(ME_LngText451, ME_LngText452)
	width := GetMaxTextLength(tblText)+8
	width2 := wAvlbl-12*2-width

	Gui, MEW_Main:Add, GroupBox,y+8 w%wAvlbl% h62 Section, %ME_LngGroupBox014%
	Gui, MEW_Main:Add, Button,xs+18 yp+20 w160 h30 gOnRegStartup, %ME_LngButton022%
	Gui, MEW_Main:Add, Button,x+14 w160 h30 gOnDelStartup, %ME_LngButton023%


	Gui, MEW_Main:Add, GroupBox, xs y+20 w%wAvlbl% h107,%ME_LngGroupBox012%
	Gui, MEW_Main:Add, Text,xs+12 yp+20 w%width% vLabel131,%ME_LngText451%
	Gui, MEW_Main:Add, Hotkey,x+0 w%width2% vConfig_HotkeyEnable gOnHotkeyChange

	Gui, MEW_Main:Add, Text,xs+12 y+8 w%width% vLabel132,%ME_LngText452%
	Gui, MEW_Main:Add, Hotkey,x+0 w%width2% vConfig_HotkeyNavi gOnHotkeyChange

	Gui, MEW_Main:Add, Text,xs+12 y+8 w%width% vLabel133,%ME_LngText453%
	Gui, MEW_Main:Add, Hotkey,x+0 w%width2% vConfig_HotkeyReload gOnHotkeyChange


	Gui, MEW_Main:Add, GroupBox,xs y+20 w%wAvlbl% h62, %ME_LngGroupBox015%
	Gui, MEW_Main:Add, Button, xs+16 yp+20 w300 h30 gDlgRegActvtExclud, %ME_LngButton029%


	Gui, MEW_Main:Add, GroupBox,xs y+20 w%wAvlbl% h52, %ME_LngGroupBox013%
	width := wAvlbl-12*2-62
	Gui, MEW_Main:Add, Edit,xs+12 yp+20 w%width% vConfig_ScriptEditor
	Gui, MEW_Main:Add, Button,x+2 yp-1 w60 h22 gOnBrowseEditor, %ME_LngButton027%


	Gui, MEW_Main:Add, GroupBox,xs y+20 w%wAvlbl% h102, %ME_LngGroupBox016%
	Gui, MEW_Main:Add, CheckBox,xs+17 yp+24 vConfig_TraySubmenu, %ME_LngCheckBox015%

	Gui, MEW_Main:Add, CheckBox,xs+17 y+14 vConfig_AdjustDlg gOnAdjustDlgHeight, %ME_LngCheckBox016%
	Gui, MEW_Main:Add, Text,xs+40 y+6 vLabel134, %ME_LngText455%
	Gui, MEW_Main:Add, Edit,x+8 w60 vConfig_DlgHeightLimit gOnAdjustDlgHeight
	Gui, MEW_Main:Add, UpDown, Range0-10000 128 vUDDlgHeightLimit
}

;-------------------------------------------------------------------------------
; Common buttons : 共通ボタン
;-------------------------------------------------------------------------------
PutCommonButtons()
{
	local width, top, left
	Gui, MEW_Main:Tab
	GuiControlGet, rcTab, MEW_Main:Pos, MainTab
	tabRight  := rcTabX + rcTabW
	tabBottom := rcTabY + rcTabH
	top  := tabBottom + 8
	Gui, MEW_Main:Add, Button, x%rcTabX% y%top% w160 h24 vBFromClipboard gImportFromClipboard, %ME_LngButton004%

	width=80
	spc=6
	left := tabRight - (130+width*2+spc*2)
	Gui, MEW_Main:Add, Button, x%left% y%top% w130 h24 vBHelp gShowHelp, %ME_LngButton003%
	Gui, MEW_Main:Add, Button, x+%spc% w%width% h24 vBSaveExit gSaveExit, %ME_LngButton001%
	Gui, MEW_Main:Add, Button, x+%spc% w%width% h24 vBExit gME_Exit, %ME_LngButton002%
}
;-------------------------------------------------------------------------------
; Adjust Position of Static Text
;-------------------------------------------------------------------------------
AdjustTextPos()
{
	global
	Loop, 140
	{
		GuiControlGet, pos, MEW_Main:pos, Label%A_Index%
		if (!ErrorLevel)
		{
			posY+=4
			posX+=2
			GuiControl, MEW_Main:Move, Label%A_Index%, x%posX% y%posY%
		}
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Window Message Handler
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; WM_COMMAND Message Handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnCommand(wParam, lParam)
{
	global
	if ((wParam>>16) != 0x0200) {
		return
	}
	static edtName := [ "ETargetName",	 "EGestureName"	  ]
	static btnRenm := [ "BTargetRename", "BGestureRename" ]
	static subRenm := [ "TargetRename",	 "GestureRename"  ]
	Loop, 2
	{
		if (lParam == ControlGetHandle(edtName[A_Index]))
		{
			if (ControlIsEnabled(btnRenm[A_Index])) {
				Gosub, % subRenm[A_Index]
				break
			}
		}
	}
}
;-------------------------------------------------------------------------------
; WM_NOTIFY Message Handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnNotify(wParam, lParam)
{
	local hCtrl
	if ((NumGet(lParam+0, A_PtrSize*2, "Ptr")&0xffffffff) == 4294967182)
	{
		;On ListView Item Double Click
		hCtrl := NumGet(lParam+0, 0, "Ptr")
		if (hCtrl == ControlGetHandle("LVGesture")) {
			SwitchTab(3)
		}
		else if (hCtrl == ControlGetHandle("LVAction")) {
			SwitchTab(1)
		}
	}
}
;-------------------------------------------------------------------------------
; WM_RBUTTONUP Message Handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnRButtonUp(wParam, lParam)
{
	global
	if (A_GuiControl=="LBButtons")
	{
		MouseClick, Left
		Gui, MEW_Main:Submit, Nohide
		if (!LBButtons) {
			return
		}
		local szTrigger := % Button_%LBButtons%
		Loop, Parse, MG_DefButtons, `n
		{
			if (A_LoopField = szTrigger) {
				return
			}
		}
		Menu, menuDelete, Add
		Menu, menuDelete, DeleteAll
		Menu, menuDelete, Add, %ME_LngMenu106%, OnDelTriggerSelect
		Menu, menuDelete, Show
	}
	else if (A_GuiControl=="LBGesture")
	{
		MouseClick, Left
		Gui, MEW_Main:Submit, Nohide
		ShowListContextMenu("G", Gesture_Editing)
	}
}
;-------------------------------------------------------------------------------
; WM_KEYDOWN Message Handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnKeyDown(wParam, lParam, uMsg, hWnd)
{
	if (wParam == 0x0D)
	{
		;On Enter Key Down
		if (hWnd==ControlGetHandle("ETargetName")
		&&	ControlIsEnabled("BTargetRename"))
		{
			Gosub, TargetRename
			GuiControl, MEW_Main:Focus, TVTarget2
		}
		else if (hWnd==ControlGetHandle("EGestureName")
		&&		 ControlIsEnabled("BGestureRename"))
		{
			GestureRename()
			GuiControl, MEW_Main:Focus, LBGesture
		}
		else if (hWnd==ControlGetHandle("EIconFile")
		||		 hWnd==ControlGetHandle("EIconIndex"))
		{
			if (ControlIsEnabled("BApplyIcon")) {
				OnApplyIcon()
			}
		}
	}
}
;-------------------------------------------------------------------------------
; WM_PAINT Message Handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnPaint(wParam, lParam, uMsg, hWnd)
{
	local w, h, hDC

	if (hWnd!=ME_hGesPatBox) {
		return
	}
	; Change GUI size to erase current gesture
	w := ME_GPBoxSizeW-1
	Gui, MGW_GPBox:Show, x0 y0 w%w% h%ME_GPBoxSizeH% NA
	Gui, MGW_GPBox:Show, x0 y0 w%ME_GPBoxSizeW% h%ME_GPBoxSizeH% NA

	MG_hFntBtn := MG_CreateFont("MS UI Gothic", MG_AdNaviSize, 0, 4)
	MG_hFntDir := MG_CreateFont("Wingdings", MG_AdNaviSize, 0, 4)
	hDC := DllCall("GetWindowDC", "Ptr",ME_hGesPatBox, "Ptr")
	DllCall("SetBkMode", "Ptr",hDC, "Ptr",1)
	w := MG_AdjustToDPI(ME_GPBoxSizeW)
	h := MG_AdjustToDPI(ME_GPBoxSizeH)
	GuiControlGet, szGesture, MEW_Main:, EGesture
	MG_DrawGesture(hDC, 3, 1, szGesture, w, h)
	DllCall("ReleaseDC", "Ptr",ME_hGesPatBox, "Ptr",hDC)
	DllCall("DeleteObject", "Ptr",MG_hFntBtn)
	DllCall("DeleteObject", "Ptr",MG_hFntDir)
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Hotkey Operations
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; On New Item Shortcut Key Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnNewItemKeyPress()
{
	global MainTabIdx
	GuiControlGet, szCtrl, MEW_Main:FocusV
	if (szCtrl="TVTarget1" || MainTabIdx==2) {
		TargetNew(false)
	}
	else if (MainTabIdx==3) {
		GestureNew()
	}
}
;-------------------------------------------------------------------------------
; On Copy Shortcut Key Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnCopyKeyPress()
{
	GuiControlGet, szCtrl, MEW_Main:FocusV
	if (szCtrl="TVTarget1" || szCtrl="TVTarget2") {
		CopyTarget()
	}
	else if (szCtrl="LBGesture") {
		CopyGesture()
	}
}
;-------------------------------------------------------------------------------
; On Paste Shortcut Key Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnPasteKeyPress()
{
	if (IsAnyListActive()) {
		ImportFromClipboard()
	}
}
;-------------------------------------------------------------------------------
; On Delete Key Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnDeleteKeyPress()
{
	local szCtrl
	GuiControlGet, szCtrl, MEW_Main:FocusV
	if (szCtrl = "LBButtons") {
		DeleteTrigger()
	}
	else if ((szCtrl="TVTarget1" || szCtrl="TVTarget2") && !ME_bTvRenaming) {
		TargetDelete()
	}
	else if (szCtrl="LVGesture") {
		ReleaseGesture(Gesture_Editing, Action_Editing)
	}
	else if (szCtrl="LBGesture") {
		GestureDelete()
	}
	else if (szCtrl = "LVAction") {
		ActionDelete(Gesture_Editing, Action_Editing)
	}
	else if (szCtrl = "LVRule") {
		Gosub, RuleDelete
	}
	else if (szCtrl = "LBGesturePattern") {
		Gosub, GesturePatternDelete
	}
}
;-------------------------------------------------------------------------------
; On Move Up List Item Shortcut Key Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnMoveUpKeyPress()
{
	global Target_Editing
	GuiControlGet, szCtrl, MEW_Main:FocusV
	if (szCtrl="TVTarget1" || szCtrl="TVTarget2") {
		TargetShift(Target_Editing, -1)
	}
	else if (szCtrl="LBGesture") {
		GestureUp()
	}
	else if (szCtrl = "LVAction") {
		Gosub, ActionUp
	}
	else if (szCtrl = "LVRule") {
		Gosub, RuleUp
	}
	else if (szCtrl = "LBGesturePattern") {
		Gosub, GesturePatternUp
	}
}
;-------------------------------------------------------------------------------
; On Move Down List Item Shortcut Key Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnMoveDownKeyPress()
{
	global Target_Editing
	GuiControlGet, szCtrl, MEW_Main:FocusV
	if (szCtrl="TVTarget1" || szCtrl="TVTarget2") {
		TargetShift(Target_Editing, 1)
	}
	else if (szCtrl="LBGesture") {
		GestureDown()
	}
	else if (szCtrl = "LVAction") {
		Gosub, ActionDown
	}
	else if (szCtrl = "LVRule") {
		Gosub, RuleDown
	}
	else if (szCtrl = "LBGesturePattern") {
		Gosub, GesturePatternDown
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Check whether any list is activated
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
IsAnyListActive()
{
	GuiControlGet, szCtrl, MEW_Main:FocusV
	return (szCtrl="TVTarget1" || szCtrl="TVTarget2"  || szCtrl="LVRule"
		|| szCtrl="LVGesture" || szCtrl="LBGesture" || szCtrl="LBGesturePattern"
		|| szCtrl="LVAction")
}

;-------------------------------------------------------------------------------
; Get Handle of GUI Control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ControlGetHandle(ctrl, wnd="MEW_Main:")
{
	hCtrl := 0
	GuiControlGet, hCtrl, %wnd%Hwnd, %ctrl%
	return hCtrl
}

;-------------------------------------------------------------------------------
; Check whether the GUI Control is Enabled
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ControlIsEnabled(ctrl, wnd="MEW_Main:")
{
	GuiControlGet, bEnabled, %wnd%Enabled, %ctrl%
	return bEnabled
}

;-------------------------------------------------------------------------------
; Get System Icons
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetSystemIcons()
{
	local szShell32 := A_WinDir "\System32\shell32.dll"
	Target_Default_IconFile	:= szShell32 ",16"
	Target_Default_Icon		:= IL_Add(MG_hImageList, szShell32, 16)
	Target_Blank_Icon		:= IL_Add(MG_hImageList, szShell32, 50)
}

;-------------------------------------------------------------------------------
; Get Desktop Height
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetDesktopHeight()
{
	MG_GetMonitorRect(0,0,, dtT,, dtB, true)
	return dtB-dtT
}

;-------------------------------------------------------------------------------
; Load Buttons
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
LoadButtons()
{
	global
	MG_BtnNames := RegExReplace(MG_DefButtons, "\n", "_")
	Loop, %A_ScriptDir%\Components\Buttons\*.ahk
	{
		if (RegExMatch(A_LoopFileName, "^([a-zA-Z0-9]+)\.ahk$", $)
		&&	!InStr("_" MG_BtnNames "_", "_" $1 "_")) {
			Join(MG_BtnNames, $1, "_")
		}
	}
	LBButtons := ""
	Loop, Parse, MG_BtnNames, _
	{
		if (Button_%A_LoopField%) {
			Join(LBButtons, Button_%A_LoopField%)
		} else {
			Join(LBButtons, A_LoopField)
		}
		Join(ButtonRegEx, A_LoopField, "|")
		Button_%A_Index% := A_LoopField
	}
}

;-------------------------------------------------------------------------------
; Own InputBox
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InputBox(ByRef OutputVar, szTitle, szPrompt, szDefault, OwnerWin="MEW_Main")
{
	global
	Gui, MEW_InBox:-MaximizeBox -MinimizeBox +HwndME_hWndInBox +Owner%OwnerWin% +Delimiter`n
	Gui, MEW_InBox:Margin , 10, 10
	Gui, MEW_InBox:Font, S11
	Gui, MEW_InBox:Add, Text, vIbText, %szPrompt%

	GuiControlGet, rcCtrl, MEW_InBox:Pos, IbText
	local Ew := (rcCtrlW >= 300) ? rcCtrlW : 300
	if (szDefault != "#NoInput#") {
		Gui, MEW_InBox:Add, Edit, y+8 w%Ew% vIbValue, %szDefault%
	}
	local Bx, Bw:=80, Bs:=8
	Bx := rcCtrlX + Ew - Bw*2 - Bs
	Gui, MEW_InBox:Font
	Gui, MEW_InBox:Add, Button, vAcceptValue gOnAcceptValue x%Bx% y+8 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_InBox:Add, Button, gOnCancelValue x+8 yp+0 w%Bw%,						 %ME_LngButton002%

	local fOK := false
	Gui, MEW_InBox:Show, AutoSize, %szTitle%
	WinWaitClose,  ahk_id %ME_hWndInBox%
	return fOK

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptValue:
	fOK := true
	GuiControlGet, OutputVar, MEW_InBox:, IbValue
	Gui, MEW_InBox:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelValue:
MEW_InBoxGuiClose:
MEW_InBoxGuiEscape:
	Gui, MEW_InBox:Destroy
	return
}

;-------------------------------------------------------------------------------
; Get Maximum Text Length
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetMaxTextLength(tblText)
{
	global
	Loop, % tblText.MaxIndex()
	{
		Gui, MEW_Dummy:Add, Text, vDmyTxt%A_Index%, % tblText[A_Index]
	}
	local max:=0
	Loop, % tblText.MaxIndex()
	{
		GuiControlGet, rcCtrl, MEW_Dummy:Pos, DmyTxt%A_Index%
		if (rcCtrlW > max) {
			max := rcCtrlW
		}
	}
	Gui, MEW_Dummy:Destroy
	return max
}

;-------------------------------------------------------------------------------
; Adjust the dialog box height to the number of items
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
AdjustDialogHeight(bAdjPos=false)
{
	local bAdjust, height

	Critical
	Gui, MEW_Main:-DPIScale
	GuiControlGet, bAdjust, MEW_Main:, Config_AdjustDlg
	GuiControlGet, rcCtrl, MEW_Main:Pos, LBGesture
	Gui, MEW_Main:+DPIScale
	;---------------------------------------------------------------------------
	; Reset to the default height
	if (!bAdjust)
	{
		if (rcCtrlH == DefListHeight) {
			Critical, Off
			return
		}
		height := DefListHeight
	}
	;---------------------------------------------------------------------------
	; Decide the dialog box height
	else
	{
		local winY, winH, framW, lbItemH, tvItemH, lbNeed, tvNeed, tvStyle, bSB, sbH, extra
		Gui, MEW_Main:-DPIScale +LastFound
		WinGetPos,,winY,,winH
		Gui, MEW_Main:+DPIScale
		Loop, 2
		{
			SendMessage, 0x01A1,,,, % "ahk_id" ControlGetHandle("LBGesture")
			lbItemH := ErrorLevel
			lbNeed := lbItemH * Gesture_Count
			framW := Mod(rcCtrlH, lbItemH)

			SendMessage, 0x111C,,,, % "ahk_id" ControlGetHandle("TVTarget1")
			tvItemH := ErrorLevel
			tvNeed := tvItemH * GetDisplayTargetNum()
			bSB := false
			WinGet, tvStyle, Style, ahk_id %ME_hTVTarget1%
			if (tvStyle & 0x00100000) {
				SysGet, sbH, 21
				tvNeed += sbH
				bSB := true
			}
			if (lbNeed >= tvNeed) {
				height := lbNeed
			} else {
				height := tvNeed
				if (Mod(height, lbItemH) > 0) {
					height := (height//lbItemH+1) * lbItemH
				}
			}
			height += framW
			extra := winH - rcCtrlH

			local dtH, limit, limSet
			dtH := limit := GetDesktopHeight()
			GuiControlGet, limSet, MEW_Main:, Config_DlgHeightLimit
			if ((limSet > 0) && (limSet < limit)) {
				limit := (limSet > DefListHeight+extra) ? limSet : DefListHeight+extra
			}
			if (height+extra > limit) {
				height := (limit-extra)//lbItemH * lbItemH + framW
			}
			if (rcCtrlH >= height)
			{
				if (rcCtrlH == DefListHeight) {
					Critical, Off
					return
				}
				else if (height < DefListHeight) {
					height := DefListHeight
				}
			}
			if (bAdjPos) {
				winY := (GetDesktopHeight() - height - extra) / 2
				WinMove,,winY
			}
			if (winY+extra+height > dtH) {
				winY := dtH - extra - height
				WinMove,,winY
			}
			if (bSB) {
				Gui, MEW_Main:-DPIScale
				GuiControl, MEW_Main:Move, TVTarget1, h%height%
				GuiControl, MEW_Main:Move, TVTarget2, h%height%
				Gui, MEW_Main:+DPIScale
			} else {
				break
			}
		}
	}
	;---------------------------------------------------------------------------
	; Adjust the dialog box height
	local diff, gbH
	static tblH := [ "MainTab", "LVGesture", "LVRule", "LBGesturePattern", "LVAction" ]
	static tblY := [ "Label3", "BAddAction", "BUpdateAction", "EAction"
				   , "BEditAction", "BClearAction", "Label4", "DDLActionCategory"
				   , "DDLActionTemplate", "BAddActionLine"
				   , "DDLLogic", "BAddRule", "BUpdateRule", "Label12", "DDLRuleType"
				   , "BRulePicker", "Label13", "ERuleValue", "BClearRule", "Label14"
				   , "DDLMatchRule", "ChkNotMatch", "ChkNotInhRules", "GroupIcon", "EIconFile"
				   , "BBrowseIcon", "PicIcon", "EIconIndex", "UDIconIndex", "BApplyIcon"
				   , "EGesture", "BAddGesturePattern", "BUpdateGesturePattern"
				   , "GesturePatternBox", "BClearGesture", "Label22", "LBButtons"
				   , "BAddTrigger", "Label23"
				   , "BStrokeUL", "BStrokeU", "BStrokeUR", "BStrokeL", "BStrokeR"
				   , "BStrokeDL", "BStrokeD", "BStrokeDR", "BButtonUp", "BGesturePatternBS"
				   , "BFromClipboard", "BHelp", "BSaveExit", "BExit" ]

	; Resize Controls
	Gui, MEW_Main:-DPIScale
	GuiControl, MEW_Main:Move, TVTarget1, h%height%
	GuiControl, MEW_Main:Move, TVTarget2, h%height%
	GuiControl, MEW_Main:Move, LBGesture, h%height%

	diff := height - rcCtrlH
	GuiControlGet, rcCtrl, MEW_Main:Pos, GroupIcon
	gbH := rcCtrlH
	GuiControl, MEW_Main:Move, GroupIcon, h0
	Loop, % tblH.MaxIndex()
	{
		GuiControlGet, rcCtrl, MEW_Main:Pos, % tblH[A_Index]
		GuiControl, MEW_Main:Move, % tblH[A_Index], % "h" rcCtrlH+diff
	}
	; Move Controls
	Loop, % tblY.MaxIndex()
	{
		idx := (diff>0) ? (tblY.MaxIndex() - A_Index + 1) : A_Index
		GuiControlGet, rcCtrl, MEW_Main:Pos, % tblY[idx]
		GuiControl, MEW_Main:Move, % tblY[idx], % "y" rcCtrlY+diff
	}
	GuiControl, MEW_Main:Move, GroupIcon, h%gbH%
	Gui, MEW_Main:+DPIScale
	Gui, MEW_Main:Show, Autosize
}

;-------------------------------------------------------------------------------
; Get Number of Displayed Targets
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetDisplayTargetNum()
{
	local cnt
	GuiControlGet, Config_FoldTarget, MEW_Main:, Config_FoldTarget
	if (!Config_FoldTarget) {
		return Target_Count
	}
	cnt := 0
	Loop, %Target_Count% {
		if (Target_%A_Index%_Level <= 1) {
			cnt++
		}
	}
	return cnt
}

;-------------------------------------------------------------------------------
; Save the Modification
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SaveModification(ope="Check", edit="")
{
	local ret:=false
	static bModified:=false, bModifiedBk:=false

	if (ope = "Resume") {
		Sleep, 1
		bModified := bModifiedBk
		return ret
	}

	Critical
	if (ope = "Suspend") {
		bModifiedBk := bModified
		bModified := false
	}
	else if (ope = "Reset") {
		bModified := false
	}
	else if (ope = "Modified")
	{
		if ((Target_Editing  && (edit="ERuleValue"))
		||	(Gesture_Editing && (edit="EGesture" || edit="EAction")))
		{
			bModified := true
		}
	}
	else if (ope = "Check" && bModified)
	{
		ret := true
		bModified := false
		if (MainTabIdx==1)
		{
			GuiControlGet, EAction, MEW_Main:, EAction
			if (EAction = "") {
				Critical, Off
				return ret
			}
		}
		local  idxEdt  := [ Gesture_Editing	 , Target_Editing	, Gesture_Editing			]
			 , statAdd := [ EnblAddAction	 , EnblAddRule		, EnblAddGesturePattern		]
			 , statUpd := [ EnblUpdateAction , EnblUpdateRule	, EnblUpdateGesturePattern	]
		static subAdd  := [ "AddAction"		 , "AddRule"		, "AddGesturePattern"		]
			 , subUpd  := [ "UpdateAction"	 , "UpdateRule"		, "UpdateGesturePattern"	]
		if (MainTabIdx<=3 && idxEdt[MainTabIdx])
		{
			if (statUpd[MainTabIdx] = "Enable") {
				Func(subUpd[MainTabIdx]).(false)
			}
			else if (statAdd[MainTabIdx] = "Enable") {
				Func(subAdd[MainTabIdx]).(false)
			}
		}
	}
	Critical, Off
	return ret
}

;-------------------------------------------------------------------------------
; On Main Tab Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnTabChange:
	SaveModification()
	GuiControlGet, MainTabIdx, MEW_Main:, MainTab
return

;-------------------------------------------------------------------------------
; On "Add Trigger" Button Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnAddTriggerPress:
	OnAddTriggerPress()
return
OnAddTriggerPress()
{
	global
	ScreenEdges := ""
	Menu, menuTrigger, Add
	Menu, menuTrigger, DeleteAll
	Menu, menuEdge, Add
	Menu, menuEdge, DeleteAll
	Loop, %A_ScriptDir%\Components\Buttons\ScreenEdges\*.ahk
	{
		local szEdgeName := RegExReplace(A_LoopFileName, "\.ahk")
		Join(ScreenEdges, szEdgeName)
		szEdgeName := "Button_" . szEdgeName
		szEdgeName := %szEdgeName%
		Menu, menuEdge, Add, %szEdgeName%, AddScreenEdge
	}
	Menu, menuTrigger, Add, %ME_LngMenu049%, :menuEdge
	Menu, menuTrigger, Add
	Menu, menuTrigger, Add, %ME_LngMenu050%, DefineNewButton
	Menu, menuTrigger, Show
}

;-------------------------------------------------------------------------------
; Add Screen Edge Recognition Module to List Box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
AddScreenEdge:
	AddScreenEdge()
return
AddScreenEdge()
{
	global
	Loop, Parse, ScreenEdges, `n
	{
		local szEdgeName := "Button_" . A_LoopField
		szEdgeName := %szEdgeName%
		if (A_ThisMenuItem = szEdgeName)
		{
			FileCopy, %A_ScriptDir%\Components\Buttons\ScreenEdges\%A_LoopField%.ahk
					, %A_ScriptDir%\Components\Buttons\%A_LoopField%.ahk, 1
			break
		}
	}
	LoadButtons()
	GuiControl, MEW_Main:, LBButtons, `n%LBButtons%
}

;-------------------------------------------------------------------------------
; Define New Button
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
DefineNewButton:
	DefineNewButton()
return
DefineNewButton()
{
	global
	Gui, MEW_Trg:-MaximizeBox -MinimizeBox +HwndME_hWndTrg +OwnerMEW_Main +Delimiter`n +LastFound

	local tblText := Array(ME_LngText023, ME_LngText024)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_Trg:Add, Text,x12 y20 w%width%, %ME_LngText023%
	Gui, MEW_Trg:Add, Edit,x+0 yp-4 w174 vTriggerName gOnEditTrigger

	Gui, MEW_Trg:Add, Text, x12 y+12 w%width%, %ME_LngText024%
	Gui, MEW_Trg:Add, Edit, x+0 yp-4 w151 vTriggerKey gOnEditTrigger
	Gui, MEW_Trg:Add, Button, x+2 yp-1 w22 h22 gOnTriggerInput, ...

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_Trg:Pos, TriggerName
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_Trg:Add, Button, vAcceptTrigger gOnAcceptTrigger x%Bx% y+14 w%Bw% Default Disabled, %ME_LngButton001%
	Gui, MEW_Trg:Add, Button, gOnCancelTrigger x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_Trg:Show, AutoSize, %ME_LngCapt004%

	WinWaitClose,  ahk_id %ME_hWndTrg%
	return

	;---------------------------------------------------------------------------
	; On Edit Trigger
OnEditTrigger:
	Gui, MEW_Trg:Submit, Nohide
	local stat := (TriggerName="" || TriggerKey="") ? "Disable" : "Enable"
	GuiControl, MEW_Trg:%stat%, AcceptTrigger
	return

	;---------------------------------------------------------------------------
	; On Input Key button press
OnTriggerInput:
	local szKey
	DlgKeyInput(szKey)
	szKey := RegExReplace(szKey, "[{}]")
	GuiControl, MEW_Trg:, TriggerKey, %szKey%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptTrigger:
	Gui, MEW_Trg:Submit, Nohide
	if (TriggerName!="" && TriggerKey!="")
	{
		if (AddButton(TriggerName, TriggerKey)) {
			Gui, MEW_Trg:Destroy
		}
	}
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelTrigger:
MEW_TrgGuiClose:
MEW_TrgGuiEscape:
	Gui, MEW_Trg:Destroy
	return
}

;-------------------------------------------------------------------------------
; Add New Trigger Button
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
AddButton(name, key)
{
	local szKey, szPathBtn, szPathEdge

	if (!RegExMatch(name, "^([a-zA-Z0-9]+)$")) {
		MsgBox, 0x30, %ME_LngCapt004%, %ME_LngMessage013%
		return false
	}
	szKey := RegExReplace("^~","",key)
	szPathBtn  := A_ScriptDir . "\Components\Buttons\" . name . ".ahk"
	szPathEdge := A_ScriptDir . "\Components\Buttons\ScreenEdges\" . name . ".ahk"
	if (!FileExist(szPathBtn) && !FileExist(szPathEdge))
	{
		local szBtn
		szBtn = 
(LTrim
		Goto,MG_%name%_End

		MG_%name%_Enable:
		`tHotkey,*%key%,MG_%name%_DownHotkey,On
		`tHotkey,*%key% up,MG_%name%_UpHotkey,On
		return

		MG_%name%_Disable:
		`tHotkey,*%key%,MG_%name%_DownHotkey,Off
		`tHotkey,*%key% up,MG_%name%_UpHotkey,Off
		return

		MG_%name%_DownHotkey:
		`tMG_TriggerDown("%name%")
		return

		MG_%name%_UpHotkey:
		`tMG_TriggerUp("%name%")
		return

		MG_%name%_Down:
		`tSetMouseDelay,-1
		`tSend,{Blind}{%szKey% Down}
		return

		MG_%name%_Up:
		`tSetMouseDelay,-1
		`tSend,{Blind}{%szKey% Up}
		return

		MG_%name%_End:

)
		FileAppend, %szBtn%, %szPathBtn%, UTF-8
		LoadButtons()
		GuiControl, MEW_Main:, LBButtons, `n%LBButtons%
		return true
	}
	else
	{
		MsgBox, 0x30, %ME_LngCapt004%, %ME_LngMessage007%
		return false
	}
}

;-------------------------------------------------------------------------------
; Delete Defined Trigger
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnDelTriggerSelect:
	DeleteTrigger()
return
DeleteTrigger()
{
	global
	Gui, MEW_Main:Submit, Nohide
	if (!LBButtons) {
		return
	}
	local szTrigger := % Button_%LBButtons%
	Loop, Parse, MG_DefButtons, `n
	{
		if (A_LoopField = szTrigger) {
			return
		}
	}
	local szPath = A_ScriptDir . "\Components\Buttons\" . szTrigger . ".ahk"
	FileDelete, %szPath%

	local sel := LBButtons
	LoadButtons()
	GuiControl, MEW_Main:, LBButtons, `n%LBButtons%
	GuiControl, MEW_Main:Choose, LBButtons, %sel%
}

;-------------------------------------------------------------------------------
; On Release Gesture Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnReleaseGesturePress:
	ReleaseGesture(Gesture_Editing, Action_Editing)
return

;-------------------------------------------------------------------------------
; On Edit Action Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnEditActionPress:
	EditAction()
return
EditAction()
{
	global Target_Editing, EAction, ME_hWndMain
	if (!Target_Editing) {
		return
	}
	Gui, MEW_Main:Submit, Nohide
	szActTemp := A_Temp . "\~MG_ActTmp.ahk"
	file := FileOpen(szActTemp, "w `n", "UTF-8")
	if (!file) {
		return
	}
	file.Write(EAction)
	file.Close

	GuiControlGet, szEditor, MEW_Main:, Config_ScriptEditor
	if (szEditor != "") {
		szEditor := """" . MG_VarInStr(szEditor) . """"
	}
	else {
		szEditor := "notepad"
	}
	DisableActionControls(true)
	MG_RunAsUser(szEditor " " szActTemp,,, true)
	DisableActionControls(false)
	WinActivate, ahk_id %ME_hWndMain%

	file := FileOpen(szActTemp, "r `n", "UTF-8")
	if (file)
	{
		szNewAction := file.Read(file.Length)
		file.Close
		if (szNewAction != EAction)
		{
			GuiControl, MEW_Main:, EAction, %szNewAction%
			SaveModification("Modified", "EAction")
		}
	}
	FileDelete, %szActTemp%
	GuiControl, MEW_Main:Focus, EAction
}

;-------------------------------------------------------------------------------
; On Clear Action Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnClearActionPress:
	GuiControl, MEW_Main:, EAction,
	SaveModification("Modified", "EAction")
return

;-------------------------------------------------------------------------------
; Disable Action Controls
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
DisableActionControls(bDisable)
{
	local stat := bDisable ? "Disable" : "Enable"
	GuiControl, MEW_Main:%stat%, TVTarget1
	GuiControl, MEW_Main:%stat%, LVGesture
	GuiControl, MEW_Main:%stat%, TVTarget2
	GuiControl, MEW_Main:%stat%, LBGesture
	GuiControl, MEW_Main:%stat%, LVAction
	GuiControl, MEW_Main:%stat%, BReleaseGesture
	GuiControl, MEW_Main:%stat%, BActionUp
	GuiControl, MEW_Main:%stat%, BActionDelete
	GuiControl, MEW_Main:%stat%, BActionDown
	GuiControl, MEW_Main:%stat%, BAddAction
	GuiControl, MEW_Main:%stat%, BUpdateAction
	GuiControl, MEW_Main:%stat%, EAction
	GuiControl, MEW_Main:%stat%, BEditAction
	GuiControl, MEW_Main:%stat%, BClearAction
	GuiControl, MEW_Main:%stat%, BAddActionLine
	if (!bDisable) {
		ChangeActionButtonStat()
	}
}

;-------------------------------------------------------------------------------
; On Icon Edit Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnIconChange:
	OnIconChange()
return
OnIconChange()
{
	local icon
	Gui, MEW_Main:Submit, Nohide
	icon := EIconIndex ? "*Icon" EIconIndex " " : ""
	icon .= "*w" MG_AdjustToDPI(16) " *h" MG_AdjustToDPI(16) " " . MG_VarInStr(EIconFile)
	GuiControl, MEW_Main:, PicIcon, %icon%
	local stat := EIconFile ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, EIconIndex
	GuiControl, MEW_Main:%stat%, UDIconIndex
	stat := (Target_Editing>0) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, BApplyIcon
}

;-------------------------------------------------------------------------------
; On Browse Icon Button Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnBrowseIcon:
	Gui, MEW_Main:Submit, Nohide
	FileSelectFile, EIconFile,, % MG_VarInStr(EIconFile), %ME_LngCapt025%, %ME_LngText558%
	if (EIconFile) {
		GuiControl, MEW_Main:, EIconFile, %EIconFile%
	}
return

;-------------------------------------------------------------------------------
; On Apply Icon Button Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnApplyIcon:
	OnApplyIcon()
return
OnApplyIcon()
{
	local idx
	Gui, MEW_Main:Submit, Nohide
	if (Target_Editing > 0)
	{
		idx := EIconIndex>0 ? EIconIndex : 1
		Target_%Target_Editing%_IconFile := EIconFile ? EIconFile "," idx : ""
		Target_%Target_Editing%_Icon := EIconFile ? IL_Add(MG_hImageList, MG_VarInStr(EIconFile), idx) : 0
		SaveModification("Suspend")
		ShowTargets()
		ShowTarget(Target_Editing)
		ShowGesture(Gesture_Editing)
		ShowAction(Gesture_Editing, Action_Editing)
		Sleep, 1
		SaveModification("Resume")
	}
}

;-------------------------------------------------------------------------------
; On 8-Dir Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
On8DirChange:
	On8DirChange()
return
On8DirChange(bConvert=true)
{
	local chk, stat, msg, pat
	GuiControlGet, chk, MEW_Main:, Config_8Dir
	stat := chk ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, Label35
	GuiControl, MEW_Main:%stat%, Config_LongThreshold
	GuiControl, MEW_Main:%stat%, UDLongThreshold
	GuiControl, MEW_Main:%stat%, Label36
	GuiControl, MEW_Main:%stat%, Config_ORangeDefault
	GuiControl, MEW_Main:%stat%, Label37
	GuiControl, MEW_Main:%stat%, Config_ORangeA
	GuiControl, MEW_Main:%stat%, Label38
	GuiControl, MEW_Main:%stat%, Config_ORangeB

	if (!bConvert) {
		return
	}
	msg := RegExReplace(ME_LngMessage008, "\[#REPLASE#\]", chk ? 8 : 4)
	msg .= (!chk) ? ME_LngMessage009 :
	MsgBox, 36, %ME_LngCapt001%, %msg%
	IfMsgBox, Yes
	{
		Loop, %Gesture_Count%
		{
			pat := ""
			Loop, Parse, Gesture_%A_Index%_Patterns, `n
			{
				Join(pat, MG_CnvDirMode(A_LoopField, chk))
			}
			Gesture_%A_Index%_Patterns := pat
		}
		ShowGesture(Gesture_Editing)
		ShowGesturePattern(Gesture_Editing, GesturePattern_Editing)
	}
}

;-------------------------------------------------------------------------------
; Convert Gesture Direction Mode
;	szGesture : Gesture string to be converted
;	mode	  : 1=4-dir to 8-dir  0=8-dir to 4-dir
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CnvDirMode(szGesture, mode)
{
	global MG_BtnNames
	szOut := ""
	max:=StrLen(szGesture), pos := 1
	while (pos <= max)
	{
		if (SubStr(szGesture, pos, 1) == "_")
		{
			szOut .= "_"
			offset := 1
		}
		else
		{
			fMatched = 0
			Loop, Parse, MG_BtnNames, _
			{
				if (A_LoopField
				&&	InStr(SubStr(szGesture, pos), A_LoopField) == 1)
				{
					szOut .= A_LoopField
					offset := StrLen(A_LoopField)
					fMatched = 1
					break
				}
			}
			if (!fMatched)
			{
				dir := SubStr(szGesture, pos, 1)
				if (mode) {
					dir := (dir="D") ? "2" : (dir="L") ? "4" : (dir="R") ? "6" : (dir="U") ? "8" : dir
				} else {
					dir := (dir="2") ? "D" : (dir="4") ? "L" : (dir="6") ? "R" : (dir="8") ? "U"
						 : (dir="1" || dir="3" || dir="7" || dir="9") ? "" : dir
				}
				szOut .= dir
				offset := 1
			}
		}
		pos += offset
	}
	return szOut
}

;-------------------------------------------------------------------------------
; On Hotkey Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnHotkeyChange:
	Gui, MEW_Main:Submit, Nohide
	if (Config_HotkeyEnable = Config_HotkeyNavi)
	{
		if (A_GuiControl = "Config_HotkeyEnable") {
			GuiControl, MEW_Main:, Config_HotkeyNavi
		}
		else {
			GuiControl, MEW_Main:, Config_HotkeyEnable
		}
	}
return

;-------------------------------------------------------------------------------
; Select excluded windows of activation
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
DlgRegActvtExclud()
{
	local sel, col1, col2, col3, col4, width, szTemp, title, class, exe, aryTmp, cnt

	sel:=0, col1:=25, col2:=200, col3:=200, col4:=200
	width := col1 + col2 + col3 + col4 + 22
	Gui, MEW_ActvtExclud:New
	Gui, MEW_ActvtExclud:Default
	Gui, MEW_ActvtExclud:+Delimiter`n -MaximizeBox -MinimizeBox +HwndME_hWndActvEx +OwnerMEW_Main
	Gui, MEW_ActvtExclud:Add, ListView, x10 y10 w%width% h172 LV1 -Multi NoSortHdr vLVActvEx gOnActvExSelect AltSubmit, `n%ME_LngListView005%
	Gui, MEW_ActvtExclud:Add, Edit, x37  w%col2% vEActExTitle gOnActExChange Disabled
	Gui, MEW_ActvtExclud:Add, Edit, x+1 w%col3% vEActExClass gOnActExChange Disabled
	Gui, MEW_ActvtExclud:Add, Edit, x+1 w%col4% vEActExExe gOnActExChange Disabled Section
	Gui, MEW_ActvtExclud:Add, Button, gOnSelWindows x37 y+8 w200, %ME_LngButton030%
	Gui, MEW_ActvtExclud:Add, Button, gOnDeleteActvEx vBDeleteActvEx x+8 w80 Disabled, %ME_LngButton018%
	Gui, MEW_ActvtExclud:Add, Button, gOnAcceptActvEx xs+33 yp w80 Default, %ME_LngButton001%
	Gui, MEW_ActvtExclud:Add, Button, gOnCancelActvEx x+8 w80, %ME_LngButton002%
	Gui, MEW_ActvtExclud:ListView, LVActvEx
	LV_ModifyCol(1, col1)
	LV_ModifyCol(2, col2)
	LV_ModifyCol(3, col3)
	LV_ModifyCol(4, col4)
	GuiControl, MEW_ActvtExclud: -Redraw, LVActvEx
	LV_Delete()
	Loop, % MG_ActvtExclud.MaxIndex()
	{
		LV_Add("", A_Index, MG_ActvtExclud[A_Index][1], MG_ActvtExclud[A_Index][2], MG_ActvtExclud[A_Index][3])
	}
	LV_Add("", LV_GetCount()+1)
	GuiControl, MEW_ActvtExclud: +Redraw, LVActvEx
	Gui, MEW_ActvtExclud:Show,, %ME_LngCapt008%

	WinWaitClose,  ahk_id %ME_hWndActvEx%
	Gui, MEW_Main:Default
	return

	;---------------------------------------------------------------------------
	; Target is selected
OnActvExSelect:
	sel := LV_GetNext()
	if (!sel)
	{
		GuiControl, MEW_ActvtExclud: Disable, EActExTitle
		GuiControl, MEW_ActvtExclud: Disable, EActExClass
		GuiControl, MEW_ActvtExclud: Disable, EActExExe
		GuiControl, MEW_ActvtExclud: Disable, BDeleteActvEx
		GuiControl, MEW_ActvtExclud:, EActExTitle,
		GuiControl, MEW_ActvtExclud:, EActExClass,
		GuiControl, MEW_ActvtExclud:, EActExExe,
		return
	}
	if (A_GuiEvent!="Normal" && A_GuiEvent!="K") {
		return
	}
	GuiControl, MEW_ActvtExclud: Enable, EActExTitle
	GuiControl, MEW_ActvtExclud: Enable, EActExClass
	GuiControl, MEW_ActvtExclud: Enable, EActExExe
	GuiControl, MEW_ActvtExclud: Enable, BDeleteActvEx
	LV_GetText(szTemp, sel, 2)
	GuiControl, MEW_ActvtExclud:, EActExTitle, %szTemp%
	LV_GetText(szTemp, sel, 3)
	GuiControl, MEW_ActvtExclud:, EActExClass, %szTemp%
	LV_GetText(szTemp, sel, 4)
	GuiControl, MEW_ActvtExclud:, EActExExe, %szTemp%
	if (sel == LV_GetCount()) {
		LV_Add("", LV_GetCount()+1)
	}
	return

	;---------------------------------------------------------------------------
	; On text change
OnActExChange:
	if (!sel) {
		return
	}
	GuiControlGet, szTemp, MEW_ActvtExclud:, %A_GuiControl%
	LV_Modify(sel, "Col" (A_GuiControl="EActExTitle" ? 2
						  : (A_GuiControl="EActExClass" ? 3
						  : (A_GuiControl="EActExExe"   ? 4 : ""))), szTemp)
	return

	;---------------------------------------------------------------------------
	; Select target from existing windows
OnSelWindows:
	if (DlgTaskList(title, class, exe)) {
		sel := LV_GetCount()
		LV_Modify(sel,, sel, title, class, exe)
		LV_Modify(sel, "Select")
		LV_Modify(sel, "Focus")
		LV_Add("", LV_GetCount()+1)
		Gosub, OnActvExSelect
	}
	return

	;---------------------------------------------------------------------------
	; Delete selected target
OnDeleteActvEx:
	sel := LV_GetNext()
	if (!sel) {
		return
	}
	if (sel < LV_GetCount()) {
		cnt := sel+1
		while (cnt <= LV_GetCount()) {
			LV_GetText(title, cnt, 2)
			LV_GetText(class, cnt, 3)
			LV_GetText(exe,   cnt, 4)
			LV_Modify(cnt-1,,, title, class, exe)
			cnt++
		}
		Gosub, OnActvExSelect
		LV_Delete(LV_GetCount())
	} else {
		GuiControl, MEW_ActvtExclud:, EActExTitle,
		GuiControl, MEW_ActvtExclud:, EActExClass,
		GuiControl, MEW_ActvtExclud:, EActExExe,
	}
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptActvEx:
	Loop, % MG_ActvtExclud.MaxIndex()
	{
		MG_ActvtExclud.RemoveAt(1)
	}
	cnt := 0
	Loop, % LV_GetCount()
	{
		LV_GetText(title, A_Index, 2)
		LV_GetText(class, A_Index, 3)
		LV_GetText(exe,   A_Index, 4)
		if (!title && !class && !exe) {
			continue
		}
		cnt++
		aryTmp := Array(title, class, exe)
		MG_ActvtExclud.InsertAt(cnt, aryTmp)
	}
	Gui, MEW_ActvtExclud:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelActvEx:
MEW_ActvtExcludGuiClose:
MEW_ActvtExcludGuiEscape:
	Gui, MEW_ActvtExclud:Destroy
	return
}

;-------------------------------------------------------------------------------
; Show Task List
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
DlgTaskList(ByRef title, ByRef class, ByRef exe)
{
	local sel, col1, col2, col3, width, nWnd, hWnd, ret:=false

	sel:=0, col1:=200, col2:=200, col3:=200
	width := col1 + col2 + col3 + 22
	Gui, MEW_TaskList:New
	Gui, MEW_TaskList:Default
	Gui, MEW_TaskList:+Delimiter`n -MaximizeBox -MinimizeBox +HwndME_hWndTskLst +OwnerMEW_ActvtExclud
	Gui, MEW_TaskList:Add, ListView, x10 y10 w%width% h400 LV1 section -Multi vLVTaskList gOnTaskSelect AltSubmit, %ME_LngListView005%
	Gui, MEW_TaskList:Add, Button, gOnSelectTask x+-168 y+8 w80 Default, %ME_LngButton031%
	Gui, MEW_TaskList:Add, Button, gOnCancelSelTsk x+8 w80, %ME_LngButton002%
	Gui, MEW_TaskList:ListView, LVTaskList
	LV_ModifyCol(1, col1)
	LV_ModifyCol(2, col2)
	LV_ModifyCol(3, col3)
	WinGet, nWnd, List,,,!!!_dummy_dummy_dummy_!!!
	Loop, %nWnd%
	{
		hWnd := nWnd%A_Index%
		if (hWnd==ME_hWndActvEx || hWnd==ME_hWndTskLst || !MG_IsActivationTarget(hWnd, false)) {
			continue
		}
		IfWinExist, ahk_id %hWnd%
		{
			WinGetTitle, title
		    WinGetClass, class
		    WinGet, exe, ProcessName
    		LV_Add("", title, class, exe)
		}
	}
	Gui, MEW_TaskList:Show,, %ME_LngCapt009%

	WinWaitClose,  ahk_id %ME_hWndTskLst%
	Gui, MEW_ActvtExclud:Default
	return ret

	;---------------------------------------------------------------------------
	; Double-click
OnTaskSelect:
	if (A_GuiEvent=="DoubleClick") {
		Gosub, OnSelectTask
	}
	return

	;---------------------------------------------------------------------------
	; Selected
OnSelectTask:
	sel := LV_GetNext()
	if (sel) {
		LV_GetText(title, sel, 1)
		LV_GetText(class, sel, 2)
		LV_GetText(exe,   sel, 3)
		ret := true
	}
	Gui, MEW_TaskList:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelSelTsk:
MEW_TaskListGuiClose:
MEW_TaskListGuiEscape:
	ret := false
	Gui, MEW_TaskList:Destroy
	return
}

;-------------------------------------------------------------------------------
; On Browse Script Editor Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnBrowseEditor:
	Gui, MEW_Main:Submit, Nohide
	FileSelectFile, Config_ScriptEditor,, % MG_VarInStr(Config_ScriptEditor), %ME_LngCapt005%, %ME_LngText556%
	if (Config_ScriptEditor) {
		GuiControl, MEW_Main:, Config_ScriptEditor, %Config_ScriptEditor%
	}
return

;-------------------------------------------------------------------------------
; On Adjust Dialog Height Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnAdjustDlgHeight:
	OnAdjustDlgHeight()
return
OnAdjustDlgHeight()
{
	local chk
	GuiControlGet, chk, MEW_Main:, Config_AdjustDlg
	MG_CtrlStat := chk ? "Enable" : "Disable"
	GuiControl, MEW_Main:%MG_CtrlStat%, Label134
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_DlgHeightLimit
	GuiControl, MEW_Main:%MG_CtrlStat%, UDDlgHeightLimit
	AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; On Register to Startup
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnRegStartup:
	bAdmin:=false
	if (MG_IsNewOS())
	{
		MsgBox, 36, %ME_LngCapt001%, %ME_LngMessage010%
		IfMsgBox, Yes
		{
			bAdmin:=true
		}
	}
	if (bAdmin) {
		FileDelete, %A_Startup%\MouseGestureL.lnk
		bResult := RegisterTaskScheduler(A_ScriptDir . "\MouseGestureL.ahk")
	}
	else {
		RegisterTaskScheduler("Delete")
		bResult := RegisterStartup()
	}
	if (bResult) {
		MsgBox,, %ME_LngCapt001%, %ME_LngMessage011%
	}
return

RegisterTaskScheduler(szMGL)
{
	if (!MG_IsNewOS()) {
		return
	}
	szPath := A_Temp . "\~MG_SchTasks.bat"
	file := FileOpen(szPath, "w `n")
	if (!file) {
		return
	}
	if (szMGL != "Delete") {
		szCommand := "SCHTASKS /Create /TN ""MouseGestureL.ahk"" /TR ""\"""
		szCommand .= A_AhkPath . "\"" \""" . szMGL
		szCommand .= "\"""" /SC ONLOGON /RL HIGHEST /F`n"
	}
	else {
		szCommand := "SCHTASKS /Delete /TN ""MouseGestureL.ahk"" /F`n"
	}
	szCommand .= "EXIT /B %ERRORLEVEL%"
	file.Write(szCommand)
	file.Close

	RunWait, *runas %szPath%,, Hide UseErrorLevel
	bResult := !ErrorLevel
	FileDelete, %szPath%
	return bResult
}

RegisterStartup()
{
	if (A_AhkPath = (A_ScriptDir . "\MouseGestureL.exe")) {
		szPath := A_AhkPath
	} else {
		szPath := A_ScriptDir . "\MouseGestureL.ahk"
	}
	FileCreateShortcut, %szPath%, %A_Startup%\MouseGestureL.lnk, %A_ScriptDir%,, MouseGestureL.ahk, %A_ScriptDir%\Components\MouseGestureL.ico,, 1
	return % !ErrorLevel
}

;-------------------------------------------------------------------------------
; On Remove from Startup
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnDelStartup:
	FileDelete, %A_Startup%\MouseGestureL.lnk
	bResult := !ErrorLevel
	bResult |= RegisterTaskScheduler("Delete")
	if (bResult) {
		MsgBox,, %ME_LngCapt001%, %ME_LngMessage012%
	}
return

;-------------------------------------------------------------------------------
; On Hint Type Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnNaviChange:
	GuiControlGet, idx, MEW_Main:, Config_UseExNavi

	MG_CtrlStat := (idx==2 || idx==3) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviTransBG
	GuiControl, MEW_Main:%MG_CtrlStat%, Label64
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviFG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorExNaviFG
	GuiControl, MEW_Main:%MG_CtrlStat%, Label65
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviBG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorExNaviBG
	GuiControl, MEW_Main:%MG_CtrlStat%, ExNaviIdvClr
	GuiControl, MEW_Main:%MG_CtrlStat%, Label66
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, UDExNaviTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, Label67
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviSize
	GuiControl, MEW_Main:%MG_CtrlStat%, UDExNaviSize
	GuiControl, MEW_Main:%MG_CtrlStat%, Label68
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviSpacing
	GuiControl, MEW_Main:%MG_CtrlStat%, UDExNaviSpacing
	GuiControl, MEW_Main:%MG_CtrlStat%, Label69
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviPadding
	GuiControl, MEW_Main:%MG_CtrlStat%, UDExNaviPadding
	GuiControl, MEW_Main:%MG_CtrlStat%, Label70
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviMargin
	GuiControl, MEW_Main:%MG_CtrlStat%, UDExNaviMargin

	MG_CtrlStat := (idx==4 || idx==5) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviOnClick
	GuiControl, MEW_Main:%MG_CtrlStat%, Label71
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviFG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorAdNaviFG
	GuiControl, MEW_Main:%MG_CtrlStat%, Label72
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviNI
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorAdNaviNI
	GuiControl, MEW_Main:%MG_CtrlStat%, Label73
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviBG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorAdNaviBG
	GuiControl, MEW_Main:%MG_CtrlStat%, Label74
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, Label75
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviFont
	GuiControl, MEW_Main:%MG_CtrlStat%, Label76
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviSize
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviSize
	GuiControl, MEW_Main:%MG_CtrlStat%, Label77
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviPosition
	GuiControl, MEW_Main:%MG_CtrlStat%, Label78
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviPaddingL
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviPaddingL
	GuiControl, MEW_Main:%MG_CtrlStat%, Label79
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviPaddingR
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviPaddingR
	GuiControl, MEW_Main:%MG_CtrlStat%, Label80
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviPaddingT
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviPaddingT
	GuiControl, MEW_Main:%MG_CtrlStat%, Label81
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviPaddingB
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviPaddingB
	GuiControl, MEW_Main:%MG_CtrlStat%, Label82
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviRound
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviRound
	GuiControl, MEW_Main:%MG_CtrlStat%, Label83
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviMargin
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviMargin
	GuiControl, MEW_Main:%MG_CtrlStat%, Label84
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviSpaceX
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviSpaceX
	GuiControl, MEW_Main:%MG_CtrlStat%, Label85
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_AdNaviSpaceY
	GuiControl, MEW_Main:%MG_CtrlStat%, UDAdNaviSpaceY

	Gosub, OnExNaviTransBGChange
return

;-------------------------------------------------------------------------------
; On Arrow Hints Transparent Background Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnExNaviTransBGChange:
	MG_CtrlStat := "Disable"
	GuiControlGet, idx, MEW_Main:, Config_UseExNavi
	if (idx==2 || idx==3)
	{
		GuiControlGet, chk, MEW_Main:, Config_ExNaviTransBG
		MG_CtrlStat := chk ? "Disable" : "Enable"
	}
	GuiControl, MEW_Main:%MG_CtrlStat%, Label65
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_ExNaviBG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorExNaviBG
return

;-------------------------------------------------------------------------------
; On Coler Setting Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnColorChange:
	GuiControlGet, SampleColor, MEW_Main:, %A_GuiControl%
	ColorTarget := RegExReplace(A_GuiControl, "Config_", "Color")
	GuiControl, MEW_Main:+Background%SampleColor%, %ColorTarget%
return

;-------------------------------------------------------------------------------
; Set Individual Colors of Arrow Hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnExNaviIdvClr:
	DlgExNaviIndividualColor()
return
DlgExNaviIndividualColor()
{
	global
	static idxRow
	idxRow := 0
	Gui, MEW_Color:New
	Gui, MEW_Color:Default
	Gui, MEW_Color:+Delimiter`n -MaximizeBox -MinimizeBox +HwndME_hWndColor +OwnerMEW_Main
	Gui, MEW_Color:Add, ListView, x10 y10 w184 h172 LV1 section -Multi NoSortHdr vLVColors gOnTriggerSelect AltSubmit, %ME_LngListView004%
	LV_ModifyCol(1, 70)
	LV_ModifyCol(2, 90)
	Gui, MEW_Color:ListView, LVColors
	GuiControl, MEW_Color: -Redraw, LVColors
	LV_Delete()
	local szColor
	Loop, Parse, MG_BtnNames, _
	{
		szColor := Config_ExNaviFG_%A_LoopField%
		LV_Add("", A_LoopField, szColor)
	}
	GuiControl, MEW_Color: +Redraw, LVColors
	Gui, MEW_Color:Add, Text, xs-2 y+10 w68 Right, %ME_LngText210%
	Gui, MEW_Color:Add, Edit, x+6 yp-4 w91 Limit6 Disabled vEArrowColor gOnArrowColorChange
	Gui, MEW_Color:Add, TreeView, x+1 w20 h20 vColorBox
	Gui, MEW_Color:Add, Button, gOnAcceptColor x+-168 y+10 w80, %ME_LngButton001%
	Gui, MEW_Color:Add, Button, gOnCancelColor x+8 yp+0 w80, %ME_LngButton002%
	Gui, MEW_Color:Show,, %ME_LngCapt006%

	WinWaitClose,  ahk_id %ME_hWndColor%
	Gui, MEW_Main:Default
	return

	;---------------------------------------------------------------------------
	; Trigger is selected
OnTriggerSelect:
	idxRow := LV_GetNext()
	if (!idxRow)
	{
		GuiControl, MEW_Color: Disable, EArrowColor
		GuiControl, MEW_Color:, EArrowColor,
		GuiControl, MEW_Color: +BackgroundFFFFFF, ColorBox
		return
	}
	if (A_GuiEvent!="Normal" && A_GuiEvent!="K") {
		return
	}
	GuiControl, MEW_Color: Enable, EArrowColor
	LV_GetText(szColor, idxRow, 2)
	GuiControl, MEW_Color:, EArrowColor, %szColor%
	return

	;---------------------------------------------------------------------------
	; On Arrow Color Change
OnArrowColorChange:
	if (!idxRow) {
		return
	}
	GuiControlGet, szColor, MEW_Color:, EArrowColor
	LV_Modify(idxRow, "Col2", szColor)
	if (szColor = "") {
		szColor := "FFFFFF"
	}
	GuiControl, MEW_Color: +Background%szColor%, ColorBox
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptColor:
	Loop, % LV_GetCount()
	{
		LV_GetText(szColor, A_Index, 2)
		local szTrigger
		LV_GetText(szTrigger, A_Index, 1)
		if (szColor != "")
		{
			CorrectColorHex(szColor, true)
			Config_ExNaviFG_%szTrigger% := szColor
		}
		else if (Config_ExNaviFG_%szTrigger%)
		{
			Config_ExNaviFG_%szTrigger% := ""
		}
	}
	Gui, MEW_Color:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelColor:
MEW_ColorGuiClose:
MEW_ColorGuiEscape:
	Gui, MEW_Color:Destroy
	return
}

;-------------------------------------------------------------------------------
; Correct Color Hex String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CorrectColorHex(ByRef szColor, fLength=false)
{
	StringUpper, szColor, szColor
	szColor := RegExReplace(szColor, "[^0-9A-F]")
	if (fLength)
	{
		len := StrLen(szColor)
		Loop, % (6 - len)
		{
			szColor := "0" . szColor
		}
	}
}

;-------------------------------------------------------------------------------
; On Hint Display Position Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnNaviPosChange:
	GuiControlGet, idx, MEW_Main:, Config_AdNaviPosition
	stat := (idx==1) ? "Show" : "Hide"
	GuiControl, MEW_Main:%stat%, Label83
	GuiControl, MEW_Main:%stat%, Config_AdNaviMargin
	GuiControl, MEW_Main:%stat%, UDAdNaviMargin
	stat := (idx==1) ? "Hide" : "Show"
	GuiControl, MEW_Main:%stat%, Label84
	GuiControl, MEW_Main:%stat%, Config_AdNaviSpaceX
	GuiControl, MEW_Main:%stat%, UDAdNaviSpaceX
	GuiControl, MEW_Main:%stat%, Label85
	GuiControl, MEW_Main:%stat%, Config_AdNaviSpaceY
	GuiControl, MEW_Main:%stat%, UDAdNaviSpaceY
return

;-------------------------------------------------------------------------------
; On Show Trail Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnShowTrailChange:
	GuiControlGet, chk, MEW_Main:, Config_ShowTrail
	MG_CtrlStat := chk ? "Enable" : "Disable"
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_DrawTrailWnd
	GuiControl, MEW_Main:%MG_CtrlStat%, Label101
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_TrailColor
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorTrailColor
	GuiControl, MEW_Main:%MG_CtrlStat%, Label102
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_TrailTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, UDTrailTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, Label103
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_TrailWidth
	GuiControl, MEW_Main:%MG_CtrlStat%, UDTrailWidth
	GuiControl, MEW_Main:%MG_CtrlStat%, Label104
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_TrailStartMove
	GuiControl, MEW_Main:%MG_CtrlStat%, UDTrailStartMove
	GuiControl, MEW_Main:%MG_CtrlStat%, Label105
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_TrailInterval
	GuiControl, MEW_Main:%MG_CtrlStat%, UDTrailInterval
return

;-------------------------------------------------------------------------------
; On Show Logs Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnShowLogsChange:
	GuiControlGet, chk, MEW_Main:, Config_ShowLogs
	MG_CtrlStat := chk ? "Enable" : "Disable"
	GuiControl, MEW_Main:%MG_CtrlStat%, Label106
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogPosition
	GuiControl, MEW_Main:%MG_CtrlStat%, Label107
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogPosX
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogPosX
	GuiControl, MEW_Main:%MG_CtrlStat%, Label108
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogPosY
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogPosY
	GuiControl, MEW_Main:%MG_CtrlStat%, Label109
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogMax
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogMax
	GuiControl, MEW_Main:%MG_CtrlStat%, Label110
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogSizeW
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogSizeW
	GuiControl, MEW_Main:%MG_CtrlStat%, Label111
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogInterval
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogInterval
	GuiControl, MEW_Main:%MG_CtrlStat%, Label112
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogFG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorLogFG
	GuiControl, MEW_Main:%MG_CtrlStat%, Label113
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogBG
	GuiControl, MEW_Main:%MG_CtrlStat%, ColorLogBG
	GuiControl, MEW_Main:%MG_CtrlStat%, Label114
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogTranspcy
	GuiControl, MEW_Main:%MG_CtrlStat%, Label115
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogFontSize
	GuiControl, MEW_Main:%MG_CtrlStat%, UDLogFontSize
	GuiControl, MEW_Main:%MG_CtrlStat%, Label116
	GuiControl, MEW_Main:%MG_CtrlStat%, Config_LogFont
return

;-------------------------------------------------------------------------------
; Show Help Document
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowHelp:
	MG_ShowHelp()
return

;-------------------------------------------------------------------------------
; On Direction Button Press
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
Dir1:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture,%EGesture%1
	}
return

Dir2:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture,%EGesture%2
	}else{
		GuiControl, MEW_Main:, EGesture,%EGesture%D
	}
return

Dir3:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture,%EGesture%3
	}
return

Dir4:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture,%EGesture%4
	}else{
		GuiControl, MEW_Main:, EGesture,%EGesture%L
	}
return

Dir6:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture,%EGesture%6
	}else{
		GuiControl, MEW_Main:, EGesture,%EGesture%R
	}
return

Dir7:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture,%EGesture%7
	}
return

Dir8:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture, %EGesture%8
	}else{
		GuiControl, MEW_Main:, EGesture, %EGesture%U
	}
return

Dir9:
	Gui, MEW_Main:Submit, NoHide
	if(Config_8Dir){
		GuiControl, MEW_Main:, EGesture, %EGesture%9
	}
return

;-------------------------------------------------------------------------------
; On Button List Events
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
LBButtons:
	;---------------------------------------------------------------------------
	; On Double Click
	if (A_GuiEvent="DoubleClick")
	{
		Gui, MEW_Main:Submit, NoHide
		if (LBGesture) {
			GuiControl, MEW_Main:, EGesture, % EGesture . Button_%LBButtons% . "_"
		}
	}
return

;-------------------------------------------------------------------------------
; On Trigger Up Button Press
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
BButtonUp:
	Gui, MEW_Main:Submit, NoHide
	GuiControl, MEW_Main:, EGesture, %EGesture%_
return

;-------------------------------------------------------------------------------
; Add New Target Entry
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetNew:
	TargetNew(false)
return
TargetNew(bSub=false, bMove=false)
{
	global
	local idx, nCh, parent
	if (bSub && Target_Editing<=1) {
		return
	}
	SaveModification()
	EnableRuleControls()
	Target_Count++
	if (!Target_Editing) {
		Target_Editing := Target_Count
	}
	idx := Target_Count
	if (bSub)
	{
		while (idx > Target_Editing+1)
		{
			TargetMove(idx-1, idx)
			if (Target_%idx%_Parent > Target_Editing) {
				Target_%idx%_Parent++
			}
			idx--
		}
		Target_%idx%_Name	  := ME_LngOthers002 "_" Target_Count
		Target_%idx%_Count	  := 0
		Target_%idx%_Icon	  := 0
		Target_%idx%_IconFile := ""
		Target_%idx%_IsAnd	  := 0
		Target_%idx%_Level	  := Target_%Target_Editing%_Level + 1
		Target_%idx%_Parent	  := Target_Editing
		Target_%idx%_NotInh	  := 0
	}
	else
	{
		Target_%idx%_Name	  := ME_LngOthers002 "_" Target_Count
		Target_%idx%_Count	  := 0
		Target_%idx%_Icon	  := 0
		Target_%idx%_IconFile := ""
		Target_%idx%_IsAnd	  := 0
		Target_%idx%_Level	  := 1
		Target_%idx%_Parent	  := ""
		Target_%idx%_NotInh	  := 0
		if (bMove)
		{
			while (idx > Target_Editing+1) {
				idx := TargetShift(idx, -1, false, true)
			}
			while (idx < Target_Editing) {
				idx := TargetShift(idx, 1, false, true)
			}
		}
	}
	ClearRule()
	ShowTargets()
	ShowTarget(idx)
	AdjustDialogHeight()
	SaveModification("Reset")
	SetFocusETargetName()
}

;-------------------------------------------------------------------------------
; Enable Rule Controls
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
EnableRuleControls()
{
	GuiControl, MEW_Main:Enable, DDLLogic
	GuiControl, MEW_Main:Enable, Label12
	GuiControl, MEW_Main:Enable, DDLRuleType
	GuiControl, MEW_Main:Enable, BRulePicker
	GuiControl, MEW_Main:Enable, Label13
	GuiControl, MEW_Main:Enable, ERuleValue
	GuiControl, MEW_Main:Enable, BClearRule
	GuiControl, MEW_Main:Enable, ChkNotMatch
}

;-------------------------------------------------------------------------------
; Swtich Tab Page
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SwitchTab(idx)
{
	Global
	if (MainTabIdx != idx)
	{
		SaveModification()
		MainTabIdx := idx
		GuiControl, MEW_Main:Choose, MainTab, %idx%
		if (idx == 1) {
			GuiControl, MEW_Main:Focus, TVTarget1
		} else if (idx == 2) {
			GuiControl, MEW_Main:Focus, TVTarget2
		} else if (idx == 3) {
			GuiControl, MEW_Main:Focus, LBGesture
		}
	}
}

;-------------------------------------------------------------------------------
; Move Up/Down Target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetUp:
	TargetShift(Target_Editing, -1)
return

TargetDown:
	TargetShift(Target_Editing, 1)
return

TargetShift(idx, shift, bShow=true, bSkipSub=true)
{
	global
	local dest, next, nCh, lv

	if ((shift<0 && ItemCanMoveUp("T", idx)="Disable")
	||	(shift>0 && ItemCanMoveDown("T", idx)="Disable")) {
		return
	}
	dest := bSkipSub ? GetNextTarget(idx, shift) : idx+shift
	nCh := bSkipSub ? GetChildTargetNum(idx) : 0
	lv := Target_%idx%_Level
	while (dest != idx)
	{
		next := idx + shift + (shift>0 ? nCh : 0)
		if (Target_%next%_Level > lv) {
			Target_%next%_Parent -= (shift + (shift>0 ? nCh : -nCh))
		}
		TargetShiftWithChildren(idx, shift, nCh)
		idx += shift
	}
	if (bShow) {
		ShowTargets()
		ShowTarget(dest, false)
	}
	return dest
}

;-------------------------------------------------------------------------------
; Get Next Target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetNextTarget(idx, shift)
{
	local next, parent
	if (shift > 0) {
		next := idx + GetChildTargetNum(idx) + 1
		next := idx + GetChildTargetNum(next) + 1
	}
	else {
		next := idx - 1
		next := idx - GetGroupTargetNum(next, Target_%idx%_Level)
	}
	return next
}

;-------------------------------------------------------------------------------
; Get the Number of Child Targets
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetChildTargetNum(idx)
{
	local nCh, next
	nCh := 0
	next := idx + 1
	if ((idx > 0) && (Target_%next%_Parent == idx))
	{
		while ((next<=Target_Count) && (Target_%next%_Level > Target_%idx%_Level)) {
			nCh++
			next++
		}
	}
	return nCh
}

;-------------------------------------------------------------------------------
; Get the Number of Targets in the Group
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetGroupTargetNum(ByRef idx, LvLimit=0)
{
	global
	while (Target_%idx%_Parent && (Target_%idx%_Level > LvLimit)) {
		idx := Target_%idx%_Parent
	}
	return (GetChildTargetNum(idx) + 1)
}

;-------------------------------------------------------------------------------
; Shift Target with Child Targets
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TargetShiftWithChildren(idx, shift, nCh)
{
	global
	local max, dest, pos, next, lv
	max := nCh + 1
	if (shift > 0) {
		dest := idx
		pos := max+idx-1
		next := pos+1
	} else {
		dest := max+idx-1
		pos := idx
		next := pos-1
	}
	TargetMove(next, "tmp")
	lv := Target_%idx%_Level
	Loop, %max%
	{
		if (Target_%pos%_Level > lv) {
			Target_%pos%_Parent += shift
		}
		TargetMove(pos, next)
		pos-=shift, next-=shift
	}
	TargetMove("tmp", dest)
}

;-------------------------------------------------------------------------------
; Delete Target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetDelete:
	TargetDelete()
return
TargetDelete()
{
	local szFull, szGes, szInc, szTarget, szMsg
	if (Target_Editing <= 1) {
		return
	}
	szFull := MakeTargetFullName(Target_Editing)
	szGes := CheckTargetUsed(szFull)
	szInc := CheckTargetIncluded(szFull)
	if (szGes!="" || szInc!="")
	{
		szTarget := RegExReplace(ME_LngMessage001, "\[#REPLASE#\]", szFull)
		szMsg := ""
		if (szGes!="") {
			szMsg := szTarget . RegExReplace(ME_LngMessage003, "\[#REPLASE#\]", szGes)
		}
		if (szInc!="") {
			szMsg .= szTarget . RegExReplace(ME_LngMessage004, "\[#REPLASE#\]", szInc)
		}
		szMsg .= ME_LngMessage005
		MsgBox, 33, %ME_LngCapt003%, %szMsg%
		IfMsgBox, Cancel
		{
			return
		}
	}
	CheckTargetUsed(szFull, true)
	CheckTargetIncluded(szFull, "Delete")
	local nCh, parent, dest
	nCh := GetChildTargetNum(Target_Editing)
	parent := Target_%Target_Editing%_Parent
	Loop, %Target_Count%
	{
		if (A_Index > Target_Editing+nCh)
		{
			if (Target_%A_Index%_Parent > Target_Editing) {
				Target_%A_Index%_Parent -= nCh+1
			}
			dest := A_Index-nCh-1
			TargetSwap(A_Index, dest)
		}
	}
	Target_Count -= nCh+1
	ClearRule()
	ClearAction(false, "BE")
	ShowTargets()
	ShowTarget(Target_Editing>Target_Count ? Target_Count : Target_Editing)
	ShowGesture(Gesture_Editing)
	ShowAssignedGestures(0, false)
	SelectAssignedAction()
	AdjustDialogHeight()
	SaveModification("Reset")
}

;-------------------------------------------------------------------------------
; Check whether the target is used
;	szTarget : Target name to be checked
;	bDelete  : true = Delete actions
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CheckTargetUsed(szTarget, bDelete=false)
{
	local szList := ""
	Loop, %Gesture_Count%
	{
		local ges := A_Index
		Loop, % Gesture_%A_Index%_Count
		{
			if (TargetIsAssigned(ges, A_Index, szTarget))
			{
				if (bDelete) {
					ActionDelete(ges, A_Index, false, false)
				} else {
					local szName := RegExReplace(ME_LngMessage001, "\[#REPLASE#\]", Gesture_%ges%_Name)
					Join(szList, szName, ME_LngMessage002)
				}
			}
		}
	}
	return szList
}

;-------------------------------------------------------------------------------
; Check whether the target is assigned to specified gesture
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TargetIsAssigned(ges, idx, tgt)
{
	global
	return ((Gesture_%ges%_%idx%_Target == tgt)
		 || (InStr(Gesture_%ges%_%idx%_Target, tgt . MG_TgDelim)==1))
}

;-------------------------------------------------------------------------------
; Check whether the target is included
;	szTarget : Target name to be checked
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CheckTargetIncluded(szTarget, ope="Check", szNewName="")
{
	local szList := ""
	Loop, %Target_Count%
	{
		local idx1 := A_Index
		Loop, % Target_%idx1%_Count
		{
			local idx2 := A_Index
			if ((InStr(Target_%idx1%_%idx2%_Type, "Include") == 1)
			&&	((Target_%idx1%_%idx2%_Value == szTarget) || (InStr(Target_%idx1%_%idx2%_Value, szTarget . MG_TgDelim)==1)))
			{
				if (ope = "Rename") {
					Target_%idx1%_%idx2%_Value := RegExReplace(Target_%idx1%_%idx2%_Value, szTarget, szNewName)
				}
				else if (ope = "Delete") {
					RuleDelete(idx1, idx2, false)
				}
				else {
					local szName := RegExReplace(ME_LngMessage001, "\[#REPLASE#\]", MakeTargetFullName(idx1))
					Join(szList, szName, ME_LngMessage002)
				}
			}
		}
	}
	return szList
}

;-------------------------------------------------------------------------------
; Sort Target List
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TargetSort:
	TargetSort()
return
TargetSort()
{
	global
	local cntTemp, idxTgt, idxCmp, idxTmp, fPrior, nCh, diff
	SaveModification()
	cntTemp := 0
	idxTgt := 0
	Loop, % Target_Count
	{
		idxTgt++
		fPrior := 0
		if (idxTgt != 1)
		{
			idxCmp := 0
			Loop, %cntTemp%
			{
				idxCmp++
				if (idxCmp==1 || Target_Temp%idxCmp%_Level>1) {
					continue
				}
				if (Target_%idxTgt%_Name < Target_Temp%idxCmp%_Name)
				{
					fPrior := 1
					nCh := GetChildTargetNum(idxTgt)
					diff := nCh + 1
					Loop, % (cntTemp-idxCmp+1)
					{
						idxTmp := cntTemp-(A_Index-1)
						if (Target_Temp%idxTmp%_Parent) {
							Target_Temp%idxTmp%_Parent += diff
						}
						TargetMove("Temp"idxTmp, "Temp"idxTmp+diff)
					}
					diff := idxTmp - idxTgt
					Loop, % nCh+1
					{
						if (A_Index > 1) {
							idxTgt++, idxTmp++
						}
						TargetMove(idxTgt, "Temp"idxTmp)
						if (Target_Temp%idxTmp%_Parent) {
							Target_Temp%idxTmp%_Parent += diff
						}
					}
					cntTemp += nCh
					break
				}
			}
		}
		cntTemp++
		if (!fPrior)
		{
			diff := cntTemp - idxTgt
			nCh := GetChildTargetNum(idxTgt)
			Loop, % nCh+1
			{
				if (A_Index > 1) {
					idxTgt++, cntTemp++
				}
				TargetMove(idxTgt, "Temp"cntTemp)
				if (Target_Temp%cntTemp%_Parent) {
					Target_Temp%cntTemp%_Parent += diff
				}
			}
		}
		if (cntTemp >= Target_Count) {
			break
		}
	}
	Loop, % Target_Count {
		TargetMove("Temp"A_Index, A_Index)
	}
	ShowTargets()
	ShowTarget(Target_Editing, false)
}

;-------------------------------------------------------------------------------
; Move Target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetMove(from, to)
{
	global
	Target_%to%_Name	 := Target_%from%_Name
	Target_%to%_Count	 := Target_%from%_Count
	Target_%to%_Icon	 := Target_%from%_Icon
	Target_%to%_IconFile := Target_%from%_IconFile
	Target_%to%_IsAnd	 := Target_%from%_IsAnd
	Target_%to%_Level	 := Target_%from%_Level 
	Target_%to%_Parent	 := Target_%from%_Parent
	Target_%to%_NotInh	 := Target_%from%_NotInh
	Loop, % Target_%from%_Count
	{
		Target_%to%_%A_Index%_Type	:= Target_%from%_%A_Index%_Type
		Target_%to%_%A_Index%_Value := Target_%from%_%A_Index%_Value
		Target_%from%_%A_Index%_Type  := ""
		Target_%from%_%A_Index%_Value := ""
	}
}

;-------------------------------------------------------------------------------
; Swap Targets
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
TargetSwap(a, b)
{
	TargetMove(a, "tmp")
	TargetMove(b, a)
	TargetMove("tmp", b)
}

;-------------------------------------------------------------------------------
; Set Focus to Target Name Edit
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SetFocusETargetName()
{
	SwitchTab(2)
	GuiControl, MEW_Main:Focus, ETargetName
	SendMessage, 0x00B1, 0, -1,, % "ahk_id" ControlGetHandle("ETargetName")
}

;-------------------------------------------------------------------------------
; Rename Target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetRename:
	Gui, MEW_Main:Submit, NoHide
	RenameTarget(ETargetName)
return
RenameTarget(name)
{
	local szFull, szFull2
	szFull := MakeTargetFullName(Target_Editing)
	Target_%Target_Editing%_Name := name
	szFull2 := MakeTargetFullName(Target_Editing)
	CheckTargetIncluded(szFull, "Rename", szFull2)
	Gui, MEW_Main:Default
	if (Target_Editing > 1) {
		Gui, MEW_Main:TreeView, TVTarget1
		TV_Modify(TvIndexToId(Target_Editing),,name)
	}
	Gui, MEW_Main:TreeView, TVTarget2
	GuiControl, MEW_Main:-g, TVTarget2
	TV_Modify(TvIndexToId(Target_Editing),,name)
	GuiControl, MEW_Main:+gTVTargetSelect, TVTarget2

	local ges:=0, pat:=0, bUpdate:=false
	Loop, % Gesture_Count
	{
		ges++
		pat:=0
		Loop, % Gesture_%ges%_Count
		{
			pat++
			if (TargetIsAssigned(ges, pat, szFull)) {
				bUpdate:=true
				Gesture_%ges%_%pat%_Target := RegExReplace(Gesture_%ges%_%pat%_Target, szFull, szFull2)
			}
		}
	}
	if (bUpdate) {
		ShowGestures()
		ShowGesture(Gesture_Editing)
	}
	AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; On Target Name Change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ETargetNameChange:
	Gui, MEW_Main:Submit, NoHide
	GuiControl, % "MEW_Main:" (CheckTargetName(ETargetName) ? "Enable" : "Disable"), BTargetRename
return

;-------------------------------------------------------------------------------
; Check Target Name
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CheckTargetName(name)
{
	global
	if (Target_Editing && !RegExMatch(name, "^(|" . MG_RuleNames . "|Icon|And|Level|NotInherit|G|" . MC_DefTargetName . ")$|.*(=|" . MG_TgDelim . ").*"))
	{
		Loop, %Target_Count%
		{
			if ((Target_%A_Index%_Parent == Target_%Target_Editing%_Parent)
			&&	(Target_%A_Index%_Name == name))
			{
				return false
			}
		}
		return true
	}
	return false
}

;-------------------------------------------------------------------------------
; Show All Targets
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowTargets(bSelFirst=false)
{
	local name, opt
	GuiControl, MEW_Main:-Redraw, TVTarget1
	GuiControl, MEW_Main:-Redraw, TVTarget2
	Gui, MEW_Main:Default
	Gui, MEW_Main:TreeView, TVTarget1
	GuiControl, MEW_Main:-g, TVTarget1
	TV_Delete()
	GuiControl, MEW_Main:+gTVTargetSelect, TVTarget1
	Gui, MEW_Main:TreeView, TVTarget2
	GuiControl, MEW_Main:-g, TVTarget2
	TV_Delete()
	GuiControl, MEW_Main:+gTVTargetSelect, TVTarget2
	Loop, %Target_Count%
	{
		GuiControlGet, Config_FoldTarget, MEW_Main:, Config_FoldTarget
		opt := Config_FoldTarget ? "" : "Expand "
		opt .= Target_%A_Index%_Icon ? "Icon"Target_%A_Index%_Icon : "Icon"Target_Blank_Icon
		name := Target_%A_Index%_Name
		Gui, MEW_Main:TreeView, TVTarget1
		if (A_Index == 1) {
			TV_Add(ME_LngOthers001, 0, "Icon"Target_Default_Icon)
		} else {
			TV_Add(name, TvIndexToId(Target_%A_Index%_Parent), opt)
		}
		Gui, MEW_Main:TreeView, TVTarget2
		TV_Add(name, TvIndexToId(Target_%A_Index%_Parent), opt)
	}
	if (bSelFirst) {
		Gui, MEW_Main:TreeView, TVTarget1
		TV_Modify(TvIndexToId(1))
		Gui, MEW_Main:TreeView, TVTarget2
		GuiControl, MEW_Main:-g, TVTarget2
		TV_Modify(TvIndexToId(1))
		GuiControl, MEW_Main:+gTVTargetSelect, TVTarget2
	}
	GuiControl, MEW_Main:+Redraw, TVTarget1
	GuiControl, MEW_Main:+Redraw, TVTarget2
}

;-------------------------------------------------------------------------------
; Make Full Name of Target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MakeTargetFullName(idx, bAction=false)
{
	global
	if (bAction && idx<=1) {
		return MC_DefTargetName
	}
	local name, parent
	name := Target_%idx%_Name
	parent := Target_%idx%_Parent
	while(parent) {
		name := Target_%parent%_Name . MG_TgDelim . name
		parent := Target_%parent%_Parent
	}
	return name
}

;-------------------------------------------------------------------------------
; On Target Fold Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnTargetFoldChange:
	SwitchTargetFolding()
return
SwitchTargetFolding(bToggle=false)
{
	global
	if (bToggle) {
		GuiControlGet, Config_FoldTarget, MEW_Main:, Config_FoldTarget
		GuiControl, MEW_Main:, Config_FoldTarget, % Config_FoldTarget ? 0 : 1
	}
	ShowTargets()
	ShowTarget(Target_Editing)
	AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; Target Tree View Events
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TVTargetSelect:
	TargetSelect()
return
TargetSelect(bSel=false)
{
	local idx, sel, tv, name
	Gui, MEW_Main:Default
	Gui, MEW_Main:TreeView, %A_GuiControl%
	;---------------------------------------------------------------------------
	; On Selection Change
	if (A_GuiEvent=="S" || bSel)
	{
		sel := TV_GetSelection()
		if (sel) {
			SelectTarget(TvIdToIndex(sel), false)
		}
	}
	;---------------------------------------------------------------------------
	; On Right Click
	else if (A_GuiEvent=="RightClick" || A_GuiEvent=="d")
	{
		idx := TvIdToIndex(A_EventInfo)
		TV_Modify(TvIndexToId(idx))
		TargetSelect(true)
		ShowListContextMenu("T", idx)
	}
	;---------------------------------------------------------------------------
	; On Double Click
	else if (A_GuiEvent == "DoubleClick")
	{
		if (!GetChildTargetNum(TvIdToIndex(A_EventInfo))) {
			SetTimer, ToggleTabs, -1
		}
	}
	;---------------------------------------------------------------------------
	; On Drag Start
	else if (A_GuiEvent == "D")
	{
		idx := TvIdToIndex(A_EventInfo)
		ShowTarget(idx, false)
	}
	;---------------------------------------------------------------------------
	; On Rename Start
	else if (A_GuiEvent == "E")
	{
		ME_bTvRenaming := true
	}
	;---------------------------------------------------------------------------
	; On Rename Finish
	else if (A_GuiEvent == "e")
	{
		ME_bTvRenaming := false
		TV_GetText(name, A_EventInfo)
		if (A_GuiControl=="TVTarget1" && Target_Editing==1) {
			Gui, MEW_Main:TreeView, TVTarget1
			TV_Modify(TvIndexToId(1),,ME_LngOthers001)
		}
		else if (CheckTargetName(name)) {
			RenameTarget(name)
			GuiControl, MEW_Main:, ETargetName,%name%
		}
		else {
			name := Target_%Target_Editing%_Name
			Gui, MEW_Main:TreeView, TVTarget1
			TV_Modify(TvIndexToId(Target_Editing),,name)
			Gui, MEW_Main:TreeView, TVTarget2
			TV_Modify(TvIndexToId(Target_Editing),,name)
		}
	}
	;---------------------------------------------------------------------------
	; On Expand / Fold
	else if (A_GuiEvent=="+" || A_GuiEvent=="-")
	{
		idx := TvIdToIndex(A_EventInfo)
		tv := (A_GuiControl = "TVTarget1") ? "TVTarget2" : "TVTarget1"
		Gui, MEW_Main:TreeView, %tv%
		GuiControl, MEW_Main:-g, %tv%
		TV_Modify(TvIndexToId(idx), A_GuiEvent "Expand")
		GuiControl, MEW_Main:+g%A_ThisLabel%, %tv%
	}
	return

ToggleTabs:
	SwitchTab(MainTabIdx==1 ? 2 : 1)
	return
}

;-------------------------------------------------------------------------------
; Select Specified Target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SelectTarget(idx, bSelList=true)
{
	global
	Gui, MEW_Main:Submit, NoHide
	SaveModification()
	EnableRuleControls()
	ShowTarget(idx, false)
	ShowRule(Target_Editing, 0)
	SelectAssignedAction()
	ShowAssignedGestures(idx)
	if (idx==1 && MG_ActionExists(Gesture_Editing, MC_DefTargetName)) {
		GuiControl, MEW_Main:Choose, LBDefAction, 1
	}
	if (bSelList) {
		Gui, MEW_Main:Default
		Gui, MEW_Main:TreeView, TVTarget1
		GuiControl, MEW_Main:-g, TVTarget1
		TV_Modify(TvIndexToId(idx))
		GuiControl, MEW_Main:+gTVTargetSelect, TVTarget1
		Gui, MEW_Main:TreeView, TVTarget2
		GuiControl, MEW_Main:-g, TVTarget2
		TV_Modify(TvIndexToId(idx))
		GuiControl, MEW_Main:+gTVTargetSelect, TVTarget2
	}
}

;-------------------------------------------------------------------------------
; Show Context Menu of Gesture/Target List
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowListContextMenu(list, idx)
{
	local name, ges, hit, stat, itemName, szBuf
	;...........................................................................
	; Create Menu
	Menu, menuContext, Add
	Menu, menuContext, DeleteAll
	if (list="T"){
		ShowUnassignedGestureMenu(0, false)
		if (MainTabIdx == 1) {
			Menu, menuContext, Add, %ME_LngMenu105%, OnListContextSelect
		}
		Menu, menuContext, Add, %ME_LngMenu103%, OnListContextSelect
		Menu, menuContext, Add, %ME_LngMenu104%, OnListContextSelect
		Menu, menuContext, Add
		Menu, menuContext, Add, %ME_LngMenu115%, :menuGestureList
	}
	else {
		Menu, menuContext, Add, %ME_LngMenu121%, OnListContextSelect
	}
	Menu, menuContext, Add
	Menu, menuContext, Add, %ME_LngMenu106%, OnListContextSelect
	Menu, menuContext, Add, %ME_LngMenu107%, OnListContextSelect
	Menu, menuContext, Add
	Menu, menuContext, Add, %ME_LngMenu108%, OnListContextSelect
	Menu, menuContext, Add, %ME_LngMenu109%, OnListContextSelect
	Menu, menuContext, Add
	Menu, menuContext, Add, %ME_LngMenu110%, OnListContextSelect
	Menu, menuContext, Add, %ME_LngMenu111%, OnListContextSelect
	Menu, menuContext, Add, %ME_LngMenu112%, OnListContextSelect
	if (list="T") {
		Menu, menuContext, Add
		Menu, menuContext, Add, %ME_LngMenu113%, OnListContextSelect
	}

	stat := ItemCanDelete(list, idx)
	if (list="T") {
		Menu, menuContext, %stat%, %ME_LngMenu104%
	}
	Menu, menuContext, %stat%, %ME_LngMenu106%
	stat := ItemCanCopy(list, idx)
	Menu, menuContext, %stat%, %ME_LngMenu107%
	Menu, menuContext, %stat%, %ME_LngMenu108%
	stat := ItemCanMoveUp(list, idx)
	Menu, menuContext, %stat%, %ME_LngMenu110%
	stat := ItemCanMoveDown(list, idx)
	Menu, menuContext, %stat%, %ME_LngMenu111%
	if (list="T") {
		GuiControlGet, Config_FoldTarget, MEW_Main:, Config_FoldTarget
		if (Config_FoldTarget) {
			Menu, menuContext, Check, %ME_LngMenu113%
		}
	}
	;...........................................................................
	; Show Menu
	itemName := ""
	Menu, menuContext, Show

	if (itemName = ME_LngMenu105) {
		SwitchTab(2)
	}
	else if (itemName = ME_LngMenu103) {
		TargetNew(false)
	}
	else if (itemName = ME_LngMenu104) {
		(list="T") ? TargetNew(true) :
	}
	else if (itemName = ME_LngMenu106) {
		(list="T") ? TargetDelete() : GestureDelete()
	}
	else if (itemName = ME_LngMenu107) {
		szBuf := (list="T") ? CopyTarget(false) : CopyGesture(false)
		if (list="T" && Target_%Target_Editing%_Level>1) {
			Target_Editing := Target_%Target_Editing%_Parent
		}
		ImportFromClipboard(szBuf)
	}
	else if (itemName = ME_LngMenu108) {
		(list="T") ? CopyTarget() : CopyGesture()
	}
	else if (itemName = ME_LngMenu109) {
		ImportFromClipboard()
	}
	else if (itemName = ME_LngMenu110) {
		(list="T") ? TargetShift(idx, -1) : GestureUp()
	}
	else if (itemName = ME_LngMenu111) {
		(list="T") ? TargetShift(idx, 1) : GestureDown()
	}
	else if (itemName = ME_LngMenu112) {
		(list="T") ? TargetSort() : GestureSort()
	}
	else if (itemName = ME_LngMenu113) {
		SwitchTargetFolding(true)
	}
	else if (itemName = ME_LngMenu121) {
		GestureNew()
	}
	return

OnListContextSelect:
	itemName := A_ThisMenuItem
	return
}

;-------------------------------------------------------------------------------
; Show Context Menu of Gesture List View
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowGestureListViewContextMenu(idx)
{
	local stat, itemName
	;...........................................................................
	; Create Menu
	ShowUnassignedGestureMenu(0, false)
	Menu, menuContext, Add
	Menu, menuContext, DeleteAll
	Menu, menuContext, Add, %ME_LngMenu114%, OnGesListContextSelect
	Menu, menuContext, Add, %ME_LngMenu115%, :menuGestureList
	Menu, menuContext, Add
	Menu, menuContext, Add, %ME_LngMenu106%, OnGesListContextSelect
	stat := (idx > 0) ? "Enable" : "Disable"
	Menu, menuContext, %stat%, %ME_LngMenu106%
	;...........................................................................
	; Show Menu
	itemName := ""
	Menu, menuContext, Show
	if (itemName = ME_LngMenu114) {
		SwitchTab(3)
	}
	else if (itemName = ME_LngMenu106) {
		ReleaseGesture(Gesture_Editing, Action_Editing)
	}
	return

OnGesListContextSelect:
	itemName := A_ThisMenuItem
	return
}

;-------------------------------------------------------------------------------
; Show Unassigned Gesture Menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowUnassignedGestureMenu(idx=0, bShow=true)
{
	local name, ges, item, hitG, hitT, gesName
	;...........................................................................
	; Create Menu
	idx := (idx > 0) ? idx : Target_Editing
	name := MakeTargetFullName(idx, true)
	Menu, menuGestureList, Add
	Menu, menuGestureList, DeleteAll
	hitG := false
	Loop, %Gesture_Count%
	{
		ges := A_Index
		hitT := false
		Loop, % Gesture_%ges%_Count {
			if (Gesture_%ges%_%A_Index%_Target == name) {
				hitT := true
				break
			}
		}
		if (!hitT) {
			Menu, menuGestureList, Add, % Gesture_%ges%_Name, OnExistGestureMenuSelect
			hitG := true
		}
	}
	if (!hitG) {
		Menu, menuGestureList, Add, %ME_LngMenu102%
		Menu, menuGestureList, Disable, %ME_LngMenu102%
	}
	Menu, menuGestureList, Add
	Menu, menuGestureList, Add, %ME_LngMenu116%, OnNewGestureMenuSelect
	;...........................................................................
	; Show Menu
	if (bShow) {
		Menu, menuGestureList, Show
	}
	return

OnExistGestureMenuSelect:
	ShowGesture(GestureIndexOf(A_ThisMenuItem))
	AddAction()
	return

OnNewGestureMenuSelect:
	GestureNew()
	AddAction()
	SwitchTab(3)
	return
}

;-------------------------------------------------------------------------------
; Show Context Menu of Action List
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowActionListContextMenu(idx)
{
	local stat, itemName
	;...........................................................................
	; Create Menu
	ShowTargetListMenu(true, false)
	Menu, menuContext, Add
	Menu, menuContext, DeleteAll
	Menu, menuContext, Add, %ME_LngMenu131%, :menuTargetList
	Menu, menuContext, Add
	Menu, menuContext, Add, %ME_LngMenu106%, OnActListContextSelect
	Menu, menuContext, Add
	Menu, menuContext, Add, %ME_LngMenu110%, OnActListContextSelect
	Menu, menuContext, Add, %ME_LngMenu111%, OnActListContextSelect

	stat := (idx <= 1) ? "Disable" : "Enable"
	Menu, menuContext, %stat%, %ME_LngMenu110%
	stat := (idx >= Gesture_%Gesture_Editing%_Count) ? "Disable" : "Enable"
	Menu, menuContext, %stat%, %ME_LngMenu111%

	;...........................................................................
	; Show Menu
	itemName := ""
	Menu, menuContext, Show

	if (itemName = ME_LngMenu106) {
		ActionDelete(Gesture_Editing, idx)
	}
	else if (itemName = ME_LngMenu110) {
		Gosub, ActionUp
	}
	else if (itemName = ME_LngMenu111) {
		Gosub, ActionDown
	}
	else if (MenuSelectedTarget) {
		UpdateAction(true, idx, MenuSelectedTarget, Gesture_%Gesture_Editing%_%idx%_Action)
		SelectTarget(TargetIndexOf(MenuSelectedTarget))
	}
	return

OnActListContextSelect:
	itemName := A_ThisMenuItem
	return
}

;-------------------------------------------------------------------------------
; Check whether the item can be deleted
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ItemCanDelete(list, idx)
{
	if (list="T") {
		return (idx <= 1) ? "Disable" : "Enable"
	} else {
		return (idx < 1) ? "Disable" : "Enable"
	}
}

;-------------------------------------------------------------------------------
; Check whether the item can be moved up
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ItemCanMoveUp(list, idx)
{
	global
	if (list="T") {
		local next := idx - 1
		return ((idx <= 2) || (Target_%next%_Level < Target_%idx%_Level)) ? "Disable" : "Enable"
	} else {
		return (idx <= 1) ? "Disable" : "Enable"
	}
}

;-------------------------------------------------------------------------------
; Check whether the item can be moved down
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ItemCanMoveDown(list, idx)
{
	global
	if (list="T") {
		local next := idx + GetChildTargetNum(idx)
		local next2 := next + 1
		return (((Target_%next%_Level > Target_%next2%_Level) && (Target_%idx%_Parent != Target_%next2%_Parent))
			 ||	(idx <= 1) || (next >= Target_Count)) ? "Disable" : "Enable"
	} else {
		return (idx >= Gesture_Count) ? "Disable" : "Enable"
	}
}

;-------------------------------------------------------------------------------
; Check whether the item can be copied
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ItemCanCopy(list, idx)
{
	global MainTabIdx
	return ((list="G" && idx>=1) || (idx==1 && MainTabIdx==2) || idx>=2)
			? "Enable" : "Disable"
}

;-------------------------------------------------------------------------------
; Retrieve Tree View Item Index from ID
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TvIdToIndex(id)
{
	if (id)
	{
		max := TV_GetCount()
		idCmp := 0
		Loop, %max%
		{
			idCmp := TV_GetNext(idCmp, "Full")
			if (idCmp == id) {
				return A_Index
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Retrieve Tree View Item ID from Index
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TvIndexToId(idx)
{
	if (idx)
	{
		max := TV_GetCount()
		id := 0
		Loop, %max%
		{
			id := TV_GetNext(id, "Full")
			if (A_Index == idx) {
				return id
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Show Specified Target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowTarget(idx, bForce=true, bKeepIcon=false)
{
	local type, rule, stat, next, next2
	if (Target_Editing==idx && !bForce) {
		return
	}
	Critical
	Target_Editing := idx
	GuiControl, MEW_Main:, ETargetName,% Target_%idx%_Name
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVRule
	GuiControl, MEW_Main:-Redraw, LVRule
	LV_Delete()
	Loop, % Target_%idx%_Count {
		type := Target_%idx%_%A_Index%_Type
		rule := GetMatchRuleStr(type)
		type := RegExReplace(type, "_.+$")
		rule := rule ? RuleDisp_%type% " (" rule ")" : RuleDisp_%type%
		LV_Add("", rule, Target_%idx%_%A_Index%_Value)
	}
	GuiControl, MEW_Main:+Redraw, LVRule
	stat := ItemCanDelete("T", idx)
	GuiControl, MEW_Main:%stat%, BTargetDelete
	stat := ItemCanMoveUp("T", idx)
	GuiControl, MEW_Main:%stat%, BTargetUp
	stat := ItemCanMoveDown("T", idx)
	GuiControl, MEW_Main:%stat%, BTargetDown
	stat := (idx < 1) ? "Disable" : "Enable"
	GuiControl, MEW_Main:%stat%, BCopyTarget
	GuiControl, MEW_Main:Choose, DDLLogic, % Target_%idx%_IsAnd + 1
	stat := (Target_%idx%_Level <= 1) ? "Disable" : "Enable"
	GuiControl, MEW_Main:%stat%, ChkNotInhRules
	GuiControl, MEW_Main:, ChkNotInhRules, % (Target_%idx%_NotInh ? 1 : 0)
	if (!bKeepIcon)
	{
		if (RegExMatch(Target_%idx%_IconFile, "^(.+?)\s*,\s*(.*?)$", $)) {
			GuiControl, MEW_Main:, EIconFile, %$1%
			GuiControl, MEW_Main:, EIconIndex, %$2%
		} else {
			GuiControl, MEW_Main:, EIconFile,
			GuiControl, MEW_Main:, EIconIndex, 1
		}
	}
	Gui, MEW_Main:TreeView, TVTarget1
	TV_Modify(TvIndexToId(idx))
	Gui, MEW_Main:TreeView, TVTarget2
	GuiControl, MEW_Main:-g, TVTarget2
	TV_Modify(TvIndexToId(idx))
	GuiControl, MEW_Main:+gTVTargetSelect, TVTarget2
	Critical, Off
}

;-------------------------------------------------------------------------------
; Move Up Rule
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
RuleUp:
	if(Rule_Editing>1){
		RuleSwap(Target_Editing,Rule_Editing-1,Rule_Editing)
		ShowTarget(Target_Editing)
		ShowRule(Target_Editing,Rule_Editing-1)
	}
return

;-------------------------------------------------------------------------------
; Move Down Rule
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
RuleDown:
	if(Rule_Editing<Target_%Target_Editing%_Count){
		RuleSwap(Target_Editing,Rule_Editing,Rule_Editing+1)
		ShowTarget(Target_Editing)
		ShowRule(Target_Editing,Rule_Editing+1)
	}
return

;-------------------------------------------------------------------------------
; Delete Rule
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
RuleDelete:
	RuleDelete(Target_Editing, Rule_Editing)
return
RuleDelete(target, idx, bUpdateGUI=true)
{
	global
	Loop
	{
		idx++
		RuleMove(target, idx, idx-1)
		if (idx >= Target_%target%_Count) {
			break
		}
	}
	Target_%target%_%idx%_Type  := ""
	Target_%target%_%idx%_Value := ""
	Target_%target%_Count--
	if (bUpdateGUI) {
		ShowTarget(Target_Editing)
		ShowRule(Target_Editing, (Rule_Editing>Target_%Target_Editing%_Count) ? Target_%Target_Editing%_Count : Rule_Editing)
	}
}

;-------------------------------------------------------------------------------
; Move Rule
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
RuleMove(target,from,to)
{
	global
	Target_%target%_%to%_Type  := Target_%target%_%from%_Type
	Target_%target%_%to%_Value := Target_%target%_%from%_Value
}

;-------------------------------------------------------------------------------
; Move Swap
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
RuleSwap(target,a,b){
	RuleMove(target,a,"tmp")
	RuleMove(target,b,a)
	RuleMove(target,"tmp",b)
}

;-------------------------------------------------------------------------------
; Check whether the Rule is Changed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
LVRuleSelect:
	IsRuleChanged()
return
IsRuleChanged()
{
	global
	if (A_GuiEvent!="Normal" && A_GuiEvent!="K") {
		return
	}
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, %A_GuiControl%
	local idx := LV_GetNext()
	if (idx == Rule_Editing) {
		return
	}
	SaveModification()
	ShowRule(Target_Editing, idx)
}

;-------------------------------------------------------------------------------
; Show Rule
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowRule(target, idx)
{
	local stat := (idx!=0) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, BRuleUp
	GuiControl, MEW_Main:%stat%, BRuleDelete
	GuiControl, MEW_Main:%stat%, BRuleDown
	Rule_Editing := idx
	if (idx==0)
	{
		GuiControl, MEW_Main:Disable, BAddRule
		GuiControl, MEW_Main:Disable, BUpdateRule
		UpdateRuleCtrlStat()
		return
	}
	local szType := RegExReplace(Target_%target%_%idx%_Type, "_.+$")
	GuiControl, MEW_Main:Choose, DDLRuleType, % RuleType_%szType%
	GuiControl, MEW_Main:-g, ERuleValue
	GuiControl, MEW_Main:, ERuleValue, % Target_%target%_%idx%_Value
	GuiControl, MEW_Main:+gOnRuleEditModify, ERuleValue

	local invert, method
	GetMatchRule(Target_%target%_%idx%_Type, invert, method)
	GuiControl, MEW_Main:, ChkNotMatch, %invert%
	GuiControl, MEW_Main:Choose, DDLMatchRule, %method%
	UpdateRuleCtrlStat()
	if (Target_Editing == target)
	{
		Gui, MEW_Main:Default
		Gui, MEW_Main:ListView, LVRule
		LV_Modify(idx, "Select")
		LV_Modify(idx, "Focus")
	}
}

;-------------------------------------------------------------------------------
; Get Matching Rule
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetMatchRule(szRuleType, ByRef invert, ByRef method)
{
	local $, $1, $2
	RegExMatch(szRuleType, "^.+_(.)(.?)", $)

	invert := 0, method := 1
	Loop, 2
	{
		if ($%A_Index% = "N") {
			invert := 1
		}
		else if ($%A_Index% = "P") {
			method := 2
		}
		else if ($%A_Index% = "T") {
			method := 3
		}
		else if ($%A_Index% = "B") {
			method := 4
		}
		else if ($%A_Index% = "R") {
			method := 5
		}
	}
}

;-------------------------------------------------------------------------------
; Get Matching Rule String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetMatchRuleStr(szRuleType)
{
	local invert, method, szRet

	GetMatchRule(szRuleType, invert, method)
	if (!invert) {
		if (method == 1) {
			szRet := ME_LngOthers004
		} else if (method == 2) {
			szRet := ME_LngOthers005
		} else if (method == 3) {
			szRet := ME_LngOthers006
		} else if (method == 4) {
			szRet := ME_LngOthers007
		} else if (method == 5) {
			szRet := ME_LngOthers008
		}
	} else {
		if (method == 1) {
			szRet := ME_LngOthers009
		} else if (method == 2) {
			szRet := ME_LngOthers010
		} else if (method == 3) {
			szRet := ME_LngOthers011
		} else if (method == 4) {
			szRet := ME_LngOthers012
		} else if (method == 5) {
			szRet := ME_LngOthers013
		}
	}
	return szRet
}

;-------------------------------------------------------------------------------
; Clear Rule
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ClearRule()
{
	global
	Rule_Editing:=0
	GuiControl, MEW_Main:Choose, DDLRuleType, 1
	GuiControl, MEW_Main:-g, ERuleValue
	GuiControl, MEW_Main:, ERuleValue,
	GuiControl, MEW_Main:+gOnRuleEditModify, ERuleValue
	GuiControl, MEW_Main:Disable, BRuleUp
	GuiControl, MEW_Main:Disable, BRuleDelete
	GuiControl, MEW_Main:Disable, BRuleDown
	UpdateRuleCtrlStat()
}

;-------------------------------------------------------------------------------
; Add Rule
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
BAddRulePress:
	AddRule()
return
AddRule(bShow=true)
{
	local idx := ++Target_%Target_Editing%_Count
	UpdateRule(bShow, idx)
}

;-------------------------------------------------------------------------------
; Update Rule
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
BUpdateRulePress:
	UpdateRule()
return
UpdateRule(bShow=true, idx=0)
{
	local szRuleType
	Gui, MEW_Main:Submit, NoHide
	idx := idx ? idx : Rule_Editing
	MakeRuleTypeStr(szRuleType, DDLRuleType)
	Target_%Target_Editing%_%idx%_Type  := szRuleType
	Target_%Target_Editing%_%idx%_Value := ERuleValue
	if (bShow) {
		ShowTarget(Target_Editing, true, true)
		ShowRule(Target_Editing, idx)
	}
	SaveModification("Reset")
}

;-------------------------------------------------------------------------------
; On Clear Rule Button Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ClearRulePress:
	GuiControl, MEW_Main:, ERuleValue
return

;-------------------------------------------------------------------------------
; On And/Or Mode Change
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
DDLLogicChoose:
	Gui, MEW_Main:Submit, NoHide
	Target_%Target_Editing%_IsAnd := DDLLogic - 1
return

;-------------------------------------------------------------------------------
; On Not Inherit Rules Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnNotInhRulesChange:
	Gui, MEW_Main:Submit, NoHide
	Target_%Target_Editing%_NotInh := ChkNotInhRules
return

;-------------------------------------------------------------------------------
; On Rule Type Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnRuleTypeChange:
	UpdateRuleCtrlStat(true)
return
UpdateRuleCtrlStat(fModify=false)
{
	local szRuleType, stat
	Gui, MEW_Main:Submit, NoHide
	MakeRuleTypeStr(szRuleType, DDLRuleType)
	Gui, MEW_Main:Default
	Gui, MEW_Main:TreeView, TVTarget2
	stat := (TV_GetSelection() && ERuleValue && !MG_RuleExists(Target_Editing, szRuleType, ERuleValue)) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, BAddRule
	EnblAddRule := stat
	if (!Rule_Editing) {
		stat := "Disable"
	}
	GuiControl, MEW_Main:%stat%, BUpdateRule
	EnblUpdateRule := stat

	stat := (DDLRuleType < 5) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, Label14
	GuiControl, MEW_Main:%stat%, DDLMatchRule
	if (fModify) {
		SaveModification("Modified", "ERuleValue")
	}
}

;-------------------------------------------------------------------------------
; Make Rule Type String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MakeRuleTypeStr(ByRef szRuleType, type)
{
	global
	szRuleType := RuleType_%type%
	if (ChkNotMatch) {
		szRuleType .= "_N"
	}
	if (type >= 5) {
		return
	}
	if (DDLMatchRule == 2) {
		szRuleType .= ChkNotMatch ? "P" : "_P"
	}
	else if (DDLMatchRule == 3) {
		szRuleType .= ChkNotMatch ? "T" : "_T"
	}
	else if (DDLMatchRule == 4) {
		szRuleType .= ChkNotMatch ? "B" : "_B"
	}
	else if (DDLMatchRule == 5) {
		szRuleType .= ChkNotMatch ? "R" : "_R"
	}
}

;-------------------------------------------------------------------------------
; On Rule Edit Modify
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnRuleEditModify:
	Gui, MEW_Main:Submit, Nohide
	SaveModification("Modified", "ERuleValue")
	UpdateRuleCtrlStat()
return

;-------------------------------------------------------------------------------
; On Target Picker Button Press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
BRulePickerPressed:
	TargetPicked()
return
TargetPicked()
{
	local sel
	Gui, MEW_Main:Submit, NoHide
	if (DDLRuleType < 5) {
		SetTimer, RulePickerTimer, 10
		Hotkey, RButton up, RulePickerHotkey, On
	}
	else if (DDLRuleType == 5) {
		Menu, CustomExpressions, Show
	}
	else if (DDLRuleType == 6) {
		sel := ShowTargetListMenu()
		GuiControl, MEW_Main:,ERuleValue, %sel%
	}
}

;-------------------------------------------------------------------------------
; Target Picker Tooltip Display Timer
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
RulePickerTimer:
	Tooltip, %ME_LngTooltip003%
return

;-------------------------------------------------------------------------------
; On Target Click
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
RulePickerHotkey:
	CoordMode,Mouse,Screen
	MouseGetPos, MG_X, MG_Y, MG_HWND, MG_HCTL, 3
	SendMessage, 0x84, 0, % MG_Y<<16|MG_X,, ahk_id %MG_HCTL%
	if (ErrorLevel == 4294967295) {
		MouseGetPos,,,,MG_HCTL, 2
	}
	if (DDLRuleType == 1) {
		WinGetClass, ERuleValue, ahk_id %MG_HWND%
	}
	else if(DDLRuleType == 2) {
		WinGetClass, ERuleValue, ahk_id %MG_HCTL%
	}
	else if(DDLRuleType == 3) {
		WinGet, ERuleValue, ProcessName, ahk_id %MG_HWND%
	}
	else {
		WinGetTitle, ERuleValue, ahk_id %MG_HWND%
	}
	GuiControl, MEW_Main:, ERuleValue, %ERuleValue%

	WinGet, EIconFile, ProcessPath, ahk_id %MG_HWND%
	GuiControl, MEW_Main:, EIconFile, %EIconFile%
	GuiControl, MEW_Main:, EIconIndex, 1

	SetTimer,RulePickerTimer,Off
	Hotkey,RButton up,Off
	Tooltip
return

;-------------------------------------------------------------------------------
; Get Rectangle Coordinates
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetRectRelative:
	GetRectByDrag(RX, RY, RW, RH, TW, TH, 0)
	DlgRectSettings(RX, RY, RW, RH, TW, TH, 0)
return

GetRectAbsolute:
	GetRectByDrag(RX, RY, RW, RH, TW, TH, 1)
	DlgRectSettings(RX, RY, RW, RH, TW, TH, 1)
return

;-------------------------------------------------------------------------------
; Get Rectangle Coordinates by Mouse Dragging
;	rcX, rcY	: X-Y coordinates of Rectangular Region
;	rcW, rcH	: Width and Height of Rectangular Region
;	tgW, tgH	: Width and Height of Target Window
;	target		: 0:Target is Active Window
;				  1:Target is Screen
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetRectByDrag(ByRef rcX, ByRef rcY, ByRef rcW, ByRef rcH, ByRef tgW, ByRef tgH, target) 
{
	global ME_LngTooltip005
	Hotkey, LButton, Dummy, On
	While (!GetKeyState("LButton", "P"))
	{
		Tooltip, %ME_LngTooltip005%
		Sleep, 10
	}
	if (target==0)
	{
		MouseGetPos, , , hwnd
		WinGetPos, , , tgW, tgH, ahk_id %hwnd%
		WinActivate, ahk_id %hwnd%
		CoordMode, Mouse, Relative
		MouseGetPos, rx1, ry1
	}
	else
	{
		tgW := A_ScreenWidth
		tgH := A_ScreenHeight
	}
	CoordMode, Mouse, Screen
	MouseGetPos, x1, y1

	Gui, MEW_CaptRect:New
	Gui, MEW_CaptRect:-Caption +HwndME_hWndCaptRect +ToolWindow +Border +AlwaysOnTop +LastFound
	WinSet, Transparent, 127
	Gui, MEW_CaptRect:Color, 0x0000ff

	While (GetKeyState("LButton", "P"))
	{
		MouseGetPos, x2, y2
		winX := (x1 < x2) ? x1 : x2
		winY := (y1 < y2) ? y1 : y2
		winW := abs(x1 - x2)
		winH := abs(y1 - y2)
		Gui, MEW_CaptRect:Show, x%winX% y%winY% w%winW% h%winH% NA
		Tooltip, %ME_LngTooltip005%
		Sleep, 10
	}
	Tooltip
	Hotkey, LButton, Dummy, Off

	if (target==0)
	{
		x1:=rx1, y1:=ry1
		CoordMode, Mouse, Relative
	}
	MouseGetPos, x2, y2

	if (x1 > x2) 
	{
		temp:=x1, x1:=x2, x2:=temp
	}
	if (y1 > y2)
	{
		temp:=y1, y1:=y2, y2:=temp
	}
	rcX:=x1, rcY:=y1, rcW:=x2-x1+1, rcH:=y2-y1+1

Dummy:
	return
}

;-------------------------------------------------------------------------------
; Setting Dialog of Rectangle Coordinates
;	rcX, rcY	: X-Y coordinates of Rectangular Region
;	rcW, rcH	: Width and Height of Rectangular Region
;	tgW, tgH	: Width and Height of Target Window
;	target		: 0:Target is Window
;				  1:Target is Screen
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
DlgRectSettings(rcX, rcY, rcW, rcH, tgW, tgH, target)
{
	local prevOrg:=1

	Gui, MEW_Rect:New
	Gui, MEW_Rect:-MaximizeBox -MinimizeBox +HwndME_hWndRect +AlwaysOnTop +OwnerMEW_CaptRect +Delimiter`n

	Gui, MEW_Rect:Add, Text, x12 y20 Section, %ME_LngText421%
	Gui, MEW_Rect:Add, Edit, x+4 yp-4 w62 vRectX 
	Gui, MEW_Rect:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_Rect:, RectX, %rcX%
	GuiControl, MEW_Rect: +gOnRectChange, RectX

	Gui, MEW_Rect:Add, Text, x+12 ys, %ME_LngText422%
	Gui, MEW_Rect:Add, Edit, x+4 yp-4 w62 vRectY
	Gui, MEW_Rect:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_Rect:, RectY, %rcY%
	GuiControl, MEW_Rect: +gOnRectChange, RectY

	Gui, MEW_Rect:Add, Text, x+12 ys, %ME_LngText501%
	Gui, MEW_Rect:Add, Edit, x+4 yp-4 w62 vRectW
	Gui, MEW_Rect:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_Rect:, RectW, %rcW%
	GuiControl, MEW_Rect: +gOnRectChange, RectW

	Gui, MEW_Rect:Add, Text, x+12 ys, %ME_LngText502%
	Gui, MEW_Rect:Add, Edit, x+4 yp-4 w62 vRectH Section
	Gui, MEW_Rect:Add, UpDown, vRectHUD Range-2147483648-2147483647 +128
	GuiControl, MEW_Rect:, RectH, %rcH%
	GuiControl, MEW_Rect: +gOnRectChange, RectH

	GuiControlGet, rcCtrl, MEW_Rect:Pos, RectHUD
	local left := rcCtrlX + rcCtrlW - 350 - 1
	Gui, MEW_Rect:Add, Text, x%left% y+4 w350 Right cBlue, %ME_LngText503%

	local tblText := Array(ME_LngText504, ME_LngText505, ME_LngText506)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_Rect:Add, Text, x12 y+14 w%width%, %ME_LngText504%
	Gui, MEW_Rect:Add, DropDownList, x+0 yp-4 w250 vRectTarget AltSubmit, %ME_LngDropDown101%
	GuiControl, MEW_Rect:Choose, RectTarget, % (target==0 ? 1 : 3)

	Gui, MEW_Rect:Add, Text, x12 y+12 w%width%, %ME_LngText505%
	Gui, MEW_Rect:Add, DropDownList, x+0 yp-4 w250 vRectOrg gOnOrgChange Choose1 AltSubmit, %ME_LngDropDown102%

	Gui, MEW_Rect:Add, Text, x12 y+12 w%width%, %ME_LngText506%
	Gui, MEW_Rect:Add, DropDownList, x+0 yp-4 w250 vRectMode Choose1 AltSubmit, %ME_LngDropDown103%

	Gui, MEW_Rect:Add, Button, gOnAcceptRect xs-105 y+12 w80, %ME_LngButton001%
	Gui, MEW_Rect:Add, Button, gOnCancelRect x+8 yp+0 w80, %ME_LngButton002%
	Gui, MEW_Rect:Show, ,%ME_LngCapt007%

	WinWaitClose,  ahk_id %ME_hWndRect%
	return

	;---------------------------------------------------------------------------
	; Origin corner is changed
OnOrgChange:
	Gui, MEW_Rect:Submit,NoHide
	if (prevOrg==1 || prevOrg==3)
	{
		if (RectOrg==2 || RectOrg==4) {
			RectX := -(tgW - RectX - 1)
		}
	}
	else
	{
		if (RectOrg==1 || RectOrg==3) {
			RectX := tgW + RectX - 1
		}
	}
	GuiControl, MEW_Rect:, RectX, %RectX%

	if (prevOrg==1 || prevOrg==2)
	{
		if (RectOrg==3 || RectOrg==4) {
			RectY := -(tgH - RectY - 1)
		}
	}
	else
	{
		if (RectOrg==1 || RectOrg==2) {
			RectY := tgH + RectY - 1
		}
	}
	GuiControl, MEW_Rect:, RectY, %RectY%

	prevOrg := RectOrg
	return

	;---------------------------------------------------------------------------
OnRectChange:
	Gui, MEW_Rect:Submit,NoHide
	local x, y, w, h
	WinGetPos, x, y, w, h, ahk_id %ME_hWndCaptRect%
	x+=(RectX-rcX), y+=(RectY-rcY), w+=(RectW-rcW), h+=(RectH-rcH)
	WinMove, ahk_id %ME_hWndCaptRect%,, %x%, %y%, %w%, %h%
	rcX:=RectX, rcY:=RectY, rcW:=RectW, rcH:=RectH
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptRect:
	Gui, MEW_Rect:Submit
	MG_SetRuleValue("MG_CursorInRect(" . RectX . "," . RectY . "," . RectW . "," . RectH . "," . RectTarget-1 . "," . RectOrg-1 . "," . RectMode-1 . ")")
	Gui, MEW_Rect:Destroy
	Gui, MEW_CaptRect:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelRect:
MEW_RectGuiClose:
MEW_RectGuiEscape:
	Gui, MEW_Rect:Destroy
	Gui, MEW_CaptRect:Destroy
	return
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Routines : ジェスチャー関連
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Show Assigned Gestures
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowAssignedGestures(idx=0, bSel=true)
{
	local name, ges
	Critical
	idx := (idx > 0) ? idx : Target_Editing
	name := MakeTargetFullName(idx, true)
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVGesture
	GuiControl, MEW_Main:-Redraw, LVGesture
	LV_Delete()
	Loop, %Gesture_Count% {
		ges := A_Index
		Loop, % Gesture_%ges%_Count {
			if (Gesture_%ges%_%A_Index%_Target == name) {
				LV_Add("", Gesture_%ges%_Name, MakeActionSummaryStr(Gesture_%ges%_%A_Index%_Action), ges)
				break
			}
		}
	}
	GuiControl, MEW_Main:+Redraw, LVGesture
	if (bSel) {
		SelectGestureInMainLV()
	}
	Critical, Off
}

;-------------------------------------------------------------------------------
; Select Assigned Gesture in Gesture ListView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SelectGestureInMainLV()
{
	local idx, hit
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVGesture
	hit := false
	Loop, % LV_GetCount() {
		LV_GetText(idx, A_Index, 3)
		if (idx == Gesture_Editing) {
			LV_Modify(A_Index, "Select")
			LV_Modify(A_Index, "Focus")
			hit := true
			break
		}
	}
	if (!hit) {
		LV_Modify(0, "-Select")
		LV_Modify(0, "-Focus")
	}
	ChangeActionButtonStat()
}

;-------------------------------------------------------------------------------
; Release Assigned Gesture
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ReleaseGesture(ges, idx)
{
	local sel
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVGesture
	sel := LV_GetNext()
	ActionDelete(ges, idx, false, false)
	TargetSelect(true)
	sel := sel>LV_GetCount() ? LV_GetCount() : sel
	LV_Modify(sel, "Select")
	LV_Modify(sel, "Focus")
	LVGestureEvents(true)
}

;-------------------------------------------------------------------------------
; Gesture List View Events
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
LVGestureSelect:
	LVGestureEvents()
return
LVGestureEvents(bSel=false)
{
	local idx, bMod
	static sel
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVGesture
	;---------------------------------------------------------------------------
	; On Selection Change
	if (A_GuiEvent="Normal" || A_GuiEvent=="K"
	||	A_GuiEvent=="RightClick" || A_GuiEvent=="d"
	||	bSel)
	{
		sel := LV_GetNext()
		LV_GetText(idx, sel, 3)
		idx := idx>0 ? idx : 0
		if (idx != Gesture_Editing) {
			bMod := SaveModification()
		}
		GuiControl, MEW_Main:Choose, LBGesture, % "`n" (idx>0 ? idx : Gesture_Editing)
		if (bMod) {
			ShowAssignedGestures(0, false)
		}
		ChangeActionButtonStat()
		;-----------------------------------------------------------------------
		; On Right Click
		if (A_GuiEvent=="RightClick" || A_GuiEvent=="d") {
			SetTimer, ShowGestureListViewContextMenu, -1
		}
	}
	return

ShowGestureListViewContextMenu:
	ShowGestureListViewContextMenu(sel)
	return
}

;-------------------------------------------------------------------------------
; Add New Gesture Entry
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureNew:
	GestureNew()
return
GestureNew(bMove=false)
{
	local idx
	SaveModification()
	EnableGestureControls()
	ClearGesturePatterns()
	ClearAction(true, "B")
	Gesture_Count++
	idx := Gesture_Count
	Gesture_%idx%_Name	 := "Gesture_" . Gesture_Count
	Gesture_%idx%_Patterns := ""
	Gesture_%idx%_Count	 := 0
	if (bMove) {
		while (idx > Gesture_Editing+1) {
			GestureSwap(idx, idx-1)
			idx--
		}
	}
	ShowGestures()
	ShowGesture(idx)
	SelectGestureInMainLV()
	AdjustDialogHeight()
	SaveModification("Reset")
	SetFocusEGestureName()
}
EnableGestureControls()
{
	global
	GuiControl, MEW_Main:Enable, EGesture
	GuiControl, MEW_Main:Enable, BClearGesture
	GuiControl, MEW_Main:Enable, GesturePatternBox
	GuiControl, MEW_Main:Enable, EAction
	GuiControl, MEW_Main:Enable, BEditAction
	GuiControl, MEW_Main:Enable, BClearAction
	GuiControl, MEW_Main:Enable, BAddActionLine
	GuiControl, MEW_Main:Disable, BGesturePatternUp
	GuiControl, MEW_Main:Disable, BGesturePatternDelete
	GuiControl, MEW_Main:Disable, BGesturePatternDown
	GuiControl, MEW_Main:Disable, BUpdateGesturePattern
	EnblUpdateGesturePattern := "Disable"
}

;-------------------------------------------------------------------------------
; Move Up Gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureUp:
	GestureUp()
return
GestureUp()
{
	global Gesture_Editing
	if (Gesture_Editing > 1) {
		GestureSwap(Gesture_Editing-1, Gesture_Editing)
		ShowGestures()
		ShowGesture(Gesture_Editing-1)
		ShowAssignedGestures()
	}
}

;-------------------------------------------------------------------------------
; Move Down Gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureDown:
	GestureDown()
return
GestureDown()
{
	global Gesture_Editing, Gesture_Count
	if (Gesture_Editing < Gesture_Count) {
		GestureSwap(Gesture_Editing, Gesture_Editing+1)
		ShowGestures()
		ShowGesture(Gesture_Editing+1)
		ShowAssignedGestures()
	}
}

;-------------------------------------------------------------------------------
; Sort Gesture List
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GestureSort:
	GestureSort()
return
GestureSort()
{
	global Gesture_Editing
	SaveModification()
	SortList("Gesture")
	ShowGesture(Gesture_Editing)
	ShowAssignedGestures()
}
SortList(list)
{
	global
	local funcMove := (list = "Target") ? Func("TargetMove")  : Func("GestureMove")
		, funcShow := (list = "Target") ? Func("ShowTargets") : Func("ShowGestures")
		, cntTemp, idxTgt, idxCmp, idxTmp, fPrior
	cntTemp := 0
	Loop, % %list%_Count
	{
		idxTgt := A_Index
		fPrior := 0
		if (list!="Target" || idxTgt!=1)
		{
			Loop, %cntTemp%
			{
				idxCmp := A_Index
				if (list="Target" && idxCmp==1) {
					continue
				}
				if (%list%_%idxTgt%_Name < %list%_Temp%idxCmp%_Name)
				{
					fPrior := 1
					Loop, % (cntTemp-idxCmp+1)
					{
						idxTmp := cntTemp-(A_Index-1)
						funcMove.("Temp"idxTmp, "Temp"idxTmp+1)
					}
					funcMove.(idxTgt, "Temp"idxTmp)
					break
				}
			}
		}
		cntTemp++
		if (!fPrior) {
			funcMove.(idxTgt, "Temp"cntTemp)
		}
	}
	Loop, % %list%_Count
	{
		funcMove.("Temp"A_Index, A_Index)
	}
	funcShow.()
}

;-------------------------------------------------------------------------------
; Delete Gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureDelete:
	GestureDelete()
return
GestureDelete()
{
	local idx := Gesture_Editing
	if (Gesture_%idx%_Count > 0)
	{
		MsgBox, 33, %ME_LngCapt003%, %ME_LngMessage006%
		IfMsgBox, Cancel
		{
			return false
		}
	}
	Loop
	{
		idx++
		GestureMove(idx, idx-1)
		if (idx>=Gesture_Count) {
			break
		}
	}
	Gesture_Count--
	ClearGesturePatterns()
	ClearAction(true, "BE")
	ShowGestures()
	ShowGesture(Gesture_Editing>Gesture_Count ? Gesture_Count : Gesture_Editing)
	ShowGesturePattern(Gesture_Editing>Gesture_Count ? Gesture_Count : Gesture_Editing, 1)
	SelectAssignedAction()
	ShowAssignedGestures()
	AdjustDialogHeight()
	SaveModification("Reset")
}

;-------------------------------------------------------------------------------
; Move Gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureMove(from, to)
{
	global
	Gesture_%to%_Name	  := Gesture_%from%_Name
	Gesture_%to%_Patterns := Gesture_%from%_Patterns
	Gesture_%to%_Count	  := Gesture_%from%_Count
	Loop, % Gesture_%from%_Count
	{
		Gesture_%to%_%A_Index%_Target := Gesture_%from%_%A_Index%_Target
		Gesture_%to%_%A_Index%_Action := Gesture_%from%_%A_Index%_Action
		Gesture_%from%_%A_Index%_Target := ""
		Gesture_%from%_%A_Index%_Action := ""
	}
}

;-------------------------------------------------------------------------------
; Swap Gestures
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
GestureSwap(a, b)
{
	GestureMove(a,"tmp")
	GestureMove(b,a)
	GestureMove("tmp",b)
}

;-------------------------------------------------------------------------------
; Set Focus to Gesture Name Edit
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SetFocusEGestureName()
{
	SwitchTab(3)
	GuiControl, MEW_Main:Focus, EGestureName
	SendMessage, 0x00B1, 0, -1,, % "ahk_id" ControlGetHandle("EGestureName")
}

;-------------------------------------------------------------------------------
; Rename Target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureRename:
	GestureRename()
return
GestureRename()
{
	local szGes
	GuiControlGet, szGes, MEW_Main:, EGestureName
	Gesture_%Gesture_Editing%_Name = %szGes%
	ShowGestures()
	ShowGesture(Gesture_Editing)
	ShowAssignedGestures()
}

;-------------------------------------------------------------------------------
; On Gesture Name Change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
EGestureNameChange:
	EGestureNameChange()
return
EGestureNameChange()
{
	local szGes
	GuiControlGet, szGes, MEW_Main:, EGestureName
	if (Gesture_Editing && szGes &&	(szGes != Gesture_%Gesture_Editing%_Name)) {
		GuiControl, MEW_Main:Enable, BGestureRename
	}
	else {
		GuiControl, MEW_Main:Disable, BGestureRename
	}
}

;-------------------------------------------------------------------------------
; Show All Gestures
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowGestures()
{
	global
	local str
	Loop, %Gesture_Count% {
		Join(str,Gesture_%A_Index%_Name)
	}
	GuiControl, MEW_Main:, LBGesture,`n%str%
}

;-------------------------------------------------------------------------------
; Gesture List Box Events
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
LBGestureSelect:
	LBGestureEvents()
return
LBGestureEvents()
{
	global
	;---------------------------------------------------------------------------
	; On Selection Change
	if (A_GuiEvent="Normal")
	{
		Gui, MEW_Main:Submit, NoHide
		SaveModification()
		ClearGesturePatterns(true, false)
		ClearAction(true, "B")
		EnableGestureControls()
		ShowGesture(%A_GuiControl%)
		;_______________________________________________________________________
		; Choose First Gesture Pattern
		GuiControl, MEW_Main:Choose, LBGesturePattern, `n1
		GuiControl, MEW_Main:-g, EGesture
		GuiControl, MEW_Main:, EGesture,
		GuiControl, MEW_Main:+gEGestureChange, EGesture
		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		SelectAssignedAction()
		SelectGestureInMainLV()
	}
}

;-------------------------------------------------------------------------------
; Select Assigned Action of Current Gesture and Target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SelectAssignedAction()
{
	local szTarget, idx
	szTarget := MakeTargetFullName(Target_Editing, true)
	idx := MG_ActionExists(Gesture_Editing, szTarget)
	if (idx) {
		ShowAction(Gesture_Editing, idx)
	}
	else {
		Gui, MEW_Main:Default
		Gui, MEW_Main:ListView, LVAction
		LV_Modify(0, "-Select")
		LV_Modify(0, "-Focus")
		ClearAction(false, "BE")
	}
}

;-------------------------------------------------------------------------------
; Show Specified Gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowGesture(idx)
{
	local stat, tgt, act, def
	Critical
	Gesture_Editing:=idx
	GuiControl, MEW_Main:Choose, LBGesture, %idx%
	GuiControl, MEW_Main:, EGestureName, % Gesture_%idx%_Name
	stat := (!idx) ? "Disable" : "Enable"
	GuiControl, MEW_Main:%stat%, BCopyGesture1
	GuiControl, MEW_Main:%stat%, BCopyGesture2
	GuiControl, MEW_Main:%stat%, BGestureDelete1
	GuiControl, MEW_Main:%stat%, BGestureDelete2
	stat := (idx<=1) ? "Disable" : "Enable"
	GuiControl, MEW_Main:%stat%, BGestureUp1
	GuiControl, MEW_Main:%stat%, BGestureUp2
	stat := (idx>=Gesture_Count) ? "Disable" : "Enable"
	GuiControl, MEW_Main:%stat%, BGestureDown1
	GuiControl, MEW_Main:%stat%, BGestureDown2
	GuiControl, MEW_Main:, LBGesturePattern, % "`n" . Gesture_%idx%_Patterns
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVAction
	GuiControl, MEW_Main:-Redraw, LVAction
	LV_Delete()
	def := ME_LngOthers003
	stat := "Disable"
	Loop, % Gesture_%idx%_Count {
		tgt := TargetIndexOf(Gesture_%idx%_%A_Index%_Target)
		act := MakeActionSummaryStr(Gesture_%idx%_%A_Index%_Action)
		if (tgt == 1) {
			def := act
			stat := "Enable"
		} else {
			LV_Add("Icon"Target_%tgt%_Icon, Gesture_%idx%_%A_Index%_Target, act, A_Index)
		}
	}
	GuiControl, MEW_Main:, LBDefAction, `n%def%
	GuiControl, MEW_Main:%stat%, LBDefAction
	GuiControl, MEW_Main:+Redraw, LVAction
	GuiControl, MEW_Main:Choose, LBGesturePattern, %GesturePattern_Editing%
	if (!Gesture_%idx%_Patterns)
	{
		GuiControl, MEW_Main:-g, EGesture
		GuiControl, MEW_Main:, EGesture,
		GuiControl, MEW_Main:+gEGestureChange, EGesture
		EGestureChange(false)
	}
	Critical, Off
}

;-------------------------------------------------------------------------------
; Make Action Summary String
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MakeActionSummaryStr(szAction)
{
	return RegExReplace(szAction, "(^;|<MG_CR>.+$)")
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Pattern : ジェスチャーパターン
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-------------------------------------------------------------------------------
; Move Up Gesture Pattern
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
GesturePatternUp:
if (GesturePatternSwap(Gesture_Editing, GesturePattern_Editing-1, GesturePattern_Editing)){
	ShowGesture(Gesture_Editing)
	ShowGesturePattern(Gesture_Editing, GesturePattern_Editing-1)
}
return

;-------------------------------------------------------------------------------
; Move Down Gesture Pattern
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
GesturePatternDown:
if (GesturePatternSwap(Gesture_Editing, GesturePattern_Editing, GesturePattern_Editing+1)){
	ShowGesture(Gesture_Editing)
	ShowGesturePattern(Gesture_Editing, GesturePattern_Editing+1)
}
return

;-------------------------------------------------------------------------------
; Delete Gesture Pattern
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GesturePatternDelete:
	GesturePatternDelete(Gesture_Editing, GesturePattern_Editing)
	ShowGesture(Gesture_Editing)
	ShowGesturePattern(Gesture_Editing, GesturePattern_Editing)
return
GesturePatternDelete(idxGes, idxPat)
{
	local szGes := ""
	Loop, Parse, Gesture_%idxGes%_Patterns,`n
	{
		if (A_Index != idxPat) {
			Join(szGes, A_LoopField)
		}
	}
	Gesture_%idxGes%_Patterns := szGes
}

;-------------------------------------------------------------------------------
; Swap Gesture Pattern
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
GesturePatternSwap(g, a, b)
{
	local tmp
	StringSplit, tmp, Gesture_%g%_Patterns,`n
	if ((a<1) || (b<1) || (a>tmp0) || (b>tmp0)) {
		return
	}
	tmp := tmp%a%
	tmp%a% := tmp%b%
	tmp%b% := tmp
	tmp := ""
	Loop, %tmp0% {
		Join(tmp, tmp%A_Index%)
	}
	Gesture_%g%_Patterns := tmp
	return 1
}

;-------------------------------------------------------------------------------
; On Gesture Pattern List Selection Change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
LBGesturePatternSelect:
	Gui, MEW_Main:Submit, NoHide
	SaveModification()
	ShowGesturePattern(Gesture_Editing, LBGesturePattern)
return

;-------------------------------------------------------------------------------
; Show Gesture Pattern
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowGesturePattern(g, idx)
{
	global
	local stat := (Gesture_%g%_Patterns && idx) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, BGesturePatternUp
	GuiControl, MEW_Main:%stat%, BGesturePatternDelete
	GuiControl, MEW_Main:%stat%, BGesturePatternDown
	if (idx==0) {
		return
	}
	local cnt:=0, szLast:=""
	GuiControl, MEW_Main:-g, EGesture
	Loop, Parse, Gesture_%g%_Patterns, `n
	{
		cnt++
		szLast:=A_LoopField
		if (A_Index == idx) {
			GuiControl, MEW_Main:, EGesture, %A_LoopField%
			break
		}
	}
	if (idx > cnt) {
		idx:=cnt
		GuiControl, MEW_Main:, EGesture, %szLast%
	}
	EGestureChange(false)
	GuiControl, MEW_Main:+gEGestureChange, EGesture
	GesturePattern_Editing:=idx
	GuiControl, MEW_Main:Choose, LBGesturePattern, %idx%
}

;-------------------------------------------------------------------------------
; On Gesture Edit Change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
EGestureChange:
	EGestureChange()
return
EGestureChange(fSetModify=true)
{
	global
	Gui, MEW_Main:Submit, NoHide
	local stat := EGesture ? "Enable" : "Disable"
	GuiControl, MEW_Main:%stat%, BStrokeU
	GuiControl, MEW_Main:%stat%, BStrokeR
	GuiControl, MEW_Main:%stat%, BStrokeL
	GuiControl, MEW_Main:%stat%, BStrokeD
	GuiControl, MEW_Main:%stat%, BButtonUp
	GuiControl, MEW_Main:%stat%, BGesturePatternBS
	if (Config_8Dir)
	{
		GuiControl, MEW_Main:%stat%, BStrokeUR
		GuiControl, MEW_Main:%stat%, BStrokeDR
		GuiControl, MEW_Main:%stat%, BStrokeDL
		GuiControl, MEW_Main:%stat%, BStrokeUL
	}
	DllCall("RedrawWindow", "Ptr",ME_hGesPatBox, "Ptr",0, "Ptr",0, "Ptr",0x0107)
	if (EGesture && fSetModify) {
		SaveModification("Modified", "EGesture")
	}
	if (!EGesture
	||	!RegExMatch(EGesture,"^([DLRU_12346789]|(" ButtonRegEx ")_)+$")
	||	MG_FindGesture(EGesture))
	{
		GuiControl, MEW_Main:Disable, BAddGesturePattern
		GuiControl, MEW_Main:Disable, BUpdateGesturePattern
		EnblAddGesturePattern := EnblUpdateGesturePattern := "Disable"
		return
	}
	if (Gesture_Editing)
	{
		GuiControl, MEW_Main:Enable, BAddGesturePattern
		EnblAddGesturePattern := "Enable"
		if (GesturePattern_Editing) {
			GuiControl, MEW_Main:Enable, BUpdateGesturePattern
			EnblUpdateGesturePattern := "Enable"
		}
	}
}

;-------------------------------------------------------------------------------
; On Gesture Backspace Button Press
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
GesturePatternBS:
	Gui, MEW_Main:Submit, NoHide
	GuiControl, MEW_Main:, EGesture, % RegExReplace(EGesture, "((" ButtonRegEx ")_|[DLRU_12346789])$")
return

;-------------------------------------------------------------------------------
; Add Gesture Pattern Button Press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
AddGesturePattern:
	AddGesturePattern()
return
AddGesturePattern(bShow=true)
{
	global
	Gui, MEW_Main:Submit, NoHide
	SaveModification("Reset")
	Join(Gesture_%Gesture_Editing%_Patterns, EGesture)
	if (bShow) {
		ShowGesture(Gesture_Editing)
		SendMessage, 0x018B, 0, 0,, % "ahk_id" ControlGetHandle("LBGesturePattern")
		GuiControl, MEW_Main:Choose, LBGesturePattern, `n%ErrorLevel%
	}
}

;-------------------------------------------------------------------------------
; Update Gesture Pattern Button Press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
UpdateGesturePattern:
	UpdateGesturePattern()
return
UpdateGesturePattern(bShow=true)
{
	local patterns
	Gui, MEW_Main:Submit, NoHide
	Loop, Parse, Gesture_%Gesture_Editing%_Patterns, `n
	{
		if (A_Index == GesturePattern_Editing) {
			Join(patterns, EGesture)
		}else{
			Join(patterns, A_LoopField)
		}
	}
	Gesture_%Gesture_Editing%_Patterns := patterns
	if (bShow) {
		ShowGesture(Gesture_Editing)
		GuiControl, MEW_Main:Disable, BAddGesturePattern
		GuiControl, MEW_Main:Disable, BUpdateGesturePattern
		EnblAddGesturePattern := EnblUpdateGesturePattern := "Disable"
	}
	SaveModification("Reset")
}

;-------------------------------------------------------------------------------
; Clear Gesture Pattern Button Press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ClearGesturePress:
	GuiControl, MEW_Main:, EGesture
return


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Action Routines : 動作割り当て
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-------------------------------------------------------------------------------
; Move Up Action
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ActionUp:
	ActionUp()
return
ActionUp()
{
	local prev
	if ((Action_Editing <= 1)
	||	((Action_Editing == 2) && (Gesture_%Gesture_Editing%_1_Target == MC_DefTargetName))) {
		return
	}
	prev := Action_Editing - 1
	if (Gesture_%Gesture_Editing%_%prev%_Target == MC_DefTargetName) {
		prev--
	}
	ActionSwap(Gesture_Editing, prev, Action_Editing)
	ShowGesture(Gesture_Editing)
	ShowAction(Gesture_Editing, prev)
}

;-------------------------------------------------------------------------------
; Move Down Action
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ActionDown:
	ActionDown()
return
ActionDown()
{
	local end, next
	end := Gesture_%Gesture_Editing%_Count
	if ((Action_Editing >= end)
	||	((Action_Editing == end-1) && (Gesture_%Gesture_Editing%_%end%_Target == MC_DefTargetName))) {
		return
	}
	next := Action_Editing + 1
	if (Gesture_%Gesture_Editing%_%next%_Target == MC_DefTargetName) {
		next++
	}
	ActionSwap(Gesture_Editing, Action_Editing, next)
	ShowGesture(Gesture_Editing)
	ShowAction(Gesture_Editing, next)
}
;-------------------------------------------------------------------------------
; Delete Action
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ActionDelete:
	ActionDelete(Gesture_Editing, Action_Editing)
return
ActionDelete(ges, idx, bUpdateGUI=true, bExcludeDef=true)
{
	local pos
	if (bExcludeDef && (Gesture_%ges%_%idx%_Target == MC_DefTargetName)) {
		return
	}
	Loop
	{
		idx++
		ActionMove(ges, idx, idx-1)
		if (idx >= Gesture_%ges%_Count) {
			break
		}
	}
	Gesture_%ges%_Count--
	if (bUpdateGUI) {
		ClearAction(false, "BE")
		ShowGesture(Gesture_Editing)
		ShowAssignedGestures(0, false)
		pos := (Action_Editing > Gesture_%Gesture_Editing%_Count)
			? Gesture_%Gesture_Editing%_Count : Action_Editing
		if ((Gesture_%Gesture_Editing%_Count > 1)
		&&	(Gesture_%Gesture_Editing%_%pos%_Target == MC_DefTargetName)) {
			pos += (pos == Gesture_%Gesture_Editing%_Count) ? -1 : 1
		}
		ShowAction(Gesture_Editing, pos)
		SelectTarget(TargetIndexOf(Gesture_%Gesture_Editing%_%pos%_Target), false)
	}
}

;-------------------------------------------------------------------------------
; Move Action
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ActionMove(g,from,to)
{
	global
	Gesture_%g%_%to%_Target:=Gesture_%g%_%from%_Target
	Gesture_%g%_%to%_Action:=Gesture_%g%_%from%_Action
}

;-------------------------------------------------------------------------------
; Swap Action
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ActionSwap(g,a,b)
{
	ActionMove(g,a,"tmp")
	ActionMove(g,b,a)
	ActionMove(g,"tmp",b)
}

;-------------------------------------------------------------------------------
; Default Action List Box Events
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
LBDefActionSelect:
	LBDefActionEvents()
return
LBDefActionEvents()
{
	global
	;---------------------------------------------------------------------------
	; On Selection Change
	if (A_GuiEvent="Normal")
	{
		Gui, MEW_Main:Submit, NoHide
		SaveModification()
		Gui, MEW_Main:Default
		Gui, MEW_Main:ListView, LVAction
		LV_Modify(0, "-Select")
		LV_Modify(0, "-Focus")
		ClearAction(true, "BE")
		SelectTarget(1)
	}
	;---------------------------------------------------------------------------
	; On Double Click
	else if (A_GuiEvent="DoubleClick")
	{
		SwitchTab(1)
	}
}

;-------------------------------------------------------------------------------
; Action List View Events
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
LVActionSelect:
	LVActionEvents()
return
LVActionEvents()
{
	local sel, ges, tgt
	static idx
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVAction
	;---------------------------------------------------------------------------
	; On Selection Change
	if (A_GuiEvent="Normal" || A_GuiEvent=="K"
	||	A_GuiEvent=="RightClick" || A_GuiEvent=="d")
	{
		sel := LV_GetNext()
		sel := sel>0 ? sel : 1
		LV_GetText(idx, sel, 3)
		if (idx != Action_Editing) {
			SaveModification()
		}
		ges := Gesture_Editing
		ShowAction(ges, idx)
		tgt := (Gesture_%ges%_Count < 1) ? 1 : TargetIndexOf(Gesture_%ges%_%idx%_Target)
		SelectTarget(tgt)
		GuiControl, MEW_Main:Choose, LBDefAction, 0
		;-----------------------------------------------------------------------
		; On Right Click
		if (A_GuiEvent=="RightClick" || A_GuiEvent=="d") {
			SetTimer, ShowActionListContextMenu, -1
		}
	}
	return

ShowActionListContextMenu:
	ShowActionListContextMenu(idx)
	return
}

;-------------------------------------------------------------------------------
; Show Target List Menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowTargetListMenu(bAction=false, bShow=true)
{
	local name, icon, hit
	Menu, menuTargetList, Add
	Menu, menuTargetList, DeleteAll
	Loop, %Target_Count%
	{
		name := MakeTargetFullName(A_Index, bAction)
		if (bAction) {
			hit := false
			Loop, % Gesture_%Gesture_Editing%_Count {
				if (name == Gesture_%Gesture_Editing%_%A_Index%_Target) {
					hit := true
					break
				}
			}
			if (hit) {
				continue
			}
		}
		else if (name == MakeTargetFullName(Target_Editing)) {
			continue
		}
		Menu, menuTargetList, Add, %name%, OnTargetListMenuSelect
		icon := (bAction && A_Index==1) ? Target_Default_IconFile : Target_%A_Index%_IconFile
		RegExMatch(icon, "^(.+?)\s*,\s*(.*?)$", $)
		icon := MG_VarInStr($1)
		if (FileExist(icon)) {
			Menu, menuTargetList, Icon, %name%, %icon%, %$2%
		}
	}
	MenuSelectedTarget := ""
	if (bShow) {
		Menu, menuTargetList, Show
		Menu, menuTargetList, DeleteAll
	}
	return MenuSelectedTarget

OnTargetListMenuSelect:
	MenuSelectedTarget := A_ThisMenuItem
	return
}

;-------------------------------------------------------------------------------
; Show Action
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowAction(g, idx)
{
	local sel, stat
	Action_Editing := idx
	Gui, MEW_Main:Default
	GuiControl, MEW_Main:-g, EAction
	GuiControl, MEW_Main:, EAction, % ReplaceCR(Gesture_%g%_%idx%_Action, 0)
	GuiControl, MEW_Main:+gOnActionEditModify, EAction
	stat := "Disable"
	if (Gesture_%g%_%idx%_Target == MC_DefTargetName) {
		GuiControl, MEW_Main:Choose, LBDefAction, 1
	}
	else if (g == Gesture_Editing)
	{
		Gui, MEW_Main:ListView, LVAction
		Loop, % LV_GetCount() {
			LV_GetText(sel, A_Index, 3)
			if (sel == idx) {
				LV_Modify(A_Index, "Select")
				LV_Modify(A_Index, "Focus")
				stat := "Enable"
				break
			}
		}
	}
	GuiControl, MEW_Main:%stat%, BActionUp
	GuiControl, MEW_Main:%stat%, BActionDelete
	GuiControl, MEW_Main:%stat%, BActionDown
	SelectGestureInMainLV()
	ChangeActionButtonStat()
}

;-------------------------------------------------------------------------------
; Clear Gesture Patterns
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ClearGesturePatterns(bClearIdx=true, bClearGUI=true)
{
	global
	if (bClearIdx) {
		GesturePattern_Editing := 0
	}
	if (bClearGUI) {
		GuiControl, MEW_Main:Disable, BUpdateGesturePattern
		EnblUpdateGesturePattern := "Disable"
		GuiControl, MEW_Main:Disable, BGesturePatternUp
		GuiControl, MEW_Main:Disable, BGesturePatternDelete
		GuiControl, MEW_Main:Disable, BGesturePatternDown
		GuiControl, MEW_Main:, EGesture,
	}
}

;-------------------------------------------------------------------------------
; Clear Action
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ClearAction(bClearIdx=true, fOperateGUI="")
{
	global
	if (bClearIdx) {
		Action_Editing := 0
	}
	if (InStr(fOperateGUI, "B")) {
		GuiControl, MEW_Main:Disable, BUpdateAction
		EnblUpdateAction := "Disable"
		GuiControl, MEW_Main:Disable, BActionUp
		GuiControl, MEW_Main:Disable, BActionDelete
		GuiControl, MEW_Main:Disable, BActionDown
	}
	if (InStr(fOperateGUI, "E")) {
		GuiControl, MEW_Main:-g, EAction
		GuiControl, MEW_Main:, EAction,
		GuiControl, MEW_Main:+gOnActionEditModify, EAction
	}
}

;-------------------------------------------------------------------------------
; Replace Carriage Return to Placeholder
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ReplaceCR(szAction, mode=-1)
{
	if (mode < 0) {
		return RegExReplace(szAction, "\n", "<MG_CR>")
	} else {
		szTab := ""
		Loop, %mode% {
			szTab .= "	"
		}
		return RegExReplace(szAction, "<MG_CR>", "`n" . szTab)
	}
}

;-------------------------------------------------------------------------------
; Change Action Button State
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ChangeActionButtonStat()
{
	global
	Gui, MEW_Main:Default
	Gui, MEW_Main:ListView, LVGesture
	EnblUpdateAction := (LV_GetNext() > 0) ? "Enable" : "Disable"
	GuiControl, MEW_Main:%EnblUpdateAction%, BUpdateAction
	GuiControl, MEW_Main:%EnblUpdateAction%, BReleaseGesture
}

;-------------------------------------------------------------------------------
; On Add Action Press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
BAddActionPress:
	ShowUnassignedGestureMenu()
return
AddAction()
{
	local idx := ++Gesture_%Gesture_Editing%_Count
	UpdateAction(true, idx)
}

;-------------------------------------------------------------------------------
; On Update Action Press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
BUpdateActionPress:
	UpdateAction()
return
UpdateAction(bShow=true, idx=0, tname="", script="")
{
	global
	Gui, MEW_Main:Submit, NoHide
	idx	   := idx	 ? idx	  : Action_Editing
	tname  := tname	 ? tname  : MakeTargetFullName(Target_Editing, 1)
	script := script ? script : EAction
	Gesture_%Gesture_Editing%_%idx%_Target := tname
	Gesture_%Gesture_Editing%_%idx%_Action := ReplaceCR(script)
	if (bShow) {
		ShowGesture(Gesture_Editing)
		ShowAssignedGestures(0, false)
		ShowAction(Gesture_Editing, idx)
	}
	SaveModification("Reset")
}

;-------------------------------------------------------------------------------
; On Action Edit Modify
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnActionEditModify:
	Gui, MEW_Main:Submit, Nohide
	SaveModification("Modified", "EAction")
return


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Action Templates
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize Action Templates
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
InitActionTemplates()
{
	global
	ActionCategory_Count=0
	MG_AddActionCategory("All", ActionType001)
	MG_AddActionCategory("Input", ActionType002)
	MG_AddActionTemplate("Input", ActionName001, "ActKeyStroke")
	MG_AddActionTemplate("Input", ActionName002, "ActMouseClick")
	MG_AddActionTemplate("Input", ActionName003, "ActSendWheel")
	MG_AddActionTemplate("Input", ActionName004, "ActMoveCursor")

	MG_AddActionCategory("Scroll", ActionType003)
	MG_AddActionTemplate("Scroll", ActionName005, "ActScroll")
	MG_AddActionTemplate("Scroll", ActionName006, "ActDragScroll")

	MG_AddActionCategory("Window", ActionType004)
	MG_AddActionTemplate("Window", ActionName007, "MG_WinActivate()")
	MG_AddActionTemplate("Window", ActionName008, "WinMinimize")
	MG_AddActionTemplate("Window", ActionName009, "WinMaximize")
	MG_AddActionTemplate("Window", ActionName010, "WinRestore")
	MG_AddActionTemplate("Window", ActionName011, "WinClose")
	MG_AddActionTemplate("Window", ActionName012, "WinSet, Bottom")
	MG_AddActionTemplate("Window", ActionName013, "WinSet, Topmost, On")
	MG_AddActionTemplate("Window", ActionName014, "WinSet, Topmost, Off")
	MG_AddActionTemplate("Window", ActionName015, "WinSet, Topmost, Toggle")
	MG_AddActionTemplate("Window", ActionName016, "ActMoveWindow")
	MG_AddActionTemplate("Window", ActionName017, "WinSet, Trans, %[" . ME_LngMessage104 . "]%")
	MG_AddActionTemplate("Window", ActionName018, "WinSet, Trans, Off")
	MG_AddActionTemplate("Window", ActionName019, "if (MG_Defer()) {`n`t`MG_ActivatePrevWin()`n}")

	MG_AddActionCategory("SameClass", ActionType010)
	MG_AddActionTemplate("SameClass", ActionName041, "ActMinimizeSameClass")
	MG_AddActionTemplate("SameClass", ActionName042, "ActCloseSameClass")
	MG_AddActionTemplate("SameClass", ActionName043, "ActTileSameClass")

	MG_AddActionCategory("Process", ActionType005)
	MG_AddActionTemplate("Process", ActionName020, "ActFileLaunch")
	MG_AddActionTemplate("Process", ActionName021, "Process, Close, % MG_Win(""pid"")")

	MG_AddActionCategory("Application", ActionType006)
	MG_AddActionTemplate("Application", ActionName022, "ButtonIDPicker")
	MG_AddActionTemplate("Application", ActionName023, "WinMenuSelectItem,,, %[" . ME_LngMessage101 . "]%")

	MG_AddActionCategory("Sound", ActionType007)
	MG_AddActionTemplate("Sound", ActionName024, "SoundSet, %[" . ME_LngMessage105 . "]%, MASTER, VOLUME")
	MG_AddActionTemplate("Sound", ActionName025, "SoundSet, %[" . ME_LngMessage106 . "]%, MASTER, MUTE")
	MG_AddActionTemplate("Sound", ActionName026, "ActSoundPlay")

	MG_AddActionCategory("Script", ActionType008)
	MG_AddActionTemplate("Script", ActionName027, "MG_Abort()")
	MG_AddActionTemplate("Script", ActionName028, "MG_Wait(%[" . ME_LngMessage108 . "%<500>%]%)")
	MG_AddActionTemplate("Script", ActionName029, "Sleep, %[" . ME_LngMessage109 . "%<500>%]%")
	MG_AddActionTemplate("Script", ActionName030, "if (MG_Timer(-%[" . ME_LngMessage110 . "%<200>%]%)) {`n`t`;" . ActionComment001 . "`n`n}`nelse {`n`t`;" . ActionComment002 . "`n`n}")
	MG_AddActionTemplate("Script", ActionName031, "if (!MG_Hold()) {`n`t`;" . ActionComment001 . "`n`n}`nelse if (MG_Hold() > %[" . ME_LngMessage111 . "%<500>%]%) {`n`t`;" . ActionComment005 . "`n`n}")
	MG_AddActionTemplate("Script", ActionName032, "if (MG_While(%[" . ME_LngMessage112 . "%<500>%]%)) {`n`t`;" . ActionComment003 . "`n`n}`nelse {`n`t`;" . ActionComment004 . "`n`n}")
	MG_AddActionTemplate("Script", ActionName033, "if (MG_Defer()) {`n`t`;" . ActionComment006 . "`n`n}%[" . ME_LngMessage113 . "%<#NoInput#>%]%")
	MG_AddActionTemplate("Script", ActionName034, "MG_SetActiveAsTarget()")

	MG_AddActionCategory("Hints", ActionType009)
	MG_AddActionTemplate("Hints", ActionName035, "MG_Tooltip=`n(`n%[" . ME_LngMessage114 . "]%`n)")
	MG_AddActionTemplate("Hints", ActionName036, "MG_StopNavi()")
	MG_AddActionTemplate("Hints", ActionName037, "MG_StopTrail()")

	MG_AddActionTemplate("Others", ActionName038, "Clipboard:=""`n(% LTrim RTrim0`n%[" . ME_LngMessage115 . "]%`n)""")
	MG_AddActionTemplate("Others", ActionName039, "ActPostMessage")
	MG_AddActionTemplate("Others", ActionName040, "ActSendMessage")
}

;-------------------------------------------------------------------------------
; Close Action Template Registration
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CloseActionTemplateReg()
{
	global
	ActionCategory_Count++
	ActionCategory%ActionCategory_Count%_Count := ActionCategoryTemp_Count
	ActionCategory%ActionCategory_Count%_Key   := ActionCategoryTemp_Key
	ActionCategory%ActionCategory_Count%_Name  := ActionCategoryTemp_Name
	Loop, %ActionCategoryTemp_Count%
	{
		ActionTitle%ActionCategory_Count%_%A_Index% := ActionTitleTemp_%A_Index%
		ActionTemplate%ActionCategory_Count%_%A_Index% := ActionTemplateTemp_%A_Index%
	}
	Loop, %ActionCategory_Count%
	{
		GuiControl, MEW_Main:, DDLActionCategory, % ActionCategory%A_Index%_Name
	}
}

;-------------------------------------------------------------------------------
; On Action Category Change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnActionCategoryChange:
	GuiControlGet, idx, MEW_Main:, DDLActionCategory
	GuiControl, MEW_Main:, DDLActionTemplate, `n
	Loop, % ActionCategory%idx%_Count
	{
		GuiControl, MEW_Main:, DDLActionTemplate, % ActionTitle%idx%_%A_Index%
	}
	GuiControl, MEW_Main:Choose, DDLActionTemplate, 1
return

;-------------------------------------------------------------------------------
; On Action Helper Button Press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
BAddActionLinePress:
	Gui, MEW_Main:Submit, NoHide
	template = ActionTemplate%DDLActionCategory%_%DDLActionTemplate%
	if (IsLabel(%template%))
	{
		Gosub, % %template%
	}
	else
	{
		ActionLine := %template%
		loop
		{
			if (RegExMatch(ActionLine, "%\[(.+?)\]%", $))
			{
				ActionComment:=$1, DefaultValue:=""
				if (RegExMatch(ActionComment, "%\<(.+?)\>%", $))
				{
					ActionComment := RegExReplace(ActionComment, "%\<(.+?)\>%")
					DefaultValue := $1
				}
				if (!MG_InputBox(ActionLineOption, ME_LngCapt011, ActionComment, DefaultValue)) {
					return
				}
				ActionLine := RegExReplace(ActionLine,"%\[(.+?)\]%",ActionLineOption)
			}
			else
			{
				break
			}
		}
		MG_AddActionScript(ActionLine)
	}
return

;-------------------------------------------------------------------------------
; Add "Key Stroke" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActKeyStroke:
	DlgKeyInput(KeyStroke, 1)
	if (KeyStroke != "") {
		MG_AddActionScript("Send, " . KeyStroke)
	}
return

;-------------------------------------------------------------------------------
; Retrieve a Key Stroke
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
DlgKeyInput(ByRef key, mode=0)
{
	local width, tblText
	static tblKey := [ "Enter", "Tab", "Esc", "Space", "Backspace", "Delete" ]

	key := ""
	Gui, MEW_Key:-MaximizeBox -MinimizeBox +HwndME_hWndKey +OwnerMEW_Main +Delimiter`n +LastFound
	Gui, MEW_Key:Add, Text, x10 y10, %ME_LngText521%
	Gui, MEW_Key:Add, Hotkey, y+10 w200 h20 VszKeyStroke gOnKeyPress
	Gui, MEW_Key:Add, Button, x+4 yp-1 w80 h20 vBSpecitalKey gOnSpecitalKey Section, %ME_LngButton026%
	Gui, MEW_Key:Add, CheckBox, x20 y+8	vKeyShift gOnChkModifier, %ME_LngCheckBox101%
	Gui, MEW_Key:Add, CheckBox, x+10	vKeyCtrl  gOnChkModifier, %ME_LngCheckBox102%
	Gui, MEW_Key:Add, CheckBox, x+10	vKeyAlt   gOnChkModifier, %ME_LngCheckBox103%
	if (mode!=0)
	{
		Gui, MEW_Key:Add, Button, xs yp-3 w80 h20 vEditKey gOnEditKey, %ME_LngButton025%

		tblText := Array(ME_LngText523, ME_LngText524)
		width := GetMaxTextLength(tblText)+8
		Gui, MEW_Key:Add, Text, x12 y+10 w%width%, %ME_LngText523%
		Gui, MEW_Key:Add, DropDownList, x+0 yp-4 w120 vKeyOpe gOnKeyOpe Choose1 AltSubmit, %ME_LngDropDown202%

		Gui, MEW_Key:Add, Text, x12 y+14 w%width%, %ME_LngText524%
		Gui, MEW_Key:Add, Edit, x+0 yp-4 w60 vKeyCount Section
		Gui, MEW_Key:Add, UpDown, Range1-2147483647 +128
		GuiControl, MEW_Key:, KeyCount, 1
	}
	else
	{
		KeyOpe := 1
		KeyCount := 1
	}
	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_Key:Pos, BSpecitalKey
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_Key:Add, Button, x%Bx% y+14 w%Bw% gOnAcceptKey Default, %ME_LngButton001%
	Gui, MEW_Key:Add, Button, x+%Bs% yp+0 w%Bw% gOnCancelKey, %ME_LngButton002%
	Gui, MEW_Key:Show, AutoSize, %ME_LngCapt012%
	CloseIME()

	WinWaitClose,  ahk_id %ME_hWndKey%
	return

	;---------------------------------------------------------------------------
	; Hotkey is pressed
OnKeyPress:
	Gui, MEW_Key:Submit, NoHide
	GuiControl, MEW_Key:, KeyShift, % InStr(szKeyStroke, "+") ? 1 : 0
	GuiControl, MEW_Key:, KeyCtrl, % InStr(szKeyStroke, "^") ? 1 : 0
	GuiControl, MEW_Key:, KeyAlt, % InStr(szKeyStroke, "!") ? 1 : 0
	return

	;---------------------------------------------------------------------------
	; Modifier Key is checked
OnChkModifier:
	Gui, MEW_Key:Submit, NoHide
	AddModifierKeyStr(szKeyStroke, KeyShift, KeyCtrl, KeyAlt)
	GuiControl, MEW_Key:, szKeyStroke, %szKeyStroke%
	return

	;---------------------------------------------------------------------------
	; Edit Key button is pressed
OnEditKey:
	Gui, MEW_Key:Submit, NoHide
	CorrectKeyStr(szKeyStroke, KeyOpe, KeyCount)
	if (MG_InputBox(szKeyStroke, ME_LngCapt013, ME_LngMessage116, szKeyStroke, "MEW_Key"))
	{
		key := szKeyStroke
		Gui, MEW_Key:Destroy
	}
	return

	;---------------------------------------------------------------------------
	; Specital Key button is pressed
OnSpecitalKey:
	Menu, menuKeyList, Add
	Menu, menuKeyList, DeleteAll
	Loop % tblKey.MaxIndex() {
		Menu, menuKeyList, Add, % tblKey[A_Index], OnKeyMenuSelect
	}
	Menu, menuKeyList, Show
	return

	;---------------------------------------------------------------------------
	; Specital Key menu item is selected
OnKeyMenuSelect:
	GuiControl, MEW_Key:, szKeyStroke, %A_ThisMenuItem%
	Gosub, OnChkModifier
	return

	;---------------------------------------------------------------------------
	; Key Operation is changed
OnKeyOpe:
	Gui, MEW_Key:Submit, NoHide
	local stat := (KeyOpe==2 || KeyOpe==3) ? "Disable" : "Enable"
	GuiControl, MEW_Key:%stat%, KeyCount
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptKey:
	Gui, MEW_Key:Submit
	CorrectKeyStr(szKeyStroke, KeyOpe, KeyCount)
	key := szKeyStroke
	Gui, MEW_Key:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelKey:
MEW_KeyGuiClose:
MEW_KeyGuiEscape:
	Gui, MEW_Key:Destroy
	return
}

;-------------------------------------------------------------------------------
; Add Modifier Key String
;	szKey : Key Stroke string to modify
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
AddModifierKeyStr(ByRef szKey, fShift, fCtrl, fAlt)
{
	szKey := RegExReplace(szKey, "[+^!]|Alt||Ctrl|Control|Shift")
	if (fAlt)
	{
		if (szKey != "")
			szKey := "!" + szKey
		else
			szKey := "Alt"
	}
	if (fCtrl)
	{
		if (szKey != "")
			szKey := "^" + szKey
		else
			szKey := "Ctrl"
	}
	if (fShift)
	{
		if (szKey != "")
			szKey := "+" + szKey
		else
			szKey := "Shift"
	}
}

;-------------------------------------------------------------------------------
; Correct Key Stroke String
;	szKey : Key Stroke string to correct
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CorrectKeyStr(ByRef szKey, ope=1, cnt=1)
{
	local key, keyOrg, ex

	if (ope == 2) {
		ex := " Down"
	} else if (ope == 3) {
		ex := " Up"
	} else if (cnt > 1) {
		ex := " " . cnt
	} else {
		ex := ""
	}
	key := keyOrg := RegExReplace(szKey, "[+^!#]")
	if (StrLen(key)==1) {
		StringLower, key, key
	}
	if (StrLen(key)>1 || ex!="") {
		key := "{" . key . ex . "}"
	}
	szKey := RegExReplace(szKey, keyOrg, key)
}

;-------------------------------------------------------------------------------
; Close IME
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CloseIME()
{
	ControlGet, hCtrl, HWND,,,A
	hWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr",hCtrl, "Ptr")
	DetectHiddenWindows, On
	SendMessage, 0x283, 6, 0,, ahk_id %hWnd%
	DetectHiddenWindows, Off
}


;-------------------------------------------------------------------------------
; Add "Mouse Click" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMouseClick:
	DlgMouseClick()
return
DlgMouseClick()
{
	global
	Gui, MEW_Click:-MaximizeBox -MinimizeBox +HwndME_hWndClick +OwnerMEW_Main +Delimiter`n +LastFound

	local tblText := Array(ME_LngText522, ME_LngText525, ME_LngText526)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_Click:Add, Text, x12 y+20 w%width%, %ME_LngText522%
	Gui, MEW_Click:Add, DropDownList, x+0 yp-4 w120 vClkButton Choose1 AltSubmit, %ME_LngDropDown201%

	Gui, MEW_Click:Add, Text, x12 y+14 w%width%, %ME_LngText525%
	Gui, MEW_Click:Add, DropDownList, x+0 yp-4 w120 vClkOpe gOnClkOpe Choose1 AltSubmit, %ME_LngDropDown203%

	Gui, MEW_Click:Add, Text, x12 y+14 w%width%, %ME_LngText526%
	Gui, MEW_Click:Add, Edit, x+0 yp-4 w62 vClickCount Section
	Gui, MEW_Click:Add, UpDown, Range1-2147483647 +128
	GuiControl, MEW_Click:, ClickCount, 1

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_Click:Pos, ClkButton
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_Click:Add, Button, gOnAcceptClick x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_Click:Add, Button, gOnCancelClick x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_Click:Show, AutoSize, %ME_LngCapt014%

	WinWaitClose,  ahk_id %ME_hWndClick%
	return

	;---------------------------------------------------------------------------
	; Mouse Operation is changed
OnClkOpe:
	Gui, MEW_Click:Submit, NoHide
	local stat := (ClkOpe==2 || ClkOpe==3) ? "Disable" : "Enable"
	GuiControl, MEW_Click:%stat%, ClickCount
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptClick:
	Gui, MEW_Click:Submit
	local szButton:=""
	if (ClkButton==1) {
		szButton := "LB"
	} else if (ClkButton==2) {
		szButton := "RB"
	} else if (ClkButton==3) {
		szButton := "MB"
	} else if (ClkButton==4) {
		szButton := "X1B"
	} else if (ClkButton==5) {
		szButton := "X2B"
	}
	local szAction
	if (ClkOpe==1) {
		szAction := "MG_Click(""" . szButton . """"
		szAction .= (ClickCount>1) ? ",," . ClickCount . ")" : ")"
	} else {
		szAction := "MG_Click(""" . szButton . """, """ . (ClkOpe==2 ? "D" : "U") . """)"
	}
	MG_AddActionScript(szAction)
	Gui, MEW_Click:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelClick:
MEW_ClickGuiClose:
MEW_ClickGuiEscape:
	Gui, MEW_Click:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Wheel Rotation" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActSendWheel:
	DlgSendWheel()
return
DlgSendWheel()
{
	global
	Gui, MEW_SW:-MaximizeBox -MinimizeBox +HwndME_hWndSW +OwnerMEW_Main +Delimiter`n +LastFound

	Gui, MEW_SW:Add, GroupBox, x12 y12 w200 h68 vSwGB Section, %ME_LngGroupBox101%
	Gui, MEW_SW:Add, Radio, xs+20 ys+20 vSwUp Checked, %ME_LngRadioBtn001%
	Gui, MEW_SW:Add, Radio, xs+20 y+12 vSwDown , %ME_LngRadioBtn002%

	Gui, MEW_SW:Add, Text, x20 y+28 Section, %ME_LngText527%
	Gui, MEW_SW:Add, Edit, x+8 yp-4 w62 vSwDst
	Gui, MEW_SW:Add, UpDown, Range1-2147483647 +128
	GuiControl, MEW_SW:, SwDst, 1

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_SW:Pos, SwGB
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_SW:Add, Button, gOnAcceptSW x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_SW:Add, Button, gOnCancelSW x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_SW:Show, AutoSize, %ME_LngCapt015%

	WinWaitClose,  ahk_id %ME_hWndSW%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptSW:
	Gui, MEW_SW:Submit
	local szDir := SwUp ? "U" : "D"
	local szAction := "MG_SendWheel(""" . szDir . """, " . SwDst . ")"
	MG_AddActionScript(szAction)
	Gui, MEW_SW:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelSW:
MEW_SWGuiClose:
MEW_SWGuiEscape:
	Gui, MEW_SW:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Cursor Movement" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMoveCursor:
	DlgMoveCursor()
return
DlgMoveCursor()
{
	global
	Gui, MEW_MC:New
	Gui, MEW_MC:-MaximizeBox -MinimizeBox +HwndME_hWndMC +OwnerMEW_Main +Delimiter`n +LastFound

	local tblText := Array(ME_LngText421, ME_LngText528)
	local width := GetMaxTextLength(tblText)
	Gui, MEW_MC:Add, Text, x12 y20 w%width% Right, %ME_LngText421%
	Gui, MEW_MC:Add, Edit, x+8 yp-4 w62 vMcX Section
	Gui, MEW_MC:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_MC:, McX, 0

	Gui, MEW_MC:Add, Text, x+18 ys+4 Right, %ME_LngText422%
	Gui, MEW_MC:Add, Edit, x+8 yp-4 w62 vMcY
	Gui, MEW_MC:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_MC:, McY, 0

	Gui, MEW_MC:Add, CheckBox, xs y+10 vMcAbs gOnMcAbs, %ME_LngCheckBox110%

	Gui, MEW_MC:Add, Text, x12 y+16 w%width% Right, %ME_LngText528%
	Gui, MEW_MC:Add, DropDownList, x+8 yp-4 w200 vMcOrg Choose1 AltSubmit, %ME_LngDropDown204%

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_MC:Pos, McOrg
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_MC:Add, Button, gOnAcceptMC x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_MC:Add, Button, gOnCancelMC x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_MC:Show, AutoSize, %ME_LngCapt016%

	WinWaitClose,  ahk_id %ME_hWndMC%
	return

	;---------------------------------------------------------------------------
	; On Absolute Coordinates Check
OnMcAbs:
	Gui, MEW_MC:Submit, NoHide
	local stat := McAbs ? "Disable" : "Enable"
	GuiControl, MEW_MC:%stat%, McOrg
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptMC:
	Gui, MEW_MC:Submit
	McOrg--
	if (McX+McY+McOrg+McAbs == 0) {
		MG_AddActionScript("MG_Move()")
	}
	else {
		MG_AddActionScript("MG_Move(" . McX . ", " . McY . ", " . McOrg . ", " . McAbs . ")")
	}
	Gui, MEW_MC:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelMC:
MEW_MCGuiClose:
MEW_MCGuiEscape:
	Gui, MEW_MC:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Scroll" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActScroll:
	DlgScroll()
return
DlgScroll()
{
	global
	Gui, MEW_SR:-MaximizeBox -MinimizeBox +HwndME_hWndSR +OwnerMEW_Main +Delimiter`n +LastFound

	local tblText := Array(ME_LngText529, ME_LngText530)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_SR:Add, Text, x12 y+20 w%width%, %ME_LngText529%
	Gui, MEW_SR:Add, DropDownList, x+0 yp-4 w140 vSrDir Choose1 AltSubmit, %ME_LngDropDown205%

	Gui, MEW_SR:Add, Text, x12 y+14 w%width%, %ME_LngText530%
	Gui, MEW_SR:Add, Edit, x+0 yp-4 w62 vSrLines Section
	Gui, MEW_SR:Add, UpDown, Range1-2147483647 +128
	GuiControl, MEW_SR:, SrLines, 1

	Gui, MEW_SR:Add, CheckBox, xs y+12 vSrPage, %ME_LngCheckBox111%

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_SR:Pos, SrDir
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_SR:Add, Button, gOnAcceptSR x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_SR:Add, Button, gOnCancelSR x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_SR:Show, AutoSize, %ME_LngCapt017%

	WinWaitClose,  ahk_id %ME_hWndSR%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptSR:
	Gui, MEW_SR:Submit
	local szDir	 := (SrDir==1 || SrDir==2) ? "V" : "H"
	local nLines := (SrDir==2 || SrDir==4) ? SrLines : -SrLines
	local szAction := "MG_Scroll2(""" . szDir . """, " . nLines . ", " . SrPage . ")"
	MG_AddActionScript(szAction)
	Gui, MEW_SR:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelSR:
MEW_SRGuiClose:
MEW_SRGuiEscape:
	Gui, MEW_SR:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Drag-Scroll" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActDragScroll:
	DlgDragScroll()
return
DlgDragScroll()
{
	global
	Gui, MEW_DS:-MaximizeBox -MinimizeBox +HwndME_hWndDS +OwnerMEW_Main +Delimiter`n +LastFound

	Gui, MEW_DS:Add, Text, x12 y10 , %ME_LngText531%
	Gui, MEW_DS:Add, Text, x12 y+4 cBlue, %ME_LngText532%

	local tblText := Array(ME_LngText533, ME_LngText534)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_DS:Add, Text, x12 y+14 w%width% Section, %ME_LngText533%
	Gui, MEW_DS:Add, Edit, x+0 yp-4 w62 vDsResV
	Gui, MEW_DS:Add, UpDown, Range1-2147483647 +128
	Gui, MEW_DS:Add, Text, x+4 yp+4, %ME_LngText535%
	GuiControl, MEW_DS:, DsResV, 30

	Gui, MEW_DS:Add, Text, x12 y+14 w%width%, %ME_LngText534%
	Gui, MEW_DS:Add, Edit, x+0 yp-4 w62 vDsResH
	Gui, MEW_DS:Add, UpDown, Range1-2147483647 +128
	Gui, MEW_DS:Add, Text, x+4 yp+4, %ME_LngText535%
	GuiControl, MEW_DS:, DsResH, 30

	local tblText := Array(ME_LngText536, ME_LngText537)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_DS:Add, Text, x12 y+16 w%width%, %ME_LngText536%
	Gui, MEW_DS:Add, DropDownList, x+0 yp-4 w280 vDsInvert Choose2 AltSubmit, %ME_LngDropDown206%

	Gui, MEW_DS:Add, Text, x12 y+12 w%width%, %ME_LngText537%
	Gui, MEW_DS:Add, DropDownList, x+0 yp-4 w280 vDsAuto Choose1 AltSubmit, %ME_LngDropDown207%

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_DS:Pos, DsAuto
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_DS:Add, Button, gOnAcceptDS x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_DS:Add, Button, gOnCancelDS x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_DS:Show, AutoSize, %ME_LngCapt018%

	WinWaitClose,  ahk_id %ME_hWndDS%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptDS:
	Gui, MEW_DS:Submit
	local szAction := "if (MG_While()) {`n"
	szAction .= "    MG_DragScroll2(" . DsInvert-1 . ", " . DsAuto-1 . ", " . DsResV . ", " . DsResH . ")`n"
	szAction .= "}"
	MG_AddActionScript(szAction)
	Gui, MEW_DS:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelDS:
MEW_DSGuiClose:
MEW_DSGuiEscape:
	Gui, MEW_DS:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Move and Resize Window" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMoveWindow:
	DlgMoveWindow()
return
DlgMoveWindow()
{
	global
	Gui, MEW_MW:New
	Gui, MEW_MW:-MaximizeBox -MinimizeBox +HwndME_hWndMW +OwnerMEW_Main +Delimiter`n +LastFound

	Gui, MEW_MW:Add, Text, x12 y10, %ME_LngText541%
	Gui, MEW_MW:Add, Text, x16 y+6 cBlue, %ME_LngText542%
	Gui, MEW_MW:Add, Text, x16 y+6 cBlue, %ME_LngText543%
	Gui, MEW_MW:Add, Text, x16 y+6 cBlue, %ME_LngText544%
	Gui, MEW_MW:Add, Text, x16 y+6 cBlue vTDescMvWin, %ME_LngText545%

	local tblText := Array(ME_LngText546, ME_LngText547, ME_LngText548, ME_LngText549)
	local width := GetMaxTextLength(tblText)
	Gui, MEW_MW:Add, Text, x26 y+18 w%width% Right, %ME_LngText546%
	Gui, MEW_MW:Add, Edit, x+8 yp-4 w62 vMwX Section
	Gui, MEW_MW:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_MW:, MwX,

	Gui, MEW_MW:Add, Text, x+20 ys+4 w%width% Right, %ME_LngText547%
	Gui, MEW_MW:Add, Edit, x+8 yp-4 w62 vMwY
	Gui, MEW_MW:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_MW:, MwY,

	Gui, MEW_MW:Add, Text, x26 y+14 w%width% Right, %ME_LngText548%
	Gui, MEW_MW:Add, Edit, x+8 yp-4 w62 vMwW Section
	Gui, MEW_MW:Add, UpDown, Range-2147483648-2147483647 +128
	GuiControl, MEW_MW:, MwW,

	Gui, MEW_MW:Add, Text, x+20 ys+4 w%width% Right, %ME_LngText549%
	Gui, MEW_MW:Add, Edit, x+8 yp-4 w62 vMwH
	Gui, MEW_MW:Add, UpDown, Range-2147483648-2147483647 +128 vMwUD
	GuiControl, MEW_MW:, MwH,

	Gui, MEW_MW:Add, CheckBox, xs y+14 vMwRelH, %ME_LngCheckBox112%

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_MW:Pos, TDescMvWin
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_MW:Add, Button, gOnAcceptMW x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_MW:Add, Button, gOnCancelMW x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_MW:Show, AutoSize, %ME_LngCapt019%

	WinWaitClose,  ahk_id %ME_hWndMW%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptMW:
	Gui, MEW_MW:Submit
	if (MwX="" && MwY="" && MwW="" && MwH="") {
		Gui, MEW_MW:Destroy
		return
	}
	MG_AddActionScript("MG_WinMove(""" . MwX . """, """ . MwY . """, """ . MwW . """, """ . MwH . """, " . MwRelH . ")")
	Gui, MEW_MW:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelMW:
MEW_MWGuiClose:
MEW_MWGuiEscape:
	Gui, MEW_MW:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Minimize / Close all windows of the same class" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMinimizeSameClass:
	DlgOperateSameClass("Minimize")
return
ActCloseSameClass:
	DlgOperateSameClass("Close")
return
DlgOperateSameClass(szOpe)
{
	global
	Gui, MEW_OSC:-MaximizeBox -MinimizeBox +HwndME_hWndOSC +OwnerMEW_Main +Delimiter`n +LastFound

	Gui, MEW_OSC:Add, Text, x12 y12 Section, %ME_LngText571%

	local tblText := Array(ME_LngText572, ME_LngText573)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_OSC:Add, Text, xs+6 y+16 w%width%, %ME_LngText572%
	Gui, MEW_OSC:Add, Edit, x+0 yp-4 w350 vEIncludeTitle

	Gui, MEW_OSC:Add, Text, xs+6 y+14 w%width%, %ME_LngText573%
	Gui, MEW_OSC:Add, Edit, x+0 yp-4 w350 vEExcludeTitle

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_OSC:Pos, EExcludeTitle
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_OSC:Add, Button, gOnAcceptOSC x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_OSC:Add, Button, gOnCancelOSC x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_OSC:Show, AutoSize, % (szOpe=="Minimize" ? ME_LngCapt026 : ME_LngCapt027)

	WinWaitClose,  ahk_id %ME_hWndOSC%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptOSC:
	Gui, MEW_OSC:Submit
	MG_AddActionScript("MG_OperateSameClass(""" szOpe """, """ EIncludeTitle """, """ EExcludeTitle """)")
	Gui, MEW_OSC:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelOSC:
MEW_OSCGuiClose:
MEW_OSCGuiEscape:
	Gui, MEW_OSC:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Tile all windows of the same class" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActTileSameClass:
	DlgTileSameClass()
return
DlgTileSameClass()
{
	global
	Gui, MEW_TSC:New
	Gui, MEW_TSC:-MaximizeBox -MinimizeBox +HwndME_hWndTSC +OwnerMEW_Main +Delimiter`n +LastFound

	Gui, MEW_TSC:Add, Text, x20 y+20, %ME_LngText581%
	Gui, MEW_TSC:Add, DropDownList, x+8 yp-4 w100 vDirTSC Choose1 AltSubmit, %ME_LngDropDown210%

	Gui, MEW_TSC:Add, GroupBox, x12 y+12 w300 h80 vGBExAreaTSC Section, %ME_LngGroupBox102%

	local tblText := Array(ME_LngText582, ME_LngText583, ME_LngText584, ME_LngText585)
	local width := GetMaxTextLength(tblText)
	Gui, MEW_TSC:Add, Text, xs+14 ys+24 w%width%, %ME_LngText582%
	Gui, MEW_TSC:Add, Edit, x+4 yp-4 w62 vExL
	Gui, MEW_TSC:Add, UpDown, Range-2147483648-2147483647 +128

	Gui, MEW_TSC:Add, Text, x+20 ys+24 w%width%, %ME_LngText583%
	Gui, MEW_TSC:Add, Edit, x+4 yp-4 w62 vExR
	Gui, MEW_TSC:Add, UpDown, Range-2147483648-2147483647 +128

	Gui, MEW_TSC:Add, Text, xs+14 y+14 w%width%, %ME_LngText584%
	Gui, MEW_TSC:Add, Edit, x+4 yp-4 w62 vExT Section
	Gui, MEW_TSC:Add, UpDown, Range-2147483648-2147483647 +128

	Gui, MEW_TSC:Add, Text, x+20 ys+4 w%width%, %ME_LngText585%
	Gui, MEW_TSC:Add, Edit, x+4 yp-4 w62 vExB
	Gui, MEW_TSC:Add, UpDown, Range-2147483648-2147483647 +128 vMwUD

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_TSC:Pos, GBExAreaTSC
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_TSC:Add, Button, gOnAcceptTCS x%Bx% y+20 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_TSC:Add, Button, gOnCancelTCS x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_TSC:Show, AutoSize, %ME_LngCapt028%

	WinWaitClose,  ahk_id %ME_hWndTSC%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptTCS:
	Gui, MEW_TSC:Submit
	local dir := DirTSC==1 ? "H" : (DirTSC==2 ? "V" : "")
	MG_AddActionScript("MG_TileSameClass(""" dir """, " ExL ", " ExT ", " ExR ", " ExB ")")
	Gui, MEW_TSC:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelTCS:
MEW_TSCGuiClose:
MEW_TSCGuiEscape:
	Gui, MEW_TSC:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "Launch File" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActFileLaunch:
	DlgLaunchFile(0)
return
ActSoundPlay:
	DlgLaunchFile(1)
return
DlgLaunchFile(mode)
{
	global
	Gui, MEW_LF:-MaximizeBox -MinimizeBox +HwndME_hWndLF +OwnerMEW_Main +Delimiter`n +LastFound

	local szCaption, szFilter
	if (mode==0)
	{
		szCaption := ME_LngCapt022
		szFilter  := ME_LngText556
		Gui, MEW_LF:Add, Text, x12 y20, %ME_LngMessage102%

		local tblText := Array(ME_LngText551, ME_LngText552, ME_LngText553, ME_LngText554)
		local width := GetMaxTextLength(tblText)+8
		Gui, MEW_LF:Add, Text, x12 y+20 w%width%, %ME_LngText551%
		Gui, MEW_LF:Add, Edit, x+0 yp-4 w341 vLfTarget
		Gui, MEW_LF:Add, Button, x+2 yp-1 w58 gOnBrowseLF vLfBrowse, %ME_LngButton027%

		Gui, MEW_LF:Add, Text, x12 y+12 w%width%, %ME_LngText552%
		Gui, MEW_LF:Add, Edit, x+0 yp-4 w400 vLfFolder

		Gui, MEW_LF:Add, Text, x12 y+14 w%width%, %ME_LngText553%
		Gui, MEW_LF:Add, DropDownList, x+0 yp-4 w400 vLfWindow Choose1 AltSubmit, %ME_LngDropDown208%

		if (MG_IsNewOS()) {
			Gui, MEW_LF:Add, Text, x12 y+14 w%width%, %ME_LngText554%
			Gui, MEW_LF:Add, DropDownList, x+0 yp-4 w400 vLfLevel Choose1 AltSubmit Section, %ME_LngDropDown209%
		}
	}
	else
	{
		szCaption := ME_LngCapt023
		szFilter  := ME_LngText557
		Gui, MEW_LF:Add, Text, x12 y20, %ME_LngMessage107%

		Gui, MEW_LF:Add, Edit, x12 y+12 w400 vLfTarget
		Gui, MEW_LF:Add, Button, x+2 yp-1 gOnBrowseLF vLfBrowse, %ME_LngButton027%
	}
	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_LF:Pos, LfWindow
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_LF:Add, Button, gOnAcceptLF x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_LF:Add, Button, gOnCancelLF x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_LF:Show, AutoSize, %szCaption%

	WinWaitClose,  ahk_id %ME_hWndLF%
	return

	;---------------------------------------------------------------------------
	; Browse a file
OnBrowseLF:
	local szPath
	FileSelectFile, szPath,,, %szCaption%, %szFilter%
	if (szPath) {
		GuiControl, MEW_LF:, LfTarget, %szPath%
	}
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptLF:
	LfLevel := 0
	Gui, MEW_LF:Submit
	local szAction, szWindow
	if (mode==0)
	{
		if (LfWindow==2) {
			szWindow := "Min"
		} else if (LfWindow==3) {
			szWindow := "Max"
		} else if (LfWindow==4) {
			szWindow := "Hide"
		} else {
			szWindow := ""
		}
		if (LfLevel==1) {
			szAction  := "MG_RunAsUser(""" . LfTarget . """, """ . LfFolder . """, """ . szWindow . """)"
		}
		else
		{
			if (MG_IsNewOS()) {
				LfTarget := "*runas " . LfTarget
			}
			szAction  := "Run, " . LfTarget . ", " . LfFolder . ", " . szWindow . " UseErrorLevel"
		}
	}
	else {
		szAction  := "SoundPlay, " . LfTarget
	}
	MG_AddActionScript(szAction)
	Gui, MEW_LF:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelLF:
MEW_LFGuiClose:
MEW_LFGuiEscape:
	Gui, MEW_LF:Destroy
	return
}


;-------------------------------------------------------------------------------
; Add "PostMessage/SendMessage" to Action Script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActPostMessage:
	DlgPostMessage(0)
return
ActSendMessage:
	DlgPostMessage(1)
return
DlgPostMessage(mode)
{
	global
	Gui, MEW_PM:-MaximizeBox -MinimizeBox +HwndME_hWndPM +OwnerMEW_Main +Delimiter`n +LastFound

	local tblText := Array(ME_LngText561, ME_LngText562, ME_LngText563)
	local width := GetMaxTextLength(tblText)+8
	Gui, MEW_PM:Add, Text, x12 y20 w%width%, %ME_LngText561%
	Gui, MEW_PM:Add, Edit, x+0 yp-4 w120 vPmMsg

	Gui, MEW_PM:Add, Text, x12 y+12 w%width%, %ME_LngText562%
	Gui, MEW_PM:Add, Edit, x+0 yp-4 w120 vPmWParam

	Gui, MEW_PM:Add, Text, x12 y+12 w%width%, %ME_LngText563%
	Gui, MEW_PM:Add, Edit, x+0 yp-4 w120 vPmLParam

	local Bx, Bw:=80, Bs:=8
	GuiControlGet, rcCtrl, MEW_PM:Pos, PmMsg
	Bx := rcCtrlX + rcCtrlW - Bw*2 - Bs
	Gui, MEW_PM:Add, Button, gOnAcceptPM x%Bx% y+14 w%Bw% Default, %ME_LngButton001%
	Gui, MEW_PM:Add, Button, gOnCancelPM x+8 yp+0 w%Bw%, %ME_LngButton002%
	Gui, MEW_PM:Show, AutoSize, %ME_LngCapt024%

	WinWaitClose,  ahk_id %ME_hWndPM%
	return

	;---------------------------------------------------------------------------
	; Accepted
OnAcceptPM:
	Gui, MEW_PM:Submit
	local szAction
	if (mode==0) {
		szAction := "PostMessage, "
	}
	else {
		szAction := "SendMessage, "
	}
	szAction .= PmMsg . ", " . PmWParam . ", " . PmLParam
	MG_AddActionScript(szAction)
	Gui, MEW_PM:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnCancelPM:
MEW_PMGuiClose:
MEW_PMGuiEscape:
	Gui, MEW_PM:Destroy
	return
}

;-------------------------------------------------------------------------------
; Get Toolbar Button ID
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ButtonIDPicker:
	Hotkey,RButton up,ButtonIDPickerHotkey,On
	SetTimer,ButtonIDPickerTimer,10
return

ButtonIDPickerTimer:
	Tooltip, %ME_LngTooltip004%
return

ButtonIDPickerHotkey:
	Hotkey,RButton up,Off
	SetTimer,ButtonIDPickerTimer,Off
	Tooltip
	if(ButtonIDPicker_ID:=GetButtonCID()){
		MG_AddActionScript("SendMessage,0x111," ButtonIDPicker_ID ",0")
	}
return

GetButtonCID()
{
	CoordMode,Mouse,Screen
	MouseGetPos,MG_X,MG_Y,MG_HWND,MG_HCTL,3
	SendMessage,0x84,0,% MG_Y<<16|MG_X,,ahk_id %MG_HCTL%
	If ErrorLevel=4294967295
		MouseGetPos,,,,MG_HCTL,2
	;mouse position on control
	WinGetPos,wx,wy,,,ahk_id %MG_HWND%
	ControlGetPos,cx,cy,,,,ahk_id %MG_HCTL%
	cmx:=MG_X-cx-wx
	cmy:=MG_Y-cy-wy
	;count
	SendMessage,0x0418,0,0,,ahk_id %MG_HCTL%
	c=%ErrorLevel%
	if(c>0){
		WinGet,pid,pid,ahk_id %MG_HWND%
		hProc := DllCall("OpenProcess", "UInt",0x1F0FFF, "UInt",0, "UInt",pid, "Ptr")
		size  := 10 + (A_PtrSize==4 ? 2 : 6) + A_PtrSize*2
		lpTB  := DllCall("VirtualAllocEx", "Ptr",hProc, "Ptr",0, "UInt",size, "UInt",0x1000, "UInt",0x4, "Ptr")
		Loop, %c%
		{
			;button struct
			SendMessage,0x417,% A_Index-1,%lpTB%,,ahk_id %MG_HCTL%
			DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",lpTB+8, "PtrP",stt, "UInt",4, "Ptr",0)
			if(!(stt&8)){
				;not hidden
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",lpTB+4, "PtrP",cid, "UInt",4, "Ptr",0)
				SendMessage,0x433,cid,%lpTB%,,ahk_id %MG_HCTL%
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",lpTB+0,  "PtrP",x1, "UInt",4, "Ptr",0)
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",lpTB+4,  "PtrP",y1, "UInt",4, "Ptr",0)
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",lpTB+8,  "PtrP",x2, "UInt",4, "Ptr",0)
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",lpTB+12, "PtrP",y2, "UInt",4, "Ptr",0)
				if((x1<=cmx)&&(x2>=cmx)&&(y1<=cmy)&&(y2>=cmy)){
					;under the cursor
					break
				}
			}
		}
		DllCall("VirtualFreeEx", "Ptr",hProc, "Ptr",lpTB, "Ptr",0, "UInt",0x8000)
		DllCall("CloseHandle", "Ptr",hProc)
		return cid
	}
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Option Routines : 設定など
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize Configuration Variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
InitConfigs(table)
{
	global
	Loop, Parse, table, `n
	{
		Config_%A_LoopField%=
	}
}

;-------------------------------------------------------------------------------
; Set Configuration Variables to GUI Controls
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ShowConfig()
{
	global
	Loop, Parse, ConfRecognition,`n
	{
		GuiControl, MEW_Main:, Config_%A_LoopField%, % Config_%A_LoopField%
	}
	Loop, Parse, ConfNavi,`n
	{
		GuiControl, MEW_Main:, Config_%A_LoopField%, % Config_%A_LoopField%
	}
	Loop, Parse, ConfAdNavi,`n
	{
		GuiControl, MEW_Main:, Config_%A_LoopField%, % Config_%A_LoopField%
	}
	Loop, Parse, ConfTrail,`n
	{
		GuiControl, MEW_Main:, Config_%A_LoopField%, % Config_%A_LoopField%
	}
	Loop, Parse, ConfLogs,`n
	{
		GuiControl, MEW_Main:, Config_%A_LoopField%, % Config_%A_LoopField%
	}
	Loop, Parse, ConfOthers,`n
	{
		GuiControl, MEW_Main:, Config_%A_LoopField%, % Config_%A_LoopField%
	}
}

;-------------------------------------------------------------------------------
; Save Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
SaveExit()
{
	local szIni, szPrev, file

	SaveModification()
	Critical
	SubmitConfigurations()
	szIni := ToIni()
	szPrev := ""
	file := FileOpen(A_ScriptDir . "\Config\MouseGestureL.ini", "r `n", "UTF-8")
	if (file) {
		szPrev := file.Read(file.Length)
		file.Close
	}
	if (szIni != szPrev) {
		FileMove, %A_ScriptDir%\Config\MouseGestureL.ini
				, %A_ScriptDir%\Config\MouseGestureL.ini.bak, 1
	} else {
		FileDelete, %A_ScriptDir%\Config\MouseGestureL.ini
	}
	FileAppend, % szIni, %A_ScriptDir%\Config\MouseGestureL.ini, UTF-8
	FileDelete, %A_ScriptDir%\Config\MG_Config.ahk
	FileAppend, % ToAhk(), %A_ScriptDir%\Config\MG_Config.ahk, UTF-8
	ExitApp
}

;-------------------------------------------------------------------------------
; Submit Configurations
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
SubmitConfigurations()
{
	global
	Gui, MEW_Main:Submit, NoHide
	Config_UseExNavi--
	Config_AdNaviPosition--
	CorrectColorHex(Config_ExNaviFG, true)
	CorrectColorHex(Config_ExNaviBG, true)
	CorrectColorHex(Config_AdNaviFG, true)
	CorrectColorHex(Config_AdNaviNI, true)
	CorrectColorHex(Config_AdNaviBG, true)
	CorrectColorHex(Config_TrailColor, true)
	CorrectColorHex(Config_LogFG, true)
	CorrectColorHex(Config_LogBG, true)
}

;-------------------------------------------------------------------------------
; Make INI Format Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ToIni()
{
	local tmp := ConfigToIni()
	Loop, %Target_Count% {
		tmp := tmp . "`n" . TargetToIni(A_Index)
	}
	Loop, %Gesture_Count% {
		tmp := tmp . "`n" . GestureToIni(A_Index)
	}
	return tmp
}

;-------------------------------------------------------------------------------
; Make Configuration Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ConfigToIni()
{
	local res := "[Settings]`n"
	Loop, Parse, ConfRecognition, `n
	{
		res := res . "" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfNavi, `n
	{
		res := res . "" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfAdNavi, `n
	{
		res := res . "" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfTrail, `n
	{
		res := res . "" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfLogs, `n
	{
		res := res . "" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfOthers, `n
	{
		res := res . "" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, MG_BtnNames, _
	{
		if (Config_ExNaviFG_%A_LoopField% != "") {
			res := res . "ExNaviFG_" . A_LoopField . "=" . Config_ExNaviFG_%A_LoopField% . "`n"
		}
	}
	res .= "`n[ActivationExcluded]`n"
	Loop, % MG_ActvtExclud.MaxIndex()
	{
		res .= A_Index "={" MG_ActvtExclud[A_Index][1] "`t" MG_ActvtExclud[A_Index][2] "`t" MG_ActvtExclud[A_Index][3] "}`n"
	}
	return res
}

;-------------------------------------------------------------------------------
; Make Target Section Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetToIni(idx)
{
	local res,delim
	res := "[" . Target_%idx%_Name . "]`n"
	if (Target_%idx%_IconFile) {
		res := res . "Icon=" Target_%idx%_IconFile "`n"
	}
	if (Target_%idx%_Level > 1) {
		res := res . "Level=" Target_%idx%_Level "`n"
	}
	if (Target_%idx%_IsAnd) {
		res := res . "And=1`n"
	}
	if (Target_%idx%_NotInh) {
		res := res . "NotInherit=1`n"
	}
	Loop, % Target_%idx%_Count {
		res := res . Target_%idx%_%A_Index%_Type "=" Target_%idx%_%A_Index%_Value "`n"
	}
	return res
}

;-------------------------------------------------------------------------------
; Make Gesture Section Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureToIni(idx)
{
	local gr,res,def
	res:="[" . Gesture_%idx%_Name . "]`n" . RegExReplace(Gesture_%idx%_Patterns,"(^|\n)","$1G=") . "`n"
	Loop, % Gesture_%idx%_Count {
		res:=res . Gesture_%idx%_%A_Index%_Target . "=" Gesture_%idx%_%A_Index%_Action . "`n"
	}
	return res
}

;-------------------------------------------------------------------------------
; Make Configuration Script Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ToAhk()
{
	local MaxLen, AG, Triggers, SubTriggers, ahk, BT2
	local tmp := ConfigToAhk()
	Loop, %Gesture_Count%
	{
		Loop, Parse, Gesture_%A_Index%_Patterns,`n
		{
			Join(AG,A_LoopField)
			MaxLen:=(MaxLen<StrLen(A_LoopField)) ? StrLen(A_LoopField) : MaxLen
		}
	}
	AG = `n%AG%`n
	tmp := tmp . "MG_MaxLength=" . MaxLen . "`n"

	Loop, Parse, MG_BtnNames, _
	{
		if(RegExMatch(AG, "`n" . A_LoopField . "_")){
			Join(Triggers, A_LoopField, "_")
			Use_%A_LoopField%=1
		}else{
			Join(BT2, A_LoopField)
		}
	}
	tmp := tmp . "MG_Triggers=" . Triggers . "`n"

	AG := RegExReplace(AG,"_","`n")
	Loop, Parse, BT2,`n
	{
		if(RegExMatch(AG,"`n" . A_LoopField . "`n")){
			Join(SubTriggers,A_LoopField,"_")
			Use_%A_LoopField% = 1
		}
	}
	tmp := tmp . "MG_SubTriggers=" . SubTriggers . "`n"

	Triggers = %Triggers%_%SubTriggers%
	Loop, Parse, Triggers, _
	{
		FileRead, ahk, %A_ScriptDir%\Components\Buttons\%A_LoopField%.ahk
		tmp := tmp . "`n`n" . ahk
	}
	tmp := tmp . "`n`nGoto,MG_Config_End`n`n"

	Loop, %Target_Count%
	{
		tmp := tmp . "`n" . TargetToAhk(A_Index)
	}
	Loop, %Gesture_Count%
	{
		tmp := tmp . "`n" . GestureToAhk(A_Index)
	}

	if (Config_HotkeyEnable) {
		tmp .= "`n" . Config_HotkeyEnable . "::Gosub, MG_ToggleEnable`nHotkey, " Config_HotkeyEnable ",, P8`n"
	}

	if (Config_HotkeyNavi) {
		tmp .= "`n" . Config_HotkeyNavi . "::Gosub, MG_NaviToggleEnable`n"
	}

	if (Config_HotkeyReload) {
		tmp .= "`n" . Config_HotkeyReload . "::MG_Reload()`nHotkey, " Config_HotkeyReload ",, P10`n"
	}

	tmp := tmp . "`n`nMG_Config_end:"
	return tmp
}

;-------------------------------------------------------------------------------
; Make Configuration Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ConfigToAhk()
{
	local res := ""
	Loop, Parse, ConfRecognition,`n
	{
		res := res . "MG_" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfNavi,`n
	{
		res := res . "MG_" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfAdNavi,`n
	{
		res := res . "MG_" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfTrail,`n
	{
		res := res . "MG_" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfLogs,`n
	{
		res := res . "MG_" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, ConfOthers,`n
	{
		res := res . "MG_" . A_LoopField . "=" . Config_%A_LoopField% . "`n"
	}
	Loop, Parse, MG_BtnNames, _
	{
		if (Config_ExNaviFG_%A_LoopField% != "") {
			res := res . "MG_ExNaviFG_" . A_LoopField . "=" . Config_ExNaviFG_%A_LoopField% . "`n"
		}
	}
	res .= "MG_ActvtExclud := ["
	Loop, % MG_ActvtExclud.MaxIndex()
	{
		res .= (A_Index>1) ? "`n`t`t`t`t,  " : ""
		res .= "[""" MG_ActvtExclud[A_Index][1] """, """ MG_ActvtExclud[A_Index][2] """, """ MG_ActvtExclud[A_Index][3] """]"
	}
	res .= "]`n"
	return res
}

;-------------------------------------------------------------------------------
; Make Target Judgment Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetToAhk(idx)
{
	local res:=0, invert, method, szType, szNot, idxInc
		, delim := Target_%idx%_IsAnd ? " && " : " || "
	Loop, % Target_%idx%_Count
	{
		szType := Target_%idx%_%A_Index%_Type
		GetMatchRule(szType, invert, method)
		szNot := invert ? "!" : ""
		szType := RegExReplace(szType, "_.+$")
		if (szType = "Custom") {
			Join(res, szNot . "(" . Target_%idx%_%A_Index%_Value . ")", delim)
		}
		else if (szType = "Include") {
			idxInc := TargetIndexOf(Target_%idx%_%A_Index%_Value)
			if (Target_%idxInc%_Parent!=idx || Target_%idxInc%_NotInh) {
				Join(res, szNot . "(" . GetTargetFuncName(idxInc) . ")", delim)
			}
		}
		else if (method == 1) {
			Join(res, szNot . "(MG_" . szType . "=""" . Target_%idx%_%A_Index%_Value . """)", delim)
		}
		else {
			Join(res, szNot . "(MG_StrComp(MG_" . szType . ", """ . Target_%idx%_%A_Index%_Value . """, " . method . "))", delim)
		}
	}
	if(!res){
		res := GetChildTargetNum(idx) ? 1 : 0
	}
	if (Target_%idx%_Parent && !Target_%idx%_NotInh) {
		res := GetTargetFuncName(Target_%idx%_Parent) " && (" res ")"
	}
	res := GetTargetFuncName(idx) . "{`n	global`n	return (" . res . ")`n}`n"
	return res
}

;-------------------------------------------------------------------------------
; Make Gesture Subroutine Strings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
GestureToAhk(idx)
{
	global
	if (!Gesture_%idx%_Patterns) {
		return ""
	}
	local szSubG:="", szSubA:="", szContG:="", szContA:="", szAct:="", szLabelG:="", szLabelA:=""
	Loop, Parse, Gesture_%idx%_Patterns, `n
	{
		if (MG_FindGesture(A_LoopField)==idx) {
			szLabelG .= "MG_Gesture_" . A_LoopField . ":`n"
			szLabelA .= "MG_GetAction_" . A_LoopField . ":`n"
		}
	}
	if (!szLabelG) {
		return ""
	}
	Loop, % Gesture_%idx%_Count
	{
		szAct := MakeActionSummaryStr(Gesture_%idx%_%A_Index%_Action)
		szAct := RegExReplace(szAct, """", """""")
		local szTarget := Gesture_%idx%_%A_Index%_Target
		local idxTgt := TargetIndexOf(szTarget)
		if (szTarget == MC_DefTargetName) {
			szContG := ReplaceCR(Gesture_%idx%_%A_Index%_Action, 2)
			szContA := "MG_ActionStr := """ . szAct . """"
		}
		else if (szSubG) {
			szSubG := szSubG  . "else if(" . GetTargetFuncName(idxTgt) . "){`n		" . ReplaceCR(Gesture_%idx%_%A_Index%_Action, 2) . "`n	}"
			szSubA := szSubA . "else if(" . GetTargetFuncName(idxTgt) . "){`n		MG_ActionStr := """ . szAct . """`n	}"
		}
		else {
			szSubG := "if(" . GetTargetFuncName(idxTgt) . "){`n		" . ReplaceCR(Gesture_%idx%_%A_Index%_Action, 2) . "`n	}"
			szSubA := "if(" . GetTargetFuncName(idxTgt) . "){`n		MG_ActionStr := """ . szAct . """`n	}"
		}
	}
	if (szSubG)
	{
		if (!szContG) {
			szContG := "MG_Cancel()"
			szContA := "MG_ActionStr := """""
		}
		szSubG = %szLabelG%	%szSubG%else{`n		%szContG%`n	}`n
		szSubA = %szLabelA%	%szSubA%else{`n		%szContA%`n	}`n
	}
	else
	{
		szContG := RegExReplace(szContG, "\n\t", "`n")
		szSubG = %szLabelG%	%szContG%`n
		szSubA = %szLabelA%	%szContA%`n
	}
	szSubG = %szSubG%return`n`n%szSubA%return`n
	return szSubG
}

;-------------------------------------------------------------------------------
; Get name of the target discriminant function
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetTargetFuncName(idx)
{
	return "MG_Is" . ((idx==1) ? "Disable" : "Target" . idx-1) . "()"
}

;-------------------------------------------------------------------------------
; Import from Clipboard
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ImportFromClipboard:
	ImportFromClipboard()
return
ImportFromClipboard(szConfig="")
{
	local bTip:=false, szIniData, tstart, gstart, tpos, gpos, idx, shift, num, name, full, alt, cnt
	if (!szConfig) {
		szConfig := Clipboard
		bTip := true
	}
	szIniData := RegExReplace(szConfig, "(<MG_TAB>|【TAB】)", "`t")
	if (InStr(szConfig, "【TAB】")) {
		szIniData := RegExReplace(szIniData, "(?<!\t)\t", "<MG_CR>")
	}
	tstart := Target_Count + 1
	gstart := Gesture_Count + 1
	tpos := Target_Editing
	gpos := Gesture_Editing
	MG_LoadIni(szIniData, tpos, gpos, bChild)
	if (tpos || gpos)
	{
		if (tpos)
		{
			;-------------------------------------------------------------------
			; Check duplicate target name
			name := Target_%Target_Count%_Name
			full := alt := MakeTargetFullName(Target_Count)
			cnt := 1
			while (TargetIndexOf(alt) != Target_Count) {
				cnt++
				alt := full " (" cnt ")"
				Target_%Target_Count%_Name := name " (" cnt ")"
			}
			;-------------------------------------------------------------------
			; Move imported targets to current position
			if (bChild && tpos==1) {
				tpos := tstart
			}
			else {
				if (!bChild) {
					num := GetGroupTargetNum(tpos)
					tpos += num - 1
				}
				shift := tstart - tpos - 1
				if (shift > 0)
				{
					Loop, % Target_Count - tstart + 1
					{
						idx := tstart + A_Index - 1
						if (Target_%idx%_Parent >= tstart) {
							Target_%idx%_Parent -= shift
						}
						Loop, %shift%
						{
							TargetSwap(idx, idx-1)
							if (Target_%idx%_Level>1 && Target_%idx%_Parent>tpos) {
								Target_%idx%_Parent++
							}
							idx--
						}
					}
				}
				tpos++
			}
			ShowTargets()
			ShowTarget(tpos)
		}
		if (gpos)
		{
			;-------------------------------------------------------------------
			; Move imported gestures to current position
			shift := gstart - gpos - 1
			if (shift > 0)
			{
				Loop, % Gesture_Count - gstart + 1
				{
					idx := gstart + A_Index - 1
					Loop, %shift% {
						GestureSwap(idx, idx-1)
						idx--
					}
				}
			}
			gpos++
			ShowGestures()
			ShowGesture(gpos)
			ShowGesturePattern(gpos, 1)
		}
		;-----------------------------------------------------------------------
		ShowConfig()
		if (bTip) {
			TrayTip, MouseGestureL, %ME_LngTooltip002%, 1
			SetTimer, HideTrayTip, -3000
		}
	}
	ShowAssignedGestures(tpos, false)
	AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; Export Target to Clipboard
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
CopyTarget:
	CopyTarget()
return
CopyTarget(bClipboard=true)
{
	local nCh, szTarget:="", szBuf:="", szMsg
	if (ItemCanCopy("T", Target_Editing) = "Disable") {
		return
	}
	if (Target_Editing)
	{
		nCh := GetChildTargetNum(Target_Editing)
		Loop, % nCh+1 {
			Join(szTarget, TargetToIni(Target_Editing+A_Index-1))
		}
		szBuf := RegExReplace(szTarget,"\n","`r`n")
		if (bClipboard) {
			Clipboard := szBuf
			sBuf := RegExMatch(szBuf, "\[(.+?)\]", $)
			szMsg := RegExReplace(ME_LngTooltip001, "\[#REPLASE#\]", $1)
			TrayTip, MouseGestureL, %szMsg%, 1
			SetTimer, HideTrayTip, -3000
		}
	}
	return szBuf
}

;-------------------------------------------------------------------------------
; Export Gesture to Clipboard
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
CopyGesture:
	CopyGesture()
return
CopyGesture(bClipboard=true)
{
	local szBuf:="", szMsg
	if (Gesture_Editing)
	{
		szBuf := RegExReplace(RegExReplace(GestureToIni(Gesture_Editing),"\t","<MG_TAB>"),"\n","`r`n")
		if (bClipboard) {
			Clipboard := szBuf
			sBuf := RegExMatch(szBuf, "\[(.+?)\]", $)
			szMsg := RegExReplace(ME_LngTooltip001, "\[#REPLASE#\]", $1)
			TrayTip, MouseGestureL, %szMsg%, 1
			SetTimer, HideTrayTip, -3000
		}
	}
	return szBuf
}

;-------------------------------------------------------------------------------
; Hide Tray Tip
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
HideTrayTip:
	TrayTip
return



#NoEnv
#Singleinstance force
;#NoTrayIcon
