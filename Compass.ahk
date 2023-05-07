^!LButton::
	Compass.Snap := true
	Compass.ClearScale()
	Compass.Measure()    ; Ctrl+Alt+LButton
	return
^!RButton::
	Compass.Snap := false
	Compass.ClearScale()
	Compass.Measure()    ; Ctrl+Alt+LButton
	return

; Measure a known distance. Sets the scale factor for measuring subsequent distances.
;^!RButton::Compass.SetScale()   ; Ctrl+Alt+RButton
 
; Clear the scale factor. Distance will not be calculated for subsequent measurements.
;^#RButton::Compass.ClearScale() ; Ctrl+Win+RButton
 
; Toggle snap to horizontal/vertical when within +/-3 degrees.
;^F12::Compass.ToggleSnap()      ; Ctrl+F12

#If Compass.Lines.MaxIndex() > 0
; Deletes all lines on screen.
Esc::Compass.DeleteLines()      ; Escape
#If

; To change the orientation of the angle:
;   1   Up=90, Down=-90, Left=180, Right=0
;   2   Up=0,  Down=180, Left=270, Right=90
;Compass.SetOrientation(2) ; Default is 1


/*  Compass
 *  By kon - ahkscript.org/boards/viewtopic.php?t=7225
 *  Translation to stand-alone Gdip thanks to jNizM - ahkscript.org/boards/viewtopic.php?&t=7225&p=45589#p45570
 *  Updated 2020-08-11
 *      Measure angles and scale distances with your mouse. Press the hotkeys and drag your mouse between two points.
 *  Note:
 *      *If you change the Measure/SetScale hotkeys, also change the keys GetKeyState monitors in the while-loop.
 *  Methods:
 *      Measure             Measure angles and scale distances with your mouse.
 *      SetScale            Sets the scale factor to use for subsequent measurements.
 *      ToggleSnap          Toggle snap to horizontal/vertical when within +/-3 degrees.
 *  Methods (Internal):
 *      SetScaleGui         Displays a GUI which prompts the user for the distance measured.
 *      pxDist              Returns the distance between two points in pixels.
 *      DecFtToArch         Converts decimal feet to architectural.
 *      gcd                 Euclidean GCD.
 *  Added methods 2020-08-05:
 *      ClearScale          Clear the scale factor. Distance will not be calculated for subsequent measurements.
 *      AdjustSnap          Adjusts points as required for snap.
 *      GDIP_Start          Start GDIP.
 *      GDIP_Close          Close GDIP.
 *      GDIP_Setup          Setup window, brush, graphics, etc for GDIP.
 *      GDIP_Cleanup        Delete brush, graphics, etc.
 *      GDIP_CreatePen      Create pen.
 *      GDIP_DeletePen      Delete pen.
 *      GDIP_CreateBrush    Create brush.
 *      GDIP_DeleteBrush    Delete brush.
 *      GDIP_DrawLine       Draw a line.
 *      GDIP_UpdateWindow   Refresh the window.
 *      DeleteLines         Delete all lines.
 *      SetOrientation      Set the orientation of the angle
 *      UpdateLines         Redraw the lines in Convert.Lines and update the window.
 *      GetWinArea          Get the total resolution of all the monitors.
 *  Added methods and adjustments 2020-08-11 thanks to gwarble 
 *  https://www.autohotkey.com/boards/viewtopic.php?p=346071#p346071
 *  https://www.autohotkey.com/boards/viewtopic.php?p=346072#p346072
 *      GDIP_DrawCrosshair  Draw a crosshair (before the mouse is clicked)
 */
class Compass {
    static Color1 := 0xffff0000, Color2 := 0xff0066ff, Lineweight1 := 1
    , ScaleFactor := "", Units := "ft", Cross := 20
    , WinW := A_ScreenWidth ; this will be updated by Compass.GetWinArea() in case there are multiple monitors
    , WinH := A_ScreenHeight
    , Orientation := 1
    , Lines := []
    
    ; Measure angles and scale distances with your mouse. Returns a line object. The return value is used internally by
    ; the SetScale method.
    Measure() {
        Conv := 180 / (4 * ATan(1)) * (this.Orientation = 1 ? -1 : 1)
        if (this.pToken = "") {
            this.GetWinArea()
            this.GDIP_Start()
        }
        TTNum := this.Lines.MaxIndex() ? this.Lines.MaxIndex() + 1 : 1
        CoordMode, Mouse, Screen
        MouseGetPos, StartX, StartY
        MouseKey := SubStr(A_ThisHotkey, 3), PrevX := "", PrevY := ""
        , hMSVCRT := DllCall("kernel32.dll\LoadLibrary", "Str", "msvcrt.dll", "Ptr")
        while (GetKeyState("Ctrl", "P") && GetKeyState(MouseKey, "P")) {    ; *Loop until Ctrl or L/RButton is released.
            MouseGetPos, CurrentX, CurrentY
            if (PrevX != CurrentX) || (PrevY != CurrentY) {
                PrevX := CurrentX, PrevY := CurrentY
                if (this.Snap)
                    this.AdjustSnap(StartX, CurrentX, StartY, CurrentY)
                this.GDIP_DrawLine(StartX, CurrentX, StartY, CurrentY)
                , Angle := DllCall("msvcrt.dll\atan2", "Double", CurrentY - StartY, "Double", CurrentX - StartX, "CDECL Double") * Conv
                if (this.Orientation = 2)
                    Angle += Angle < -90 ? 450 : 90
                if (this.ScaleFactor) {
                    Dist := Format("{1:0.3f}", this.pxDist(CurrentX, StartX, CurrentY, StartY) * this.ScaleFactor)
                    if (this.Units = "ft")
                        Dist .= " ft (" . this.DecFtToArch(Dist) . ")"
                    else 
                        Dist .= " " . this.Units
                }
                ToolTip, % Format("{1:0.3f}", Angle) . "°" . (Dist ? "`n" Dist : ""),,, % TTNum
                this.UpdateLines()
            }
        }
        DllCall("kernel32.dll\FreeLibrary", "Ptr", hMSVCRT)
        if (this.Snap)
            this.AdjustSnap(StartX, CurrentX, StartY, CurrentY)
        Line := {"StartX": StartX, "EndX": CurrentX, "StartY": StartY, "EndY": CurrentY
            , "Angle": Format("{1:0.3f}", Angle) . "°", "Len": Dist, "pxDist": this.pxDist(StartX, CurrentX, StartY, CurrentY)}
        this.Lines.Push(Line)
        return Line
    }

    ; Enter the known distance measured to set the scale factor to be used with all subsequent calls to Measure. The
    ; user will be prompted to enter the real world dimension corresponding to the current measurement. Distance will be
    ; calculated for any subsequent measurements.
    SetScale() {
        this.SetScaleGui(this.Measure().pxDist)
        ; Pop the most recent line from this.Lines and redraw the remaining lines. (We don't want this line to remain
        ; on screen, or count towards the measurement total in this.Lines.MaxIndex().)
        ToolTip,,,, % this.Lines.MaxIndex()
        this.Lines.Pop()
        this.UpdateLines()
        if (this.Lines.MaxIndex() < 1)
            this.GDIP_Close()
    }

    ; Clear the scale factor. Distance will not be calculated for subsequent measurements.
    ClearScale() {
        this.ScaleFactor := 1
        this.Units := "像素"
    }
    
    SetScaleGui(pxLen) {
        static Text1, Text2, Text3, Edit1, Edit2, Button1
        Gui, SetScale: -Caption +Owner +LastFound +AlwaysOnTop
        WinID := WinExist()
        Gui, SetScale: Add, Text, vText1 x10 y10, Length
        Gui, SetScale: Add, Text, vText2 x110 y10, Units
        Gui, SetScale: Add, Edit, vEdit1 x10 y+10 w90
        GuiControlGet, Edit1, SetScale:pos, Edit1
        Gui, SetScale: Add, Edit, vEdit2 x+10 w90 y%Edit1Y%, % this.Units
        Gui, SetScale: Add, Text, vText3 x10 y+10, Enter the length of this measurement.
        Gui, SetScale: Add, Button, vButton1 x10 y+10 w190 gSetScaleOK Default, Ok
        Gui, SetScale: Show,, Set Scale
        WinSet AlwaysOnTop
        GuiControl, Focus, Edit1
        WinWaitNotActive, ahk_id %WinID%
        SetScaleGuiEscape:
        Gui, SetScale: Destroy
        return

        SetScaleOK:
        Gui, SetScale: Submit
        if Edit1 is number
            this.ScaleFactor := Edit1 / pxLen
        if (Edit2)
            this.Units := Edit2
        return
    }
    
    AdjustSnap(StartX, ByRef CurrentX, StartY, ByRef CurrentY) {
        if ((ADiff := Abs(CurrentY - StartY) / Abs(CurrentX - StartX))  < 0.052407 && ADiff)
            CurrentY := StartY
        else if (ADiff > 19.081136)
            CurrentX := StartX
    }
    
    ; Toggle snap to horizontal/vertical when within +/-3 degrees.
    ToggleSnap() {
        this.Snap := !this.Snap
        TrayTip, Compass, % "Snap: " (this.Snap ? "On" : "Off")
    }

    pxDist(x1, x2, y1, y2) {
        return Sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
    }

    DecFtToArch(DecFt, Precision:=16) {
        Ft := Floor(DecFt), In := 12 * Mod(DecFt, 1)
        , UpperLimit := 1 - (HalfPrecision := 0.5 / Precision)
        , Fraction := Mod(In, 1), In := Floor(In)
        if (Fraction >= UpperLimit) {
            In++, Fraction := ""
            if (In = 12)
                In := 0, Ft++
        }
        else if (Fraction < HalfPrecision)
            Fraction := ""
        else {
            Step := 1 / Precision
            loop % Precision - 1 {
                if (Fraction >= UpperLimit - (A_Index * Step)) {
                    gcd := this.gcd(Precision, n := Precision - A_Index)
                    , Fraction := " " n // gcd "/" Precision // gcd
                    break
                }
            }
        }
        return LTrim((Ft ? Ft "'-" : "") In Fraction """", " 0")
    }

    gcd(a, b) {
        while (b)
            b := Mod(a | 0x0, a := b)
        return a
    }
    
    GDIP_Start() {
        if !(DllCall("kernel32.dll\GetModuleHandle", "Str", "gdiplus", "Ptr"))
            this.hGDIPLUS := DllCall("kernel32.dll\LoadLibrary", "Str", "gdiplus.dll", "Ptr")
        VarSetCapacity(SI, 24, 0), NumPut(1, SI, 0, "UInt")
        DllCall("gdiplus.dll\GdiplusStartup", "UPtrP", pToken, "Ptr", &SI, "Ptr", 0)
        if !(this.pToken := pToken) {
            MsgBox, GDIPlus could not be started.`nCheck the availability of GDIPlus on your system.
            return
        }
        this.GDIP_Setup()
    }
    
    GDIP_Close() {
        this.GDIP_Cleanup()
        DllCall("gdiplus.dll\GdiplusShutdown", "UPtr", this.pToken)
        DllCall("kernel32.dll\FreeLibrary", "Ptr", this.hGDIPLUS)
        this.pToken := "", this.hGDIPLUS := "" ; Clear these values to indicate that GDIP is not started
    }
    
    GDIP_Setup() {
        Gui, Compass: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        Gui, Compass: Show, NA
        this.hWnd := WinExist()
        VarSetCapacity(BI, 40, 0), NumPut(this.WinW, BI, 4, "UInt"), NumPut(this.WinH, BI, 8, "UInt"), NumPut(40, BI, 0, "UInt")
        NumPut(1, BI, 12, "UShort"), NumPut(0, BI, 16, "UInt"), NumPut(32, BI, 14, "UShort")
        this.hbm := DllCall("gdi32.dll\CreateDIBSection", "Ptr", this.hdc := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "UPtr", &BI, "UInt", 0, "UPtr*", 0, "Ptr", 0, "UInt", 0, "Ptr")
        DllCall("user32.dll\ReleaseDC", "Ptr", this.hWnd, "Ptr", this.hdc)
        this.hdc := DllCall("gdi32.dll\CreateCompatibleDC", "Ptr", 0, "Ptr")
        this.obm := DllCall("gdi32.dll\SelectObject", "Ptr", this.hdc, "Ptr", this.hbm)
        DllCall("gdiplus.dll\GdipCreateFromHDC", "Ptr", this.hdc, "PtrP", Graphics)
        this.Graphics := Graphics
        DllCall("gdiplus.dll\GdipSetSmoothingMode", "Ptr", this.Graphics, "Int", 4)
        this.GDIP_CreatePen()
        this.GDIP_CreateBrush()
    }
    
    GDIP_Cleanup() {
        this.GDIP_DeletePen()
        this.GDIP_DeleteBrush()
        DllCall("gdi32.dll\SelectObject", "Ptr", this.hdc, "Ptr", this.obm)
        DllCall("gdi32.dll\DeleteObject", "Ptr", this.hbm)
        DllCall("gdi32.dll\DeleteDC", "Ptr", this.hdc)
        DllCall("gdiplus.dll\GdipDeleteGraphics", "Ptr", this.Graphics)
        this.hdc := "", this.obm := "", this.hdc := "", this.Graphics := ""
        Gui, Compass: Destroy
    }
    
    GDIP_CreatePen() {
        DllCall("gdiplus.dll\GdipCreatePen1", "UInt", this.Color1, "Float", this.Lineweight1, "Int", 2, "PtrP", pPen)
        this.pPen := pPen
    }
    
    GDIP_DeletePen() {
        DllCall("gdiplus.dll\GdipDeletePen", "Ptr", this.pPen)
        this.pPen := ""
    }
    
    GDIP_CreateBrush() {
        DllCall("gdiplus.dll\GdipCreateSolidFill", "Int", this.Color2, "PtrP", pBrush)
        this.pBrush := pBrush
    }
    
    GDIP_DeleteBrush() {
        DllCall("gdiplus.dll\GdipDeleteBrush", "Ptr", this.pBrush)
        this.pBrush := ""
    }
    
    GDIP_DrawLine(StartX, CurrentX, StartY, CurrentY) {
        DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", StartX, "Float", StartY, "Float", CurrentX, "Float", CurrentY)
        , DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", StartX+this.Cross, "Float", StartY, "Float", StartX-this.Cross, "Float", StartY)
        , DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", CurrentX, "Float", CurrentY+this.Cross, "Float", CurrentX, "Float", CurrentY-this.Cross)
        , DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", StartX, "Float", StartY+this.Cross, "Float", StartX, "Float", StartY-this.Cross)
        , DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", CurrentX+this.Cross, "Float", CurrentY, "Float", CurrentX-this.Cross, "Float", CurrentY)
        , DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", this.Graphics, "Ptr", this.pBrush, "Float", StartX - 4, "Float", StartY - 4, "Float", 8, "Float", 8) ;fixed uncentered circles...
        , DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", this.Graphics, "Ptr", this.pBrush, "Float", CurrentX - 4, "Float", CurrentY - 4, "Float", 8, "Float", 8)
    }
    
    GDIP_UpdateWindow() {
        VarSetCapacity(PT, 8), NumPut(0, PT, 0, "UInt"), NumPut(0, PT, 4, "UInt")
        , DllCall("user32.dll\UpdateLayeredWindow", "Ptr", this.hWnd, "Ptr", 0, "UPtr", &PT, "Int64*", this.WinW | this.WinH << 32, "Ptr", this.hdc, "Int64*", 0, "UInt", 0, "UInt*", 0x1FF0000, "UInt", 2)
        , DllCall("gdiplus.dll\GdipGraphicsClear", "Ptr", this.Graphics, "UInt", 0x00FFFFFF)
    }
    
    GDIP_DrawCrosshair(X, Y) {
        DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", X+this.Cross, "Float", Y, "Float", X-this.Cross, "Float", Y)
        , DllCall("gdiplus.dll\GdipDrawLine", "Ptr", this.Graphics, "Ptr", this.pPen, "Float", X, "Float", Y+this.Cross, "Float", X, "Float", Y-this.Cross)
        , DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", this.Graphics, "Ptr", this.pBrush, "Float", X - 4, "Float", Y - 4, "Float", 8, "Float", 8)
    }
    
    ; Clears all the visible lines
    DeleteLines() {
        for i, v in this.Lines
            ToolTip,,,, % i
        this.Lines := []
        this.GDIP_Close()
    }
    
    ; Orientation   Angle
    ; 1             Up=90, Down=-90, Left=180, Right=0
    ; 2             Up=0,  Down=180, Left=270, Right=90
    SetOrientation(Orientation:=1) {
        this.Orientation := Orientation
    }
    
    ; Redraw the lines in this.Lines and update the window
    UpdateLines() {
        for i, Line in this.Lines
            this.GDIP_DrawLine(Line.StartX, Line.EndX, Line.StartY, Line.EndY)
        this.GDIP_UpdateWindow()
    }
    
    ; Gets the max coordinates of all the monitors.
    GetWinArea() {
        SysGet, MonCnt, MonitorCount
        Loop, % MonCnt
        {
            SysGet, Mon, Monitor, % A_Index
            if (MonRight > this.WinW)
                this.WinW := MonRight
            if (MonBottom > this.WinH)
                this.WinH := MonBottom
        }
    }
    
    Crosshair() {
        if (this.pToken = "") {
            this.GetWinArea()
            this.GDIP_Start()
        }
        CoordMode, Mouse, Screen
        MouseGetPos, StartX, StartY
        while (GetKeyState("Ctrl", "P")) {    ; *Loop until Ctrl or L/RButton is released.
            MouseGetPos, CurrentX, CurrentY
            if (PrevX != CurrentX) || (PrevY != CurrentY) { ; only redraw when the mouse if moved
                PrevX := CurrentX, PrevY := CurrentY
                this.GDIP_DrawCrosshair(CurrentX, CurrentY)
                this.UpdateLines()
            }
        }
        this.UpdateLines()
    }
}