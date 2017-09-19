local keys = {}

local choices = {}
local weightTable = {}
local cur = ""
local running = false
local predicted = ""
local selection = 1
local cursor = ""

local cursor_offset = 0

function GetEssentialVariables()
	cursor_active = SKIN:GetVariable('CURSOR', '_')
	defaultSort = SKIN:GetVariable('DefaultSort', 'alphabet')
--GET EXCLUDED KEYWORD
	exKeyWord = split(SKIN:GetVariable('Exclude_KeyWord'), ',')

	getWeight()

	programTable = {}
	getProgramList()

	fileView = SKIN:GetMeasure('MeasureChild1')
	pathView = SKIN:GetMeasure('MeasureChild2')
	iconView = SKIN:GetMeasure('MeasureChild3')
	meterGenerator()
	if #programTable == 0 then
		reloadProgram()
	else
		loading_files = false
		sortChoice(programTable,defaultSort)
		curPage = 1
		setIcon(programTable)
		pageButton(0)
		SKIN:Bang("!Update")
		Start()
	end
	
end

function reloadProgram()
	
	fileCount = SKIN:GetMeasure('MeasureFileCount')
	folderQueue = 1
	fileQueue = 2
	loading_files = true
	programTable = {}
	SKIN:Bang('!SetOption', 'MeasureFileCount', 'Folder', '#ShortcutFolder1#')
	SKIN:Bang('!SetOption', 'MeasureFolder', 'Path', '#ShortcutFolder1#')

	SKIN:Bang('!SetOption', 'MeasureChild1', 'Index', 2)
	SKIN:Bang('!SetOption', 'MeasureChild2', 'Index', 2)
	SKIN:Bang('!SetOption', 'MeasureChild3', 'Index', 2)
	SKIN:Bang('!SetOption', 'MeasureChild3', 'IconPath', '#@#launcherIcon\\0.ico')
	
	SKIN:Bang('!CommandMeasure', 'MeasureFolder', 'Update')
end


