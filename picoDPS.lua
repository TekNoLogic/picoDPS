
local myDamage, timeincombat, pId, petId = 0, 0
local damagetotals, times, ids, units, unitnames, colors, shown = {}, {}, {}, {}, {}, {}
local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true}
for class,color in pairs(RAID_CLASS_COLORS) do colors[class] = string.format("%02x%02x%02x", color.r*255, color.g*255, color.b*255) end


local obj = LibStub("LibDataBroker-1.1"):NewDataObject("picoDPS", {text = "0.0 DPS"})


local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")


f:SetScript("OnUpdate", function(self, elap)
	for unit,id in pairs(ids) do
		if UnitAffectingCombat(unit) then times[id] = (times[id] or 0) + elap end
	end

	if shown then obj.OnEnter(shown) end
end)


function f:PLAYER_LOGIN()
	pId = UnitGUID("player")
	petId = UnitGUID("pet") or "0x0"

	ids.player, ids.pet = UnitGUID("player"), UnitGUID("pet")
	units[ids.player] = ids.player
	unitnames.player = "|cff"..colors[select(2, UnitClass("player"))]..UnitName("player").."|r"

	local petid = UnitGUID("pet")
	if petid then units[petid] = ids.player end

	self:PARTY_MEMBERS_CHANGED()

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end


function f:PARTY_MEMBERS_CHANGED()
	for i=1,4 do
		ids["party"..i] = UnitGUID("party"..i)
		if ids["party"..i] then
			units[ids["party"..i]] = ids["party"..i]
			unitnames["party"..i] = "|cff"..colors[select(2, UnitClass("party"..i)) or "PRIEST"]..UnitName("party"..i).."|r"
		end

		local petid = UnitGUID("partypet"..i)
		if petid then units[petid] = ids["party"..i] end
	end
end


function f:COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, id, _, _, _, _, _, spellid, _, _, damage)
	if not events[eventtype] then return end

	if id == pId or id == petId then
		if eventtype == "SWING_DAMAGE" then
			damage = spellid
		end
		myDamage = myDamage + damage
	end

	if units[id] then damagetotals[units[id]] = (damagetotals[units[id]] or 0) + (eventtype == "SWING_DAMAGE" and spellid or damage) end
end


function f:PLAYER_REGEN_ENABLED()
	obj.text = string.format("%.1f DPS", (damagetotals[ids.player] or 0)/(times[ids.player] or 1))
end



------------------------
--      Tooltip!      --
------------------------

local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


function obj.OnEnter(self)
	shown = self
 	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(GetTipAnchor(self))
	GameTooltip:ClearLines()

	GameTooltip:AddLine("picoDPS")

	GameTooltip:AddDoubleLine(unitnames.player or UnitName("player"), string.format("%.1f DPS (%d)", (damagetotals[ids.player] or 0)/(times[ids.player] or 1), damagetotals[ids.player] or 0), nil,nil,nil,1,1,1)
	for unit,id in pairs(ids) do
		if unit ~= "player" then GameTooltip:AddDoubleLine(unitnames[unit] or UnitName(unit), string.format("%.1f DPS (%d)", (damagetotals[id] or 0)/(times[id] or 1), damagetotals[id] or 0), nil,nil,nil,1,1,1) end
	end

	GameTooltip:Show()
end


function obj.OnLeave()
	shown = nil
	GameTooltip:Hide()
end
