-- sv_warden
local listMic = {}


concommand.Add("jb_hasmic",function(p,c,a)
	listMic[p:UniqueID()] = tonumber(a[1])
end)

function _R.Player:HasMic()
	if not listMic[self:UniqueID()] then return false end

	return tobool(listMic[self:UniqueID()])
end

function _R.Player:HasAwnseredMic()
	if not listMic[self:UniqueID()] then return false end

	return true
end

function JB:SetWarden(p)
	JB.wardenPlayer = p
	for k,v in pairs(team.GetPlayers(TEAM_GUARD)) do
		v:SetModel("models/player/police.mdl")
	end
	p:SetModel("models/player/barney.mdl")
	net.Start("JSWP")
	net.WriteEntity(p)
	net.Broadcast()
end

function JB:ResetWarden()
	JB.wardenPlayer = nil
	net.Start("JRSW")
	net.Broadcast()
end