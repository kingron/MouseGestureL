;===============================================================================
;
;		MouseGestureL.ahk - Language Definition Module
;			<< English >>
;														Created by Pyonkichi
;===============================================================================
;-------------------------------------------------------------------------------
; Common
;-------------------------------------------------------------------------------
; Default Target Name
MC_DefTargetName = Default

; Default Settings
MC_PresetItems =
(%
[Ignored Targets]
Icon=%A_WinDir%\system32\shell32.dll,110

[Browser]
Icon=%A_WinDir%\system32\inetcpl.cpl,7
Exe=iexplore.exe
Exe=chrome.exe
Exe=firefox.exe

[Explorer]
Icon=%A_WinDir%\explorer.exe,1
WClass=CabinetWClass
WClass=ExploreWClass
WClass=Progman
WClass=WorkerW

[Icon]
Icon=%A_WinDir%\explorer.exe,1
Level=2
Custom=MG_TreeListHitTest()

[RB_]
G=RB_
Default=;Activate Window<MG_CR>MG_WinActivate()
Explorer/Icon=;Cancel Gesture<MG_CR>MG_Abort()

[RB_LB__]
G=RB_LB__
Default=;Close Window<MG_CR>PostMessage, 0x0010

[RB_L]
G=RB_L_
Default=;Back<MG_CR>Send, !{Left}

[RB_R]
G=RB_R_
Default=;Forward<MG_CR>Send, !{Right}

[RB_U]
G=RB_U_
Default=;Jump to Top<MG_CR>Send, ^{Home}

[RB_D]
G=RB_D_
Default=;Jump to Bottom<MG_CR>Send, ^{End}

[RB_LU]
G=RB_LU_

[RB_LD]
G=RB_LD_

[RB_RU]
G=RB_RU_
Default=;Activate Previous Active Window<MG_CR>if (MG_Defer()) {		MG_ActivatePrevWin()<MG_CR>}

[RB_RD]
G=RB_RD_
Default=;Minimize Window<MG_CR>PostMessage, 0x0112, 0xF020, 0

[RB_UL]
G=RB_UL_

[RB_UR]
G=RB_UR_

[RB_DL]
G=RB_DL_

[RB_DR]
G=RB_DR_
)

; Help File
MC_HelpFile = MouseGestureL_ENG.chm

; Buttons
MC_LngButton001 = &Close
MC_LngButton002 = C&opy to Clipboard

; Messages
MC_LngMessage001 = Help document is not found.
MC_LngMessage002 =
(LTrim
				There might be problem in the settings.
				Find cause of the problem from the following messages,
				and correct the settings with configuration dialog.
				If you cannot do it, restore the configuration file from your backup.
				
				------------------------------------------------------------`n`n
)

if (MG_IsEdit)
{
	Goto SetEdit
}
;-------------------------------------------------------------------------------
; for Application
;-------------------------------------------------------------------------------
; Menus
MG_LngMenu001 = &Enable Gesture
MG_LngMenu002 = Show &Gesture Hints
MG_LngMenu003 = &Configuration...
MG_LngMenu004 = Edit &User Extension Script
MG_LngMenu005 = Co&py Logs to Clipboard
MG_LngMenu006 = &Open Plugins Folder
MG_LngMenu007 = &Plugins
MG_LngMenu008 = &Language...
MG_LngMenu009 = MouseGestureL &Help
MG_LngMenu010 = &About MouseGestureL
MG_LngMenu011 = &Restart MouseGestureL
MG_LngMenu012 = E&xit
MG_LngMenu013 = &Mouse Gesture

; Tooltips
MG_LngTooltip001 = Gesture Enabled
MG_LngTooltip002 = Gesture Disabled
MG_LngTooltip003 = Hints ON
MG_LngTooltip004 = Hints OFF

; Other Text
MG_LngOthers001 =
(LTrim
				;===============================================================================
				;
				;		User Extension Script for MouseGestureL.ahk
				;
				;	- Additional initialization process and user-defined subroutines and
				;	  functions can be described to this file.
				;	- You can change the size of the configuration dialog box by setting
				;	  the appropriate variables.
				;	- Script must be reloaded when you have modified contents of this.
				;
				;===============================================================================

)
MG_LngOthers002 = Initialization Process
MG_LngOthers003 = Subroutine Definition
MG_LngOthers004 = for MouseGestureL.ahk
MG_LngOthers005 = for MG_Edit.ahk
MG_LngOthers006 = for both MouseGestureL.ahk and MG_Edit.ahk

Goto EndLanguage

;-------------------------------------------------------------------------------
; for MG_Edit
;-------------------------------------------------------------------------------
SetEdit:

; Gesture Triggers
Button_LB	= Left-Button Down
Button_RB	= Right-Button Down
Button_MB	= Middle-Button Down
Button_X1B	= Button-4 Down
Button_X2B	= Button-5 Down
Button_X3B	= Button-6 Down
Button_X4B	= Button-7 Down
Button_X5B	= Button-8 Down
Button_X6B	= Button-9 Down
Button_X7B	= Button-10 Down
Button_X8B	= Button-11 Down
Button_X9B	= Button-12 Down
Button_WU	= Wheel-Up
Button_WD	= Wheel-Down
Button_LT	= Wheel-Tilting Left
Button_RT	= Wheel-Tilting Right
Button_ET	= Touch Screen Top (All)
Button_ETA	= Touch Screen Top (Left Half)
Button_ETB	= Touch Screen Top (Right Half)
Button_ET1	= Touch Screen Top (Left 1/3)
Button_ET2	= Touch Screen Top (Center 1/3)
Button_ET3	= Touch Screen Top (Right 1/3)
Button_EB	= Touch Screen Bottom (All)
Button_EBA	= Touch Screen Bottom (Left Half)
Button_EBB	= Touch Screen Bottom (Right Half)
Button_EB1	= Touch Screen Bottom (Left 1/3)
Button_EB2	= Touch Screen Bottom (Center 1/3)
Button_EB3	= Touch Screen Bottom (Right 1/3)
Button_EL	= Touch Screen Left (All)
Button_ELA	= Touch Screen Left (Upper Half)
Button_ELB	= Touch Screen Left (Lower Half)
Button_EL1	= Touch Screen Left (Upper 1/3)
Button_EL2	= Touch Screen Left (Middle 1/3)
Button_EL3	= Touch Screen Left (Lower 1/3)
Button_ER	= Touch Screen Right (All)
Button_ERA	= Touch Screen Right (Upper Half)
Button_ERB	= Touch Screen Right (Lower Half)
Button_ER1	= Touch Screen Right (Upper 1/3)
Button_ER2	= Touch Screen Right (Middle 1/3)
Button_ER3	= Touch Screen Right (Lower 1/3)
Button_CRT	= Touch Screen Right-Top Corner
Button_CLT	= Touch Screen Left-Top Corner
Button_CRB	= Touch Screen Right-Bottom Corner
Button_CLB	= Touch Screen Left-Bottom Corner

; Action Categories
ActionType001 = All
ActionType002 = Input Device Emulation
ActionType003 = Scrolling
ActionType004 = Window Control
ActionType005 = Process Control
ActionType006 = Application Control
ActionType007 = Sound Control
ActionType008 = Script Control
ActionType009 = Hints and Trail
ActionType010 = Control all windows of the same class
ActionType100 = Others

; Action Templates
ActionName001 = Generate Key Stroke
ActionName002 = Generate Mouse Click
ActionName003 = Generate Wheel Rotation
ActionName004 = Move Cursor
ActionName005 = Scroll
ActionName006 = Drag-Scroll
ActionName007 = Activate Window
ActionName008 = Minimize Window
ActionName009 = Maximize Window
ActionName010 = Restore Window
ActionName011 = Close Window
ActionName012 = Send Window to Bottom
ActionName013 = Turn on Window Topmost
ActionName014 = Turn off Window Topmost
ActionName015 = Toggle Window Topmost
ActionName016 = Move and Resize Window
ActionName017 = Change Window Transparency
ActionName018 = Turn off Window Transparency
ActionName019 = Activate Previous Active Window
ActionName020 = Run Program
ActionName021 = Kill Process
ActionName022 = Execute Toolbar Button Command
ActionName023 = Execute Menubar Commond
ActionName024 = Sound Volume
ActionName025 = Mute Sound
ActionName026 = Play a Sound
ActionName027 = Abort Current Gesture
ActionName028 = Wait for Next Gesture
ActionName029 = Wait
ActionName030 = Execute After Waiting
ActionName031 = Execute After Button Up
ActionName032 = Repeat Until Button Up
ActionName033 = Execute After Recognition Process
ActionName034 = Control Active Window as Target
ActionName035 = Show Text as Tooltip Hints
ActionName036 = Stop Gesture Hints
ActionName037 = Stop Gesture Trail
ActionName038 = Copy Text to Clipboard
ActionName039 = Post Message
ActionName040 = Send Message
ActionName041 = Minimize all windows of the same class
ActionName042 = Close all windows of the same class
ActionName043 = Tile all windows of the same class

; Action Comments
ActionComment001 = Action to be run immediately after the gesture.
ActionComment002 = Action to be run when the waiting time has elapsed.
ActionComment003 = Action to be repeated while a button is pressed.
ActionComment004 = Action to be run when a button has been released.
ActionComment005 = Action to be run when a button has been released.
ActionComment006 = Action to be run when a recognition has been finished.

; Caption of Dialog Box
ME_LngCapt001 = MouseGestureL
ME_LngCapt002 = MouseGestureL Configuration
ME_LngCapt003 = Confirm Deletion
ME_LngCapt004 = Create New Button
ME_LngCapt005 = Specify a Script Editor
ME_LngCapt006 = Individual Arrow Colors
ME_LngCapt007 = Rectangular Region
ME_LngCapt008 = Excluded windows for task switcher
ME_LngCapt009 = Task List
ME_LngCapt011 = Add Action
ME_LngCapt012 = Input Keystroke
ME_LngCapt013 = Edit Keystroke Directly
ME_LngCapt014 = Establish Mouse Click
ME_LngCapt015 = Establish Wheel Rotation
ME_LngCapt016 = Establish Cursor Movement
ME_LngCapt017 = Establish Scroll
ME_LngCapt018 = Establish Drag-Scroll
ME_LngCapt019 = Establish Move and Resize Window
ME_LngCapt022 = Specify a Launch File
ME_LngCapt023 = Specify a Sound File
ME_LngCapt024 = Post/SendMessage
ME_LngCapt025 = Choose Icon File
ME_LngCapt026 = Minimize all windows of the same class
ME_LngCapt027 = Close all windows of the same class
ME_LngCapt028 = Tile all windows of the same class

; Tabs
ME_LngTab001 = Main`nTargets`nGestures`nRecognition`nHints`nTrail && Logs`nOthers

; Menus
ME_LngMenu001 = Window Elements
ME_LngMenu002 = Titlebar
ME_LngMenu003 = Titlebar Icon
ME_LngMenu004 = Minimize Button
ME_LngMenu005 = Maximize Button
ME_LngMenu006 = Close Button
ME_LngMenu007 = Help Button
ME_LngMenu008 = Menubar
ME_LngMenu009 = Vertical Scrollbar
ME_LngMenu010 = Horizontal Scrollbar
ME_LngMenu011 = Window Frame
ME_LngMenu012 = Resizable Corner
ME_LngMenu013 = Other Area
ME_LngMenu014 = Tree/List
ME_LngMenu015 = Mouse Cursor
ME_LngMenu016 = Normal (Arrow)
ME_LngMenu017 = Line (Text Input)
ME_LngMenu018 = Finger (Link Hover)
ME_LngMenu019 = Sand Glass
ME_LngMenu020 = Cross
ME_LngMenu021 = Disabled
ME_LngMenu022 = Arrow + Sand Glass
ME_LngMenu023 = Arrow + Question Mark
ME_LngMenu024 = 4-Direction Arrow
ME_LngMenu025 = Up-Down Arrow
ME_LngMenu026 = Left-Right Arrow
ME_LngMenu027 = UL-DR Arrow
ME_LngMenu028 = UR-DL Arrow
ME_LngMenu029 = Vertical Arrow
ME_LngMenu030 = Any of the above curors
ME_LngMenu031 = Default (Application Specified)
ME_LngMenu032 = Window Status
ME_LngMenu033 = Maximized
ME_LngMenu034 = Normal
ME_LngMenu035 = Transparent
ME_LngMenu036 = Opaque
ME_LngMenu037 = Topmost
ME_LngMenu038 = Non-Topmost
ME_LngMenu039 = Keyboard Status
ME_LngMenu040 = Shift Key Down
ME_LngMenu041 = Shift Key Up
ME_LngMenu042 = Ctrl Key Down
ME_LngMenu043 = Ctrl Key Up
ME_LngMenu044 = Alt Key Down
ME_LngMenu045 = Alt Key Up
ME_LngMenu046 = Rectangular Region
ME_LngMenu047 = Window Relative
ME_LngMenu048 = Screen Absolute
ME_LngMenu049 = Screen Edge Recognition
ME_LngMenu050 = Create New Button
ME_LngMenu102 = (None)
ME_LngMenu105 = Configure &Target
ME_LngMenu103 = &New Target	Ctrl+N
ME_LngMenu104 = Add &Sub Target
ME_LngMenu106 = &Delete	Delete
ME_LngMenu107 = Du&plicate
ME_LngMenu108 = &Copy to Clipboard	Ctrl+C
ME_LngMenu109 = &Import from Clipboard	Ctrl+V
ME_LngMenu110 = Move &Up	Shift+Up
ME_LngMenu111 = Move D&own	Shift+Down
ME_LngMenu112 = So&rt in Ascending
ME_LngMenu113 = &Fold All Sub Targets	Ctrl+F
ME_LngMenu114 = Configure &Gesture
ME_LngMenu115 = &Add Gesture
ME_LngMenu116 = Define &New Gesture
ME_LngMenu121 = &New Gesture	Ctrl+N
ME_LngMenu131 = Change &Target

