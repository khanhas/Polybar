#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Taskbar Magic.ico
#AutoIt3Wrapper_outfile=Taskbar Magic.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseAnsi=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "appbarHelper.au3"

setState(0, 1)

HotKeySet("!^{esc}", "overRide")

If Not FileExists("settings.ini") Then
	FileWrite("settings.ini", "")
EndIf

Dim $size[4]
$hwnd = 0
$running = True

$dockEdge = IniRead("settings.ini", "settings", "dockEdge", "Bottom")

If $dockEdge == "Top" Then
	$dockEdge = $ABE_TOP
ElseIf $dockEdge == "Left" Then
	$dockEdge = $ABE_LEFT
ElseIf $dockEdge == "Right" Then
	$dockEdge = $ABE_Right
Else
	$dockEdge = $ABE_BOTTOM
EndIf

$GUI = GUICreate("Taskbar Hider Options", 445, 130)
GUICtrlCreateLabel("Allocate", 15, 42)
$heightBox = GUICtrlCreateInput(getDefAllocation(), 60, 40, 81, 21)
	$upDown = GUICtrlCreateUpdown($heightBox)
GUICtrlCreateLabel("pixels at the bottom of the screen", 145, 42)
$runOnStartCheck = GUICtrlCreateCheckbox("Run on startup?", 15, 65, 100, 20)
$runHiddenCheck = GUICtrlCreateCheckbox("Begin running without GUI?", 125, 65, 175, 20)
$dockLeft = GUICtrlCreateButton("Left", 305, 55, 35, 20)
$dockTop = GUICtrlCreateButton("Top", 345, 40, 50, 20)
$dockRight = GUICtrlCreateButton("Right", 400, 55, 35, 20)
$dockBottom = GUICtrlCreateButton("Bottom", 345, 65, 50, 20)
$show = GUICtrlCreateButton("Show", 15, 92, 89, 33, 0)
$hide = GUICtrlCreateButton("Hide", 120, 92, 89, 33, 0)
$quit = GUICtrlCreateButton("Quit", 225, 92, 89, 33, 0)
$cancel = GUICtrlCreateButton("Ok", 330, 92, 89, 33, 0)
GUICtrlCreateLabel("Written by Ben Perkins of Magic Soft Inc.", 15, 6, 200, 17)
$ad = GUICtrlCreateLabel("http://www.MagicSoftInc.com", 15, 22, 200, 17)
	GUICtrlSetColor($ad, 0x0000FF)
	GUICtrlSetCursor($ad, 0)
	

If shouldRunOnStart() == "True" Then
	GUICtrlSetState($runOnStartCheck, $GUI_CHECKED)
EndIf
If runHidden() == "True" Then
	GUICtrlSetState($runHiddenCheck, $GUI_CHECKED)
EndIf

AdlibEnable("reset", 2500)

If runHidden() == False Then
	GUISetState(@SW_SHOW, $GUI)

	GUISwitch($GUI)
	While 1
		$msg = GUIGetMsg()
		If $msg == $ad Then Run("explorer http://www.magicsoftinc.com/")
		If $msg == $show Then
			$running = False
			setState(1, 1)
		ElseIf $msg == $hide Then
			$running = True
			setState(0, 1)
		EndIf
		If $msg == $cancel Then
			GUISetState(@SW_HIDE, $GUI)
			ExitLoop
		EndIf
		If $msg == $runOnStartCheck Then
			If GUICtrlRead($runOnStartCheck) == 1 Then
				shouldRunOnStart(1)
			Else
				shouldRunOnStart(0)
			EndIf
		EndIf
		If $msg == $runHiddenCheck Then
			If GUICtrlRead($runHiddenCheck) == 1 Then
				runHidden(1)
			Else
				runHidden(0)
			EndIf
		EndIf
		If $msg == $GUI_EVENT_CLOSE or $msg == $quit Then
			quit()
		EndIf
	WEnd
EndIf

$height = GUICtrlRead($heightBox)
setDefAllocation($height)

Global $hwnd=_AppbarNew("My Appbar","MY_CALLBACK")
_AppbarSetDockingEdges(True, True, True, True)
_AppbarDock($hwnd, $ABE_BOTTOM, 100, $height)

