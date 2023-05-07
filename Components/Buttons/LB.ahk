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