; Static Text
ME_LngText001 = &Targets:
ME_LngText002 = &Gestures:
ME_LngText003 = &Target Priorities:
ME_LngText004 = Action &Script:
ME_LngText005 = Cat&egory:
ME_LngText021 = Gesture Triggers:
ME_LngText022 = Cursor Movement:
ME_LngText023 = Button Name:
ME_LngText024 = Key String:
ME_LngText025 = Default Action:
ME_LngText026 = H
ME_LngText027 = L
ME_LngText051 = &Name:
ME_LngText052 = &Type:
ME_LngText053 = &Value:
ME_LngText054 = &Rule:
ME_LngText100 = Stroke sampling interval (ms):
ME_LngText101 = Detection start:
ME_LngText102 = 4-Direction "LL" and "RR":
ME_LngText103 = 4-Direction "UU" and "DD":
ME_LngText104 = 8-Direction long diagonal:
ME_LngText105 = First stroke:
ME_LngText106 = After orthogonal:
ME_LngText107 = After diagonal:
ME_LngText108 = Cursor movement to start judgment of timeout (pixels):
ME_LngText109 = Time threshold (ms):
ME_LngText110 = Time limit of double gesture (ms):
ME_LngText111 = Sampling interval (ms):
ME_LngText112 = Range of corners:
ME_LngText113 = Horizontal:
ME_LngText114 = Vertical:
ME_LngText115 = Waiting time to forced release trigger buttons after timeout (sec):`n( 0 to Disable forced release function )
ME_LngText200 = Type of hints:
ME_LngText201 = Interval of drawing process:
ME_LngText202 = Persistence time of hints:
ME_LngText203 = Color of arrows (RRGGBB):
ME_LngText204 = Background color (RRGGBB):
ME_LngText205 = Transparency (0～255):
ME_LngText206 = Size of arrows:
ME_LngText207 = Spaces between arrows:
ME_LngText208 = Margin from edge:
ME_LngText209 = Distance from cursor:`n( -1 to Stay in origin )
ME_LngText210 = Arrow color:
ME_LngText300 = Text color (RRGGBB):
ME_LngText301 = Text color 2 (RRGGBB):
ME_LngText302 = Background color (RRGGBB):
ME_LngText303 = Transparency (0～255):
ME_LngText304 = Character size:
ME_LngText305 = Font name:
ME_LngText306 = Position:
ME_LngText307 = Left margin:
ME_LngText308 = Right margin:
ME_LngText309 = Top margin:
ME_LngText310 = Bottom margin:
ME_LngText311 = Roundness of corners:
ME_LngText312 = Distance from cursor:`n( -1 to Stay in origin )
ME_LngText313 = Distance from H-edge:
ME_LngText314 = Distance from V-edge:
ME_LngText400 = Line color (RRGGBB):
ME_LngText401 = Line transparency (0～255):
ME_LngText402 = Line width:
ME_LngText403 = Cursor movement to start gesture trail:
ME_LngText404 = Interval of drawing process (ms):
ME_LngText421 = X:
ME_LngText422 = Y:
ME_LngText423 = Number of log lines:
ME_LngText424 = Width of log window:
ME_LngText451 = Toggle Gesture Enabling:
ME_LngText452 = Toggle Gesture Hints:
ME_LngText453 = Restart MouseGestureL:
ME_LngText455 = Limit of height ( 0 to No limit ):
ME_LngText501 = Width:
ME_LngText502 = Height:
ME_LngText503 = * 0 in Width or Height means whole window size.
ME_LngText504 = Target:
ME_LngText505 = Origin:
ME_LngText506 = Judge in:
ME_LngText521 = Input Key:
ME_LngText522 = Button:
ME_LngText523 = Operation:
ME_LngText524 = Count:
ME_LngText525 = Operation:
ME_LngText526 = Click Count:
ME_LngText527 = Unit of Rotation:
ME_LngText528 = Origin:
ME_LngText529 = Direction:
ME_LngText530 = Unit of Scroll:
ME_LngText531 = This can scroll the target by cursor movement while a button is pressed.
ME_LngText532 = * This function has to be assigned to the gesture when a button is being`n   pressed.
ME_LngText533 = Vertical Sensitivity:
ME_LngText534 = Horizontal Sensitivity:
ME_LngText535 = (Smaller value is higher sensitivity)
ME_LngText536 = Direction:
ME_LngText537 = Operation:
ME_LngText541 = Specify the upper-left coordinates and size of the window.
ME_LngText542 = - The item which is specified with blank will not be changed.
ME_LngText543 = - If "Relative Value" is checked, the position/size of the`n  window will be increased or decreased from current`n  position/size.
ME_LngText544 = - If "Relative Value" is checked and fractions are specified,`n  the position/size of the window will be determined by ratio`n  to current position/size.
ME_LngText545 = - If "Relative Value" is unchecked and fractions are specified,`n  the position/size of the window will be determined by ratio`n  to the desktop size.`n  (Specify "0" instead of "1/1" to Width and Height.)
ME_LngText546 = Left:
ME_LngText547 = Top:
ME_LngText548 = Width:
ME_LngText549 = Height:
ME_LngText551 = Command Line:
ME_LngText552 = Working Folder:
ME_LngText553 = Window State:
ME_LngText554 = Privilege Level:
ME_LngText556 = Program Files (*.exe)
ME_LngText557 = Sound Files (*.wav;*.mid)
ME_LngText558 = Icon Files (*.ico;*.exe;*.dll;*.cpl;*.icl)
ME_LngText561 = Message:
ME_LngText562 = wParam:
ME_LngText563 = lParam:
ME_LngText571 = Strings to filter by window title: (These can be blank)
ME_LngText572 = String to include:
ME_LngText573 = String to exclude:
ME_LngText581 = Direction of tiling:
ME_LngText582 = Left side:
ME_LngText583 = Right side:
ME_LngText584 = Upper side:
ME_LngText585 = Lower side:

; Buttons
ME_LngButton001 = &OK
ME_LngButton002 = &Cancel
ME_LngButton003 = MouseGestureL &Help
ME_LngButton004 = &Import from clipboard
ME_LngButton005 = +
ME_LngButton006 = -
ME_LngButton007 := Chr(0xE9)
ME_LngButton008 := Chr(0xEA)
ME_LngButton009 = S
ME_LngButton010 = C
ME_LngButton011 = F
ME_LngButton012 = X
ME_LngButton013 = Change
ME_LngButton014 = Add
ME_LngButton015 = Update
ME_LngButton016 = E
ME_LngButton017 = Helper
ME_LngButton018 = Delete
ME_LngButton019 = Add Trigger
ME_LngButton020 = Any button up
ME_LngButton021 = Remove last one step`nfrom current gesture
ME_LngButton022 = Register to Startup
ME_LngButton023 = Remove from Startup
ME_LngButton024 = Set individual arrow colors
ME_LngButton025 = Edit
ME_LngButton026 = Special Key
ME_LngButton027 = Browse...
ME_LngButton028 = Apply Icon
ME_LngButton029 = Specify the excluded windows for task switcher
ME_LngButton030 = Select from existing windows...
ME_LngButton031 = Select

