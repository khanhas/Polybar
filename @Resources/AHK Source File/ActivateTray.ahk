#NoTrayIcon

X = %1%
Y = %2%
direction = %3%

IfWinExist, ahk_class NotifyIconOverflowWindow
{
  WinHide, ahk_class NotifyIconOverflowWindow
}
Else
{
  DetectHiddenWindows, On
  WinGetPos,,,WidthOfTray,HeightOfTray,ahk_class NotifyIconOverflowWindow
  TrueX := X-WidthOfTray/2
  TrueY := Y-HeightOfTray*direction
  ControlClick, Button2, ahk_class Shell_TrayWnd
  WinMove, ahk_class NotifyIconOverflowWindow, , %TrueX%, %TrueY%
  WinShow, ahk_class NotifyIconOverflowWindow
  WinActivate, ahk_class NotifyIconOverflowWindow 
}