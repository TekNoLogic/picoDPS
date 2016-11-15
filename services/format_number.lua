
local myname, ns = ...


function ns.FormatNumber(num)
	if num >= 1000000 then
		return string.format("%.1fm", num/1000000)
	elseif num >= 1000 then
		return string.format("%.1fk", num/1000)
	else
		return string.format("%.1f", num)
	end
end
