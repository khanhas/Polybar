function Initialize()
	maxNum = tonumber(SELF:GetOption('NumOfNum'))
	if not maxNum or maxNum < 3 then
		error('Incorrect NumOfNum value.')
	end

	input = SELF:GetOption('InputMeasure', nil)
	if not input then
		error('No InputMeasure.')
	else
		input = SKIN:GetMeasure(input)
	end

	unit = SELF:GetOption('Unit', nil)
	if not unit then
		error('No Unit.')
	end
		
	factor = 0
	factor2 = 1
	if unit == 'db' then
		factor = 1000
		factor2 = 8
		unit = {'kb', 'Mb', 'Gb'}
	elseif unit == 'bb' then
		factor = 1024
		factor2 = 8
		unit = {'Kibit', 'Mibit', 'Gibit'}
	elseif unit == 'dB' then
		factor = 1000
		unit = {'kB', 'MB', 'GB'}
	elseif unit == 'bB' then
		factor = 1024
		unit = {'KiB', 'MiB', 'GiB'}
	else
		unit = nil
		error('Incorrect Unit value. Valid options: db, bb, dB, bB.')
	end

	kiloThreshold = 1000*factor
	megaThreshold = 1000*factor*factor
	gigaThreshold = 1000*factor*factor*factor
end

function Update()
	if not maxNum or not input or not unit then return 'Error' end

	local value = input:GetValue() * factor2

	if value < kiloThreshold then
		return concat{scale(value), unit[1]}

	elseif value < megaThreshold then
		return concat{scale(value / factor), unit[2]}

	elseif value < gigaThreshold then
		return concat{scale(value / factor / factor), unit[3]}

	end
end

function scale(v)
	local i, f = math.modf(v / factor)
	local remainFrac = maxNum - string.len(i)
	if remainFrac == 0 then
		f = ''
	elseif remainFrac > 0 then
		f = round(f, remainFrac)
		if f < 1 and f > 0 then
			f = tostring(f)
			local fracLen = string.len(f)
			local addZero = remainFrac - (fracLen - 2)
			f = concat{'.', f:sub(3, fracLen), string.rep('0', addZero)}
		elseif f == 1 then
			i = i + 1
			remainFrac = maxNum - string.len(i)
			local addZero = math.abs(remainFrac)
			f = concat{'.', string.rep('0', addZero)}
		else
			local addZero = math.abs(remainFrac)
			f = concat{'.', string.rep('0', addZero)}
		end
	end
	return concat{i, f}
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function concat(t)
	return table.concat(t, "")
end