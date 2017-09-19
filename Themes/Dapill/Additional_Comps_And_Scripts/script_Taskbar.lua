function Initialize()
	dofile(SKIN:GetVariable('@')..'Scripts\\Taskbar_Common_Script.lua')
	GetEssentialVariables()
end

function Update()
	--Check Skin position
	if SKIN:GetVariable('currentconfigY')*1 >= SKIN:GetVariable('ScreenAreaHeight')/2 then
		dotPosition = '(#Bar_Height#/2 + #Icon_Size#/2 + #Dot_DistanceToIcon#)'
		topGap = '#AdaptiveBackground_TopGap#'
		botGap = '#AdaptiveBackground_BottomGap#'
	else
		dotPosition = '(#Bar_Height#/2 - #Icon_Size#/2 - #Dot_DistanceToIcon#)'
		botGap = '#AdaptiveBackground_TopGap#'
		topGap = '#AdaptiveBackground_BottomGap#'
	end
	UpdateNow()
end

--This function is used for drawing subprocess tracking shape. 
--TotalRunning is total number of subprocess of 1 process.
--CurrentDrawingIndex is taskbar index of process that currently drawing.
--CurrentActiveWindow: Return true if currently drawing process is active. Return false if currently drawing process is not active process. 
--shapeCount is start at 2
-- If theme doesn't need it, leave it blank, do not remove it.
function DrawSubProcessShape(TotalRunning,CurrentDrawingIndex,CurrentActiveWindow)
	TotalRunning = TotalRunning - 1

	--Distance between dots. Normally they are 6 pixel, if there're too much subprocess and they're possibly overflow icon zone, (IconGap+IconSize)/TotalRunning will be new DotGap.
	local DotGap = 6
	if (DotGap * TotalRunning) > (processWidth - IconGap) then
		DotGap = (processWidth - IconGap)/TotalRunning
	end
	--Distance between first dot and last dot
	local totalDotSpace = TotalRunning * DotGap 
	if CurrentActiveWindow then 
		DotTrait = 'ActiveDotColor'
	else
		DotTrait = 'DotColor'
	end
	--Start drawing
	SKIN:Bang('!SetOption SubprocessTrackingShape Shape'..shapeCount..' "Rectangle '..(processWidth/2 + processWidth * CurrentDrawingIndex - totalDotSpace/2 - 2)..','..dotPosition..','..(totalDotSpace+4)..',4,2 | StrokeWidth 0 | Extend '..DotTrait..'"')
	shapeCount=shapeCount+1
end

--DrawProcessBackground function used for drawing background under all application.
--TotalProcess: total number of processes.
--If theme doesn't need it, leave it blank, do not remove it.
function DrawProcessBackground(TotalProcess)
	SKIN:Bang('!SetOption TaskbarShape Shape3 "Rectangle 0,(#Bar_Height#/2 - #Icon_Size# / 2 - '..topGap..'),'..(TotalProcess * processWidth)..',('..topGap..' + '..botGap..' + #Icon_Size#),#AdaptiveBackground_RoundCornerAmount# | Extend AdaptiveBackground"')
end

--DrawIconHighlight function used for drawing attribute of icon when mouse is hovering on.
--iconIndex: taskbar index of process mouse currently over.
--If theme doesn't need it, leave it blank, do not remove it.
function DrawIconHighlight(iconIndex)
	MouseOver_IconIndex = iconIndex
--When mouse over icon, Lighten it up, draw background shape for that icon
	SKIN:Bang('!SetOption', iconIndex..'Icon', 'ImageTint', '#Icon_MouseOver_TintColor#')
	SKIN:Bang('!UpdateMeter', iconIndex..'Icon')
	SKIN:Bang('!SetOption', iconIndex..'Shape', 'Trait', 'StrokeWidth 0 | Fill LinearGradient Grad')
	SKIN:Bang('!UpdateMeter', iconIndex..'Shape')
	SKIN:Bang('!Redraw')
end

--ProcessMouseLeave function used for drawing attribute of icon when mouse leaves.
--iconIndex: taskbar index of process that mouse just leaves.
--If theme doesn't need it, leave it blank, do not remove it.
function ProcessMouseLeave(iconIndex)
	MouseOver_IconIndex = -1
	iconIndex = getIndex(iconIndex)
	SKIN:Bang('!SetOption', iconIndex..'Icon', 'ImageTint', '#Icon_MouseLeave_TintColor#')
	SKIN:Bang('!UpdateMeter', iconIndex..'Icon')
	SKIN:Bang('!SetOption', iconIndex..'Shape', 'Trait', 'StrokeWidth 0 | Fill LinearGradient NoGrad')
	SKIN:Bang('!UpdateMeter', iconIndex..'Shape')
	SKIN:Bang('!Redraw')
end