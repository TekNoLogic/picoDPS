
local myname, ns = ...


ns.dataobj = LibStub("LibDataBroker-1.1"):NewDataObject("picoDPS", {type = "data source", text = "0.0 DPS"})


function ns.Refresh()
	local dps = (ns.damagetotals[ns.ids.player] or 0)/(ns.times[ns.ids.player] or 1)
	ns.dataobj.text = ns.FormatNumber(dps).. " DPS"

	if ns.shown then ns.dataobj.OnEnter(ns.shown) end
end
ns.PLAYER_REGEN_ENABLED = ns.Refresh


function ns.dataobj:OnClick()
	for i in pairs(ns.damagetotals) do ns.damagetotals[i] = nil end
	for i in pairs(ns.times) do ns.times[i] = nil end

	ns.dataobj.text = "0.0 DPS"
end
