; ================== By Kingron =======================
; Win = #	Ctrl = ^	Alt = !	Shift = +
global ontop := true
global cursorPID := 0
global osdPID := 0
global winhole := 0
global spyPID := 0
global wallpaper := 0
global hideWindows := []

SetTimer, GetAndSetBingWallpaper, 3600000
GetAndSetBingWallpaper()
setTaskBarTransparent()
; ComObjCreate("SAPI.SpVoice").Speak("欢迎使用鼠标手势")
; 使用 ControlSend, ahk_parent, ^!a, A ，可以直接给窗口发热键而不触发全局热键

RegRead DisabledHotkeys, HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced, DisabledHotkeys
If (DisabledHotkeys = "") {
	Run reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DisabledHotkeys /d QWTUSFGHKCVM
	MsgBox 0x41040,提示,关闭了系统默认热键设置(Win+Q/W/T/U/S/F/G/H/K/C/V/M)。`n请注销或者重启系统以便生效
}
goto End

#+w::
    GetAndSetBingWallpaper()
    return
; 获取并设置Bing壁纸函数
GetAndSetBingWallpaper() {
    FileCreateDir, Wallpaper
    ; 获取Bing壁纸的URL
    ; https://bing.angustar.com/api/list?count=1&date=20230101
    URLDownload := "https://www.bing.com/HPImageArchive.aspx?format=js&idx=" . wallpaper . "&n=1"
    wallpaper := wallpaper + 1
    if (wallpaper >= 7) {
        wallpaper := 0
    }

    ; 发送HTTP请求获取JSON数据
    UrlDownloadToFile, % URLDownload, bing.json

    ; 解析JSON数据，提取壁纸URL
    FileEncoding, UTF-8
    FileRead, BingData, bing.json
    if (BingData == "") {
        return
    }
;    ImageFile := "Wallpaper\" . RegExReplace(BingData, ".*""urlbase"":""\/th\?id=([^""]*).*", "$1") . "_1920x1080.jpg"
    ImageFile := "Wallpaper\" . RegExReplace(BingData, ".*""urlbase"":""\/th\?id=([^""]*).*", "$1") . "_UHD.jpg"
    if (!FileExist(ImageFile)) {
;        ImageURL := RegExReplace(BingData, ".*""url"":""([^""]*).*", "$1")
        ImageURL := RegExReplace(BingData, ".*""urlbase"":""([^""]*).*", "$1") . "_UHD.jpg"
        ImageTitle := RegExReplace(BingData, ".*""title"":""([^""]*).*", "$1")
        ImageCopyright := RegExReplace(BingData, ".*""copyright"":""([^""]*).*", "$1")
        ; 下载壁纸图片
        URLDownload := "https://www.bing.com" . ImageURL
        OutputDebug, % URLDownload
        UrlDownloadToFile, % URLDownload, % ImageFile
        if (FileExist(ImageFile)) {
	        try {
	            RunWait, ffmpeg -y -i "%ImageFile%" -vf "drawtext=fontfile=微软雅黑:text='%ImageTitle%':x=w-tw-0.01*w:y=h-th-h*0.075:fontsize=0.025*h:fontcolor=white`,drawtext=fontfile=微软雅黑:text='%ImageCopyright%':x=w-tw-0.01*w:y=h-th-0.045*h:fontsize=0.02*h:fontcolor=white" -q:v 6 "%ImageFile%",, Hide
	        } catch e {
	            OutputDebug, % e.Message
	        }
	    }
    }
    ; 设置壁纸
    if (FileExist(ImageFile)) {
	    Run, reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%A_WorkingDir%\%ImageFile%" /f,, hide
		DllCall("SystemParametersInfo", "UInt", 0x0014, "UInt", 0, "Str", A_WorkingDir . "\" . ImageFile, "UInt", 2)
	}
    FileDelete, bing.json
}

; Hot Run 管理
#Include *i %A_ScriptDir%\HotRun.ahk
#^+a::
	Gui, HotRun:New, +LastFound +Resize +MinSize320x550
	Gui, HotRun:Add, Text, x10 y10 w300 h20 +Resize, 请输入快捷键，打勾表示支持Win 键
	Gui, HotRun:Add, HotKey, x10 y30 w300 h20 vMyHotkey,
	Gui, HotRun:Add, CheckBox, x320 y30 w90 h20 vCheckboxWin, Win 键
	Gui, HotRun:Add, Text, x10 y60 w400 h20, 运行指令，例如 URL，程序完整路径等
	Gui, HotRun:Add, Edit, x10 y80 w400 h20 vMyCmd,
	Gui, HotRun:Add, Button, x10 y110 w60 h30 gHotRunOK Default, 确定
	Gui, HotRun:Add, Button, x80 y110 w60 h30 gCancel, 取消

	filename := A_ScriptDir . "\HotRun.ahk"
	lines := ""
	if FileExist(filename) {
		FileRead, lines, % filename
		lines := StrReplace(lines, "`r`n", "|")
	}
	Gui, HotRun:Add, ListBox, x10 y150 w400 h390 vHotRunList readonly, % lines
	Gui, HotRun:Show, w420 h550, 新快捷运行(HotRun.ahk)
	return

	HotRunGuiSize:
		GuiControl, Move, MyHotKey, % "w" A_GuiWidth-120
		GuiControl, Move, CheckboxWin, % "x" A_GuiWidth-100
		GuiControl, Move, MyCmd, % "w" A_GuiWidth-20
		GuiControl, Move, HotRunList, % "w" A_GuiWidth-20 " h" A_GuiHeight-160
		return

	HotRunGuiEscape:
	HotRunGuiCancel:
	HotRunGuiClose:
		Gui, Destroy
		return

	HotRunOK:
		Gui, Submit, NoHide
		if MyHotkey =
		{
			MsgBox, 48, 错误, 请添加快捷键
			Return
		}
		if MyCmd =
		{
			MsgBox, 48, 错误, 请输入运行目标，例如 URL 或者程序完整路径
			Return
		}

        filename := A_ScriptDir . "\HotRun.ahk"
        if CheckboxWin {
            line := Format("#{}::Run,{}", MyHotkey, MyCmd)
        } else {
            line := Format("{}::Run,{}", MyHotkey, MyCmd)
        }
		if InFile(filename, line) {
		    MsgBox 48, 错误, 热键运行定义已经存在
		    return
		}
		FileAppend,`r`n%line%, % filename, UTF-8
		Gui, Destroy
		Reload
	    return

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
#c::Run cmd.exe, % A_Desktop
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
#g::Run gost -C D:\Tools\gost.json
^#g::   ; 随机密码生成
    InputBox, length, 请输入随机密码字符串长度
    charset := "@~_?!$#%0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@~_?!$#%"
    password := ""
    if (length > 0) {
        Loop, %length% {
            Random, index, 1, StrLen(charset)
            ch := SubStr(charset, index, 1)
            password .= ch
        }
        showMessage("结果", password)
        clipboard := password
    }
	return

