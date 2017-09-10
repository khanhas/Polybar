function Initialize()
	dofile(SKIN:GetVariable('@')..'Scripts\\AppLauncher_Common_Script.lua')

	sideGap = 30
	topGap = 75 

	appXGap = 105
	appYGap = 110

	appColumn = 4
	appRow = 2

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
		SKIN:Bang('!SetOption', 'PageShape', 'Shape'..shapeIndex, 'Rectangle '..posX..',0,5,5 | Extend Selected | Offset -2.5,-2.5')
	else
		SKIN:Bang('!SetOption', 'PageShape', 'Shape'..shapeIndex, 'Rectangle '..posX..',0,4,4 | Extend Normal | Offset -2,-2')
	end
end