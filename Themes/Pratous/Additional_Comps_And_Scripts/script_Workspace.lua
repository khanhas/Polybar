function Initialize()
	maximumWorkspace = tonumber(SKIN:GetVariable('Maximum_Workspace'))
	dotGap = SKIN:ParseFormula('('..SKIN:GetVariable('Workspace_Number_Gap')..'*2)')
	SKIN:Bang('!CommandMeasure GetWorkspaceVariable "Run"')
end
oldCurrentWorkspace = -1
changingWorkspace = false
function Update()
	totalWorkspace = tonumber(SKIN:GetVariable('Workspace_Total',-1))
	currentWorkspace = tonumber(SKIN:GetVariable('Workspace_Current',-1))
	if not totalWorkspace or not currentWorkspace then
		SKIN:Bang('!HideMeterGroup', 'WorkspaceManager_All')
		SKIN:Bang('!ShowMeter', 'WorkspaceError')
		return
	end
	for i = 1, maximumWorkspace do
		SKIN:Bang('!ShowMeter', 'Workspace'..i)
		if i <= totalWorkspace then
			SKIN:Bang('!SetOption', 'Workspace'..i, 'LeftMouseUpAction', '!CommandMeasure WorkspaceWindowSendMessage "SendMessage 16687 2 '..i..'"') --Switch to workspace
		else
			SKIN:Bang('!SetOption', 'Workspace'..i, 'LeftMouseUpAction', string.rep('[!CommandMeasure WorkspaceWindowSendMessage "SendMessage 16687 3 1"]',i-totalWorkspace)) --Create new workspace
		end
	end
	if oldCurrentWorkspace ~= currentWorkspace and not changingWorkspace then
		SKIN:Bang('[!CommandMeasure WorkspaceActionTimer "Stop 1"][!CommandMeasure WorkspaceActionTimer "Execute 1"]')
		timing=1
		changingWorkspace = true
	end
end

timing = 0
maxTime = 40
function ChangeWorkspaceAnimation()
	if timing > 0 and timing < maxTime then
		timing = timing + 1
		slideAnimation = (oldCurrentWorkspace-1)*dotGap+(currentWorkspace-oldCurrentWorkspace)*dotGap*outQuint(timing,0,1,maxTime)
		if currentWorkspace <= maximumWorkspace then 
			SKIN:Bang('!ShowMeter', 'WorkspaceCurrent')
			SKIN:Bang('!SetOPtion', 'WorkspaceCurrent', 'Shape', 'Rectangle ('..slideAnimation..'),#Bar_Height#,(#Workspace_Number_Gap#*2),-3 | Extend IndicatorTrait')
			SKIN:Bang('!UpdateMeter', 'WorkspaceCurrent')
			SKIN:Bang('!Redraw')
		else
			SKIN:Bang('[!HideMeter WorkspaceCurrent]')
		end
	elseif timing == maxTime then
		timing = 0
		oldCurrentWorkspace = currentWorkspace
		changingWorkspace = false
		SKIN:Bang('!CommandMeasure WorkspaceActionTimer "Stop 1"')
	end
end

function outQuint(t, b, c, d)
  t = t / d - 1
  return c * (math.pow(t, 5) + 1) + b
end