Goto,MG_LT_End

MG_LT_Enable:
	Hotkey,*WheelLeft,MG_LT_DownHotkey,On
	Hotkey,*WheelLeft up,MG_LT_UpHotkey,On
	MG_LT_Enabled := 1
return

MG_LT_Disable:
	Hotkey,*WheelLeft,MG_LT_DownHotkey,Off
	Hotkey,*WheelLeft up,MG_LT_UpHotkey,Off
	MG_LT_Enabled := 0
return

MG_LT_DownHotkey:
	MG_TriggerDown("LT")
return

MG_LT_UpHotkey:
	MG_TriggerUp("LT")
return

MG_LT_Down:
	MG_SendButton("LT", "WheelLeft", "Down")
return

MG_LT_Up:
	MG_SendButton("LT", "WheelLeft", "Up")
return

MG_LT_Check:
	MG_CheckButton("LT", "WheelLeft")
return

MG_LT_End:
