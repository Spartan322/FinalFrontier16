if (CLIENT) then
	SWEP.IconLetter 			= "Q"

	SWEP.PrintName 			= "Smoke Grenade"
end

SWEP.Base 					= "jb_grenade_base"
--SWEP.Primary.Ammo 			= "smokegrenade"

SWEP.ViewModel 				= "models/weapons/v_eq_smokegrenade.mdl"
SWEP.WorldModel 				= "models/weapons/w_eq_smokegrenade.mdl"

function SWEP:ThrowFar()

	if self.Primed != 2 then return end

	local tr = self.Owner:GetEyeTrace()

	if (!SERVER) then return end

	local ent = ents.Create ("ent_smokegrenade")

			local v = self.Owner:GetShootPos()
				v = v + self.Owner:GetForward() * 1
				v = v + self.Owner:GetRight() * 3
				v = v + self.Owner:GetUp() * 1
			ent:SetPos( v )

	ent:SetAngles (Vector(math.random(1,100),math.random(1,100),math.random(1,100)))
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 3200
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 2100
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 2500
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 2500
	else
		self.Force = 2500
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() *self.Force *1.2 + Vector(0,0,200) )
	phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

	self.Owner:RemoveAmmo(1, self.Primary.Ammo)

	timer.Simple(0.6,
	function()

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self.Primed = 0
		else
			self.Primed = 0
			self.Weapon:Remove()
			self.Owner:ConCommand("lastinv")
		end
	end)
end

/*---------------------------------------------------------
ThrowShort
---------------------------------------------------------*/
function SWEP:ThrowShort()

	if self.Primed != 2 then return end

	local tr = self.Owner:GetEyeTrace()

	if (!SERVER) then return end

	local ent = ents.Create ("ent_smokegrenade")

			local v = self.Owner:GetShootPos()
				v = v + self.Owner:GetForward() * 2
				v = v + self.Owner:GetRight() * 3
				v = v + self.Owner:GetUp() * -3
			ent:SetPos( v )

	ent:SetAngles (Vector(math.random(1,100),math.random(1,100),math.random(1,100)))
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 1100
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 300
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 700
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 700
	else
		self.Force = 700
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() * self.Force * 2 + Vector(0, 0, 0))
	phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

	self.Owner:RemoveAmmo(1, self.Primary.Ammo)

	timer.Simple(0.6,
	function()

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self.Primed = 0
		else
			self.Primed = 0
			self.Weapon:Remove()
			self.Owner:ConCommand("lastinv")
		end
	end)
end