#h:: 
	Process, Exist, heidisql.exe
	if (ErrorLevel == 0) {
		Run HeidiSQL\heidisql.exe
	}
	return
#^h:: Run, %A_ScriptDir%\HashCalc.ahk
; HotString 管理
#Hotstring EndChars `t
#include *i %A_ScriptDir%\HotString.ahk
#+h::
	Gui, HotStr:Add, Text, x10 y10 w400 h20, 请输入短语如 fyi，短语可用 tab 键触发替换
	Gui, HotStr:Add, Edit, x10 y30 w400 h20 vShortText,
	Gui, HotStr:Add, Text, x10 y60 w400 h20, 完整内容，例如 for your information
	Gui, HotStr:Add, Edit, x10 y80 w400 h20 vLongText,
	Gui, HotStr:Add, Button, x10 y110 w60 h30 gQuickText Default, 确定
	Gui, HotStr:Add, Button, x80 y110 w60 h30 gCancel, 取消

	filename := A_ScriptDir . "\HotString.ahk"
	lines := ""
	if FileExist(filename) {
		FileRead, lines, % filename
		lines := StrReplace(lines, "`r`n", "|")
	}
	Gui, HotStr:Add, ListBox, x10 y150 w400 h390 vHotStrList, % lines
	Gui, HotStr:Show, w420 h550, 添加新短语(HotString.ahk)
	return

	HotStrGuiEscape:
	HotStrGuiCancel:
	HotStrGuiClose:
		Gui, Destroy
		return
	QuickText:
		Gui, Submit, NoHide
		if ShortText =
		{
			MsgBox, 48, 错误, 请输入短语
			Return
		}
		if LongText =
		{
			MsgBox, 48, 错误, 请输入被替换的完整内容
			Return
		}

        filename := A_ScriptDir . "\HotString.ahk"
        line := Format(":COT:{}::{}", ShortText, LongText)
		if InFile(filename, line) {
		    MsgBox 48, 错误, 短语定义已经存在
		    return
		}
		FileAppend,`r`n%line%, % filename, UTF-8
		Gui, Destroy
		Reload
	    return
#i::Run compmgmt.msc,,Max
#j::Run "C:\Program Files\Git\git-bash.exe"
#k::Run "putty.exe" @gcp
#^k::
	if (osdPID = 0) {
		Run, %A_ScriptDir%\KeypressOSD.ahk,,,osdPID
	} else {
		Process, Close, %osdPID%
		osdPID := 0
	}
	return
#F1::
;	if (winhole = 0) {
		Run, %A_ScriptDir%\winhole.ahk,,,winhole
;	} else {
;		Process, Close, %winhole%
;		winhole := 0
;	}
	return
