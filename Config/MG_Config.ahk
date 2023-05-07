MG_IniFileVersion=1.34
MG_8Dir=1
MG_ActiveAsTarget=0
MG_Interval=30
MG_PrvntCtxtMenu=0
MG_Threshold=60
MG_LongThresholdX=800
MG_LongThresholdY=600
MG_LongThreshold=700
MG_TimeoutThreshold=12
MG_Timeout=600
MG_DGInterval=0
MG_TmReleaseTrigger=3
MG_ORangeDefault=3
MG_ORangeA=3
MG_ORangeB=3
MG_EdgeInterval=20
MG_EdgeIndiv=0
MG_CornerX=1
MG_CornerY=1
MG_DisableDefMB=0
MG_DisableDefX1B=0
MG_DisableDefX2B=0
MG_UseNavi=0
MG_UseExNavi=3
MG_NaviInterval=10
MG_NaviPersist=0
MG_ExNaviTransBG=1
MG_ExNaviFG=000000
MG_ExNaviBG=FFFFFF
MG_ExNaviTranspcy=255
MG_ExNaviSize=24
MG_ExNaviSpacing=2
MG_ExNaviPadding=4
MG_ExNaviMargin=8
MG_AdNaviFG=FFFFFF
MG_AdNaviNI=7F7F7F
MG_AdNaviBG=000000
MG_AdNaviTranspcy=220
MG_AdNaviSize=12
MG_AdNaviFont=Meiryo
MG_AdNaviPosition=0
MG_AdNaviPaddingL=6
MG_AdNaviPaddingR=6
MG_AdNaviPaddingT=3
MG_AdNaviPaddingB=3
MG_AdNaviRound=1
MG_AdNaviMargin=14
MG_AdNaviSpaceX=2
MG_AdNaviSpaceY=2
MG_AdNaviOnClick=0
MG_ShowTrail=1
MG_DrawTrailWnd=0
MG_TrailColor=00FF00
MG_TrailTranspcy=200
MG_TrailWidth=5
MG_TrailStartMove=3
MG_TrailInterval=5
MG_ShowLogs=0
MG_LogPosition=4
MG_LogPosX=0
MG_LogPosY=0
MG_LogMax=20
MG_LogSizeW=400
MG_LogInterval=500
MG_LogFG=FFFFFF
MG_LogBG=000000
MG_LogTranspcy=100
MG_LogFontSize=10
MG_LogFont=MS UI Gothic
MG_EditCommand=
MG_HotkeyEnable=
MG_HotkeyNavi=
MG_HotkeyReload=
MG_ScriptEditor=
MG_TraySubmenu=0
MG_AdjustDlg=0
MG_DlgHeightLimit=800
MG_FoldTarget=0
MG_ActvtExclud := []
MG_MaxLength=7
MG_Triggers=RB_MB
MG_SubTriggers=LB_WU_WD


Goto,MG_RB_End

MG_RB_Enable:
	Hotkey,*RButton,MG_RB_DownHotkey,On
	Hotkey,*RButton up,MG_RB_UpHotkey,On
	MG_RB_Enabled := 1
return

MG_RB_Disable:
	Hotkey,*RButton,MG_RB_DownHotkey,Off
	Hotkey,*RButton up,MG_RB_UpHotkey,Off
	MG_RB_Enabled := 0
return

MG_RB_DownHotkey:
	MG_TriggerDown("RB")
return

MG_RB_UpHotkey:
	MG_TriggerUp("RB")
return

MG_RB_Down:
	MG_SendButton("RB", "RButton", "Down")
return

MG_RB_Up:
	MG_SendButton("RB", "RButton", "Up")
return

MG_RB_Check:
	MG_CheckButton("RB", "RButton")
return

MG_RB_End:


Goto,MG_MB_End

MG_MB_Enable:
	Hotkey,*MButton,MG_MB_DownHotkey,On
	Hotkey,*MButton up,MG_MB_UpHotkey,On
	MG_MB_Enabled := 1
return

MG_MB_Disable:
	Hotkey,*MButton,MG_MB_DownHotkey,Off
	Hotkey,*MButton up,MG_MB_UpHotkey,Off
	MG_MB_Enabled := 0
