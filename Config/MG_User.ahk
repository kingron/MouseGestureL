; ================== By Kingron =======================
; Win = #	Ctrl = ^	Alt = !	Shift = +
global ontop := true
global cursorPID := 0
global osdPID := 0
RegRead DisabledHotkeys, HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced, DisabledHotkeys
If (DisabledHotkeys = "") {
	Run reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DisabledHotkeys /d QWTUSFGHKCVM
	MsgBox 关闭了系统默认热键设置(Win+Q/W/T/U/S/F/G/H/K/C/V/M)。`n请注销或者重启系统以便生效
}
goto End

; 给Windows开始菜单添加程序别名
^#a::
	Gui, Add, Text, x10 y5 w200 h20, 请输入别名，例如 xyz
	Gui, Add, Edit, x10 y30 w300 h20 vAlias, 
	Gui, Add, Text, x10 y55 w200 h20, 请输入可执行文件名和路径
	Gui, Add, Edit, x10 y80 w300 h20 vExe, 
	Gui, Add, Button, x10 y110 w60 h30 gAliasOk Default, 确定
	Gui, Add, Button, x80 y110 w60 h30 gCancel, 取消
	Gui, Show, w320 h150, 添加新命令
	return

	AliasOk:
		Gui, Submit, NoHide
		if Alias =
		{
			MsgBox, 48, 错误, 请输入别名
			Return
		}
		if Exe =
		{
			MsgBox, 48, 错误, 请输入可执行文件名和路径
			Return
		}
		Run cmd /c reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%Alias%.exe" /ve /d "%Exe%" /f
		Gui, Destroy
	return

#a::Run autoruns.exe
#b::Run "https://start.duckduckgo.com"
#c::Run "cmd.exe"
; #d:: 最小化桌面
; Ctrl+Win+D，重复当前行
#^d::
	SendInput {End}+{Home}
	SendInput ^c
	SendInput {End}{Enter}
	SendInput ^v
	return
; #e:: 资源管理器
#f::Run hfs.exe
#g::Run gost -C \Tools\gost.json
#h:: 
	Process, Exist, heidisql.exe
	if (ErrorLevel == 0) {
		Run HeidiSQL\heidisql.exe
	}
	return
#^h:: Run, HashCalc.ahk
#i::Run "compmgmt.msc"
#j::Run "C:\Program Files\Git\git-bash.exe"
#k::Run "putty.exe" @k3
#^k::
	if (osdPID = 0) {
		Run, KeypressOSD.ahk,,,osdPID
	} else {
		Process, Close, %osdPID%
		osdPID := 0
	}
	return
; #l:: 锁定计算机
; #m:: 最小化所有
#m::Run "SumatraPDF-3.4.6-64.exe"
#n::Run Notepad++
#o::Run wifi.bat
; #p:: 显示器
#q::
	Process, Exist, msedge.exe
	if (ErrorLevel == 0) {
		Run "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
		Sleep 600
	}
	WinGet, vWinList, List, ahk_class Chrome_WidgetWin_1
	Loop, %vWinList% {
		; 判断是否是最小化了，如果是，还原窗口
		WinGet, MinMax, MinMax, % "ahk_id" vWinList%A_Index%
		If (MinMax == -1) {
			WinRestore, % "ahk_id" vWinList%A_Index%
		}

		WinActivate,% "ahk_id" vWinList%A_Index%
	}
	return
#+q::
	def := Clipboard
	InputBox, word, 单词, `n请输入要翻译的单词,,300,146,,,,,%def%
	if ErrorLevel
		return

	Run, https://fanyi.baidu.com/#en/zh/%word%
; Run, "C:\Windows\System32\WScript.exe" "D:\tools\gt.js" "%word%"

;  shell := ComObjCreate("WScript.Shell")
;  exec := shell.Exec("CScript.exe //Nologo D:\tools\gt.js """ . word . """")
;  text := exec.StdOut.ReadAll()
  
;  Gui Destroy
;  Gui Add, Edit, w800 h600, %text%
;  Gui Add, Button, Default, 确定
;  Gui Show, , %word% 翻译结果 (按ESC关闭)
;  GuiControl Focus, okButton
	return
#+a::
	WinGet, vWinList, List, ahk_class ApplicationFrameWindow
	first := true
	Loop, %vWinList% {
		; 判断是否是最小化了，如果是，还原窗口
		WinGet, MinMax, MinMax, % "ahk_id" vWinList%A_Index%
		If (MinMax == -1) {
			WinRestore, % "ahk_id" vWinList%A_Index%
		}

		if (ontop) {
			if (first) {
				WinActivate,% "ahk_id" vWinList%A_Index%
				first := false
			} 
			WinSet, TopMost,, % "ahk_id" vWinList%A_Index%
		} else {
			WinSet, Bottom,, % "ahk_id" vWinList%A_Index%
		}
	}
	ontop := !ontop
	return
; #r:: 运行
; #s:: Everything
#t::WinSet,TopMost,,A
; #u:: 辅助工具
; #v:: 剪切板
; Ctrl+Shift+V，粘贴为纯文本
^+v::
	Clip0 = %ClipBoardAll%
	ClipBoard = %ClipBoard%
	Send ^v
	Sleep 100
	ClipBoard = %Clip0%
	VarSetCapacity(Clip0, 0)
	return
; 定义快捷键Ctrl+Alt+V，粘贴 HTML 原始代码
^!v::
	Clip0 = %ClipBoardAll%
	ClipBoard := ExtractHtmlData()
	Send ^v
	Sleep 100
	ClipBoard = %Clip0%
	VarSetCapacity(Clip0, 0)
	Return
#!v::Run rundll32.exe sysdm.cpl`,EditEnvironmentVariables
#w::WinClose,A
; #x:: 移动中心
#y:: MouseClick, right
#z::Run procexp.exe
#^z::
	Gui, New, +LastFound +Resize +ToolWindow +MinSize200x150 +AlwaysOnTop
	Gui, Font, s16
    Gui, Add, Text, x10 y10 w580 h20 left, 请输入表达式：
    Gui, Add, Edit, x10 y40 w490 h30 Resize r1 vInputText, % left(Clipboard, "`n")
    Gui, Add, Button, x510 y40 w80 h30 vCalcButton gCalcOK Default, 计算
    Gui, Add, Edit, x10 y80 w580 h390 vResultText Resize,
    Gui, Show, w600 h480, 计算器
	WinSet, Transparent, 240
	return
	
	CalcOK:
		GuiControlGet, InputText, , InputText
		if (InputText != "") return

		GuiControlGet, CurrentText, , ResultText
		FormatTime, CurrentDateTime,, [HH:mm:ss]
		try { 
			#Include %A_ScriptDir%\ActiveScript.ahk
			vb := new ActiveScript("VBScript")
			result := vb.Eval(InputText)
			GuiControl, Focus, InputText
			Sleep 10
			Send ^a
			vb := ""
		} catch e {
			result := e.Message
		}
		GuiControl, , ResultText, % CurrentDateTime " " InputText " => " result "`r`n" CurrentText
		return
/*	
	InputBox, express, 表达式计算, `n请输入表达式如数学公式,,400,150,,,,, %Clipboard%
	try { 
	Tempfile := A_Temp . "\mgu_temp.vbs"
		s := Format("WScript.echo Eval(""{}"")", express)
		FileAppend % s, % Tempfile
		cmd := "cscript //nologo " Tempfile
		result := Exec(cmd)
		FileDelete, %Tempfile%

		#Include %A_ScriptDir%\ActiveScript.ahk
		vb := new ActiveScript("VBScript")
		result := express . " =>`n" . vb.Eval(express)
	} catch e {
		result := % "错误: " e.Message "`n行: " e.Line 
	}
	showMessage("结果", result)
	return
*/
#`::WinMinimize,A
; 等价于按数字小键盘 *
#\::SendInput, {NumpadMult}
; 关闭显示器
#,::SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER
; 重启XPS 13z的蓝牙设备，其中的 *PID_3004* 为蓝牙硬件的ID参数
#.::SendInput, ^{NumpadAdd}
#/::Run "HxD.exe"
#'::Run, "C:\Program Files (x86)\WinSCP\WinSCP.exe"
; Win+; = 表情输入框

; Note: From now on whenever you run AutoHotkey directly, this script
; will be loaded.  So feel free to customize it to suit your needs.

; Please read the QUICK-START TUTORIAL near the top of the help file.
; It explains how to perform common automation tasks such as sending
; keystrokes and mouse clicks.  It also explains more about hotkeys.

;================ TransActive =====================
; Author: Programus
;
; Set Current active window Transparent. 
; HotKey: 
;	 Win-Alt-0: Switch transparent
;	 Win-Alt-↓: less transparent
;	 Win-Alt-↑: more transparent

#!UP:: SetTrans(4)
#!DOWN:: SetTrans(-4)

SetTrans(offset) {
	WinGet, trans, Transparent, A
	if (trans == "") {
		trans := 255
	}
	trans += offset
	if (trans <= 0) {
		trans = 0
	}
	if (trans >= 255) {
		trans := 255
		WinSet, Transparent, OFF, A
	} else {
		WinSet, Transparent, %trans%, A
	}
}

; 执行命令并返回输出内容
Exec(command) {
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec(command)
	err := exec.StdErr.ReadAll()
	return exec.StdOut.ReadAll() . right(err, ": ")
}

right(Str, Separator) {
	pos := InStr(Str, Separator)
	if (pos > 0) {
		return SubStr(Str, pos + StrLen(Separator))
	}
	return Str
}

left(Str, Separator) {
	pos := InStr(Str, Separator)
	if (pos > 0) {
		return SubStr(Str, 1, pos - 1)
	}
	return Str
}

; 获取剪贴板中 CF_HTML 格式数据
ExtractHtmlData() {
	static CF_HTML := DllCall("RegisterClipboardFormat", "Str", "HTML Format")
	DllCall("OpenClipboard", "Uint", 0)
	format := 0
	Loop {
		format := DllCall("EnumClipboardFormats", "Uint", format)
	} until format = CF_HTML || format = 0
	if (format != CF_HTML) {
		DllCall("CloseClipboard")
		return
	}
	hData := DllCall("GetClipboardData", "Uint", CF_HTML, "Ptr")
	pData := DllCall("GlobalLock", "Ptr", hData)
	html := StrGet(pData, "UTF-8")
	DllCall("GlobalUnlock", "Ptr", hData)
	DllCall("CloseClipboard")
	
	pos := InStr(html, "<html")
	if (pos > 1) {
		html := SubStr(html, pos)
	}
	return html
}

; 连续两次按左 Ctrl
~LControl::
	if (A_PriorHotkey == "~LControl" and A_TimeSincePriorHotkey < 200) {
		if (cursorPID == 0) {
			Run, cursorhighlight.ahk,,,cursorPID
		} else {
			Process, Close, %cursorPID%
			cursorPID := 0
		}
	}
	return

; 连续两次按 ESC 最小化当前窗口
~Esc::
	if (A_PriorHotkey = "~Esc" and A_TimeSincePriorHotkey < 200) {
		WinMinimize, A
	}
	return

~CapsLock::
	if (A_PriorHotkey = "~CapsLock" and A_TimeSincePriorHotkey < 200) {
		SendInput, {PgUp}
	}
	return

~LAlt::
	if (A_PriorHotkey = "~LAlt" and A_TimeSincePriorHotkey < 200) {
		SendInput, {PgDn}
	}
	return

; Win = #	Ctrl = ^	Alt = !	Shift = +	 

; 按Win+Shift + ↑↓ 设置窗口为屏幕上半部分和下半部分
#+UP:: MoveIt(8)
#+DOWN:: MoveIt(2)
#!^UP:: MoveIt(7)
#!^DOWN:: MoveIt(9)
#!^LEFT:: MoveIt(1)
#!^RIGHT::MoveIt(3)

; 按Ctrl + Win + 上下左右光标移动当前窗口
#^UP::
	WinGetPos, x, y, w, h, A
	nv := y - 30
	if nv < 0 
	nv := 0
	WinMove A,, %x%, %nv%
	return

#^DOWN::
	WinGetPos, x, y,,,A
	nv := y + 30
	if nv > A_ScreenHeight - 20
	nv := A_ScreenHeight - 20
	WinMove A,, %x%, %nv%
	return

#^LEFT::
	WinGetPos, x, y,,,A
	nv := x - 30
;	if nv < 0
;	nv := 0
	WinMove A,, %nv%, %y%
	return

#^RIGHT::
	WinGetPos, x, y,,,A
	nv := x + 30
	if nv > A_ScreenWidth 
	nv := A_ScreenWidth
	WinMove A,, %nv%, %y%
	return

; 按Ctrl + Shift + Win + 上下左右光标移动当前窗口
#+^UP::
	WinGetPos, x, y, w, h, A
	nv := y - 1
	if nv < 0
	nv := 0
	WinMove A,, %x%, %nv%
	return

#+^DOWN::
	WinGetPos, x, y,,,A
	nv := y + 1
	if nv > A_ScreenHeight - 20
	nv := A_ScreenHeight - 20
	WinMove A,, %x%, %nv%
	return

#+^LEFT::
	WinGetPos, x, y,,,A
	nv := x - 1
;	if nv < 0
;	nv := 0
	WinMove A,, %nv%, %y%
	return

#+^RIGHT::
	WinGetPos, x, y,,,A
	nv := x + 1
	if nv > A_ScreenWidth
	nv := A_ScreenWidth
	WinMove A,, %nv%, %y%
	return

; 屏幕取色，Win + Alt + C
#!c:: 
	; 显示取色信息，跟随鼠标移动显示
	Tooltip, , % "1"
	; 获取桌面工作区域矩形
	SysGet, WorkArea, MonitorWorkArea
	; MsgBox % "工作区域矩形: Left=" . WorkAreaLeft . ", Top=" . WorkAreaTop . ", Right=" . WorkAreaRight . ", Bottom=" . WorkAreaBottom

	Loop
	{
		; 监听鼠标移动
		CoordMode, Mouse, Screen
		CoordMode, Pixel, Screen
		CoordMode, ToolTip, Screen
		MouseGetPos, X, Y
		PixelGetColor, color, %X%, %Y%
		R := (color & 0x000000FF)
		G := (color & 0x0000FF00) >> 8
		B := (color & 0x00FF0000) >> 16
		rgb := Format("#{:x}{:x}{:x}", r, g, b)
		s := Format("({},{})颜色(Esc退出并复制):`nHTML - {}`nR={}, G={}, B={}", X, Y, rgb, R, G, B)

		ty := Y + 20
		if (ty > WorkAreaBottom - 60) {
			ty := WorkAreaBottom - 60
		}
		ToolTip, % s, % X + 20, % ty
		Sleep, 10
		if (GetKeyState("Escape", "P")) { ; ESC键退出
			ToolTip
			Clipboard := rgb
			break
		}
	}
	return

; 给QQ增加查找联系人的快捷键 Ctrl + F
#IfWinActive ahk_class TXGuiFoundation
^f::
	; 20，115
	Click 120, 115 
	return
#IfWinActive

; 资源管理器中，按 Ctrl+Shift+C，复制文件名
#IfWinActive ahk_exe explorer.exe
^+c::
	send ^c
	sleep,200
	clipboard = %clipboard% ;%null%
	tooltip,%clipboard%
	sleep, 2000
	tooltip,
	return
#IfWinActive

; 给Chrome 增加F3作为打开首页的快捷键
#IfWinActive ahk_class Chrome_WidgetWin_1
F3:: SendInput !{home}
#IfWinActive

^PrintScreen::
	Process, Exist, Snagit32.exe
	if (ErrorLevel == 0) {
		Run D:\Tools\SnagIt\Snagit32.exe
		Sleep 3000
	}
	Run D:\Tools\SnagIt\Snagit32.exe /ci
	return

; Ctrl + Win + ]，滚轮缩放放大
LWin & ]:: MouseClick,WheelUp,,,1,0,D,R

; Ctrl + Win + ]，滚轮缩放缩小
LWin & [:: MouseClick,WheelDown,,,1,0,D,R

; Ctrl + \，等价于小键盘 Ctrl + NumPad+，即自动调整列表空间表格宽度
^\::SendInput ^{NumpadAdd}

; 移动窗口到当前窗口上下左右边缘, 参数： 1~9
MoveIt(Q)
{
	; Get the windows pos
	WinGetPos,X,Y,W,H,A,,,
	WinGet,M,MinMax,A

	; Calculate the top center edge
	CX := X + W/2
	CY := Y + 20

	SysGet, Count, MonitorCount

	num = 1
	Loop, %Count%
	{
		SysGet, Mon, MonitorWorkArea, %num%
 
		if( CX >= MonLeft && CX <= MonRight && CY >= MonTop && CY <= MonBottom )
		{
			MW := (MonRight - MonLeft)
			MH := (MonBottom - MonTop)
			MHW := (MW / 2)
			MHH := (MH / 2)
			MMX := MonLeft + MHW
			MMY := MonTop + MHH

			if( M != 0 )
				WinRestore,A

			if( Q == 1 )
				WinMove,A,,MonLeft,MMY,MHW,MHH
			if( Q == 2 )
				WinMove,A,,MonLeft,MMY,MW,MHH
			if( Q == 3 )
				WinMove,A,,MMX,MMY,MHW,MHH
			if( Q == 4 )
				WinMove,A,,MonLeft,MonTop,MHW,MH
			if( Q == 5 )
			{
				if( M == 0 )
					WinMaximize,A
				else
					WinRestore,A
			}
			if( Q == 6 )
				WinMove,A,,MMX,MonTop,MHW,MH
			if( Q == 7 )
				WinMove,A,,MonLeft,MonTop,MHW,MHH
			if( Q == 8 )
				WinMove,A,,MonLeft,MonTop,MW,MHH
			if( Q == 9 )
				WinMove,A,,MMX,MonTop,MHW,MHH
			return
		}

		num += 1
	}

	return
}

GuiSize:
    GuiControl, Move, InputText, % "w" A_GuiWidth-120 " h30"
    GuiControl, Move, CalcButton, % "X" A_GuiWidth-90 " h30"
    GuiControl, Move, ResultText, % "w" A_GuiWidth-20 " h" A_GuiHeight-90
	return
GuiEscape:
GuiClose:
Cancel:
	Gui Destroy
	return

OSD(text)
{
	; borderless, no progressbar, font size 25, color text 009900
	Progress, hide Y800 W1000 b zh0 cw000000 FM20 CT00BB00,, %text%, AutoHotKeyProgressBar, 微软雅黑
	Progress, show
	WinSet, Transparent, 200, AutoHotKeyProgressBar
	;WinSet, TransColor, 000000 200, AutoHotKeyProgressBar
	SetTimer, RemoveToolTipOSD, 3000
	Return

	RemoveToolTipOSD:
		SetTimer, RemoveToolTipOSD, Off
		Progress, Off
		return
}

; Exposes two hotkeys:  
; - Win+G generates & pastes a new lowercase guid
; - Win+Shift+G generates & pastes a new UPPERCASE guid
; In both cases, the guid is left on the clipboard so you can easily paste it more than once.
;
GUID()
{ 
	format = %A_FormatInteger%	   ; save original integer format
	SetFormat Integer, Hex		   ; for converting bytes to hex
	VarSetCapacity(A,16)
	DllCall("rpcrt4\UuidCreate","Str",A)
	Address := &A
	Loop 16
	{
		x := 256 + *Address		   ; get byte in hex, set 17th bit
		StringTrimLeft x, x, 3		; remove 0x1
		h = %x%%h%					; in memory: LS byte first
		Address++
	}
	SetFormat Integer, %format%	  ; restore original format
	h := SubStr(h,1,8) . "-" . SubStr(h,9,4) . "-" . SubStr(h,13,4) . "-" . SubStr(h,17,4) . "-" . SubStr(h,21,12)
	return h
} 

; Win+Shift+G - Generate an UPPERCASE GUID
#+g::
	guid := GUID()
	StringUpper, guid, guid
	Clipboard := guid
	SendInput,^v
	return

; Win+Shift+G - Generate an Lowercase uuid
#^+g::
	guid := GUID()
	StringLower, guid, guid
	StringReplace, guid, guid,-,,All
	Clipboard := guid
	SendInput,^v
	return

GetIPs() {
	; 查询本机所有网络适配器的IP地址
	wbemLocator := ComObjCreate("WbemScripting.SWbemLocator")
	wbemServices := wbemLocator.ConnectServer(".", "root\cimv2")
	networkAdapters := wbemServices.ExecQuery("SELECT IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True")
	; 遍历所有网络适配器，输出IP地址
	ip := ""
	for adapter in networkAdapters
	{
		ipAddresses := adapter.IPAddress
		for index, ipAddress in ipAddresses
		{
			ip := ip . "`t" . index . "`n"
		}
	}
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	; whr.Open("GET", "https://api.ipify.org", false)
	extIP := ""
	try {
		whr.Open("GET", "http://myip.ipip.net/", false)
		whr.Send()
		extIP := StrReplace(whr.ResponseText, "来自于：", "`n`t")
	}
	ip := "外部地址: `n`t" . extIP . "`n" . "内部地址: `n" . ip
	whr := ""
	return ip
}

showMessage(title, text) {
	Gui +LastFound +ToolWindow +AlwaysOnTop
	WinSet, Transparent, 240
	Gui, Font, s18
	Gui, Add, Edit, x10 y10 w680 h380, %text%
	Gui, Show, w700 h400, %title%
}

#+i:: showMessage("结果(按ESC关闭)", GetIPs())

IsWindowVisible(window_name) {
	ID := WinExist(window_name)

	If( ErrorLevel != 0 ) {
		; MsgBox, Window %window_name% not found!
		return -1
	}

	If( ID > 0 ) {
		WinGetPos, X, Y, , , ahk_id %ID%
		active_window_id_hwnd := WindowFromPoint(X, Y)

		; MsgBox, %X%, %Y%, %active_window_id_hwnd%
		If( active_window_id_hwnd == ID ) {
			; MsgBox, Window %window_name% is visible!
			return 1
		}
		else {
			; MsgBox, Window %window_name% is NOT visible!
			return 0
		}
	}

	; MsgBox, Window %window_name% not found!
	return -1
}

WindowFromPoint(x, y)
{
	VarSetCapacity(POINT, 8)
	Numput(x, POINT, 0, "int")
	Numput(y, POINT, 4, "int")
	return DllCall("WindowFromPoint", int64, NumGet(POINT, 0, "int64"))
}

#include %A_ScriptDir%\gdip.ahk
PrintScreen::
	FormatTime, CurrentDateTime,, yyyyMMdd_HHmmss_
	EnvGet, UserProfile, USERPROFILE
	folder := UserProfile . "\Pictures\autocapture\"
	IfNotExist, % folder
	{
		FileCreateDir, % folder
	}
	file := folder . CurrentDateTime . A_MSec . ".png"
	
	pToken := Gdip_Startup()
	hWnd := WinExist("A")
	pBitmap := Gdip_BitmapFromHWND(hWnd)
	Gdip_SetBitmapToClipboard(pBitmap)
	Gdip_SaveBitmapToFile(pBitmap, file)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown("pToken")
	
	OSD("截图保存到文件`n" . file)
	return

#If MouseIsOver("ahk_class Shell_TrayWnd")
WheelUp::Send {Volume_Up}
WheelDown::Send {Volume_Down}

MouseIsOver(WinTitle) {
	MouseGetPos,,, Win
	return WinExist(WinTitle . " ahk_id " . Win)
}
#If

IsWin8OrHigh() {
	ver := +left(A_OSVersion, ".")
	return ver >= 8
}

#If !IsWin8OrHigh()
; Win + Print Screen, Windows 8 及以上，系统会自动保存到图片目录下
#PrintScreen::
	SendInput !{PrintScreen}
	Process, Exist,mspaint.exe
	if not Errorlevel
		Run, mspaint.exe
	WinActivate, Paint
	WinWaitActive ,,Paint,1,
	SendInput ^v
	return
#If

End:
