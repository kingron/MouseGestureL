Goto,MG_RT_End

MG_RT_Enable:
	Hotkey,*WheelRight,MG_RT_DownHotkey,On
	Hotkey,*WheelRight up,MG_RT_UpHotkey,On
	MG_RT_Enabled := 1
return

MG_RT_Disable:
	Hotkey,*WheelRight,MG_RT_DownHotkey,Off
	Hotkey,*WheelRight up,MG_RT_UpHotkey,Off
	MG_RT_Enabled := 0
return

MG_RT_DownHotkey:
	MG_TriggerDown("RT")
return

MG_RT_UpHotkey:
	MG_TriggerUp("RT")
return

MG_RT_Down:
	MG_SendButton("RT", "WheelRight", "Down")
return

MG_RT_Up:
	MG_SendButton("RT", "WheelRight", "Up")
return

MG_RT_Check:
	MG_CheckButton("RT", "WheelRight")
return

MG_RT_End:
