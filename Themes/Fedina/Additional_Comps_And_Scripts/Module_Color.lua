--This script return color of module base on its position in bar.

function Initialize()
	width = SKIN:GetVariable('Bar_Width')
end

abs = math.abs
function GetColor(color1, color2, dir, position)
	dir = dir:lower()
	local scale = 0
	if dir == "side to middle" then
		scale = 1 - abs(width/2 - position) / (width/2)
	elseif dir == 'middle to side' then
		scale = abs(width/2 - position) / (width/2)
	elseif dir == 'left to right' then
		scale = (width - position) / width
	elseif dir == 'right to left' then
		scale = position / width
	else
		print(SELF:GetName() .. ': Unrecognized Direction. Valid options: side to middle, middle to side, left to right, right to left.')
	end
	
	local r,g,b = separateColor(color1)
	local r2,g2,b2 = separateColor(color2)

	local rM,gM,bM = r + (r2 - r)*scale, g + (g2 - g)*scale, b + (b2 - b)*scale
	return string.format('%02X', rM) .. string.format('%02X', gM) .. string.format('%02X', bM)
end

function separateColor(hex)
	local r, g, b = hex:match('(..)(..)(..)')
	return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end