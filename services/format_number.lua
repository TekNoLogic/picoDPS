
local myname, ns = ...


function ns.FormatNumber(num)
	if num >= 1000 then
		return string.format("%.1fk", num/1000.0)
	else
		return string.format("%.1f", num)
	end
end
