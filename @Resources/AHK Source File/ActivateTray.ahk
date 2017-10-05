#SingleInstance, force
#NoTrayIcon

DetectHiddenWindows, On
SetWinDelay, 16
X = %1%
Y = %2%
direction = %3%

IfWinActive, ahk_class NotifyIconOverflowWindow
	WinHide, ahk_class NotifyIconOverflowWindow
Else {
	WinGetPos,,,WidthOfTray,HeightOfTray,ahk_class NotifyIconOverflowWindow
	TrueX := X-WidthOfTray/2
	TrueY := Y-HeightOfTray*direction
	ControlClick, Button2, ahk_class Shell_TrayWnd
	loop {
		WinMove, ahk_class NotifyIconOverflowWindow, , %TrueX%, %TrueY%
		WinActivate, ahk_class NotifyIconOverflowWindow
		IfWinNotActive, ahk_class NotifyIconOverflowWindow
			ExitApp
	}
}