; #l:: 锁定计算机
; #m:: 最小化所有
#m::Run "SumatraPDF.exe"
#n::Run Notepad++
#o::
    if (A_OSVersion >= "10.0") {
            ; Turn on/off WIFI hotspot
            Run powershell -encodedCommand JABwAHIAbwBmAGkAbABlACAAPQAgAFsAVwBpAG4AZABvAHcAcwAuAE4AZQB0AHcAbwByAGsAaQBuAGcALgBDAG8AbgBuAGUAYwB0AGkAdgBpAHQAeQAuAE4AZQB0AHcAbwByAGsASQBuAGYAbwByAG0AYQB0AGkAbwBuACwAVwBpAG4AZABvAHcAcwAuAE4AZQB0AHcAbwByAGsAaQBuAGcALgBDAG8AbgBuAGUAYwB0AGkAdgBpAHQAeQAsAEMAbwBuAHQAZQBuAHQAVAB5AHAAZQA9AFcAaQBuAGQAbwB3AHMAUgB1AG4AdABpAG0AZQBdADoAOgBHAGUAdABJAG4AdABlAHIAbgBlAHQAQwBvAG4AbgBlAGMAdABpAG8AbgBQAHIAbwBmAGkAbABlACgAKQAKACQAdABtACAAPQAgAFsAVwBpAG4AZABvAHcAcwAuAE4AZQB0AHcAbwByAGsAaQBuAGcALgBOAGUAdAB3AG8AcgBrAE8AcABlAHIAYQB0AG8AcgBzAC4ATgBlAHQAdwBvAHIAawBPAHAAZQByAGEAdABvAHIAVABlAHQAaABlAHIAaQBuAGcATQBhAG4AYQBnAGUAcgAsAFcAaQBuAGQAbwB3AHMALgBOAGUAdAB3AG8AcgBrAGkAbgBnAC4ATgBlAHQAdwBvAHIAawBPAHAAZQByAGEAdABvAHIAcwAsAEMAbwBuAHQAZQBuAHQAVAB5AHAAZQA9AFcAaQBuAGQAbwB3AHMAUgB1AG4AdABpAG0AZQBdADoAOgBDAHIAZQBhAHQAZQBGAHIAbwBtAEMAbwBuAG4AZQBjAHQAaQBvAG4AUAByAG8AZgBpAGwAZQAoACQAcAByAG8AZgBpAGwAZQApAAoAaQBmACAAKAAkAHQAbQAuAFQAZQB0AGgAZQByAGkAbgBnAE8AcABlAHIAYQB0AGkAbwBuAGEAbABTAHQAYQB0AGUAIAAtAGUAcQAgADEAKQAgAHsACgAgACAAIAAgACQAdABtAC4AUwB0AG8AcABUAGUAdABoAGUAcgBpAG4AZwBBAHMAeQBuAGMAKAApACAAfAAgAE8AdQB0AC0ATgB1AGwAbAAKACAAIAAgACAAZQBjAGgAbwAgACIASABvAHQAcwBwAG8AdAAgAHMAdABvAHAAcABlAGQAIgAKACAAIAAgACAAcwBsAGUAZQBwACAAMwAKAH0AIABlAGwAcwBlACAAewAKACAAIAAgACAAJAB0AG0ALgBTAHQAYQByAHQAVABlAHQAaABlAHIAaQBuAGcAQQBzAHkAbgBjACgAKQAgAHwAIABPAHUAdAAtAE4AdQBsAGwACgAgACAAIAAgAGUAYwBoAG8AIAAiAEgAbwB0AHMAcABvAHQAIABzAHQAYQByAHQAZQBkACIACgAgACAAIAAgAHMAbABlAGUAcAAgADMACgB9AA==
	} else {
            Run wifi.bat
	}
    return

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
	InputBox, word, 单词, `n使用百度进行翻译。`n请输入要翻译的内容，可以是句子或者单词,,400,180,,,,,%def%
	if ErrorLevel
		return

	Run, https://fanyi.baidu.com/#en/zh/%word%
