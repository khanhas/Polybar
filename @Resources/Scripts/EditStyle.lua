function Initialize()
	folderview = SKIN:GetMeasure('MeasureChild1')
	foldercount = SKIN:GetMeasure('MeasureFolderCount')
	getColorScheme()
end

q=2
themeFolder ={}
function gatherThemeFolder()
	local curFolder = folderview:GetStringValue()
	if curFolder ~= '' and curFolder ~= '..' then
		table.insert(themeFolder,curFolder)
	end
	q = q+1
	if q <= foldercount:GetValue() + 1 then
		SKIN:Bang('[!SetOption MeasureChild1 Index '..q..'][!CommandMeasure MeasureFolder "Update"]')
	else
		themeMP = math.ceil(#themeFolder/3)
		themeChangePage(0)
	end
end
themeCurP = 1
function themeChangePage(dir)
	if themeCurP + dir <= themeMP and themeCurP + dir >= 1 then
		themeCurP = themeCurP + dir
		local shapecount = 2
		local dotdis = 20*(themeMP-1) > 200 and 200/(themeMP-1) or 20
		local maxdis = dotdis*(themeMP-1) 
		SKIN:Bang('[!SetOption ThemePage X '..(300-maxdis/2)..'][!SetOption ThemeBackPage X '..(300-maxdis/2-10)..'][!SetOption ThemeNextPage X '..(300+maxdis/2+10)..']')
		for i = 1,themeMP do
			if i == themeCurP then
				SKIN:Bang('[!SetOption ThemePage Shape'..shapecount..' "Rectangle '..((i-1)*dotdis-5)..','..(-5)..',10,10,2|Extend CurrPage"]')
				shapecount = shapecount+1
			else
				SKIN:Bang('[!SetOption ThemePage Shape'..shapecount..' "Rectangle '..((i-1)*dotdis-2.5)..',-2.5,5,5|Extend NotCurrPage"]')
				shapecount=shapecount+1
			end
		end
	else
		print('Page Not Available. Stop Pressing.')
		return
	end
	for i = 1+3*(themeCurP-1),3+3*(themeCurP-1) do
		local meterPos = i-3*(themeCurP-1)
		if themeFolder[i] then
			SKIN:Bang('[!ShowMeterGroup Theme'..meterPos..']'
					..'[!SetOption Theme'..meterPos..' ImageName "#RootConfigPath#Themes\\'..themeFolder[i]..'\\Additional_Comps_And_Scripts\\Demo"]'
					..'[!SetOption Theme'..meterPos..' LeftMouseUpAction """[!CommandMeasure Script "chooseTheme('..i..')"]"""]'
					..'[!SetOption Theme'..meterPos..'Name Text "'..themeFolder[i]..'"]')
		else
			SKIN:Bang('[!HideMeterGroup Theme'..meterPos..']')
		end
	end
end

function chooseTheme(index)
	DefaultAddModuleFile = {}
	local file = io.open(SKIN:GetVariable('ROOTCONFIGPATH')..'Themes\\'..themeFolder[index]..'\\Config\\Config.inc')
	local file_content = file:read('*line')
	while file_content do
		file_content = file_content:gsub(' ','')
		DefaultAddModList = file_content:match('^DefaultAddedModules=(.*)$')
		if DefaultAddModList then break end
		file_content = file:read('*line')
	end
	file:close()
	DefaultAddModuleFile={}
	for modules in DefaultAddModList:gmatch('[^,]+') do
		table.insert(DefaultAddModuleFile,string.lower(modules))
	end
	AddedModList = SKIN:GetVariable('AddedModule')
	AddModuleFile ={}
	for modules in AddedModList:gmatch('[^,]+') do
		table.insert(AddModuleFile,string.lower(modules))
	end
	for i = 3,#AddModuleFile+2 do
		SKIN:Bang('[!WriteKeyValue IncludedModule @Include'..i..' "" "#ROOTCONFIGPATH#Polybar.ini"]')
	end
	SKIN:Bang('[!WriteKeyValue Variables AddedModule "'..table.concat(DefaultAddModuleFile,',')..'" "#@#MainBarVariables.inc"]')

	for k,v in pairs(DefaultAddModuleFile) do
		SKIN:Bang('[!WriteKeyValue IncludedModule @Include'..(k+2)..' "#*ROOTCONFIGPATH*#Themes\\#*Theme*#\\'..v..'.inc" "#ROOTCONFIGPATH#Polybar.ini"]')
	end
	SKIN:Bang('[!WriteKeyValue Variables Theme "'..themeFolder[index]..'" "#@#MainBarVariables.inc"]'
			..'[!Refresh][!Refresh "#ROOTCONFIG#]')
end

timing,timing2,timing3,timing4,timing5,timing6,timing7,timing8,timing9,timing10 = 0,0,0,0,0,0,0,0,0,0
function Update()
	if timing > 0 and timing < 30 then
		timing = timing + 1*dir
		local expandAnimate = outExpo(timing, 0, 1, 30)*(dir+1)/2 + inExpo(timing, 0, 1, 30)*(1-dir)/2
		SKIN:Bang('[!SetOption Theme1 H '..round(100+40*expandAnimate)..']'
				..'[!SetOption Theme1Name H '..round(25*(1-expandAnimate))..']'
				..'[!SetOption Theme1Name Y '..round(215+25*expandAnimate)..']')
	end
	if timing2 > 0 and timing2 < 30 then
		timing2 = timing2 + 1*dir2
		local expandAnimate = outExpo(timing2, 0, 1, 30)*(dir2+1)/2 + inExpo(timing2, 0, 1, 30)*(1-dir2)/2
		SKIN:Bang('[!SetOption Theme2 H '..round(100+40*expandAnimate)..']'
				..'[!SetOption Theme2Name H '..round(25*(1-expandAnimate))..']'
				..'[!SetOption Theme2Name Y '..round(215+25*expandAnimate)..']')
	end
	if timing3 > 0 and timing3 < 30 then
		timing3 = timing3 + 1*dir3
		local expandAnimate = outExpo(timing3, 0, 1, 30)*(dir3+1)/2 + inExpo(timing3, 0, 1, 30)*(1-dir3)/2
		SKIN:Bang('[!SetOption Theme3 H '..round(100+40*expandAnimate)..']'
				..'[!SetOption Theme3Name H '..round(25*(1-expandAnimate))..']'
				..'[!SetOption Theme3Name Y '..round(215+25*expandAnimate)..']')
	end
	if timing4 > 0 and timing4 < 30 then
		timing4 = timing4 + 1*dir4
		local ballAnimate = outQuad(timing4, 0, 1, 30)*(dir4+1)/2 + inExpo(timing4, 0, 1, 30)*(1-dir4)/2
		SKIN:Bang('[!SetOption ManuallyShape Shape3 "Ellipse #MouseX#,#MouseY#,'..(300*ballAnimate)..'|Extend balltrait"]')
	end
	if timing5 > 0 and timing5 < 30 then
		timing5 = timing5 + 1*dir5
		local ballAnimate = outQuad(timing5, 0, 1, 30)*(dir5+1)/2 + inExpo(timing5, 0, 1, 30)*(1-dir5)/2
		SKIN:Bang('[!SetOption NeedRefreshShape Shape3 "Ellipse #MouseX#,#MouseY#,'..(300*ballAnimate)..'|Extend balltrait"]')
	end
	if timing6 > 0 and timing6 < 15 then
		timing6 = timing6 + 1*dir6
		local riseAnimate = outQuad(timing6, 0, 1, 15)*(dir6+1)/2 + inQuad(timing6, 0, 1, 15)*(1-dir6)/2
		SKIN:Bang('[!SetOption FontColorShape Shape2 "Rectangle 470,'..(460-2*riseAnimate)..',100,50,3 | Extend Display"]'
			..'[!SetOption FontColorShape Shape "Ellipse 520,505,50,'..(15*riseAnimate)..'| StrokeWidth 0 | Fill RadialGradient Grad"]'
			..'[!SetOption FontColorShape Grad2 "'..(90*(dir6+1)/2 + 270*(1-dir6)/2)..'|F94F50;0|F94F50;'..riseAnimate..'|F94F5000;'..riseAnimate..'"]')
	elseif timing6 == 0 then
		timing6=-1
		SKIN:Bang('[!SetOption FontColorShape Grad2 "0|00000000;0|00000000;1"]')
	end
	if timing7 > 0 and timing7 < 15 then
		timing7 = timing7 + 1*dir7
		local riseAnimate = outQuad(timing7, 0, 1, 15)*(dir7+1)/2 + inQuad(timing7, 0, 1, 15)*(1-dir7)/2
		SKIN:Bang('[!SetOption BarColorShape Shape2 "Rectangle 470,'..(532-2*riseAnimate)..',100,50,3 | Extend Display"]'
			..'[!SetOption BarColorShape Shape "Ellipse 520,577,50,'..(15*riseAnimate)..'| StrokeWidth 0 | Fill RadialGradient Grad"]'
			..'[!SetOption BarColorShape Grad2 "'..(90*(dir7+1)/2 + 270*(1-dir7)/2)..'|F94F50;0|F94F50;'..riseAnimate..'|F94F5000;'..riseAnimate..'"]')
	elseif timing7 == 0 then
		timing7=-1
		SKIN:Bang('[!SetOption BarColorShape Grad2 "0|00000000;0|00000000;1"]')
	end
	if timing8 > 0 and timing8 < 20 then
		timing8 = timing8 + 1
		local slideAnimate = inOutQuad(timing8, 0, 1, 20)
		SKIN:Bang('[!SetOption Theme1 X '..(25-195*slideAnimate)..']'
				..'[!SetOption Theme1Shape X '..(-197.5*slideAnimate)..']'
				..'[!SetOption Theme1 ImageAlpha '..(255*(1-slideAnimate))..']'
				..'[!SetOption Theme1Shape Color "Fill Color 249,79,80,'..(255*(1-slideAnimate))..'"]'
				..'[!SetOption Theme2 X '..(212-(212+170)*slideAnimate)..']'
				..'[!SetOption Theme2Shape X '..(-385*slideAnimate)..']'
				..'[!SetOption Theme2 ImageAlpha '..(255*(1-slideAnimate))..']'
				..'[!SetOption Theme2Shape Color "Fill Color 249,79,80,'..(255*(1-slideAnimate))..'"]'
				..'[!SetOption Theme3 X '..(400-(400+170)*slideAnimate)..']'
				..'[!SetOption Theme3Shape X '..(-572.5*slideAnimate)..']'
				..'[!SetOption Theme3 ImageAlpha '..(255*(1-slideAnimate))..']'
				..'[!SetOption Theme3Shape Color "Fill Color 249,79,80,'..(255*(1-slideAnimate))..'"]')
	elseif timing8 == 20 then 
		themeChangePage(-1)
		timing10=1
		timing8=21
	end
	if timing9 > 0 and timing9 < 20 then
		timing9 = timing9 + 1
		local slideAnimate = inOutQuad(timing9, 0, 1, 20)
		SKIN:Bang('[!SetOption Theme1 X '..(25+(600-25)*slideAnimate)..']'
				..'[!SetOption Theme1Shape X '..((600-22.5)*slideAnimate)..']'
				..'[!SetOption Theme1 ImageAlpha '..(255*(1-slideAnimate))..']'
				..'[!SetOption Theme1Shape Color "Fill Color 249,79,80,'..(255*(1-slideAnimate))..'"]'
				..'[!SetOption Theme2 X '..(212+(600-212)*slideAnimate)..']'
				..'[!SetOption Theme2Shape X '..((600-210)*slideAnimate)..']'
				..'[!SetOption Theme2 ImageAlpha '..(255*(1-slideAnimate))..']'
				..'[!SetOption Theme2Shape Color "Fill Color 249,79,80,'..(255*(1-slideAnimate))..'"]'
				..'[!SetOption Theme3 X '..(400+(600-400)*slideAnimate)..']'
				..'[!SetOption Theme3Shape X '..((600-397)*slideAnimate)..']'
				..'[!SetOption Theme3 ImageAlpha '..(255*(1-slideAnimate))..']'
				..'[!SetOption Theme3Shape Color "Fill Color 249,79,80,'..(255*(1-slideAnimate))..'"]')
	elseif timing9 == 20 then 
		themeChangePage(1)
		timing10=1
		timing9=21
	end

	if timing10 > 0 and timing10 < 10 then
		timing10 = timing10 + 1
		local fadeinAnimate = inOutQuad(timing10, 0, 1, 10)
		SKIN:Bang('[!SetOption Theme1 X 25]'
				..'[!SetOption Theme1Shape X 0]'
				..'[!SetOption Theme1 ImageAlpha '..(255*fadeinAnimate)..']'
				..'[!SetOption Theme1Shape Color "Fill Color 249,79,80,'..(255*fadeinAnimate)..'"]'
				..'[!SetOption Theme2 X 212]'
				..'[!SetOption Theme2Shape X 0]'
				..'[!SetOption Theme2 ImageAlpha '..(255*fadeinAnimate)..']'
				..'[!SetOption Theme2Shape Color "Fill Color 249,79,80,'..(255*fadeinAnimate)..'"]'
				..'[!SetOption Theme3 X 400]'
				..'[!SetOption Theme3Shape X 0]'
				..'[!SetOption Theme3 ImageAlpha '..(255*fadeinAnimate)..']'
				..'[!SetOption Theme3Shape Color "Fill Color 249,79,80,'..(255*fadeinAnimate)..'"]')
	end

end

function outExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b
	end
end

function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function inQuad(t, b, c, d)
	t = t / d
	return c * math.pow(t, 2) + b
end

function inExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001
	end
end

function outCubic(t, b, c, d)
	t = t / d - 1
	return c * (math.pow(t, 3) + 1) + b
end

function inOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * math.pow(t, 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

colorSchemeTable = {}
function getColorScheme()
	local colorCount = 1
	local color = SKIN:GetVariable('Color_Scheme'..colorCount)
	while color do
		if color == '' then 
			color = 'ffffff' 
			SKIN:Bang('!WriteKeyValue Variables Color_Scheme'..colorCount..' ffffff "#ROOTCONFIGPATH#Themes\\#Theme#\\Config\\Config.inc"')
		end
		table.insert(colorSchemeTable,color)
		colorCount = colorCount + 1
		color = SKIN:GetVariable('Color_Scheme'..colorCount)
	end
	colorSchemeMP = math.ceil(#colorSchemeTable/8)
	colorSchemeChangePage(0)
end

colorSchemeCurrP = 1
function colorSchemeChangePage(dir)
	if colorSchemeCurrP + dir <= colorSchemeMP and colorSchemeCurrP + dir >= 1 then
		colorSchemeCurrP = colorSchemeCurrP + dir
		local shapeCount = 2
		local dotdis = 20*(colorSchemeMP-1) > 100 and 100/(colorSchemeMP-1) or 20
		local maxdis = dotdis*(colorSchemeMP-1) 
		SKIN:Bang('[!SetOption ColorSchemePage X '..(490-maxdis/2)..'][!SetOption ColorSchemeBackPage X '..(490-maxdis/2-5)..'][!SetOption ColorSchemeNextPage X '..(490+maxdis/2+5)..']')
		for i = 1,colorSchemeMP do
			if i == colorSchemeCurrP then
				SKIN:Bang('[!SetOption ColorSchemePage Shape'..shapeCount..' "Rectangle '..((i-1)*dotdis-5)..','..(-5)..',10,10,2|Extend CurrPage"]')
				shapeCount = shapeCount+1
			else
				SKIN:Bang('[!SetOption ColorSchemePage Shape'..shapeCount..' "Rectangle '..((i-1)*dotdis-2.5)..',-2.5,5,5|Extend NotCurrPage"]')
				shapeCount=shapeCount+1
			end
		end
	else
		print('Page Not Available. Stop Pressing.')
		return
	end
	for i = 1+8*(colorSchemeCurrP-1),8+8*(colorSchemeCurrP-1) do
		local meterPos = i-8*(colorSchemeCurrP-1)
		if colorSchemeTable[i] then
			SKIN:Bang('[!ShowMeter ColorSchemeSelector'..meterPos..']'
					..'[!SetOption ColorSchemeSelector'..meterPos..' Shape "Rectangle 0,0,30,60 | StrokeWidth 0 | Fill Color #Color_Scheme'..i..'#"]'
					..'[!SetOption ColorSchemeSelector'..meterPos..' LeftMouseUpAction """["#@#RainRGB4.exe" "VarName=Color_Scheme'..i..'" "FileName=#ROOTCONFIGPATH#Themes\\#Theme#\\Config\\Config.inc"]"""]')
		else
			SKIN:Bang('[!HideMeter ColorSchemeSelector'..meterPos..']')
		end
	end
end

function slideEdit(mouseX)
	local percent = clamp(mouseX - startX, 0, 150) / 150 

	if editVar == 'Bar_Opacity' then
		sendValue( string.format('%02x',round(percent * 255)))
	else
		sendValue( round( percent * SKIN:GetVariable(maxVar)))
	end
end

function scrollEdit(a)
	if editVar == 'Bar_Opacity' then
		local cur = tonumber(SKIN:GetVariable(editVar), 16) + a
		sendValue( string.format('%02x',clamp(cur, 0, 255)))
	else
		local cur = SKIN:GetVariable(editVar) + a
		sendValue( clamp(cur , 0, tonumber(SKIN:GetVariable(maxVar))))
	end
end

function sendValue(val)
	SKIN:Bang('!SetVariable', editVar, val)
	SKIN:Bang('!WriteKeyValue', 'Variables', editVar, val, "#ROOTCONFIGPATH#Themes\\#Theme#\\Config\\Config.inc")
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function clamp(num,down,up)
	return num < down and down or (num > up and up or num)
end