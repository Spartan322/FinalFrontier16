
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 70
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	SWEP.DrawWeaponInfoBox  = true
	
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
end

SWEP.Primary.Automatic		= true

SWEP.Author			= "_NewBee"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category		= "_NewBee"

SWEP.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Recoil			= 1.5
SWEP.Damage			= 40
SWEP.NumShots		= 1
SWEP.Cone			= 0.02
SWEP.IronCone		= 0.01
SWEP.MaxCone		= 0.5
SWEP.ShootConeAdd	= 0.005
SWEP.CrouchConeMul 	= 0.6
SWEP.Delay			= 0.15

SWEP.IronCycleSpeed = 20

SWEP.Primary.ClipSize		= 5
SWEP.DefaultClip	= 0
SWEP.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.RunPos = Vector(0,0,0)
SWEP.RunAng = Angle(0,0,0)

SWEP.AimPos = Vector(0,0,0)
SWEP.AimAng = Angle(0,0,0)

SWEP.OriginsPos = Vector(0,0,0)
SWEP.OriginsAng = Angle(0,0,0)

function SWEP:SetupDataTables( )
	self:DTVar( "Int", 0, "Mode" )
	self:DTVar( "Float", 0, "LastShoot" )
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SetDTInt(0, 0)

	if CLIENT then
		JB:CheckWeaponTable(self.Weapon:GetClass(),self.WorldModel)
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	
	if self.OldAmmo then
		self:SetClip1(self.OldAmmo)
	end
	
	timer.Destroy(self.Owner:SteamID().."ReloadTimer")
	
	return true
end

function SWEP:Holster()
	self.OldAmmo = self:Clip1()
	self:SetClip1(1)
	
	self.Weapon:SetDTInt(0, 0)
	
	timer.Destroy(self.Owner:SteamID().."ReloadTimer")
	
	return true
end

SWEP.NextReload = CurTime()
function SWEP:Reload()	
	if self.NextReload > CurTime() or CLIENT or self.Owner:GetAmmoCount(self.Ammo) <= 0 then return end
	
	self.NextReload = CurTime()+4
	
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	
	local clip = self:Clip1()
	local dur
	if clip > 0 then
		self.Rechamber = false
		self:SetClip1(1)
		
		dur = self.Owner:GetViewModel():SequenceDuration()
	else
		self.Rechamber = true
		
		dur = self.ReloadSequenceTime or self.Owner:GetViewModel():SequenceDuration()
	end

	self.Owner:GiveAmmo(-self.Primary.ClipSize,self.Ammo)
				
	self:SetNextPrimaryFire(CurTime()+dur)
	timer.Create(self.Owner:SteamID().."ReloadTimer", dur,1,function(self)
		if not self.Owner or not IsValid(self.Owner )) or not self.Owner.GetAmmoCount then return end
		local clip = self:Clip1()
		local a
		if self.Owner:GetAmmoCount(self.Ammo) < self.Primary.ClipSize then
			a = self.Owner:GetAmmoCount(self.Ammo)
		else
			a = self.Primary.ClipSize
		end
	
		self.Owner:RemoveAmmo(a, self.Ammo)
		
		if not self.Rechamber then
			self:SetClip1(a+1)
		else
			self:SetClip1(a)
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self:SetNextPrimaryFire(CurTime()+1)
			
		end	
	end,self)
		
	self.Weapon:SetDTInt(0, 0)
end

SWEP.AddCone = 0
SWEP.LastShoot = CurTime()
function SWEP:Think()	
	if not SERVER then return end
	
	local mul = 1
	if self.Owner:Crouching() then
		mul = self.CrouchConeMul
	end
	
	if self.LastShoot+0.2 < CurTime() then 
		self.AddCone = self.AddCone-(self.ShootConeAdd/5)
		if self.AddCone < 0 then
			self.AddCone=0
		end
	end
	
	if self:GetDTInt(0) == 1 then
		self.Weapon:SetDTFloat(1, math.Clamp((self.IronCone+self.AddCone)*mul, 0.002, 0.12))
	elseif self:GetDTInt(0) == 2 then
		self.Weapon:SetDTFloat(1, math.Clamp((self.Cone+self.AddCone+0.5)*mul, 0.002, 0.12))
	else
		self.Weapon:SetDTFloat(1, math.Clamp((self.Cone+self.AddCone)*mul, 0.002, 0.12))
	end
	
	if not self.Owner.FOVRate then self.Owner.FOVRate = 90 end
		
	local dt = self:GetDTInt(0)
		
	if dt == 1 then
		self.Owner.FOVRate = math.Approach(  self.Owner.FOVRate,  90-10,  3)
	else
		self.Owner.FOVRate = math.Approach(  self.Owner.FOVRate,  90,  3)
	end
	self.Owner:SetFOV(self.Owner.FOVRate)

	if self.Owner:KeyDown(IN_SPEED) and self.Owner:OnGround() and self.Owner:GetVelocity():Length() > self.Owner:GetRunSpeed()-100 then
		self.Weapon:SetDTInt(0, 2)
		if SERVER then
			self.Owner:SetFOV(0, 0.5)
			self.Owner:DrawViewModel(true)
		end
		return
	elseif self:GetDTInt(0) > 1 then
		self:SetDTInt(0,0)
		return
	end
