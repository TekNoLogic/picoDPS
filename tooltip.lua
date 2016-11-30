
local myname, ns = ...


local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


local tip = LibStub("tektip-1.0").new(4)
local function AddMultiLine(id, is_player)
	local name = ns.unitnames[id] or is_player and UnitName("player") or "???"
	local total = ns.FormatNumber(ns.damagetotals[id] or 0)
	local dps = ns.FormatNumber((ns.damagetotals[id] or 0)/(ns.times[id] or 1))

	local time = ns.times[id] or 0
	if time > 60 then
		time = string.format("%d:%d", (time / 60), (time % 60))
	else
		time = string.format("%ds", time)
	end

	tip:AddMultiLine(name, time, total, dps, nil,nil,nil, 1,1,1, 1,1,1, 1,1,1)
end


function ns.dataobj:OnEnter()
	ns.shown = self
	tip:AnchorTo(self)

	tip:AddLine("picoDPS")
	tip:AddLine(" ")

	tip:AddMultiLine("Player", "Time", "Total", "DPS")
	AddMultiLine(ns.ids.player, true)

	for id in pairs(ns.damagetotals) do
		if id ~= ns.ids.player then AddMultiLine(id) end
	end

	tip:Show()
end


function ns.dataobj.OnLeave()
	ns.shown = nil
	tip:Hide()
end
