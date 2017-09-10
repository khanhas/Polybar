#NoTrayIcon
#SingleInstance force
#InstallKeybdHook
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if %0% = 0
{
	ExitApp
	Exit
}

CoordMode, Mouse, Screen
Loop
{
	IfWinNotExist, ahk_exe rainmeter.exe
        ExitApp
		
	Input, LastKey, L1 E B I M
	if (LastKey = "\") or (LastKey = "'") or (LastKey = "[") or (LastKey = "]") or (LastKey = "`n") {
		LastKey := "\" . LastKey
	}
	
	if (LastKey = """") {
		LastKey := "QUOT"
	}
	
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('%LastKey%')" "%2%"
	KeyWait, LastKey ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('%LastKey%')" "%2%"
}
return

~BS::
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('BS')" "%2%"
	KeyWait, Enter ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('BS')" "%2%"
return

~Delete::
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('Delete')" "%2%"
	KeyWait, Del ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('Delete')" "%2%"
return

;~Enter::
;	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('Enter')" "%2%"
;	KeyWait, Enter ; Wait for user to physically release it.
;	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('Enter')" "%2%"
;return

~Up::
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('Up')" "%2%"
	KeyWait, Up ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('Up')" "%2%"
return

~Down::
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('Down')" "%2%"
	KeyWait, Down ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('Down')" "%2%"
return

~Left::
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('Left')" "%2%"
	KeyWait, Left ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('Left')" "%2%"
return

~Right::
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyDown('Right')" "%2%"
	KeyWait, Right ; Wait for user to physically release it.
	Run, %1% !CommandMeasure "MEASURE_COMPLETION_SCRIPT" "KeyUp('Right')" "%2%"
return