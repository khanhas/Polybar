function Initialize()
	dofile(SKIN:GetVariable('@')..'Scripts\\AppLauncher_Common_Script.lua')

	sideGap = 30
	topGap = 75

	appXGap = 120
	appYGap = 125

	appColumn = 4
	appRow = 2

	dotZoneMaxWidth = SKIN:GetVariable('Width') - sideGap * 8

	GetEssentialVariables()
end

function Update()
	return UpdateNow()
end

--[[
DrawPageIndicator
Desc: Drawing shapes that indicate current page and total number of pages
Para:
	shapeIndex: currently drawing shape index
	posX: position X of currently drawing shape
	isCurrentPage (boolean): is currently drawing shape belong to current page
]]
function DrawPageIndicator(shapeIndex, posX, isCurrentPage)
	if isCurrentPage then
		SKIN:Bang('!SetOption', 'PageShape', 'Shape'..shapeIndex, 'Ellipse '..posX..',0,3 | Extend Selected ')
	else
		SKIN:Bang('!SetOption', 'PageShape', 'Shape'..shapeIndex, 'Ellipse '..posX..',0,2 | Extend Normal')
	end
end

function DrawSelectingShape(X, Y)
	SKIN:Bang('!SetOption', 'METER_BACKGROUND', 'Shape3', 'Rectangle ' .. X .. ',' .. Y .. ',110,120 | Extend Selecting')
end

function ClearSelectingShape()
	SKIN:Bang('!SetOption', 'METER_BACKGROUND', 'Shape3', 'Rectangle 0,0,0,0 | StrokeWidth 0')
end