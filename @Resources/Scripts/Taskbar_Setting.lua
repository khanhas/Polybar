function Initialize()
	taskbarFile = SKIN:ReplaceVariables('#ROOTCONFIGPATH#Themes\\#Theme#\\taskbar.inc')
end

varTable = {}

function parseVariable()
	local allVar = SKIN:GetMeasure('TaskbarVariableParsing'):GetStringValue()
	allVar = allVar:gsub(' ','')
	for line in allVar:gmatch('(.-)\n') do
		if line:sub(1,1) ~= ';' then
			k,v = line:match('^(.-)=(.-)\n?$')
			if k and v then
				if v:find('#') then v = SKIN:ReplaceVariables(v) end
				v = v:gsub(string.char(13),'')
				varTable[k] = v
			end
		end
	end
	setSetting()
end

function setSetting()
	if varTable['Icon_Gap'] then SKIN:Bang('!SetOption', 'GapNumber', 'Text', varTable['Icon_Gap']) end
	if varTable['Icon_Size'] then SKIN:Bang('!SetOption', 'SizeNumber', 'Text', varTable['Icon_Size']) end
	if varTable['Title_Pad'] then SKIN:Bang('!SetOption', 'PadNumber', 'Text', varTable['Title_Pad']) end
	if varTable['Taskbar_Max_Process_Width'] then SKIN:Bang('!SetOption', 'DefaultWidthNumber', 'Text', varTable['Taskbar_Max_Process_Width']) end
	if varTable['Taskbar_Width'] then SKIN:Bang('!SetVariable', 'Width', varTable['Taskbar_Width']) end
	
	if varTable['Taskbar_Show_Icon'] then
		varTable['Taskbar_Show_Icon'] = varTable['Taskbar_Show_Icon']:lower() == 'true'
		if varTable['Taskbar_Show_Icon'] then
			SKIN:Bang('!SetOption', 'IconToggle', 'State', 'Fill Color F94F50')
			SKIN:Bang('!ShowMeterGroup', 'IconEnabled')
		else
			SKIN:Bang('!SetOption', 'IconToggle', 'State', 'Fill Color 505050')
			SKIN:Bang('!HideMeterGroup', 'IconEnabled')
		end
		SKIN:Bang('!SetOption', 'IconToggle', 'Shape2', 'Ellipse '..(15+(varTable['Taskbar_Show_Icon'] and 30 or 0))..',0,12 | StrokeWidth 0 | Extend State')

	end

	if varTable['Taskbar_Show_Title'] then
		varTable['Taskbar_Show_Title'] = varTable['Taskbar_Show_Title']:lower() == 'true'
		if varTable['Taskbar_Show_Title'] then
			SKIN:Bang('!SetOption', 'TitleToggle', 'State', 'Fill Color F94F50')
			SKIN:Bang('!ShowMeterGroup', 'TitleEnabled')
		else
			SKIN:Bang('!SetOption', 'TitleToggle', 'State', 'Fill Color 505050')
			SKIN:Bang('!HideMeterGroup', 'TitleEnabled')
		end
		SKIN:Bang('!SetOption', 'TitleToggle', 'Shape2', 'Ellipse '..(15+(varTable['Taskbar_Show_Title'] and 30 or 0))..',0,12 | StrokeWidth 0 | Extend State')
	end

	if varTable['Taskbar_Show_Icon'] and varTable['Taskbar_Show_Title'] then
		SKIN:Bang('!ShowMeterGroup', 'TitleIconEnabled')
	else
		SKIN:Bang('!HideMeterGroup', 'TitleIconEnabled')
	end

	if varTable['Taskbar_Process_Width_Mode'] then
		local mode = varTable['Taskbar_Process_Width_Mode']:lower()
		if mode == 'fixed' then
			SKIN:Bang('!SetOption', 'WidthModeBaseShape', 'Animation', 'Offset 0,0')
		elseif mode == 'adapt' then
			SKIN:Bang('!SetOption', 'WidthModeBaseShape', 'Animation', 'Offset (330/2),0')
		elseif mode == 'hybrid' then
			SKIN:Bang('!SetOption', 'WidthModeBaseShape', 'Animation', 'Offset 330,0')
		end
	end
end

function syncValue()
	SKIN:Bang('!UpdateMeasure', 'TaskbarVariableParsing')
	SKIN:Bang('!CommandMeasure', 'TaskbarVariableParsing', 'Update')
	SKIN:Bang('!CommandMeasure', 'TaskbarScript', 'GetEssentialVariables()', '#ROOTCONFIG#')
	SKIN:Bang('!Update', '#ROOTCONFIG#')
end

function toggleIconTitle(kind)
	local t ,i = varTable['Taskbar_Show_Title'], varTable['Taskbar_Show_Icon']
	if kind == 'title' then
		t = not t
		if not i then i = not i end
	elseif kind == 'icon' then
		i = not i
		if not t then t = not t end
	end
	SKIN:Bang('!SetVariable', 'Taskbar_Show_Icon', tostring(i), '#ROOTCONFIG#')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Taskbar_Show_Icon', tostring(i), taskbarFile)

	SKIN:Bang('!SetVariable', 'Taskbar_Show_Title', tostring(t), '#ROOTCONFIG#')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Taskbar_Show_Title', tostring(t), taskbarFile)

	if t ~= varTable['Taskbar_Show_Title'] then
		timing = t and 1 or 9
		dir = t and 1 or -1
	end
	if i ~= varTable['Taskbar_Show_Icon'] then
		timing2 = i and 1 or 9
		dir2 = i and 1 or -1
	end

	syncValue()
end

oldMode, newMode = 0,0
function changeMode(kind)
	SKIN:Bang('!SetVariable', 'Taskbar_Process_Width_Mode', kind, '#ROOTCONFIG#')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Taskbar_Process_Width_Mode', kind, taskbarFile)

	local mode = varTable['Taskbar_Process_Width_Mode']:lower()

	if kind ~= mode then
		timing3 = 1
		if mode == 'fixed' then
			oldMode = 0
		elseif mode == 'adapt' then
			oldMode = 330/2
		elseif mode == 'hybrid' then
			oldMode = 330
		end
		if kind == 'fixed' then
			newMode = 0
		elseif kind == 'adapt' then
			newMode = 330/2
		elseif kind == 'hybrid' then
			newMode = 330
		end
	end
	syncValue()
end

dragVar = ''
dragMeter = ''
clickY = 0
startDrag = false
function dragEdit(mouseX)
	if startDrag then
		clickX= mouseX
		startDrag = false
	end
	local curValue = tonumber(varTable[dragVar])
	local e = math.floor((mouseX - clickX)/10) + curValue
	SKIN:Bang('!SetOption', dragMeter, 'Text', e)
	SKIN:Bang('!SetVariable', dragVar, e, '#ROOTCONFIG#')
	SKIN:Bang('!WriteKeyValue', 'Variables', dragVar, e, taskbarFile)
end

function scrollEdit(a)
	local curValue =  tonumber(SKIN:GetVariable('Width')) + a
	SKIN:Bang('!SetVariable', 'Width', curValue)
	SKIN:Bang('!SetVariable', 'Taskbar_Width', curValue, '#ROOTCONFIG#')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Taskbar_Width', curValue, taskbarFile)
	
end
timing,timing2,timing3 = 0,0,0
dir, dir2 = 1,1
function Update()
	if timing > 0 and timing < 10 then
		timing = timing + dir
		local toggleAnimation = outQuad(timing,0,1,10)
		SKIN:Bang('!SetOption', 'TitleToggle', 'Shape2', 'Ellipse '..(15+30*toggleAnimation)..',0,12 | StrokeWidth 0 | Extend State')
	end

	if timing2 > 0 and timing2 < 10 then
		timing2 = timing2 + dir2
		local toggleAnimation = outQuad(timing2,0,1,10)
		SKIN:Bang('!SetOption', 'IconToggle', 'Shape2', 'Ellipse '..(15+30*toggleAnimation)..',0,12 | StrokeWidth 0 | Extend State')
	end

	local distanceModifier = math.abs(newMode-oldMode)/(330/2)
	if timing3 > 0 and timing3 < 30*distanceModifier then
		timing3 = timing3 + 1
		local modeAnimation = outQuad(timing3,0,1,30*distanceModifier)
		SKIN:Bang('!SetOption', 'WidthModeBaseShape', 'Animation', 'Offset '..(oldMode + (newMode - oldMode)*modeAnimation)..',0')
		SKIN:Bang('!SetOption', 'WidthModeBaseShape', 'Scaling', 'Scale '..(modeAnimation*2-1)..','..(modeAnimation*2-1))
	end

end

function outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function inQuart(t, b, c, d)
  t = t / d
  return c * math.pow(t, 4) + b
end