function gatherShortcutFile()
	local curFile = fileView:GetStringValue()
	local curPath = pathView:GetStringValue()
	local curIcon = iconView:GetStringValue()
	if curFile ~= '' and curFile ~= '..' then
		choices[curFile:lower()] = curPath
		if excludeKeyword(curFile:lower()) then
			table.insert(programTable, {['title'] = curFile:lower(), ['origTitle'] = curFile, ['path'] = curPath, ['icon'] = curIcon})
		end
	end
	
	fileQueue = fileQueue+1
	if fileQueue <= fileCount:GetValue() + 1 then
		SKIN:Bang('!SetOption', 'MeasureChild1', 'Index', fileQueue)
		SKIN:Bang('!SetOption', 'MeasureChild2', 'Index', fileQueue)
		SKIN:Bang('!SetOption', 'MeasureChild3', 'Index', fileQueue)
		SKIN:Bang('!SetOption', 'MeasureChild3', 'IconPath', '#@#launcherIcon\\'..#programTable..'.ico')
		SKIN:Bang('!CommandMeasure', 'MeasureFolder', 'Update')
		SKIN:Bang('!Update')
	end
	
	if fileQueue > fileCount:GetValue() + 1 then
		folderQueue = folderQueue + 1
		local folderPath = SKIN:GetVariable('ShortcutFolder'..folderQueue)
		if folderPath and folderPath ~= '' then
			fileQueue = 2
			SKIN:Bang('!SetOption', 'MeasureFileCount', 'Folder', folderPath)
			SKIN:Bang('!UpdateMeasure', 'MeasureFileCount')
			SKIN:Bang('!SetOption', 'MeasureFolder', 'Path', folderPath)
			SKIN:Bang('!SetOption', 'MeasureChild1', 'Index', 2)
			SKIN:Bang('!SetOption', 'MeasureChild2', 'Index', 2)
			SKIN:Bang('!SetOption', 'MeasureChild3', 'Index', 2)
			SKIN:Bang('!CommandMeasure', 'MeasureFolder', 'Update')
		else
			loading_files = false
			writeProgramList()
			sortChoice(programTable,defaultSort)
			curPage = 1
			setIcon(programTable)
			pageButton(0)
			SKIN:Bang("!Update")
		end
	end
end

function Start()
	if not running and not loading_files then
		print('Starting Input')
		SKIN:Bang("!CommandMeasure", "MEASURE_CURSOR", "Execute 1")
		browser = SKIN:GetVariable('Browser', 'chrome')
		SKIN:Bang('!CommandMeasure', 'RUN_KEYPRESS', 'Run')
		SKIN:Bang('!SetOption', 'Back', 'LeftMouseUpAction', '[!CommandMeasure "MEASURE_COMPLETION_SCRIPT" "Suspend()"]')
		running = true
		UpdateValues()
	end
end

function UpdateNow()
	if defaultSort == 'alphabet' then
		SKIN:Bang('!SetOption', 'AlphabetSort', 'FontColor' , '#ButtonSelectedColor#')
		SKIN:Bang('!SetOption', 'WeightSort', 'FontColor' , '#ButtonNotSelectedColor#')
	elseif defaultSort == 'weight' then
		SKIN:Bang('!SetOption', 'WeightSort', 'FontColor' , '#ButtonSelectedColor#')
		SKIN:Bang('!SetOption', 'AlphabetSort', 'FontColor' , '#ButtonNotSelectedColor#')
	end
	if (loading_files) then return "Loading Applications..." end

	if (not running) then
		if (cur == '') then
			SKIN:Bang('!SetVariable', 'CURRENT', "")
			SKIN:Bang('!ShowMeterGroup', 'SortButton')
			return SKIN:GetVariable('DefaultText', '...') 
		else
			SKIN:Bang('!HideMeterGroup', 'SortButton')
			return calcSpaces() .. cursor_active
		end
	else
		if (cur == '') then
			SKIN:Bang('!ShowMeterGroup', 'SortButton')
			SKIN:Bang('!ShowMeter', 'SearchIcon')
			return cursor
		else
			SKIN:Bang('!HideMeterGroup', 'SortButton')
			SKIN:Bang('!HideMeter', 'SearchIcon')
			return calcSpaces() .. cursor
		end
	end
end

function UpdateValues()
	local commandvar = ""
	local selectionvar = ""
	predicted = ""
	local pred = {}
	if (cur ~= "") then
		pred = getList()
		if (#pred > 0) and (selection <= #pred) then
			pred = weightSort(alphabetSort(pred))
			selectionvar = pred[selection]['remainText']
		elseif (string.sub(cur, 1, 2) == "$ ") then
			selectionvar = cur
		elseif (string.match(cur, "^!" )) then
			selectionvar = cur		
		end
		predicted = pred[selection]
		setIcon(pred)
	else
		setIcon(programTable)
	end
	pageButton(0)
	SKIN:Bang('!SetVariable', 'CURRENT', cur)
	SKIN:Bang('!SetVariable', 'SELECTION', selectionvar)
	SKIN:Bang('!Update')
end

function getList()
	local pred = {}
	local find = string.find

	for _, value in pairs(programTable) do 
		local titleSplitted = split(value['title']," ")
		local curSplitted = split(cur," ")
		for i = 1, #titleSplitted do

			local remainText = ''
			if #curSplitted > 1 then
				
				for j = 1,#curSplitted-1 do remainText = remainText .. curSplitted[j] .. ' ' end
				local finishedWord, finishedIndex = curSplitted[#curSplitted-1], nil
				for j = 1,#titleSplitted do 
					if finishedWord == titleSplitted[j] then
						finishedIndex = j
						break
					end
				end
				if (
					finishedIndex ~= i and
					curSplitted[#curSplitted] == titleSplitted[i]:sub(1, curSplitted[#curSplitted]:len()) and
					find(value['title'], cur)
				) then
		
					for j = i,#titleSplitted do remainText = remainText .. (j == i and '' or ' ') .. titleSplitted[j] end
					table.insert(pred, value)
					pred[#pred]['remainText'] = remainText
					break
				end
			else
				if (
					cur == titleSplitted[i]:sub(1, cur:len()) or 
					(
						cur:sub(cur:len()) == ' ' and 
						find(titleSplitted[i], cur:sub(1,cur:len()-1)) and
						find(value['title'], cur)
					)
				) then
					for j = i,#titleSplitted do remainText = remainText .. (j == i and '' or ' ') .. titleSplitted[j] end
					table.insert(pred, value)
					pred[#pred]['remainText'] = remainText
					break
				end
			end
		end
	end
	return pred
end

function alphabetSort(pred)
	table.sort(pred, function (a,b) return a['title'] < b['title'] end)
	return pred
end

function weightSort(pred)
	for i = 1,#pred do
		for e = i, #pred do
			local a = weightTable[pred[e]['title']] or 0
			local b = weightTable[pred[i]['title']] or 0
			if a > b then pred[e],pred[i] = pred[i],pred[e] end
		end
	end
	return pred
end

function sortChoice(pred,c)
	if c == 'alphabet' then
		return alphabetSort(pred)
	elseif c == 'weight' then
		return weightSort(pred)
	end
end
function calcSpaces(text)
	local s = ""
	for i = 1, cur:len() - cursor_offset do s = s.. string.sub(cur, i, i) end
	return s
end

function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function excludeKeyword(name)
	for _,v in pairs(exKeyWord) do
		if string.find(name, v) then
			return false
		end
	end
	return true
end

function CursorOn()
	cursor = cursor_active
end

function CursorOff()
	cursor = ' '
end

function RestartCursor()
	if running then		
		SKIN:Bang("!CommandMeasure", "MEASURE_CURSOR", "Stop 1")
		SKIN:Bang("!CommandMeasure", "MEASURE_CURSOR", "Execute 1")
	end
end

function RestartScroll()
	if scroll_dir ~= 0 then
		SKIN:Bang("!CommandMeasure", "MEASURE_SCROLL", "Stop 1")
		SKIN:Bang("!CommandMeasure", "MEASURE_SCROLL", "Execute 1")
	end
end

function ScrollOn()
	if (scroll_dir == 2) then
		if cursor_offset > 0 then
			cursor_offset = cursor_offset - 1
			UpdateValues()
		end
	elseif (scroll_dir == 3) then
		if cursor_offset < string.len(cur) then
			cursor_offset = cursor_offset + 1
			UpdateValues()
		end
	end
end

function selectMeter(dir)
	selection = selection - (curPage-1)*(appColumn * appRow)
	
	DrawNotSelectingShape(selection)
	SKIN:Bang('!UpdateMeter', 'Shape'..selection)

	if dir == 'clear' then
		SKIN:Bang('!Redraw')
		return
	else
		selection = selection + dir
	end

	local max = #curTable < (appColumn * appRow) and #curTable or (appColumn * appRow)
	if selection < 0 then
		selection = 1
		selecting = false
		selectMeter('clear')
		return
	elseif selection > max then 
		selection = max
	end
	UpdateValues()
	DrawSelectingShape(selection)
	SKIN:Bang('!UpdateMeter', 'Shape'..selection)
	SKIN:Bang('!Redraw')
end
function KeyDown(k)
	if (running) then
		if (not selecting) then
			if (k == 'Right') then
				scroll_dir = 2
				SKIN:Bang("!CommandMeasure", "MEASURE_SCROLL", "Execute 1")
			elseif (k == 'Left') then
				scroll_dir = 3
				SKIN:Bang("!CommandMeasure", "MEASURE_SCROLL", "Execute 1")
			elseif (k == 'Down') then
				selecting = true
				selectMeter('clear')
				selection = 1
				selectMeter(0)
			elseif (k ~= 'Up') then
				keys[k] = true
			end
		else
			if (k == 'Right') then
				selectMeter(1)
			elseif (k == 'Left') then
				selectMeter(-1)
			elseif (k == 'Down') then
				selectMeter(appColumn)
			elseif (k == 'Up') then
				selectMeter(-appColumn)
			else
				keys[k] = true
			end
		end
	end
end

function KeyUp(k)
	if (running) then
		if (k == 'Right') or (k == 'Left') then
			scroll_dir = 0
		elseif (k ~= 'Up') and (k ~= 'Down') then
			keys[k] = nil
			KeyPressed(k)
		end
	end
end

function KeyPressed(k)
	if (running) then
		if (k == 'BS') then
			if (cur:len() - cursor_offset > 0) then
				cur = string.sub(cur, 0, (cur:len() - 1) - cursor_offset) .. string.sub(cur, (cur:len() + 1) - cursor_offset, cur:len())
				selectMeter('clear')
				selection = 1
			end
		elseif (k == 'Delete') then
			if (cursor_offset > 0) then
				cur = string.sub(cur, 0, (cur:len()) - cursor_offset) .. string.sub(cur, (cur:len() + 2) - cursor_offset, cur:len())
				cursor_offset = cursor_offset - 1
				selectMeter('clear')
				selection = 1
			end
		elseif (k == '\t') then
			if not pcall(End) then print('Error ending input (Please Report This!)') end
			selectMeter('clear')
			selection = 1
		elseif (k == '\n') then
			if not pcall(End) then print('Error ending input (Please Report This!)') end
			selectMeter('clear')
			selection = 1
		else
			if (k == "QUOT") then k = "\"" end
			cur = string.sub(cur, 0, (cur:len()) - cursor_offset) .. k .. string.sub(cur, (cur:len() + 1) - cursor_offset, cur:len())
			selection = 1
		end
		curPage = 1
		pageButton(0)
		UpdateValues()
		SKIN:Bang('!Update')
	end
end

function Suspend()
	if running then
		running = false
		SKIN:Bang('!CommandMeasure', 'RUN_KEYPRESS', 'Kill')
		SKIN:Bang('!SetOption', 'Back', 'LeftMouseUpAction', '')
		SKIN:Bang('!Update')
	end
end

function End()
	if (running) and (cur ~= "") then
		keys = {}
		running = false
		SKIN:Bang('!CommandMeasure', 'RUN_KEYPRESS', 'Kill')
		cursor_offset = 0
		
		if predicted then
			local curCur = predicted['title']
			getWeight()
			if (weightTable[curCur] == nil) then 
				weightTable[curCur] = 1 
			else 
				weightTable[curCur] = weightTable[curCur] + 1 
			end
			local weightStorage = io.open(SKIN:GetVariable('@') .. 'launcherWeightStorage.txt',"w+")
			for ke,v in pairs(weightTable) do weightStorage:write(ke .. ";" .. v .. "\n") end
			weightStorage:close()
			
			SKIN:Bang('\["' .. predicted['path'] .. '"\]')
			

		elseif string.match(cur, "^$ ") then
			print(os.execute([[start cmd /k ]] .. string.sub(cur, 3, cur:len())))
		elseif string.match(cur, "^!") then
			if string.match(cur, "^!search ") then
				print(os.execute("start " .. browser .. " "..SKIN:GetVariable('SearchEnginePath').."\"" .. string.sub(cur, 9, cur:len()) .. "\""))
			elseif string.match(cur, "^!goto ") then
				print(os.execute("start " .. browser .. " \"" .. string.sub(cur, 7, cur:len()) .. "\""))
			end
		end
		SKIN:Bang('!DeactivateConfig')
		cur = ""
	end
end

function getWeight()
	local weightStorage = io.open(SKIN:GetVariable('@') .. 'launcherWeightStorage.txt','r')
	weightTable = {}
	if not weightStorage then return end
	local line = weightStorage:read('*line')
	while line do
		local t = split(line, ';')
		local ke,v = t[1],t[2]
		weightTable[ke] = tonumber(v)
		line = weightStorage:read('*line')
	end
	weightStorage:close()
end

function writeProgramList()
	local file = io.open(SKIN:GetVariable('@') .. 'launcherProgramList.txt','w')
	for i = 1, #programTable do
		local curProg = programTable[i]
		file:write(curProg['origTitle'], '|', curProg['path'], '|', curProg['icon'], '\n')
	end
	file:close()
end

function getProgramList()
	local file = io.open(SKIN:GetVariable('@') .. 'launcherProgramList.txt','r')
	local line = file:read('*line')
	while line do
		local curProg = split(line,'|')
		table.insert(programTable, {origTitle = curProg[1], title = curProg[1]:lower(), path = curProg[2], icon = curProg[3]})
		line = file:read('*line')
	end
end

function meterGenerator()
	local file = io.open(SKIN:GetVariable('@')..'meterFile.inc','w')
	for i = 1, (appColumn * appRow) do
		file:write( '[Shape'..i..']\n',
					'Meter=Shape\n',
					'MeterStyle=ShapeStyle\n',
					'[Text'..i..']\n',
					'Meter=String\n',
					'MeterStyle=TextStyle\n',
					'[Icon'..i..']\n',
					'Meter=Image\n',
					'MeterStyle=IconStyle\n')
	end
	file:close()
end

function setIcon(pred)
	local c = 1
	local r = 1
	animationTable = {}
	curTable = pred
	maxPage = math.ceil(#pred/(appColumn * appRow))
	for i = 1 + (appColumn * appRow)*(curPage-1), (appColumn * appRow)*curPage do
		local curIndex = i - (appColumn * appRow)*(curPage-1)
		local s, t, p = 'Shape'..curIndex, 'Text'..curIndex, 'Icon'..curIndex
		if i <= #pred then
			SKIN:Bang('!ShowMeter', s)
			SKIN:Bang('!ShowMeter', t)
			SKIN:Bang('!ShowMeter', p)
			SKIN:Bang('!SetOption', s, 'X', sideGap + (c-1) * appXGap)
			SKIN:Bang('!SetOption', s, 'Y', topGap + (r-1) * appYGap)
			SKIN:Bang('!SetOption', p, 'LeftMouseUpAction', '"'..pred[i]['path']..'"')
			SKIN:Bang('!SetOption', s, 'ToolTipText', pred[i]['origTitle'])
			SKIN:Bang('!SetOption', t, 'Text', pred[i]['origTitle'])
			SKIN:Bang('!SetOption', p, 'ImageName', pred[i]['icon'])
			if c == appColumn then r, c = r + 1, 0 end
			c = c + 1
			SKIN:Bang('!UpdateMeter', s)
			SKIN:Bang('!UpdateMeter', t)
			SKIN:Bang('!UpdateMeter', p)
		else
			SKIN:Bang('!HideMeter', s)
			SKIN:Bang('!HideMeter', t)
			SKIN:Bang('!HideMeter', p)
		end
	end
	SKIN:Bang('!Redraw')
end

shapeCount = 2
function pageButton(dir,page)
	if dir and (curPage + dir) <= maxPage and (curPage + dir) >= 1 then
		curPage = curPage + dir
	elseif page and page >= 1 and page <= maxPage then
		curPage = page
	else 
		return
	end
	
	dotDis = 20*(maxPage-1) > 200 and 200/(maxPage-1) or 20
	maxDis = dotDis*(maxPage-1)
	shapeX = SKIN:GetVariable('Width')/2 - maxDis/2

	SKIN:Bang('!SetOption', 'PageShape', 'X', shapeX)
	SKIN:Bang('!SetOption', 'PageShape', 'Shape', 'Rectangle 0,-15,'..maxDis..',30 | Extend HitBox')

	for i = 2, shapeCount do
		SKIN:Bang('!SetOption', 'PageShape', 'Shape'..i, '')
	end
	shapeCount = 2
	for i = 1, maxPage do
		DrawPageIndicator(i+1,(i-1)*dotDis,i==curPage)
		shapeCount = shapeCount + 1
	end

	SKIN:Bang('!UpdateMeter', 'PageShape')	
	SKIN:Bang('!Redraw')
end

floor = math.floor

function slidePage(mouseX)
	local delta = (mouseX - shapeX)
	if delta < 0 then delta = 0 end
	local page = floor(delta * (maxPage-1) / maxDis + 1 + 0.5)
	if page > maxPage then page = maxPage end
	pageButton(nil,page)
	setIcon(curTable)
end

function chooseAnimation()
	if timing1 > 0 and timing1 < 20 then
		timing1 = timing1 + 1
	end
end