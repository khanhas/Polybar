function Initialize()
	maximumWorkspace = tonumber(SKIN:GetVariable('Maximum_Workspace'))
	dotGap = tonumber(SKIN:GetVariable('Workspace_Number_Gap'))
	SKIN:Bang('!CommandMeasure GetWorkspaceVariable "Run"')
end
oldCurrentWorkspace = 1
changingWorkspace = false
function Update()
	totalWorkspace = tonumber(SKIN:GetVariable('Workspace_Total',-1))
	currentWorkspace = tonumber(SKIN:GetVariable('Workspace_Current',-1))
	for i = 1, maximumWorkspace do
		if i <= totalWorkspace then
			SKIN:Bang('!ShowMeter Workspace'..i)
		else
			SKIN:Bang('!HideMeter Workspace'..i)
		end
	end
	if totalWorkspace ~= -1 then
		local trueTotalWorkspace = totalWorkspace > maximumWorkspace and maximumWorkspace or totalWorkspace
		SKIN:Bang('!SetOption WorkspaceShape Shape "Rectangle -20,0,([Workspace1:W]*'..trueTotalWorkspace..'+40),#Section_Height#,5 |StrokeWidth 0 | Fill Color #Color_Scheme1#"')
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
		animation = outBack(timing,0,1,maxTime)

		slideAnimation = (oldCurrentWorkspace-1)*dotGap*2+(currentWorkspace-oldCurrentWorkspace)*dotGap*2*animation
		if currentWorkspace <= maximumWorkspace then 
			SKIN:Bang('[!ShowMeter WorkspaceCurrent]'
					..'[!SetOPtion WorkspaceCurrent Shape "Rectangle '..slideAnimation..',#Section_Height#,(#Workspace_Number_Gap#*2),-3,1.5 | Extend Trait"][!UpdateMeter WorkspaceCurrent][!Redraw]')
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

function outBack(t, b, c, d, s)
  if not s then s = 1.2 end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function inBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end