end

function SWEP:PrimaryAttack()

	local ct = CurTime()

	if self:GetDTInt(0) > 1 then
		self:SetNextPrimaryFire(ct+self.Delay)
		return
	elseif self:Clip1() <= 0 then
		self:SetNextPrimaryFire(ct+self.Delay)
		self:EmitSound( "Weapon_Pistol.Empty" )
		return
	end
	
	self:SetNextPrimaryFire(ct+self.Delay)
	
	if self.Weapon:GetDTInt(0) ~= 1 then
		self:CSShootBullet( self.Damage, self.Recoil * 1.5, self.NumShots, self.Weapon:GetDTFloat(1))
	else
		self:CSShootBullet( self.Damage, self.Recoil * 0.75, self.NumShots, self.Weapon:GetDTFloat(1))
	end
	
	self.AddCone = math.Clamp(self.AddCone+self.ShootConeAdd,0,self.MaxCone)
	self.LastShoot = ct
	
	if SERVER then
		self.Owner:EmitSound(self.Sound, 100, math.random(95, 105))
	end

	self:TakePrimaryAmmo(1)
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
		
	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward()
	bullet.Spread 	= Vector( cone, cone, 0 )
	bullet.Tracer	= 4
	bullet.Force	= self.Damage
	bullet.Damage	= self.Damage
	
	bullet.Callback = function(attacker, trace, dmginfo)	-- penetration tyay	
		self.Owner:LagCompensation(false)
		
		local penetrationForce
		local hitMat = trace.MatType 
		
		if hitMat == MAT_PLASTIC then
			penetrationForce = 1.25
		elseif hitMat == MAT_WOOD then
			penetrationForce = 1
		elseif hitMat == MAT_TILE then
			penetrationForce = 0.75
		elseif hitMat == MAT_CONCRETE then
			penetrationForce = 0.5
		elseif hitMat == MAT_METAL or hitMat == MAT_VENT then
			penetrationForce = 0.5
		else
			penetrationForce = 1
		end
		
		local forward = bullet.Dir:Normalize()
		local tr = {}
		tr.start = trace.HitPos + (forward * 10) * penetrationForce
		tr.endpos = tr.start + (forward * 10) * penetrationForce
		tr.filter = self
		
		local trace2 = util.TraceLine(tr)
		
		if not trace2.HitWorld and trace.Entity ~= trace2.Entity then
			local bullet2 = {}
			bullet2.Num = bullet.Num
			bullet2.Src = trace.HitPos + forward * 8 * penetrationForce
			bullet2.Dir = bullet.Dir
			bullet2.Spread = Vector(0, 0, 0)
			bullet2.Tracer = bullet.Tracer
			bullet2.Force = bullet.Force * 0.9
			bullet2.Damage = bullet.Damage * 0.9
			
			self.Owner:FireBullets(bullet2)
		end
		
	end
	
	self.Owner:FireBullets(bullet)
	--if self:GetDTInt(0,0) != 1 then
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:MuzzleFlash()
	
	
	if ( (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT and IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - (recoil * 1 * 0.3)
		eyeang.yaw = eyeang.yaw - (recoil * math.random(-1, 1) * 0.3)
		self.Owner:SetEyeAngles( eyeang )
	
	end
end

local CurMove = -2
local AmntToMove = 0.4
local MoveCycle = 0
local Ironsights_Time = 0.1
local CurShakeA = 0.03
local CurShakeB = 0.03
local randomdir = 0
local randomdir2 = 0
local timetorandom = 0
local BlendPos = Vector(0, 0, 0)
local BlendAng = Vector(0, 0, 0)
local ApproachRate = 0.2
local RollModSprint = 0

function SWEP:GetViewModelPosition(pos, ang)
	local t = FrameTime()
	local dt = self.Weapon:GetDTInt(0)
	if dt == 2 then
		TargetPos = self.RunPos
		TargetAng = self.RunAng
	elseif dt == 1 then
		TargetPos = self.AimPos
		TargetAng = self.AimAng
	else
		TargetPos = self.OriginsPos
		TargetAng = self.OriginsAng
	end
	
	if self.Weapon:GetDTInt(0) == 1 then
		ApproachRate = t * 15
	else
		ApproachRate = t * 10
	end
	
	BlendPos = LerpVector(ApproachRate, BlendPos, TargetPos)
	BlendAng = LerpVector(ApproachRate, BlendAng, TargetAng)
		
	CurShakeA = math.Approach(CurShakeA, randomdir, 0.01)
	CurShakeB = math.Approach(CurShakeB, randomdir2, 0.01)
		
	if CurTime() > timetorandom then
		randomdir = math.Rand(-0.1, 0.1)
		randomdir2 = math.Rand(-0.1, 0.1)
		timetorandom = CurTime() + 0.2
	end
	
	if dt == 1 then -- stop the Sway when we are in ironsights
		self.SwayScale 	= 0.1
		self.BobScale 	= 0
	elseif dt == 2  then
		self.SwayScale 	= 2
		self.BobScale 	= 2
	else
		self.SwayScale 	= 1.5
		self.BobScale 	= 0.4
	end

	if CurMove == -2 then
		MoveCycle = 1
	elseif CurMove == 2 then
		MoveCycle = 2
	end
	
	if MoveCycle == 1 then
		CurMove = math.Approach(CurMove, 2, 0.11 - CurMove * 0.05)
	elseif MoveCycle == 2 then
		CurMove = math.Approach(CurMove, -2, 0.11 - CurMove * 0.05)
	end

	if self.AimAng then
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		BlendAng.x + CurShakeB * self.BobScale )
		ang:RotateAroundAxis( ang:Up(), 		BlendAng.y + CurShakeA * self.BobScale)
		ang:RotateAroundAxis( ang:Forward(), 	BlendAng.z + CurShakeA * self.BobScale)
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()	
	
	pos = pos + BlendPos.x * Right 
	pos = pos + BlendPos.y * Forward
	pos = pos + BlendPos.z * Up
	
	return pos, ang
end

if CLIENT then
	function SWEP:FireAnimationEvent(pos, ang, ev)
		if ev == 5001 then
			if not self.Owner:ShouldDrawLocalPlayer() then
				local vm = self.Owner:GetViewModel()
				local muz = vm:GetAttachment("1")
				
				if not self.Weapon.Em then
					self.Weapon.Em = ParticleEmitter(muz.Pos)
				end
				
				local par = self.Weapon.Em:Add("sprites/frostbreath", muz.Pos)
				par:SetStartSize(math.random(0.5, 1))
				par:SetStartAlpha(120)
				par:SetEndAlpha(0)
				par:SetEndSize(math.random(5, 5.5))
				par:SetDieTime(1.5 + math.Rand(-0.3, 0.3))
				par:SetRoll(math.Rand(0.2, 1))
				par:SetRollDelta(0.8 + math.Rand(-0.3, 0.3))
				par:SetColor(120,120,120,255)
				par:SetGravity(Vector(0, 0, 5))
				local mup = (muz.Ang:Up()*-20)
				par:SetVelocity(Vector(0, 0,7)+Vector(mup.x,mup.y,0))
				
				local par = self.Weapon.Em:Add("sprites/heatwave", muz.Pos)
				par:SetStartSize(8)
				par:SetEndSize(0)
				par:SetDieTime(0.3)
				par:SetGravity(Vector(0, 0, 2))
				par:SetVelocity(Vector(0, 0, 20))				
			end
		end
	end

	function SWEP:AdjustMouseSensitivity()
		if self.Weapon:GetDTInt(0) == 1 then
			return 0.2
		else
			return 1
		end
	end
	
	local gap = 5
	local gap2 = 0
	local CurAlpha_Weapon = 255
	local x2 = (ScrW() - 1024) / 2
	local y2 = (ScrH() - 1024) / 2
	local x3 = ScrW() - x2
	local y3 = ScrH() - y2
	function SWEP:DrawHUD()
		local FT = FrameTime()

		x, y = ScrW() / 2, ScrH() / 2
		
		local scale = (10 * self.Cone)* (2 - math.Clamp( (CurTime() - self:GetDTFloat(1)) * 5, 0.0, 1.0 ))
		
		if self.Weapon:GetDTInt(0) > 0 then
			CurAlpha_Weapon = math.Approach(CurAlpha_Weapon, 0, FT / 0.0017)
		else
			CurAlpha_Weapon = math.Approach(CurAlpha_Weapon, 230, FT / 0.001)
		end
		
		gap = math.Approach(gap, 50 * ((10 / (self.Owner:GetFOV() / 90)) * self.Weapon:GetDTFloat(1)), 1.5 + gap * 0.1)
		
	-- add BlackOps zombie-ish riiight :D
		surface.SetDrawColor(0,0,0,(CurAlpha_Weapon/230)*180)
		surface.DrawRect(x - gap - 10, y - 1, 11, 3)
		surface.DrawRect(x + gap, y - 1, 11, 3)
		surface.DrawRect(x - 1, y + gap, 3, 11)
		surface.DrawRect(x - 1, y - gap - 10, 3, 11)
		
		surface.SetDrawColor(255,255,255, CurAlpha_Weapon)
		surface.DrawRect(x - gap - 9, y, 10, 1)
		surface.DrawRect(x + gap, y, 10, 1)
		surface.DrawRect(x , y + gap, 1,10)
		surface.DrawRect(x, y - gap - 9, 1, 10)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local dt = self:GetDTInt(0)
	
	if not self.Owner.FOVRate then self.Owner.FOVRate = 90 end
	
	if dt == 2 then
		return
	elseif dt == 1 then
		self:SetDTInt(0,0)	
	else
		self:SetDTInt(0,1)	
	end
end

function SWEP:OnRestore()
end
