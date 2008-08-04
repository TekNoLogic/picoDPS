
local myDamage, timeincombat, pId, petId = 0, 0
local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true}


local obj = LibStub("LibDataBroker-1.1"):NewDataObject("picoDPS", {text = "0.0 DPS"})


local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")


function f:PLAYER_LOGIN()
	pId = UnitGUID("player")
	petId = UnitGUID("pet") or "0x0"

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end


function f:COMBAT_LOG_EVENT_UNFILTERED(_, eventType, Id, _, _, _, _, _, spellID, _, _, damage)
	if not events[eventType] then return end

	if Id == pId or Id == petId then
		if eventType == "SWING_DAMAGE" then
			damage = spellID
		end
		myDamage = myDamage + damage
	end
end


function f:PLAYER_REGEN_DISABLED()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	timeincombat = timeincombat - GetTime()
end


function f:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	timeincombat = timeincombat + GetTime()
	obj.text = string.format("%.1f DPS", myDamage/timeincombat)
end