;	Run, https://www.deepl.com/translator#en/zh/%word%
;  shell := ComObjCreate("WScript.Shell")
;  exec := shell.Exec("CScript.exe //Nologo D:\tools\gt.js """ . word . """")
;  text := exec.StdOut.ReadAll()
  
;  Gui Destroy
;  Gui Add, Edit, w800 h600, %text%
;  Gui Add, Button, Default, 确定
;  Gui Show, , %word% 翻译结果 (按ESC关闭)
;  GuiControl Focus, okButton
	return
#^q::PostMessage, 0x12, 0, 0,, A
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
			WinSet, AlwaysOnTop, On, % "ahk_id" vWinList%A_Index%
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
#^w::
	if (spyPID = 0) {
		Run, %A_ScriptDir%\WindowSpy.ahk,,,spyPID
	} else {
		Process, Close, %spyPID%
		spyPID := 0
	}
	return
; #x:: 移动中心
#y:: MouseClick, right
#z::Run procexp.exe
#^z::
	global ScriptEngine := 1
	Gui, Calc:New, +LastFound +Resize +MinSize200x150
	Gui, Calc:Font, s16
    Gui, Calc:Add, Text, x10 y10 w880 h20 left, 请输入表达式，按 Ctrl + D，清空结果框：
    Gui, Calc:Add, Edit, x10 y40 w800 h130 Resize vInputText -background, % Clipboard
    Gui, Calc:Add, Button, x810 y40 w80 h30 vCalcButton gCalcOK Default, &Calc
	Gui, Calc:Font, s11
    Gui, Calc:Add, Radio, x810 y90 w90 h30 vRadioVBS left gSelectEngine, VBScript
    Gui, Calc:Add, Radio, x810 y130 w90 h30 vRadioJS checked left gSelectEngine, JScript
    Gui, Calc:Color, , 0xeeeeee
    Gui, Calc:Add, Edit, x10 y180 w880 h490 vResultText Resize,
    Gui, Calc:Show, w900 h680, 计算器
	WinSet, Transparent, 240
	return

	SelectEngine:
		if (A_GuiControl = "RadioVBS") {
			MsgBox 0x41040,提示,使用VBS引擎时，最后返回值必须用 result = 赋值，例如 result = a + b，result = chr(65)等，否则不会输出结果。
			ScriptEngine := 0
		} else {
			ScriptEngine := 1
		}
		return
#IfWinActive, 计算器 ahk_class AutoHotkeyGUI
    ^g::
    ^enter::
    ^f::
        ControlClick, Button1, A,
        return
	^d::
		GuiControl, Calc:Text, ResultText,
		return
#IfWinActive
	CalcGuiSize:
		GuiControl, Move, InputText, % "w" A_GuiWidth-110
		GuiControl, Move, CalcButton, % "X" A_GuiWidth-90
		GuiControl, Move, RadioVBS, % "X" A_GuiWidth-90
		GuiControl, Move, RadioJS, % "X" A_GuiWidth-90
		GuiControl, Move, ResultText, % "w" A_GuiWidth-20 " h" A_GuiHeight-190
		return

	CalcGuiEscape:
	CalcGuiClose:
	CalcCancel:
		Gui Destroy
		return

	CalcOK:
		GuiControlGet, InputText, , InputText
		if (InputText != "") return

		GuiControlGet, CurrentText, , ResultText
		FormatTime, CurrentDateTime,, [HH:mm:ss]
		try {
			vb := ComObjCreate("MSScriptControl.ScriptControl")
			if (ScriptEngine = 0) {
				vb.Language := "VBscript"
				vb.AddCode(InputText)
				result := vb.Eval("result") . "`r`n"
			} else {
				vb.Language := "JScript"
				result := vb.eval(InputText) . "`r`n"
			}

			vb := ""
		} catch e {
			result := e.Message
		}
		GuiControl, , ResultText, % CurrentDateTime " " InputText " => " result "`r`n" CurrentText
        GuiControl, Focus, InputText
        Sleep 10
        Send ^a
		return
#ESC::
    hideWindows.push(WinExist("A"))
    WinHide,A
	return
^#ESC::
    if (hideWindows.Length() > 0) {
		hwnd = % hideWindows.pop()
        WinShow, ahk_id %hwnd%
        WinActivate, ahk_id %hwnd%
	} else {
		MsgBox 0x41030,提示,没有隐藏窗口了
	}
	return
#`::WinMinimize,A
; 等价于按数字小键盘 *
#\::SendInput, {NumpadMult}
; 关闭显示器
#,::
    ; SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER
    DllCall("user32.dll\PostMessage", Int, -1, Int, 0x0112, Int, 0xF170, Int, 2)  ; Turn off the monitor, black screen
    ; DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0) ; sleep
    return
#.::Run ScreenRuler\screenruler.exe
#/::Run HxD.exe
; 打开回收站
#F11::Run ::{645FF040-5081-101B-9F08-00AA002F954E}
; Win+; = 表情输入框

;================ TransActive =====================
; Set Current active window Transparent.
; HotKey: 
;	 Win-Alt-0: Switch transparent
;	 Win-Alt-↓: less transparent
;	 Win-Alt-↑: more transparent

~Alt & WheelUp:: ; 按住Alt键并向上滚动
#!UP::
    SetTrans(5)
    return
~Alt & WheelDown:: ; 按住Alt键并向下滚动
#!DOWN::
    SetTrans(-5)
    return

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

InFile(filename, string)
{
	if !FileExist(filename) {
		return false
	}
    FileOpen := FileOpen(filename, "r") ; 打开文件以供读取

    while !FileOpen.AtEOF() ; 当文件未到达末尾时
    {
        line := StrReplace(FileOpen.ReadLine(), "`r`n") ; 逐行读取文件内容
        line := trim(line)
        if (line = string) ; 判断当前行是否等于指定字符串
        {
            FileOpen.Close() ; 关闭文件
            return true ; 匹配到指定字符串，返回 true
        }
    }

    FileOpen.Close() ; 关闭文件
    return false ; 未匹配到指定字符串，返回 false
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

;; 连续两次按左 Ctrl，当前会导致长按有问题，先去掉
;~LControl::
;    if (A_PriorHotkey == "~LControl" and A_TimeSincePriorHotkey < 200) {
;    }
;	return

; 连续两次按 ESC 最小化当前窗口
~Esc::
	if (A_PriorHotkey = "~Esc" and A_TimeSincePriorHotkey < 200) {
	    WinSet, Bottom,, A
	}
	return

CapsLock & d::
	Send {Home}
	Send +{End}
	Send {Del}
	Send {Del}
    Return

^CapsLock::
;	if (A_PriorHotkey == "CapsLock" and A_TimeSincePriorHotkey < 200) {
		if (cursorPID == 0) {
			Run, %A_ScriptDir%\cursorhighlight.ahk,,,cursorPID
		} else {
			Process, Close, %cursorPID%
			cursorPID := 0
		}
;	}
	return

; 下面会导致长按 Alt 有问题，暂时去掉
;~LAlt::
;	if (A_PriorHotkey = "~LAlt" and A_TimeSincePriorHotkey < 200) {
;		SendInput, {PgDn}
;	}
;	return

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
^f::Click 120, 115
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

GuiEscape:
GuiClose:
Cancel:
	Gui Destroy
	return

GetStringInfo(str, ByRef lineCount, ByRef maxLength)
{
    lines := StrSplit(str, "`n")
    lineCount := lines.MaxIndex()  ; 获取总行数
    maxLength := 0

    for index, line in lines
    {
        line := StrReplace(line, "`r")  ; 移除回车符
        currentByteLength := 0
        Loop, Parse, line
        {
            char := A_LoopField
            if (Asc(char) < 128)
                currentByteLength += 1  ; 英文字符为1字节
            else
                currentByteLength += 2  ; 中文字符或非ASCII字符为2字节
        }
        if (currentByteLength > maxLength)
            maxLength := currentByteLength
    }
}

OSD(text)
{
	GetStringInfo(text, lineCount, maxLength)
	width := (maxLength + 4) * 15
	; borderless, no progressbar, font size 25, color text 009900
	Progress, hide Y800 W%width% b zh0 cw000000 FM20 CT00BB00,, %text%, AutoHotKeyProgressBar, 微软雅黑
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

GetDnsAddress()
{
    if (DllCall("iphlpapi.dll\GetNetworkParams", "ptr", 0, "uint*", size) = 111) && !(VarSetCapacity(buf, size, 0))
        throw Exception("Memory allocation failed for FIXED_INFO struct", -1)
    if (DllCall("iphlpapi.dll\GetNetworkParams", "ptr", &buf, "uint*", size) != 0)
        throw Exception("GetNetworkParams failed with error: " A_LastError, -1)
    addr := &buf, DNS_SERVERS := []
    DNS_SERVERS[1] := StrGet(addr + 264 + (A_PtrSize * 2), "cp0")
    ptr := NumGet(addr+0, 264 + A_PtrSize, "uptr")
    while (ptr) {
        DNS_SERVERS[A_Index + 1] := StrGet(ptr+0 + A_PtrSize, "cp0")
        ptr := NumGet(ptr+0, "uptr")
    }
    ret := ""
    for i, v in DNS_SERVERS {
        ret := ret . "`t" . v . "`n"
    }
    return ret
}

GetMacAddress(delimiter := ":", case := False)
{
    if (DllCall("iphlpapi.dll\GetAdaptersInfo", "ptr", 0, "uint*", size) = 111) && !(VarSetCapacity(buf, size, 0))
        throw Exception("Memory allocation failed for IP_ADAPTER_INFO struct", -1)
    if (DllCall("iphlpapi.dll\GetAdaptersInfo", "ptr", &buf, "uint*", size) != 0)
        throw Exception("GetAdaptersInfo failed with error: " A_LastError, -1)
    addr := &buf, MAC_ADDRESS := []
    while (addr) {
        loop % NumGet(addr+0, 396 + A_PtrSize, "uint")
            mac .= Format("{:02" (case ? "X" : "x") "}", NumGet(addr+0, 400 + A_PtrSize + A_Index - 1, "uchar")) "" delimiter ""
        MAC_ADDRESS[A_Index] := SubStr(mac, 1, -1), mac := ""
        addr := NumGet(addr+0, "uptr")
    }
	ret := ""
	for i, v in MAC_ADDRESS {
	    ret := ret . "`t" . v . "`n"
	}
	return ret
}

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
	ip := "外部地址: `n`t" . extIP . "`n" . "内部地址: `n" . ip . "`nDNS 服务器:`n" . GetDnsAddress() . "`nMAC地址:`n" . GetMacAddress()
	whr := ""
	return ip
}

showMessage(title, text) {
	Global MyBox
	Gui Msg:New, +LastFound +ToolWindow +AlwaysOnTop +Resize +MinSize200x150
	WinSet, Transparent, 240
	Gui, Msg:Font, s18
	Gui, Msg:Add, Edit, x10 y10 w680 h380 vMyBox Resize, %text%
	Gui, Msg:Show, w700 h400, %title%
	return

	MsgGuiSize:
		GuiControl, Move, MyBox, % "w" A_GuiWidth-20 " h" A_GuiHeight-20
		return
	MsgGuiEscape:
	MsgGuiClose:
	MsgGuiCancel:
		Gui,Msg:Destroy
		return
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
	; 下面方式不能抓取 Overlayer Window
	; pBitmap := Gdip_BitmapFromHWND(hWnd)
	WinGetPos, x, y, w, h, A
	hBitmap := HBitmapFromScreen(x, y, w, h)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
	DeleteObject(hBitmap)
	Gdip_SetBitmapToClipboard(pBitmap)
	Gdip_SaveBitmapToFile(pBitmap, file)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown("pToken")
	
	OSD("截图保存到文件`n" . file)
	return

; 鼠标在任务栏滚动调整音量
#If MouseIsOver("ahk_class Shell_TrayWnd") || MouseIsOver("ahk_class Shell_SecondaryTrayWnd")
WheelUp::Send {Volume_Up}
WheelDown::Send {Volume_Down}
; 任务栏 Ctrl + 鼠标滚动，调整屏幕亮度
^WheelUp:: AdjustScreenBrightness(5)
^WheelDown:: AdjustScreenBrightness(-5)

MouseIsOver(WinTitle) {
	MouseGetPos,,, Win
	return WinExist(WinTitle . " ahk_id " . Win)
}

AdjustScreenBrightness(step) {
    service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
    monitors := ComObjGet(service).ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=TRUE") 
    monMethods := ComObjGet(service).ExecQuery("SELECT * FROM wmiMonitorBrightNessMethods WHERE Active=TRUE")

    for i in monitors { 
        curt := i.CurrentBrightness
        break 
    }
    toSet := curt + step
    if (toSet > 100)
        toSet := 100
    if (toSet < 0)
        toSet := 0

    for i in monMethods {
        i.WmiSetBrightness(1, toSet)
        break
    }

    BrightnessOSD()
}

BrightnessOSD() {
	static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
	 ,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
	static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
	HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	IF !(HWND) {
		try IF ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
			try IF ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
				DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
				 ,ObjRelease(flyoutDisp)
			}
			ObjRelease(shellProvider)
		}
		HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	}
	DllCall(PostMessagePtr, "Ptr", HWND, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
}
#If

IsWin8OrHigh() {
	ver := +left(A_OSVersion, ".")
	return ver >= 8
}

ProcessChineseChars(string)
{
    result := ""
    i := 1

    while i <= StrLen(string) - 1
    {
        ch := SubStr(string, i, 1)
        nextCh := SubStr(string, i + 1, 1)
        if (ch = " " && nextCh > "~") {
        } else {
            result .= ch
        }

        i++
    }

    return result
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

#Include *i %A_ScriptDir%\ocr.ahk
#^x::
	hBitmap := HBitmapFromScreen(GetArea()*)
	pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
	DllCall("DeleteObject", "Ptr", hBitmap)
	text := ocr(pIRandomAccessStream, "zh-Hans-CN")
	OutputDebug OCR: %text%
    text := ProcessChineseChars(text)
	OutputDebug After space: %text%
	ObjRelease(pIRandomAccessStream)
	showMessage("识别结果", text)
	Return

; Ctrl, Alt 键在远程桌面失效，可以在本地和远程都安装AHK，然后分别写如下代码来避免，原理是利用App键中转绕过去
#IfWinActive, ahk_exe mstsc.exe|dsTermServ.exe
; 本地，客户端
*^AppsKey::^LAlt

; 远程server 端
; *^LAlt::^AppsKey
#IfWinActive

CapsLock & q:: SendInput {Volume_Mute}
CapsLock & w:: SendInput {Media_Play_Pause}
CapsLock & r:: SendInput {Media_Prev}
CapsLock & f:: SendInput {Media_Next}
CapsLock & e:: SendInput {Launch_Media}
CapsLock & t:: SendInput {Launch_Mail}
CapsLock & c:: Run, Calc
CapsLock & n:: Run, Notepad

#IfWinActive, ahk_class Chrome_WidgetWin_1
Capslock & c::
    Send, !d ; 切换到地址栏
    Sleep, 100
    Send, ^c ; 复制地址
    Sleep, 100
    decodedURL := UriDecode(Clipboard)
    Clipboard := decodedURL ; 将解码后的地址复制到剪贴板
    Return
#IfWinActive

#Include %A_ScriptDir%\ActiveScript.ahk
UriDecode(Uri)
{
    oSC := new ActiveScript("JScript")
	return oSC.decodeURIComponent(Uri)
}

setTaskBarTransparent() {
	WinSet, Transparent, 220, ahk_class Shell_TrayWnd
	WinSet, Transparent, 220, ahk_class ahk_class Shell_SecondaryTrayWnd
}

; Retrieve the width (w) and height (h) of the client area.
GetClientSize(hwnd, ByRef w, ByRef h)
{
    VarSetCapacity(rc, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
    w := NumGet(rc, 8, "int")
    h := NumGet(rc, 12, "int")
}

#F3:: Reload /restart
CapsLock & s::
	InputBox, text, 内容, `n请输入要语音输出的内容,,400,180,,,,,学习时间到了，学习让人进步，学习让人快乐
	if ErrorLevel
		return
	ComObjCreate("SAPI.SpVoice").Speak(text)
	return

; 设置快捷键为 Caps Lock + a, 显示 ASCII 码表，支持系统默认代码页和 Code Page 437 切换
CapsLock & a::
    global CP437 := true
    global AscFontName := "Lucida Sans Unicode"
	global MyPicture, AscTitle, AscPicture, AscHwnd
	AscTitle := CP437 ? "ASCII 码表 - 代码页 437" : "ASCII 码表 - 系统默认代码页"
	Gui, Asc:New, +LastFound +Resize +MinSize1320x920
    Gui, Asc:Show, w1320 h920 Maximize, %AscTitle%
    AscHwnd := WinExist()
	GetClientSize(AscHwnd, w, h)
	Gui, Asc:Add, Picture, x0 y0 w%w% h%h% 0xE vMyPicture +HwndAscPicture
	drawAscii(AscPicture, w, h)
	OnMessage(0x0203, "DoubleClickHandler") ; WM_RBUTTONDBLCLK
	OnMessage(0x0205, "PopupMenu")   ; WM_RBUTTONUP
    return

	AscGuiSize:
		GuiControl, Move, MyPicture, % "x0 y0 w" A_GuiWidth " h" A_GuiHeight
	    drawAscii(AscPicture, A_GuiWidth, A_GuiHeight)
		return

	AscGuiEscape:
	AscGuiClose:
	AscGuiCancel:
		Gui, Destroy
		return

DoubleClickHandler(wParam, lParam, msg, hwnd) {
	if (AscHwnd != hwnd) {
		return
	}
	GoSub, ChangeCodePage
}

PopupMenu(wParam, lParam, msg, hwnd) {
	if (AscHwnd != hwnd) {
		return
	}

    Menu, MyMenu, Add
	Menu, MyMenu, DeleteAll
    Menu, MyMenu, Add, 切换代码页`(&P`), ChangeCodePage
    Menu, MyMenu, Add
    Menu, MyMenu, Add, Arial, AscFont, +Check
    Menu, MyMenu, Add, Consolas, AscFont, +Check
    Menu, MyMenu, Add, Courier New, AscFont, +Check
    Menu, MyMenu, Add, Georgia, AscFont, +Check
    Menu, MyMenu, Add, Lucida Console, AscFont, +Check
    Menu, MyMenu, Add, Lucida Sans Unicode, AscFont, +Check
    Menu, MyMenu, Add, Microsoft Sans Serif, AscFont, +Check
    Menu, MyMenu, Add, Microsoft YaHei UI, AscFont, +Check
    Menu, MyMenu, Add, Segoe UI, AscFont, +Check
    Menu, MyMenu, Add, Symbol, AscFont, +Check
    Menu, MyMenu, Add, Tahoma, AscFont, +Check
    Menu, MyMenu, Add, Times New Roman, AscFont, +Check
    Menu, MyMenu, Add, Trebuchet MS, AscFont, +Check
    Menu, MyMenu, Add, Verdana, AscFont, +Check
    Menu, MyMenu, Add, Webdings, AscFont, +Check
    Menu, MyMenu, Add, Wingdings, AscFont, +Check
    Menu, MyMenu, Add, Wingdings 2, AscFont, +Check
    Menu, MyMenu, Add, Wingdings 3, AscFont, +Check
    Menu, MyMenu, Add, 等线, AscFont, +Check
    Menu, MyMenu, Add, 黑体, AscFont, +Check
    Menu, MyMenu, Add, 宋体, AscFont, +Check
    Menu, MyMenu, Add, 幼圆, AscFont, +Check
    Menu, MyMenu, Add, 微软雅黑, AscFont, +Check
    Menu, MyMenu, Check, %AscFontName%
	Menu, MyMenu, Show
}

ChangeCodePage:
	CP437 := !CP437
    GoSub, CodePage
    return
CodePage:
	AscTitle := CP437 ? "ASCII 码表 - 代码页 437" : "ASCII 码表 - 系统默认代码页"
	WinSetTitle, A, ,%AscTitle%
    WinGetPos, x, y, w, h, ahk_id %AscPicture%
	drawAscii(AscPicture, w, h)
	return

AscFont:
    Menu, MyMenu, UnCheck, %AscFontName%
	OutputDebug You selected %A_ThisMenuItem% from the menu %A_ThisMenu%.
	AscFontName := A_ThisMenuItem
	Menu, MyMenu, Check, %A_ThisMenuItem%
	GoSub, CodePage
	return

drawAscii(hWnd, w, h) {
	size := (h - 54) / 64
    CW := (w - 20) // 4  ; 列宽
    OutputDebug 字体大小: %size%, 列宽: %CW%
	top := 41

	pToken := Gdip_Startup()
    pBitmap := Gdip_CreateBitmap(w, h)
    graphics := Gdip_GraphicsFromImage(pBitmap)
    pPen := Gdip_CreatePen(0xff000000, 2)
	Gdip_DrawRectangle(graphics, pPen, 10, 10, w - 20, h - 20)
	Gdip_DrawLine(graphics, pPen, 10, 40, w - 10, 40)

    pBrush := Gdip_BrushCreateSolid(0xffcccccc)
	Gdip_FillRectangle(graphics, pBrush, 11, 11, w - 22, 29)

	pPen := Gdip_CreatePen(0xff000000, 1)
    hFamily := Gdip_FontFamilyCreate(AscFontName) ; Verdana, Lucida Sans Unicode, Georgia, Consolas
    hFont := Gdip_FontCreate(hFamily, (h - 54) // 64, 1)
    hFormat := Gdip_StringFormatCreate(0x4000)
    pBrushText := Gdip_BrushCreateSolid("0xff000000")
    Gdip_SetTextRenderingHint(graphics, 1)  ; 抗锯齿设置
    hFamilyCn := Gdip_FontFamilyCreate("微软雅黑")
    hFontCn := Gdip_FontCreate(hFamilyCn, (h - 54) // 64, 0)

    loop, 4 {
        CreateRectF(RC, (A_Index - 1) * CW + 20, 15, 80, 15), Gdip_DrawString(graphics, "字符", hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, (A_Index - 1) * CW + 80, 15, 80, 15), Gdip_DrawString(graphics, "DEC", hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, (A_Index - 1) * CW + 140, 15, 80, 15), Gdip_DrawString(graphics, "HEX", hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, (A_Index - 1) * CW + 200, 15, 80, 15), Gdip_DrawString(graphics, "OCT", hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, (A_Index - 1) * CW + 260, 15, 80, 15), Gdip_DrawString(graphics, "Unicode", hFontCn, hFormat, pBrushText, RC)
    }

    cp437_1 := ["␀", "␁", "␂", "␃", "␄", "␅", "␆", "␇", "␈", "␉", "␊", "␋", "␌", "␍", "␎", "␏"
            , "␐", "␑", "␒", "␓", "␔", "␕", "␖", "␗", "␘", "␙", "␚", "␛", "␜", "␝", "␞", "␟"
            , "␠", "!", """", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/"
            , "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?"]
    cp437_2 := ["@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"
            , "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\", "]", "^", "_"
            , "``", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"
            , "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "␡"]
    cp437_3 := ["Ç", "ü", "é", "â", "ä", "à", "å", "ç", "ê", "ë", "è", "ï", "î", "ì", "Ä", "Å"
            , "É", "æ", "Æ", "ô", "ö", "ò", "û", "ù", "ÿ", "Ö", "Ü", "¢", "£", "¥", "₧", "ƒ"
            , "á", "í", "ó", "ú", "ñ", "Ñ", "ª", "º", "¿", "⌐", "¬", "½", "¼", "¡", "«", "»"
            , "░", "▒", "▓", "│", "┤", "╡", "╢", "╖", "╕", "╣", "║", "╗", "╝", "╜", "╛", "┐"]
    cp437_4 := ["└", "┴", "┬", "├", "─", "┼", "╞", "╟", "╚", "╔", "╩", "╦", "╠", "═", "╬", "╧"
            , "╨", "╤", "╥", "╙", "╘", "╒", "╓", "╫", "╪", "┘", "┌", "█", "▄", "▌", "▐", "▀"
            , "α", "ß", "Γ", "π", "Σ", "σ", "µ", "τ", "Φ", "Θ", "Ω", "δ", "∞", "φ", "ε", "∩"
            , "≡", "±", "≥", "≤", "⌠", "⌡", "÷", "≈", "°", "∙", "·", "√", "ⁿ", "²", "■", "　"]

	loop, 64 {
		i := A_Index - 1
		if (mod(A_Index, 2) = 0) {
			Gdip_FillRectangle(graphics, pBrush, 11, i * size + top + 1, w - 22, size)
		}

		; 第一列
		ch := CP437 ? cp437_1[A_Index] : chr(i)
        CreateRectF(RC, 20, i * size + top, 80, size), Gdip_DrawString(graphics, ch, hFont, hFormat, pBrushText, RC)
        CreateRectF(RC, 80, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:02d}", i), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 140, i * size + top, 80, size), Gdip_DrawString(graphics, Format("0x{1:02X}", i), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 200, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:03o}", i), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 260, i * size + top, 80, size), Gdip_DrawString(graphics, Asc(ch), hFontCn, hFormat, pBrushText, RC)

		; 第二列
		ch := CP437 ? cp437_2[A_Index] : chr(64 + i)
        CreateRectF(RC, 20 + CW, i * size + top, 80, size), Gdip_DrawString(graphics, ch, hFont, hFormat, pBrushText, RC)
        CreateRectF(RC, 80 + CW, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:02d}", 63 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 140 + CW, i * size + top, 80, size), Gdip_DrawString(graphics, Format("0x{1:02X}", 63 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 200 + CW, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:03o}", 63 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 260 + CW, i * size + top, 80, size), Gdip_DrawString(graphics, Asc(ch), hFontCn, hFormat, pBrushText, RC)

		; 第三列
		ch := CP437 ? cp437_3[A_Index] : chr(128 + i)
        CreateRectF(RC, 20 + CW * 2, i * size + top, 80, size), Gdip_DrawString(graphics, ch, hFont, hFormat, pBrushText, RC)
        CreateRectF(RC, 80 + CW * 2, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:02d}", 127 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 140 + CW * 2, i * size + top, 80, size), Gdip_DrawString(graphics, Format("0x{1:02X}", 127 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 200 + CW * 2, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:03o}", 127 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 260 + CW * 2, i * size + top, 80, size), Gdip_DrawString(graphics, Asc(ch), hFontCn, hFormat, pBrushText, RC)

		; 第四列
		ch := CP437 ? cp437_4[A_Index] : chr(192 + i)
        CreateRectF(RC, 20 + CW * 3, i * size + top, 80, size), Gdip_DrawString(graphics, ch, hFont, hFormat, pBrushText, RC)
        CreateRectF(RC, 80 + CW * 3, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:02d}", 191 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 140 + CW * 3, i * size + top, 80, size), Gdip_DrawString(graphics, Format("0x{1:02X}", 191 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 200 + CW * 3, i * size + top, 80, size), Gdip_DrawString(graphics, Format("{1:03o}", 191 + A_Index), hFontCn, hFormat, pBrushText, RC)
        CreateRectF(RC, 260 + CW * 3, i * size + top, 80, size), Gdip_DrawString(graphics, Asc(ch), hFontCn, hFormat, pBrushText, RC)
	}

	Gdip_DrawLine(graphics, pPen, 10 + CW, 10, 10 + CW, h - 10)
	Gdip_DrawLine(graphics, pPen, 10 + CW * 2, 10, 10 + CW * 2, h - 10)
	Gdip_DrawLine(graphics, pPen, 10 + CW * 3, 10, 10 + CW * 3, h - 10)

    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hWnd, hBitmap)
	Gdip_DeleteBrush(pBrush), Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
	Gdip_DeleteFont(hFontCn), Gdip_DeleteFontFamily(hFamilyCn)
	Gdip_DeleteGraphics(graphics), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Gdip_Shutdown("pToken")
}

