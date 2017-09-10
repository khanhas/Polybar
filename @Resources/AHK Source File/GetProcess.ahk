#NoEnv
#NoTrayIcon

OldProcess := "N/A"
ProgramPath = %1%
VariableName = %2%
ConfigName = %3%
WinGet, ProcessProcess, ProcessName, A

Loop {
	Sleep, 100
	IfWinNotExist, ahk_exe rainmeter.exe
		ExitApp
	WinGet, ProcessProcess, ProcessName, A
	if (ProcessProcess <> OldProcess)
		Run, "%ProgramPath%" !SetVariable "%VariableName%" "%ProcessProcess%" "%ConfigName%"
		OldProcess := ProcessProcess
}