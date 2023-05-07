Goto,MG_X1B_End

MG_X1B_Enable:
	Hotkey,*XButton1,MG_X1B_DownHotkey,On
	Hotkey,*XButton1 up,MG_X1B_UpHotkey,On
	MG_X1B_Enabled := 1
return

MG_X1B_Disable:
	Hotkey,*XButton1,MG_X1B_DownHotkey,Off
	Hotkey,*XButton1 up,MG_X1B_UpHotkey,Off
	MG_X1B_Enabled := 0
return

MG_X1B_DownHotkey:
	MG_TriggerDown("X1B")
return

MG_X1B_UpHotkey:
	MG_TriggerUp("X1B")
return

MG_X1B_Down:
	if (!MG_DisableDefX1B) {
		MG_SendButton("X1B", "XButton1", "Down")
	}
return

MG_X1B_Up:
	if (!MG_DisableDefX1B) {
		MG_SendButton("X1B", "XButton1", "Up")
	}
return

MG_X1B_Check:
	MG_CheckButton("X1B", "XButton1")
return

MG_X1B_End:
