Goto,MG_X2B_End

MG_X2B_Enable:
	Hotkey,*XButton2,MG_X2B_DownHotkey,On
	Hotkey,*XButton2 up,MG_X2B_UpHotkey,On
	MG_X2B_Enabled := 1
return

MG_X2B_Disable:
	Hotkey,*XButton2,MG_X2B_DownHotkey,Off
	Hotkey,*XButton2 up,MG_X2B_UpHotkey,Off
	MG_X2B_Enabled := 0
return

MG_X2B_DownHotkey:
	MG_TriggerDown("X2B")
return

MG_X2B_UpHotkey:
	MG_TriggerUp("X2B")
return

MG_X2B_Down:
	if (!MG_DisableDefX2B) {
		MG_SendButton("X2B", "XButton2", "Down")
	}
return

MG_X2B_Up:
	if (!MG_DisableDefX2B) {
		MG_SendButton("X2B", "XButton2", "Up")
	}
return

MG_X2B_Check:
	MG_CheckButton("X2B", "XButton2")
return

MG_X2B_End:
