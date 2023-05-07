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