; Items of Drop Down List
ME_LngDropDown001 = Match Any Rule`nMatch All Rules
ME_LngDropDown002 = Window Class`nControl Class`nFile Name`nTitle`nCustom Condition`nMatch Other Targets
ME_LngDropDown003 = Match Exact Word`nMatch Partial Word`nMatch Prefix`nMatch Suffix`nRegular Expression
ME_LngDropDown004 = Tooltips`nArrows Type 1`nArrows Type 2`nAdvanced`nNavigation
ME_LngDropDown005 = Cursor Position`nUpper-Left Corner`nUpper-Right Corner`nLower-Left Corner`nLower-Right Corner
ME_LngDropDown006 = Upper-Left Corner`nUpper-Right Corner`nLower-Left Corner`nLower-Right Corner`nSpecified Coordinates
ME_LngDropDown101 = Relative Coordinates of Target Window`nRelative Coordinates of Target Control`nAbsolute Coordinates of Screen
ME_LngDropDown102 = Upper-Left`nUpper-Right`nLower-Left`nLower-Right
ME_LngDropDown103 = Gesture Starting Position`nGesture Ending Position
ME_LngDropDown201 = Left Button`nRight Button`nMiddle Button`nX1 Button`nX2 Button
ME_LngDropDown202 = Normal Stroke`nPress Down`nRelease 
ME_LngDropDown203 = Click`nPress Down`nRelease 
ME_LngDropDown204 = Gesture Starting Position`nAction Starting Position`nCurrent Cursor Position
ME_LngDropDown205 = Scroll Up`nScroll Down`nScroll Left`nScroll Right
ME_LngDropDown206 = Same direction of a cursor movement`nOpposite direction of a cursor movement
ME_LngDropDown207 = Scroll as much as the cursor movement`nScroll automatically while a button is pressed
ME_LngDropDown208 = Normal Window`nMinimized`nMaximized`nHidden
ME_LngDropDown209 = Run as User`nRun as Administrator
ME_LngDropDown210 = Horizontal`nVertical`nAs Panes

; Column Titles of ListView
ME_LngListView001 = Type`nValue
ME_LngListView002 = Gesture`nAction
ME_LngListView003 = Target`nAction
ME_LngListView004 = Trigger`nColor
ME_LngListView005 = Title`nWindow Class`nFilename

; Group Box
ME_LngGroupBox001 = General settings of recognition process
ME_LngGroupBox002 = Detection Threshold (pixels)
ME_LngGroupBox003 = Diagonal Angle
ME_LngGroupBox004 = Timeout
ME_LngGroupBox005 = Screen Edge Recognition
ME_LngGroupBox006 = Extra Mouse Buttons
ME_LngGroupBox007 = Common Options
ME_LngGroupBox008 = Arrow Hints
ME_LngGroupBox009 = Advanced Hints
ME_LngGroupBox010 = Gesture Trail
ME_LngGroupBox011 = Logging
ME_LngGroupBox012 = Hotkeys
ME_LngGroupBox013 = Script Editor
ME_LngGroupBox014 = Startup
ME_LngGroupBox015 = Task Switcher
ME_LngGroupBox016 = Others
ME_LngGroupBox017 = &Icon
ME_LngGroupBox101 = Direction of Wheel Rotation
ME_LngGroupBox102 = Edge areas to exclude from the screen for tiling

; Check Box
ME_LngCheckBox001 = Not match
ME_LngCheckBox002 = Don't inherit the rules from parent target
ME_LngCheckBox003 = 8-Direction mode
ME_LngCheckBox004 = Control active window as target
ME_LngCheckBox005 = Recognize each display area individually
ME_LngCheckBox006 = Disable default behavior of Middle Button
ME_LngCheckBox007 = Disable default behavior of X1 Button
ME_LngCheckBox008 = Disable default behavior of X2 Button
ME_LngCheckBox009 = Show gesture hints by default
ME_LngCheckBox010 = Transparent background
ME_LngCheckBox011 = Show hints when trigger button is pressed
ME_LngCheckBox012 = Show gesture trail
ME_LngCheckBox013 = Show gesture logs
ME_LngCheckBox014 = Draw trail into overwrap window
ME_LngCheckBox015 = Cascade mouse gesture tray menu
ME_LngCheckBox016 = Adjust dialog box height to the number of items
ME_LngCheckBox017 = Don't reproduce original mouse movements when undefined gesture is performed
ME_LngCheckBox101 = Shift
ME_LngCheckBox102 = Ctrl
ME_LngCheckBox103 = Alt
ME_LngCheckBox110 = Absolute Coordinates
ME_LngCheckBox111 = Page Scroll
ME_LngCheckBox112 = Relative Value

; Radio Button
ME_LngRadioBtn001 = Rotation Up
ME_LngRadioBtn002 = Rotation Down

; Messages
ME_LngMessage001 = "[#REPLASE#]"
ME_LngMessage002 := ", "
ME_LngMessage003 := " is assigned to Gesture [#REPLASE#].`n"
ME_LngMessage004 := " is included in Target [#REPLASE#].`n"
ME_LngMessage005 = `nAre you sure to delete this?
ME_LngMessage006 = The Actions are assigned to this Gesture.`nAre you sure to delete this?
ME_LngMessage007 = This button name already exists.
ME_LngMessage008 = Do you want to convert existing gestures to [#REPLASE#]-direction mode?
ME_LngMessage009 = `n`n* The diagonal movement will be removed.
ME_LngMessage010 = Do you want to launch MouseGestureL.ahk as administrator on startup?
ME_LngMessage011 = MouseGestureL.ahk has been registered to startup.
ME_LngMessage012 = MouseGestureL.ahk has been removed from startup.
ME_LngMessage013 = Only alphanumeric characters can be used to the trigger name.
ME_LngMessage101 = The menu bar item of the application can be executed.`n`n  - There are unsupported applications.`n`nSpcify the menu items (Delimiter: [ , ]   Max: 6 Level Deep):
ME_LngMessage102 = Input program command line or URL.
ME_LngMessage104 = Spcify a transparency.`n`n  0: Transparent  ...  255: Opaque
ME_LngMessage105 = Specify one of the following values.`n`n      0 ... 100	: Set Absolute Value`n     +1 ... +100	: Increment`n     -1 ... -100	: Decrement
ME_LngMessage106 = Specify one of the following characters.`n`n     1 : Mute ON`n     0 : Mute OFF`n     + : Toggle Mute
ME_LngMessage107 = Specify the sound file to be played.`n`n  * The file format that is not supported by OS cannot be played.
ME_LngMessage108 = After a button is released once, the next button-down event will be`naccepted as a continuation of same gesture until the timeout.`n`n  - This function has to be assigned to the gesture when a button is`n    released.`n`n  << Example: Right double-click >>  `n    1. Assign this function to RB__.`n    2. Assign the action for double-click to RB__RB__.`n`nSpecify the timeout in millisecond:
ME_LngMessage109 = Script stops until the specified time has elapsed.`n`n  - Next gesture cannot be accepted while waiting.`n    If you need long waiting, you'd better use`n    "Execute After Recognition Process".`n`nSpecify the waiting time in millisecond:
ME_LngMessage110 = The action is delayed until specified time has elapsed since gesture was`nrecognized.`n`n  - If this function is assigned to the gesture when a button is being pressed,`n    it performs as "Pressing and Holding a Button".`n  - If the gesture status is changed before the waiting time has not elapsed,`n    the action is canceled.`n`n  << Example: Single-click and double-click of middle button >>`n   The action of single-click only performs when you don't double-click`n   with following settings.`n    1. Assign this function to MB__ and describe the action for single-click`n       into after the "else {".`n    2. Assign the action for double-click to MB__MB__.`n`nSpecify the delay time in millisecond:
ME_LngMessage111 = The action is executed when a button has been released`nafter the specified time has elapsed.`n`n  - This function has to be assigned to the gesture when`n    a button is being pressed.`n`nSpecify the waiting time in millisecond:
ME_LngMessage112 = The action is repeated at a specified intervals while`na button is being pressed.`n`n  - This function has to be assigned to the gesture`n    when a button is being pressed.`n`nSpecify the interval in millisecond:
ME_LngMessage113 = The action is executed when the recognition process`nhas been finished.`n`n  - This function is used if the action script is stopped`n    for a long time.`n    For example, a message box is displayed by the script.`n
ME_LngMessage114 = Show the text with Tooltip Hints.`n`n  - This function has to be assigned to the gesture when a button`n    is being pressed.`n  - This does not work if Tooltip Hints is disabled.`n  - If you want to show multiline text, press the "OK" to close`n    this dialog, then edit the inside text of ( ).`n`nInput text to be shown:
ME_LngMessage115 = Set the text to Clipboard`n`n  - Tab is ``t、 Return is ``n`n  - If you want to copy multiline text, press the "OK" to close`n    this dialog, then edit the inside text of ( ).`n`nInput text to be copied:
ME_LngMessage116 = Input key stroke string.`n`n    Format: +^!#{Key Name}	+ :Shift	  ^ :Ctrl`n				! :Alt	  # :Windows`n`n  - The { } surrounding the key name of a single character can be omitted.`n  - {Key Down} for Press Down, {Key Up} for Press Up.`n  - {LButton},{RButton},{MButton},{XButton1} and {XButton2} for a Mouse Click.`n  - If you specify the multiple keys, it will generate the serial key strokes.

; Tooltips
ME_LngTooltip001 = "[#REPLASE#]" has been copied to clipboard.
ME_LngTooltip002 = Settings have been imported.
ME_LngTooltip003 = Right-Click on Target Window
ME_LngTooltip004 = Right-Click on Target Button
ME_LngTooltip005 = Select the Rectangular Region by Left Dragging

; Fonts
ME_AdNaviFont	 = Meiryo
ME_ScriptFont	 = MS Gothic
ME_ScriptSize	 =
ME_ArrowFont	 = Wingdings
ME_ArrowSize	 = S8
ME_ArrowAlignUp	 = +0x0400
ME_ArrowAlignDn	 = +0x0800

; Other Text
ME_LngOthers001	 = Default
ME_LngOthers002	 = Target
ME_LngOthers003	 = N/A
ME_LngOthers004	 = 
ME_LngOthers005	 = Match Partial Word
ME_LngOthers006	 = Match Prefix
ME_LngOthers007	 = Match Suffix
ME_LngOthers008	 = Regular Expression
ME_LngOthers009	 = Not Match
ME_LngOthers010	 = Not Match Partial Word
ME_LngOthers011	 = Not Match Prefix
ME_LngOthers012	 = Not Match Suffix
ME_LngOthers013	 = Not Match by RegExp.

;-------------------------------------------------------------------------------
EndLanguage:
	MG_Language := RegExReplace(A_LineFile, "m)^.+\\|\.ahk$")

