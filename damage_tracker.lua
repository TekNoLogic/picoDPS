
local myname, ns = ...


ns.damagetotals, ns.times = {}, {}


local logevents = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	DAMAGE_SHIELD = true,
	DAMAGE_SPLIT = true
}


local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elap)
	for unit,id in pairs(ns.ids) do
		if UnitAffectingCombat(unit) then ns.times[id] = (ns.times[id] or 0) + elap end
	end

	ns.Refresh()
end)


function ns.COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, logevent, hideCaster,
	sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	destGUID, destName, destFlags, destRaidFlags, ...)

	if not logevents[logevent] then return end

	local spellId, spellName, spellSchool, amount, overkill, school, resisted,
	      blocked, absorbed, critical, glancing, crushing = ...

	if logevent == "SWING_DAMAGE" then
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing,
		crushing = ...
	end

	local unit = ns.units[sourceGUID]
	if unit then
		ns.damagetotals[unit] = (ns.damagetotals[unit] or 0) + amount
	end
end
