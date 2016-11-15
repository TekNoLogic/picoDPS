
local myname, ns = ...


ns.ids, ns.units, ns.unitnames = {}, {}, {}


local colors = {}
for class,clr in pairs(RAID_CLASS_COLORS) do colors[class] = clr.colorStr end


local function Colorize(text, _, class)
	return "|c"..colors[class or "PRIEST"]..text.."|r"
end


function ns.OnLogin()
	local playerid = UnitGUID("player")
	ns.ids.player = playerid
	ns.units[playerid] = playerid
	ns.unitnames[playerid] = Colorize(UnitName("player"), UnitClass("player"))

	local petid = UnitGUID("pet")
	if petid then ns.units[petid], ns.ids.pet = playerid, petid end

	ns.GROUP_ROSTER_UPDATE()

	ns.RegisterEvent("PLAYER_REGEN_ENABLED")
	ns.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	ns.RegisterEvent("GROUP_ROSTER_UPDATE")
	ns.RegisterEvent("UNIT_PET")
end


function ns.UNIT_PET(event, unit)
	if unit == "player" then
		local petid = UnitGUID("pet")
		ns.ids.pet = petid
		if petid then ns.units[petid] = ns.ids.player end
	elseif unit ~= "target" and unit ~= "focus" then
		local group, id = unit:match("^(%D+)(%d+)$")
		if not id then
			ns.Print("Error parsing unit", unit)
		else
			local petid = UnitGUID(group.."pet"..id)
			if petid then ns.units[petid] = ns.ids[unit] end
		end
	end
end


function ns.GROUP_ROSTER_UPDATE()
	for i=1,4 do
		local id = UnitGUID("party"..i)
		ns.ids["party"..i] = id
		if ns.ids["party"..i] then
			ns.units[id] = id
			local _, class = UnitClass("party"..i)
			ns.unitnames[id] = Colorize(UnitName("party"..i), UnitClass("party"..i))
		end

		local petid = UnitGUID("partypet"..i)
		if petid then ns.units[petid] = id end
	end

	for i=1,40 do
		local id = UnitGUID("raid"..i)
		ns.ids["raid"..i] = id
		if ns.ids["raid"..i] then
			ns.units[id] = id
			ns.unitnames[id] = Colorize(UnitName("raid"..i), UnitClass("raid"..i))
		end

		local petid = UnitGUID("raidpet"..i)
		if petid then ns.units[petid] = id end
	end
end
