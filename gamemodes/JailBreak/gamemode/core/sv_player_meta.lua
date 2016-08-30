-- sv_player_hooks

function _R.Player:IsGuard()
	return ((self:Team() == TEAM_GUARD or self:Team() == TEAM_GUARD_DEAD) and self.character)
end

function _R.Player:IsPrisoner()
	return ((self:Team() == TEAM_PRISONER or self:Team() == TEAM_PRISONER_DEAD) and self.character)
end

function _R.Player:HasChoosen() -- Are we out of the selection menu yet?
	return tobool(self.character) -- turn it into a boolean
end

function _R.Player:SendNotification(m,i)
	net.Start("JNC")
	net.WriteString(m)
	if i then
		net.WriteString(i)
	end
	net.Send(self)
end