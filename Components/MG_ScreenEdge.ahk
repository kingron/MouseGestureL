;===============================================================================
;
;		MouseGestureL.ahk - Screen Edge Recognition Module
;
;														Created by lukewarm
;														Modified by Pyonkichi
;===============================================================================
MG_Edge_Monitor_Set()

Goto, MG_ScrenEdge_End

;-------------------------------------------------------------------------------
; Enable or Disable Screen Edge Recognition Process
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Edge_Monitor_Set(on=1)
{
	global
	if (on)
	{
		MG_CornerX := (MG_CornerX > 0) ? MG_CornerX : 1
		MG_CornerY := (MG_CornerY > 0) ? MG_CornerY : 1
		SetTimer, MG_Edge_Monitor, %MG_EdgeInterval%
	}
	else
	{
		SetTimer, MG_Edge_Monitor, OFF
	}
}


;-------------------------------------------------------------------------------
; Screen Edge Recognition Process
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Edge_Monitor:
	MG_Edge_Monitor()
return
MG_Edge_Monitor()
{
	local ptX, ptY, scrL, scrT, scrR, scrB, scrW, scrH
	CoordMode, Mouse, Screen
	MouseGetPos, ptX, ptY
	;...........................................................................
	; Get screen rectangule
	if (MG_EdgeIndiv)
	{
		MG_GetMonitorRect(ptX, ptY, scrL, scrT, scrR, scrB)
		scrW := scrR - scrL
		scrH := scrB - scrT
		scrR--, scrB--
	}
	else
	{
		SysGet, scrL, 76
		SysGet, scrT, 77
		SysGet, scrW, 78
		SysGet, scrH, 79
		scrR := scrL + scrW - 1
		scrB := scrT + scrH - 1
	}
	MG_Edge_State := ""
	;...........................................................................
	; Left side
	if (ptX == scrL)
	{
		if (MG_EdgeIndiv && MG_MonitorExists(ptX-1, ptY)) {
			; Another monitor exists in left side
		}
		else if (MG_Edge_CLT_Enabled && ptY>=scrT && ptY<(scrT+MG_CornerY))
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrL, scrT-1)) {
				MG_Edge_State=CLT
			}
		}
		else if (MG_Edge_CLB_Enabled && ptY>(scrB-MG_CornerY) && ptY<=scrB)
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrL, scrB+1)) {
				MG_Edge_State=CLB
			}
		}
		else if (MG_Edge_EL1_Enabled && ptY<(scrT+scrH/3)) {
			MG_Edge_State=EL1
		}
		else if (MG_Edge_EL2_Enabled && ptY>=(scrT+scrH/3) && ptY<(scrT+scrH*2/3)) {
			MG_Edge_State=EL2
		}
		else if (MG_Edge_EL3_Enabled && ptY>=(scrT+scrH*2/3)) {
			MG_Edge_State=EL3
		}
		else if (MG_Edge_ELA_Enabled && ptY<(scrT+scrH/2)) {
			MG_Edge_State=ELA
		}
		else if (MG_Edge_ELB_Enabled && ptY>=(scrT+scrH/2)) {
			MG_Edge_State=ELB
		}
		else if (MG_Edge_EL_Enabled) {
			MG_Edge_State=EL
		}
	}
	;...........................................................................
	; Right side
	else if (ptX == scrR)
	{
		if (MG_EdgeIndiv && MG_MonitorExists(ptX+1, ptY)) {
			; Another monitor exists in right side
		}
		else if (MG_Edge_CRT_Enabled && ptY>=scrT && ptY<(scrT+MG_CornerY))
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrR, scrT-1)) {
				MG_Edge_State=CRT
			}
		}
		else if (MG_Edge_CRB_Enabled && ptY>(scrB-MG_CornerY) && ptY<=scrB)
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrR, scrB+1)) {
				MG_Edge_State=CRB
			}
		}
		else if (MG_Edge_ER1_Enabled && ptY<(scrT+scrH/3)) {
			MG_Edge_State=ER1
		}
		else if (MG_Edge_ER2_Enabled && ptY>=(scrT+scrH/3) && ptY<(scrT+scrH*2/3)) {
			MG_Edge_State=ER2
		}
		else if (MG_Edge_ER3_Enabled && ptY>=(scrT+scrH*2/3)) {
			MG_Edge_State=ER3
		}
		else if (MG_Edge_ERA_Enabled && ptY<(scrT+scrH/2)) {
			MG_Edge_State=ERA
		}
		else if (MG_Edge_ERB_Enabled && ptY>=(scrT+scrH/2)) {
			MG_Edge_State=ERB
		}
		else if (MG_Edge_ER_Enabled) {
			MG_Edge_State=ER
		}
	}
	;...........................................................................
	; Upper side
	else if (ptY == scrT)
	{
		if (MG_EdgeIndiv && MG_MonitorExists(ptX, ptY-1)) {
			; Another monitor exists in upper side
		}
		else if (MG_Edge_CLT_Enabled && ptX>=scrL && ptX<(scrL+MG_CornerX))
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrL-1, scrT)) {
				MG_Edge_State=CLT
			}
		}
		else if (MG_Edge_CRT_Enabled && ptX>(scrR-MG_CornerX) && ptX<=scrR)
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrR+1, scrT)) {
				MG_Edge_State=CRT
			}
		}
		else if (MG_Edge_ET1_Enabled && ptX<(scrL+scrW/3)) {
			MG_Edge_State=ET1
		}
		else if (MG_Edge_ET2_Enabled && ptX>=(scrL+scrW/3) && ptX<(scrL+scrW*2/3)) {
			MG_Edge_State=ET2
		}
		else if (MG_Edge_ET3_Enabled && ptX>=(scrL+scrW*2/3)) {
			MG_Edge_State=ET3
		}
		else if (MG_Edge_ETA_Enabled && ptX<(scrL+scrW/2)) {
			MG_Edge_State=ETA
		}
		else if (MG_Edge_ETB_Enabled && ptX>=(scrL+scrW/2)) {
			MG_Edge_State=ETB
		}
		else if (MG_Edge_ET_Enabled) {
			MG_Edge_State=ET
		}
	}
	;...........................................................................
	; Lower side
	else if (ptY == scrB)
	{
		if (MG_EdgeIndiv && MG_MonitorExists(ptX, ptY+1)) {
			; Another monitor exists in lower side
		}
		else if (MG_Edge_CLB_Enabled && ptX>=scrL && ptX<(scrL+MG_CornerX))
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrL-1, scrB)) {
				MG_Edge_State=CLB
			}
		}
		else if (MG_Edge_CRB_Enabled && ptX>(scrR-MG_CornerX) && ptX<=scrR)
		{
			if (!MG_EdgeIndiv || !MG_MonitorExists(scrR+1, scrB)) {
				MG_Edge_State=CRB
			}
		}
		else if (MG_Edge_EB1_Enabled && ptX<(scrL+scrW/3)) {
			MG_Edge_State=EB1
		}
		else if (MG_Edge_EB2_Enabled && ptX>=(scrL+scrW/3) && ptX<(scrL+scrW*2/3)) {
			MG_Edge_State=EB2
		}
		else if (MG_Edge_EB3_Enabled && ptX>=(scrL+scrW*2/3)) {
			MG_Edge_State=EB3
		}
		else if (MG_Edge_EBA_Enabled && ptX<(scrL+scrW/2)) {
			MG_Edge_State=EBA
		}
		else if (MG_Edge_EBB_Enabled && ptX>=(scrL+scrW/2)) {
			MG_Edge_State=EBB
		}
		else if (MG_Edge_EB_Enabled) {
			MG_Edge_State=EB
		}
	}
	;...........................................................................
	; Not Edge
	else
	{
		if (MG_Edge_Active)
		{
			MG_Edge_State := MG_Edge_Active
			MG_Edge_Active := ""
			MG_TriggerUp(MG_Edge_State)
		}
		MG_Edge_State := ""
	}
	;...........................................................................
	; Process trigger-down actions
	if (!MG_Edge_Active && MG_Edge_State && MG_Edge_State!=MG_Edge_Active)
	{
		MG_Edge_Active := MG_Edge_State
		SetTimer, MG_Edge_TriggerTimer, -1
	}
}

;-------------------------------------------------------------------------------
; Check wheter monitor exists in specified coordinates
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_MonitorExists(ptX, ptY)
{
	pt := (ptY<<32) | (ptX & 0xffffffff)
	return DllCall("user32.dll\MonitorFromPoint", "UInt64",pt, "UInt",0, "Ptr")
}

;-------------------------------------------------------------------------------
; Process trigger-down actions
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Edge_TriggerTimer:
	MG_TriggerDown(MG_Edge_Active)
return


MG_ScrenEdge_End:
