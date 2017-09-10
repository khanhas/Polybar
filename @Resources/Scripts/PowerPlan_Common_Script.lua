function Initialize()
	filePath = SELF:GetOption('PlanList_FilePath')
	brightnessPath = SELF:GetOption('BrightnessLevel_FilePath')
	runCommand = SELF:GetOption('RunCommand_Measure')
	meter = SELF:GetOption('Meter_Name')
	style = SELF:GetOption('Meter_Style')
	config = SELF:GetOption('Config')
	configFile = SELF:GetOption('Config_File')
	configPath = SELF:GetOption('Config_Path')
	SKIN:Bang('!CommandMeasure', 'BatteryFetchPowerPlanList', 'Run')
	SKIN:Bang('!CommandMeasure', 'BatteryFetchBrightnessLevel', 'Run')
end

function GetList()
	local file = io.open(filePath,'r')
	local content = file:read('*a')
	file:close()

	local action = '[!DeactivateConfig "'..config..'"][!ActivateConfig "'..config..'" "'..configFile..'"]'
	local count = 0
	local activeIndex = 0
	for plan in content:gmatch('Power Scheme GUID: (.-)\n') do
		count = count + 1
		local guid, name = plan:match('(.-) %((.-)%)')
		local active = plan:match('%*') == '*'

		action = action .. '[!SetOption '..meter..count..' Text "'..name..'" "'..config..'"]'
		if not active then 
			action = action .. '[!SetOption '..meter..count..' LeftMouseUpAction """[!SetOption PowerPlanSwitch Parameter "powercfg /setactive '..guid..'][!UpdateMeasure PowerPlanSwitch][!CommandMeasure PowerPlanSwitch Run]""" "'..config..'"]'
		else
			activeIndex = count
		end
	end
	for i = 1, count do
		SKIN:Bang('!WriteKeyValue', meter..i, 'Meter', 'String', configPath)
		SKIN:Bang('!WriteKeyValue', meter..i, 'MeterStyle', style, configPath)
	end
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Total', count, configPath)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Active', activeIndex, configPath)
	SKIN:Bang('!SetVariable', 'Battery_PowerPlan_Activate', action)
end

function GetBrightness()
	local file = io.open(brightnessPath, 'r')
	local content = file:read('*a')
	file:close()
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Brightness', content:match('CurrentBrightness : (%d+)'), configPath)
end