GUISwitch($GUI)
While 1
	$msg = GUIGetMsg()
	If $msg == $ad Then Run("explorer http://www.magicsoftinc.com/")
	If $msg == $GUI_EVENT_CLOSE or $msg == $quit Then
		quit()
	ElseIf $msg == $cancel Then
		If $running == True Then
			setState(0, 1)
		Else
			setState(1, 1)
		EndIf
		GUISetState(@SW_HIDE, $GUI)
	ElseIf $msg == $show Then
		setState(1, 1)
		$running = False
	ElseIf $msg == $hide Then
		setState(0, 1)
		$running = True
	ElseIf $msg == $runOnStartCheck Then
		If GUICtrlRead($runOnStartCheck) == 1 Then
			shouldRunOnStart(1)
		Else
			shouldRunOnStart(0)
		EndIf
	ElseIf $msg == $runHiddenCheck Then
		If GUICtrlRead($runHiddenCheck) == 1 Then
			runHidden(1)
		Else
			runHidden(0)
		EndIf
	ElseIf $msg == $dockTop Then
		IniWrite("settings.ini", "settings", "dockEdge", "Top")
		_AppbarDock($hwnd, $ABE_TOP, 100, $height)
	ElseIf $msg == $dockBottom Then
		IniWrite("settings.ini", "settings", "dockEdge", "Bottom")
		_AppbarDock($hwnd, $ABE_BOTTOM, 100, $height)
	ElseIf $msg == $dockLeft Then
		IniWrite("settings.ini", "settings", "dockEdge", "Left")
		_AppbarDock($hwnd, $ABE_LEFT, $height, 100)
	ElseIf $msg == $dockRight Then
		IniWrite("settings.ini", "settings", "dockEdge", "Right")
		_AppbarDock($hwnd, $ABE_RIGHT, $height, 100)
	EndIf
	
	If GUICtrlRead($heightBox) <> $height Then
		$height = GUICtrlRead($heightBox)
		_AppbarDock($hwnd,$ABE_BOTTOM,40,$height)
		setDefAllocation($height)
		If $running == True Then
			setState(0, 1)
		Else
			setState(1, 1)
		EndIf
	EndIf
WEnd

Func getDefAllocation()
	Return IniRead("settings.ini", "settings", "allocate", "45")
EndFunc

Func setDefAllocation($height2)
	Return IniWrite("settings.ini", "settings", "allocate", $height2)
EndFunc

Func shouldRunOnStart($param = -1)
	If $param == -1 Then
		Return IniRead("settings.ini", "settings", "startup", "False")
	ElseIf $param == 0 Then
		FileDelete(@StartupDir & "\hideTM.lnk")
		IniWrite("settings.ini", "settings", "startup", "False")
	Else
		FileCreateShortcut(@ScriptFullPath, @StartupDir & "\hideTM.lnk")
		IniWrite("settings.ini", "settings", "startup", "True")
	EndIf
EndFunc

Func runHidden($param = -1)
	If $param == -1 Then
		Return IniRead("settings.ini", "settings", "runHidden", "False")
	ElseIf $param == 0 Then
		IniWrite("settings.ini", "settings", "runHidden", "False")
	Else
		IniWrite("settings.ini", "settings", "runHidden", "True")
	EndIf
EndFunc

Func setState($state, $times)
	If $state == 0 Then
		$mod = @SW_HIDE
	Else
		$mod = @SW_SHOW
	EndIf
	For $i = 1 to $times
		WinSetState("[CLASS:Button]", "", $mod)
		WinSetState("[CLASS:Shell_TrayWnd]", "", $mod)
	Next
EndFunc

Func reset()
	HotKeySet("!^{esc}", "overRide")
	If $running == True Then
		setState(0, 2)
	Else
		setState(1, 2)
	EndIf
EndFunc

Func overRide()
	GUISetState(@SW_SHOW, $GUI)
	WinActivate($GUI)
EndFunc

Func quit()
	$running = False
	setState(1, 2)
	HotKeySet("!^{esc}")
	WinSetState("[CLASS:Button]", "", @SW_SHOW)
	Exit
EndFunc

Func MY_CALLBACK($hWnd, $MsgID, $WParam, $LParam)
	ConsoleWrite("MY_CALLBACK hwnd: " & $hwnd & @LF)
EndFunc

; this will be called as autoit exits - this ensures the appbar is cleaned up
Func OnAutoItExit()
	_AppbarRemove($hwnd)
EndFunc

; this will be by the bottom button
Func dockBottom()
	_AppbarDock($hwnd,$ABE_BOTTOM,40,40)
EndFunc

; this will be by the bottom button
Func dockTop()
	_AppbarDock($hwnd,$ABE_TOP,40,40)
EndFunc