return

MG_MB_DownHotkey:
	MG_TriggerDown("MB")
return

MG_MB_UpHotkey:
	MG_TriggerUp("MB")
return

MG_MB_Down:
	if (!MG_DisableDefMB) {
		MG_SendButton("MB", "MButton", "Down")
	}
return

MG_MB_Up:
	if (!MG_DisableDefMB) {
		MG_SendButton("MB", "MButton", "Up")
	}
return

MG_MB_Check:
	MG_CheckButton("MB", "MButton")
return

MG_MB_End:


Goto,MG_LB_End

MG_LB_Enable:
	Hotkey,*LButton,MG_LB_DownHotkey,On
	Hotkey,*LButton up,MG_LB_UpHotkey,On
	MG_LB_Enabled := 1
return

MG_LB_Disable:
	Hotkey,*LButton,MG_LB_DownHotkey,Off
	Hotkey,*LButton up,MG_LB_UpHotkey,Off
	MG_LB_Enabled := 0
return

MG_LB_DownHotkey:
	MG_TriggerDown("LB")
return

MG_LB_UpHotkey:
	MG_TriggerUp("LB")
return

MG_LB_Down:
	MG_SendButton("LB", "LButton", "Down")
return

MG_LB_Up:
	MG_SendButton("LB", "LButton", "Up")
return

MG_LB_Check:
	MG_CheckButton("LB", "LButton")
return

MG_LB_End:


Goto,MG_WU_End

MG_WU_Enable:
	Hotkey,*WheelUp,MG_WU_Hotkey,On
	MG_WU_Enabled := 1
return

MG_WU_Disable:
	Hotkey,*WheelUp,MG_WU_Hotkey,Off
	MG_WU_Enabled := 0
return

MG_WU_Hotkey:
	MG_ButtonPress("WU")
return

MG_WU_Press:
	MG_SendButton("WU", "WheelUp")
return

MG_WU_End:


Goto,MG_WD_End

MG_WD_Enable:
	Hotkey,*WheelDown,MG_WD_Hotkey,On
	MG_WD_Enabled := 1
return

MG_WD_Disable:
	Hotkey,*WheelDown,MG_WD_Hotkey,Off
	MG_WD_Enabled := 0
return

MG_WD_Hotkey:
	MG_ButtonPress("WD")
return

MG_WD_Press:
	MG_SendButton("WD", "WheelDown")
return

MG_WD_End:


Goto,MG_Config_End


MG_IsDisable(){
	global
	return ((MG_StrComp(MG_Title, "GIMP", 4)) || (MG_Exe="vmplayer.exe") || (MG_StrComp(MG_Exe, "teamviewer.exe", 2)) || (MG_Exe="unity.exe") || (MG_Exe="xnview.exe") || (MG_StrComp(MG_Exe, "mstsc.exe", 2)) || (MG_WClass="ApplicationFrameWindow") || (MG_Exe="dstermserv.exe"))
}

MG_IsTarget1(){
	global
	return ((MG_HitTest()=="Caption"))
}

MG_IsTarget2(){
	global
	return ((MG_Exe="msedge.exe"))
}

MG_IsTarget3(){
	global
	return ((MG_Exe="idea64.exe") || (MG_Exe="code.exe"))
}

MG_IsTarget4(){
	global
	return ((MG_Exe="winword.exe"))
}


MG_Gesture_MB_U_:
	;Generate Key Stroke
	Send, {PgUp}
return

MG_GetAction_MB_U_:
	MG_ActionStr := "Generate Key Stroke"
return

MG_Gesture_RB_:
	PostMessage, 0x001F, 0, 0
	PostMessage, 0x001F, 0, 0, , ahk_id %MG_HCTL%
	IfWinNotActive
	{
		WinActivate
	}
return

MG_GetAction_RB_:
	MG_ActionStr := "PostMessage, 0x001F, 0, 0"
return

MG_Gesture_RB_2_:
	;Jump to Bottom
	Send,^{End}
return

MG_GetAction_RB_2_:
	MG_ActionStr := "Jump to Bottom"
