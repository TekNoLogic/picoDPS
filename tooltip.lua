
local myname, ns = ...


local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


local tip = LibStub("tektip-1.0").new(3)
function ns.dataobj:OnEnter()
	ns.shown = self
	tip:AnchorTo(self)

	tip:AddLine("picoDPS")
	tip:AddLine(" ")

	tip:AddMultiLine("Player", "Total", "DPS")
	tip:AddMultiLine(ns.unitnames[ns.ids.player] or UnitName("player"), ns.damagetotals[ns.ids.player] or 0, string.format("%.1f", (ns.damagetotals[ns.ids.player] or 0)/(ns.times[ns.ids.player] or 1)), nil,nil,nil, 1,1,1, 1,1,1)
	for id in pairs(ns.damagetotals) do
		if id ~= ns.ids.player then tip:AddMultiLine(ns.unitnames[id] or "???", ns.damagetotals[id] or 0, string.format("%.1f", (ns.damagetotals[id] or 0)/(ns.times[id] or 1)), nil,nil,nil, 1,1,1, 1,1,1) end
	end

	tip:Show()
end


function ns.dataobj.OnLeave()
	ns.shown = nil
	tip:Hide()
end