#MButton::
#!x::
	#include gdip.ahk
	#include ocr.ahk

	SysGet, xPrimary, 76  ; 获取主屏幕左上角X坐标
	SysGet, yPrimary, 77  ; 获取主屏幕左上角Y坐标
	SysGet, wScreen, 78   ; 获取屏幕宽度
	SysGet, hScreen, 79   ; 获取屏幕高度

	pToken := Gdip_Startup()
	mskSize = 30

	; 获取整个屏幕的截图
	hBitmap := HBitmapFromScreen(xPrimary, yPrimary, wScreen, hScreen)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
	pBitmapOut := Gdip_CreateBitmap(wScreen, hScreen)
	Gdip_PixelateBitmap(pBitmap, pBitmapOut, mskSize)

	Gui, Msk:New, +LastFound +AlwaysOnTop +ToolWindow -Caption
	Gui, Msk:Show, x0 y0 w%wScreen% h%hScreen%, 马赛克
	hWnd := WinExist()
	hdc := GetDC(hWnd)

	; 绘制马赛克后的位图到窗口
	graphics := Gdip_GraphicsFromHDC(hdc)
	Gdip_DrawImage(graphics, pBitmapOut, 0, 0, wScreen, hScreen)
return

#IfWinActive, 马赛克 ahk_class AutoHotkeyGUI
	MButton::
		Send, {Esc}
	WheelUp::
		mskSize := (mskSize - 5 < 5) ? 5 : mskSize - 5
		Gdip_PixelateBitmap(pBitmap, pBitmapOut, mskSize)
		Gdip_DrawImage(graphics, pBitmapOut, 0, 0, wScreen, hScreen)
		return
	WheelDown::
		mskSize := mskSize + 5 > 100 ? 100 : mskSize + 5
		Gdip_PixelateBitmap(pBitmap, pBitmapOut, mskSize)
		Gdip_DrawImage(graphics, pBitmapOut, 0, 0, wScreen, hScreen)
	return
