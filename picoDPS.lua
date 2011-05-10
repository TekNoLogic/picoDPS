
local myDamage, timeincombat, pId = 0, 0
local damagetotals, times, ids, units, unitnames, colors, shown = {}, {}, {}, {}, {}, {}
local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true}
for class,color in pairs(RAID_CLASS_COLORS) do colors[class] = string.format("%02x%02x%02x", color.r*255, color.g*255, color.b*255) end


local obj = LibStub("LibDataBroker-1.1"):NewDataObject("picoDPS", {type = "data source", text = "0.0 DPS"})


local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("PLAYER_LOGIN")


f:SetScript("OnUpdate", function(self, elap)
	for unit,id in pairs(ids) do
		if UnitAffectingCombat(unit) then times[id] = (times[id] or 0) + elap end
	end

	obj.text = string.format("%.1f DPS", (damagetotals[pId] or 0)/(times[pId] or 1))
	if shown then obj.OnEnter(shown) end
end)


function f:PLAYER_LOGIN()
	pId = UnitGUID("player")

	ids.player = pId
	units[pId] = pId
	unitnames[pId] = "|cff"..colors[select(2, UnitClass("player"))]..UnitName("player").."|r"

	local petid = UnitGUID("pet")
	if petid then units[petid], ids.pet = pId, petid end

	self:PARTY_MEMBERS_CHANGED()
	self:RAID_ROSTER_UPDATE()

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_PET")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end


function f:UNIT_PET(unit)
	if unit == "player" then
		local petid = UnitGUID("pet")
		ids.pet = petid
		if petid then units[petid] = pId end
	elseif unit ~= "target" and unit ~= "focus" then
		local group, id = unit:match("^(%D+)(%d+)$")
		if not id then
			print(string.format("picoDPS: Error parsing unit %q", unit))
		else
			local petid = UnitGUID(group.."pet"..id)
			if petid then units[petid] = ids[unit] end
		end
	end
end


function f:PARTY_MEMBERS_CHANGED()
	for i=1,4 do
		local id = UnitGUID("party"..i)
		ids["party"..i] = id
		if ids["party"..i] then
			units[id] = id
			unitnames[id] = "|cff"..colors[select(2, UnitClass("party"..i)) or "PRIEST"]..UnitName("party"..i).."|r"
		end

		local petid = UnitGUID("partypet"..i)
		if petid then units[petid] = id end
	end
end


function f:RAID_ROSTER_UPDATE()
	for i=1,40 do
		local id = UnitGUID("raid"..i)
		ids["raid"..i] = id
		if ids["raid"..i] then
			units[id] = id
			unitnames[id] = "|cff"..colors[select(2, UnitClass("raid"..i)) or "PRIEST"]..UnitName("raid"..i).."|r"
		end

		local petid = UnitGUID("raidpet"..i)
		if petid then units[petid] = id end
	end
end


function f:COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, _, id, _, _, _, _, _, _, _, _, spellid, _, _, damage)
	if not events[eventtype] then return end

	if id == pId or id == ids.pet then
		if eventtype == "SWING_DAMAGE" then
			damage = spellid
		end
		myDamage = myDamage + damage
	end

	if units[id] then damagetotals[units[id]] = (damagetotals[units[id]] or 0) + (eventtype == "SWING_DAMAGE" and spellid or damage) end
end


function f:PLAYER_REGEN_ENABLED()
	obj.text = string.format("%.1f DPS", (damagetotals[pId] or 0)/(times[pId] or 1))
end


function obj:OnClick()
	for i in pairs(damagetotals) do damagetotals[i] = nil end
	for i in pairs(times) do times[i] = nil end

	obj.text = "0.0 DPS"
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


local tip = LibStub("tektip-1.0").new(3)
function obj.OnEnter(self)
	shown = self
	tip:AnchorTo(self)

	tip:AddLine("picoDPS")
	tip:AddLine(" ")

	tip:AddMultiLine("Player", "Total", "DPS")
	tip:AddMultiLine(unitnames[pId] or UnitName("player"), damagetotals[pId] or 0, string.format("%.1f", (damagetotals[pId] or 0)/(times[pId] or 1)), nil,nil,nil, 1,1,1, 1,1,1)
	for id in pairs(damagetotals) do
		if id ~= pId then tip:AddMultiLine(unitnames[id] or "???", damagetotals[id] or 0, string.format("%.1f", (damagetotals[id] or 0)/(times[id] or 1)), nil,nil,nil, 1,1,1, 1,1,1) end
	end

	tip:Show()
end


function obj.OnLeave()
	shown = nil
	tip:Hide()
end
