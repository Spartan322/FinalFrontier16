-- hands. can carry things.
if SERVER then
   AddCSLuaFile("shared.lua")
end

SWEP.HoldType           = "pistol"

if CLIENT then
   SWEP.PrintName       = "No weapon"
   SWEP.Slot            = 3
end


SWEP.ViewModel          = ""
SWEP.WorldModel         = ""

SWEP.DrawCrosshair      = true
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 0.1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 0.1

function SWEP:Initialize()
   self:SetWeaponHoldType("normal")
end

local function SetSubPhysMotionEnabled(ent, enable)
   if not IsValid(ent) then return end

   for i=0, ent:GetPhysicsObjectCount()-1 do
	  local subphys = ent:GetPhysicsObjectNum(i)
	  if IsValid(subphys) then
		 subphys:EnableMotion(enable)
		 if enable then
			subphys:Wake()
		 end
	  end
   end
end

local function KillVelocity(ent)
   ent:SetVelocity(vector_origin)

   SetSubPhysMotionEnabled(ent, false)

   timer.Simple(0, SetSubPhysMotionEnabled, ent, true)
end

function SWEP:Reset(keep_velocity)
   if IsValid(self.CarryHack) then
	  self.CarryHack:Remove()
   end

   if IsValid(self.Constr) then
	  self.Constr:Remove()
   end

   if IsValid(self.EntHolding) then
	  if not IsValid(self.PrevOwner) then
		 self.EntHolding:SetOwner(nil)
	  else
		 self.EntHolding:SetOwner(self.PrevOwner)
	  end

	  local phys = self.EntHolding:GetPhysicsObject()
	  if IsValid(phys) then
		 phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
		 phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		 phys:EnableCollisions(true)
	  end

   end

   self.EntHolding = nil
   self.CarryHack = nil
   self.Constr = nil
end
SWEP.reset = SWEP.Reset

function SWEP:CheckValidity()

   if (not IsValid(self.EntHolding)) or (not IsValid(self.CarryHack)) or (not IsValid(self.Constr)) then

	  -- if one of them is not valid but another is non-nil...
	  if (self.EntHolding or self.CarryHack or self.Constr) then
		 --print("checkvalidity found badness, Resetting...")
		 self:Reset()
	  end

	  return false
   else
	  return true
   end
end

local function PlayerStandsOn(ent)
   for _, ply in pairs(player.GetAll()) do
	  if ply:GetGroundEntity() == ent then
		 return true
	  end
   end

   return false
end

if SERVER then

local ent_diff = vector_origin
local ent_diff_time = CurTime()

local stand_time = 0
function SWEP:Think()
   if not self:CheckValidity() then return end

   -- If we are too far from our object, force a drop. To avoid doing this
   -- vector math extremely often (esp. when everyone is carrying something)
   -- even though the occurrence is very rare, limited to once per
   -- second. This should be plenty to catch the rare glitcher.
   if CurTime() > ent_diff_time then
	  ent_diff = self:GetPos() - self.EntHolding:GetPos()
	  if ent_diff:Dot(ent_diff) > 40000 then
		 self:Reset()
		 return
	  end

	  ent_diff_time = CurTime() + 1
   end

   if CurTime() > stand_time then

	  if PlayerStandsOn(self.EntHolding) then
		 self:Reset()
		 return
	  end

	  stand_time = CurTime() + 0.1
   end

   self.CarryHack:SetPos(self.Owner:EyePos() + self.Owner:GetAimVector() * 70)

   self.CarryHack:SetAngles(self.Owner:GetAngles())

   self.EntHolding:PhysWake()
end

end

function SWEP:PrimaryAttack()
   self:DoAttack(false)
end

function SWEP:SecondaryAttack()
   self:DoAttack(true)
end

function SWEP:MoveObject(phys, pdir, maxforce, is_ragdoll)
   if not IsValid(phys) then return end
   local speed = phys:GetVelocity():Length()

   -- remap speed from 0 -> 125 to force 1 -> 4000
   local force = maxforce + (1 - maxforce) * (speed / 125)

   if is_ragdoll then
	  force = force * 2
   end

   pdir = pdir * force

   local mass = phys:GetMass()
   -- scale more for light objects
   if mass < 50 then
	  pdir = pdir * (mass + 0.5) * (1 / 50)
   end

   phys:ApplyForceCenter(pdir)
end

function SWEP:GetRange(target)
   if IsValid(target) and target:IsWeapon() and allow_wep:GetBool() then
	  return wep_range:GetFloat()
   elseif IsValid(target) and target:GetClass() == "prop_ragdoll" then
	  return 75
   else
	  return 100
   end
end

function SWEP:AllowPickup(target)
   local phys = target:GetPhysicsObject()
   local ply = self:GetOwner()

   return (IsValid(phys) and IsValid(ply) and not phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP))
end

function SWEP:DoAttack(pickup)
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

   if IsValid(self.EntHolding) then
	  self:Drop()

	  self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
	  return
   end

   local ply = self.Owner

   local trace = ply:GetEyeTrace(MASK_SHOT)
   if IsValid(trace.Entity) then
	  local ent = trace.Entity
	  local phys = trace.Entity:GetPhysicsObject()

	  if not IsValid(phys) or not phys:IsMoveable() or phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
		 return
	  end

	  -- if we let the client mess with physics, desync ensues
	  if CLIENT then return end

	  if pickup then
		 --print("attempting pickup")
		 if (ply:EyePos() - trace.HitPos):Length() < self:GetRange(ent) then
			--print("target is in range")

			if self:AllowPickup(ent) then
			   self:Pickup()
			   self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

			   -- make the refire slower to avoid immediately dropping
			   local delay = (ent:GetClass() == "prop_ragdoll") and 0.8 or 0.5

			   self.Weapon:SetNextSecondaryFire(CurTime() + delay)
			   return
			else
			   local is_ragdoll = trace.Entity:GetClass() == "prop_ragdoll"

			   -- pull heavy stuff
			   local ent = trace.Entity
			   local phys = ent:GetPhysicsObject()
			   local pdir = trace.Normal * -1

			   if is_ragdoll then

				  phys = ent:GetPhysicsObjectNum(trace.PhysicsBone)

				  -- increase refire to make rags easier to drag
				  --self.Weapon:SetNextSecondaryFire(CurTime() + 0.04)
			   end

			   if IsValid(phys) then
				  self:MoveObject(phys, pdir, 6000, is_ragdoll)
				  return
			   end
			end
		 end
	  else
		 if (ply:EyePos() - trace.HitPos):Length() < 100 then
			local phys = trace.Entity:GetPhysicsObject()
			if IsValid(phys) then
			   if IsValid(phys) then
				  local pdir = trace.Normal
				  self:MoveObject(phys, pdir, 6000, (trace.Entity:GetClass() == "prop_ragdoll"))

				  self.Weapon:SetNextPrimaryFire(CurTime() + 0.03)
			   end
			end
		 end
	  end
   end
end

-- Perform a pickup
function SWEP:Pickup()
   if CLIENT or IsValid(self.EntHolding) then return end

   local ply = self.Owner
   local trace = ply:GetEyeTrace(MASK_SHOT)
   local ent = trace.Entity
   self.EntHolding = ent
   local entphys = ent:GetPhysicsObject()

   --print("picking up", ent)

   if IsValid(ent) and IsValid(entphys) then

	  --print("creating carry hack ent")

	  self.CarryHack = ents.Create("prop_physics")
	  if IsValid(self.CarryHack) then
		 self.CarryHack:SetPos(self.EntHolding:GetPos())

		 self.CarryHack:SetModel("models/weapons/w_bugbait.mdl")

		 self.CarryHack:SetColor(50, 250, 50, 240)
		 self.CarryHack:SetNoDraw(true)
		 self.CarryHack:DrawShadow(false)

		 self.CarryHack:SetHealth(999)
		 self.CarryHack:SetOwner(ply)
		 self.CarryHack:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		 self.CarryHack:SetSolid(SOLID_NONE)

		 self.CarryHack:Spawn()

		 -- if we already are owner before pickup, we will not want to disown
		 -- this entity when we drop it
		 self.PrevOwner = self.EntHolding:GetOwner()

		 self.EntHolding:SetOwner(ply)

		 local phys = self.CarryHack:GetPhysicsObject()
		 if IsValid(phys) then
			phys:SetMass(200)
			phys:SetDamping(0, 1000)
			phys:EnableGravity(false)
			phys:EnableCollisions(false)
			phys:EnableMotion(false)
			phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
		 end

		 entphys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
		 local bone = math.Clamp(trace.PhysicsBone, 0, 1)

		 self.Constr = constraint.Weld(self.CarryHack, self.EntHolding, 0, bone, 0, true)


	  end
   end
end

local down = Vector(0, 0, -1)
function SWEP:AllowEntityDrop()
   local ply = self.Owner
   local ent = self.CarryHack
   if (not IsValid(ply)) or (not IsValid(ent)) then return false end

   local ground = ply:GetGroundEntity()
   if ground and (ground:IsWorld() or IsValid(ground)) then return true end

   local diff = (ent:GetPos() - ply:GetShootPos()):Normalize()

   return down:Dot(diff) <= 0.75
end

function SWEP:Drop(throw)
   if not self:CheckValidity() then return end

   if not self:AllowEntityDrop() then return end

   if SERVER then
	  self.Constr:Remove()
	  self.CarryHack:Remove()

	  local ent = self.EntHolding

	  local phys = ent:GetPhysicsObject()
	  if IsValid(phys) then
		 phys:EnableCollisions(true)
		 phys:EnableGravity(true)
		 phys:EnableDrag(true)
		 phys:EnableMotion(true)
		 phys:Wake()
		 phys:ApplyForceCenter(self.Owner:GetAimVector() * 500)

		 phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
		 phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
	  end

	  ent:SetPhysicsAttacker(self.Owner)
   end

   self:Reset()
end


function SWEP:OnRemove()
   self:Reset()
end

function SWEP:Deploy()
   self:Reset()
   return self.BaseClass:Deploy()
end

function SWEP:Holster()
   self:Drop()
   return self.BaseClass:Holster()
end


function SWEP:ShouldDropOnDie()
   return false
end

function SWEP:OnDrop()
   self:Remove()
end

if CLIENT then
   function SWEP:DrawHUD()
	  local x=ScrW()/2
	  local y=ScrH()/2

	  surface.SetDrawColor(0,0,0,180)
	  surface.DrawRect(x-15,y-15,3,30)
	  surface.DrawRect(x+13,y-15,3,30)
	  surface.DrawRect(x-15,y-15,30,3)
	  surface.DrawRect(x-15,y+13,30,3)

	  surface.SetDrawColor(255,255,255,230)
	  surface.DrawRect(x-14,y-14,1,28)
	  surface.DrawRect(x+14,y-14,1,28)
	  surface.DrawRect(x-14,y-14,28,1)
	  surface.DrawRect(x-14,y+14,28,1)
   end
end