#If

MskGuiEscape:
MskGuiClose:
MskGuiCancel:
	Gdip_DeleteGraphics(graphics)
	Gdip_DisposeImage(pBitmapOut)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
	DeleteObject(hBitmap)
	Gui, Destroy
	return

~CapsLock::
    status := GetKeyState("CapsLock", "T") ? "On" : "Off"
	OSD("CapsLock " . status)
	return
~NumLock::
    status := GetKeyState("NumLock", "T") ? "On" : "Off"
	OSD("NumLock " . status)
	return
~ScrollLock::
    status := GetKeyState("ScrollLock", "T") ? "On" : "Off"
	OSD("ScrollLock " . status)
	return
#Insert::
	; InputBox, word, 单词, `n使用百度进行翻译。`n请输入要翻译的内容，可以是句子或者单词,,400,180,,,,,%def%
	InputBox, TimeInput, 倒计时, 请输入倒计时时间`n输入格式: HH:MM:SS,, 200, 142,,,,,%TimeInput%
	if (ErrorLevel) {
		return
	}
	
	RegExMatch(TimeInput, "^(\d{1,2}):(\d{1,2}):(\d{1,2})$", match)
	if !match {
		return
	}
	TotalSeconds := (match1 * 3600) + (match2 * 60) + match3
	FormatTime, StartTime,, yyyy-MM-dd HH:mm:ss
	SetTimer, TimerDone, -%TotalSeconds%000
	return
TimerDone:
	FormatTime, now,, yyyy-MM-dd HH:mm:ss
    showMessage("提示", "倒计时 " . TimeInput . " 结果`n开始: " . StartTime . "`n结束: " . now)
    ComObjCreate("SAPI.SpVoice").Speak("倒计时已结束")
return

End:
