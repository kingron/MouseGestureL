; 转换为十六进制字符串
strToHex(str)
{
    static v := A_IsUnicode ? "_i64tow" : "_i64toa"
    loop, parse, str
    {
        VarSetCapacity(s, 65, 0)
        DllCall("msvcrt.dll\" v, "Int64", Asc(A_LoopField), "Str", s, "UInt", 16, "CDECL")
        hex .= "0x" s " "
    }
    return SubStr(hex, 1, (StrLen(hex) - 1))
}

; 进制转换
;MsgBox, % "Decimal:`t`t42`n"
;        . "to Binary:`t`t"      ConvertBase(10, 2, 42)       "`n"
;        . "to Octal:`t`t"       ConvertBase(10, 8, 42)       "`n"
;        . "to Hexadecimal:`t"   ConvertBase(10, 16, 42)      "`n`n"
;        . "Hexadecimal:`t2A`n"
;        . "to Decimal:`t"       ConvertBase(16, 10, "2A")    "`n"
;        . "to Octal:`t`t"       ConvertBase(16, 8, "2A")     "`n"
;        . "to Binary:`t`t"      ConvertBase(16, 2, "2A")     "`n`n"
ConvertBase(InputBase, OutputBase, nptr)
{
    static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
    static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
    VarSetCapacity(s, 66, 0)
    value := DllCall("msvcrt.dll\" u, "Str", nptr, "UInt", 0, "UInt", InputBase, "CDECL Int64")
    DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", OutputBase, "CDECL")
    return s
}

CRC32(str)
{
    static table := []
    loop 256 {
        crc := A_Index - 1
        loop 8
            crc := (crc & 1) ? (crc >> 1) ^ 0xEDB88320 : (crc >> 1)
        table[A_Index - 1] := crc
    }
    crc := ~0
    loop, parse, str
        crc := table[(crc & 0xFF) ^ Asc(A_LoopField)] ^ (crc >> 8)
    return Format("{:#x}", ~crc)
}

; ===============================================================================================================================
; CRC32 Files via DllCall (WinAPI)
; ===============================================================================================================================

CRC32_File(filename)
{
    if !(f := FileOpen(filename, "r", "UTF-8"))
        throw Exception("Failed to open file: " filename, -1)
    f.Seek(0)
    while (dataread := f.RawRead(data, 262144))
        crc := DllCall("ntdll.dll\RtlComputeCrc32", "uint", crc, "ptr", &data, "uint", dataread, "uint")
    f.Close()
    return Format("{:#x}", crc)
}

GetVersion()
{
    return { 1 : DllCall("Kernel32.dll\GetVersion") & 0xff
           , 2 : DllCall("Kernel32.dll\GetVersion") >> 8 & 0xff
           , 3 : DllCall("Kernel32.dll\GetVersion") >> 16 & 0xffff }
}

; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Version: 2015-5-29 / Added 'reset' option (by tmplinshi)
;          2014-7-03 / toralf
;          2014-1-2  / tmplinshi
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH(DimSize, cList*){       ; http://ahkscript.org/boards/viewtopic.php?t=1079
  static cInfo := {}

  If (DimSize = "reset")
    Return cInfo := {}

  For i, ctrl in cList {
    ctrlID := A_Gui ":" ctrl
    If ( cInfo[ctrlID].x = "" ){
        GuiControlGet, i, %A_Gui%:Pos, %ctrl%
        MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
        fx := fy := fw := fh := 0
        For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
            If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
              f%dim% := 1
        cInfo[ctrlID] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a , m:MMD}
    }Else If ( cInfo[ctrlID].a.1) {
        dgx := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
        For i, dim in cInfo[ctrlID]["a"]
            Options .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
        GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % Options
} } }