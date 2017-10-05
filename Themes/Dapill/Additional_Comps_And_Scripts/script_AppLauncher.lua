function Initialize()
	dofile(SKIN:GetVariable('@')..'Scripts\\AppLauncher_Common_Script.lua')

	sideGap = 30
	topGap = 75

	appXGap = 105
	appYGap = 110

	appColumn = 3
	appRow = 4

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
	SKIN:Bang('!SetOption', 'METER_BACKGROUND', 'Shape', 'Rectangle ' .. X .. ',' .. Y .. ',100,100,3 | Extend Selecting')
end

function ClearSelectingShape()
	SKIN:Bang('!SetOption', 'METER_BACKGROUND', 'Shape', 'Rectangle 0,0,0,0 | StrokeWidth 0')
end