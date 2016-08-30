Player:ViewBounce( scale ) -- Try to keep it clientside.
	self:ViewPunch( Angle( math.Rand( -0.2, -0.1 ) * scale, math.Rand( -0.05, 0.05 ) * scale, 0 ) )
end

Player:GetFixedSteamID()
	local sID = self:SteamID()
	return string.gsub(sID,string.Left(sID,10),"")
end

Player:HasPrimary()
	for k,v in pairs(self:GetWeapons())do
		if string.Left(v:GetClass(),10) == "jb_primary" then
			return true
		end
	end
end

Player:HasSecondary()
	for k,v in pairs(self:GetWeapons())do
		if string.Left(v:GetClass(),12) == "jb_secondary" then
			return true
		end
	end
end

function JB:PlayerNoClip(p)
	return p:IsAdmin() or SinglePlayer() or GetConVar("sv_cheats"):GetInt()
end