return

MG_Gesture_RB_28_:
	;Generate Key Stroke
	Send, ^w
return

MG_GetAction_RB_28_:
	MG_ActionStr := "Generate Key Stroke"
return

MG_Gesture_RB_4_:
	;Back
	Send,!{Left}
return

MG_GetAction_RB_4_:
	MG_ActionStr := "Back"
return

MG_Gesture_RB_26_:
	;Generate Key Stroke
	Send, +^l
return

MG_GetAction_RB_26_:
	MG_ActionStr := "Generate Key Stroke"
return

MG_Gesture_RB_LB__:
	if(MG_IsTarget2()){
		;Generate Key Stroke
		Send, ^w
	}else if(MG_IsTarget3()){
		;Generate Key Stroke
		Send, ^{F4}
	}else{
		;Close Window
		WinClose
	}
return

MG_GetAction_RB_LB__:
	if(MG_IsTarget2()){
		MG_ActionStr := "Generate Key Stroke"
	}else if(MG_IsTarget3()){
		MG_ActionStr := "Generate Key Stroke"
	}else{
		MG_ActionStr := "Close Window"
	}
return

MG_Gesture_RB_9_:
	;Maximize Window
	WinMaximize
return

MG_GetAction_RB_9_:
	MG_ActionStr := "Maximize Window"
return

MG_Gesture_RB_6_:
	;Forward
	Send,!{Right}
return

MG_GetAction_RB_6_:
	MG_ActionStr := "Forward"
return

MG_Gesture_RB_62_:
	;Minimize Window
	WinMinimize
return

MG_GetAction_RB_62_:
	MG_ActionStr := "Minimize Window"
return

MG_Gesture_RB_1_:
	;Minimize Window
	WinMinimize
return

MG_GetAction_RB_1_:
	MG_ActionStr := "Minimize Window"
return

MG_Gesture_RB_68_:
	;Maximize Window
	WinMaximize
return

MG_GetAction_RB_68_:
	MG_ActionStr := "Maximize Window"
return

MG_Gesture_RB_8_:
	;Jump to Top
	Send,^{Home}
return

MG_GetAction_RB_8_:
	MG_ActionStr := "Jump to Top"
return

MG_Gesture_RB_82_:
	;Generate Key Stroke
	Send, {F5}
return

MG_GetAction_RB_82_:
	MG_ActionStr := "Generate Key Stroke"
return

MG_Gesture_RB_WD_:
	if(MG_IsTarget2()){
		;Generate Key Stroke
		Send, ^{Tab}
	}else{
		;Win+Tab
		;Send, !{Tab}
		
		Send, {LWinDOWN}{Tab}
		SetTimer, Send_LWinUP, 800
		
	}
return

MG_GetAction_RB_WD_:
	if(MG_IsTarget2()){
		MG_ActionStr := "Generate Key Stroke"
	}else{
		MG_ActionStr := "Win+Tab"
	}
return

MG_Gesture_RB_WU_:
	if(MG_IsTarget2()){
		;Generate Key Stroke
		Send, +^{Tab}
	}else{
		;Win+Shift+Tab
		;Send, +!{Tab}
		
		Send, {LWinDOWN}{Shift}{Tab}
		SetTimer, Send_LWinUP, 800
		
		Send_LWinUP:
		KeyWait, MButton, R 
		SetTimer, Send_LWinUP, off
		Send, {LWinUP}
		return
		
	}
return

MG_GetAction_RB_WU_:
	if(MG_IsTarget2()){
		MG_ActionStr := "Generate Key Stroke"
	}else{
		MG_ActionStr := "Win+Shift+Tab"
	}
return

MG_Gesture_RB_616_:
	if(MG_IsTarget2()){
		;Generate Key Stroke
		Send, ^#T
	}else{
		;Generate Key Stroke
		Send, ^z
	}
return

MG_GetAction_RB_616_:
	if(MG_IsTarget2()){
		MG_ActionStr := "Generate Key Stroke"
	}else{
		MG_ActionStr := "Generate Key Stroke"
	}
return


MG_Config_end: