
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then
	SWEP.PrintName			= "AK-74"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
end

SWEP.Base				= "jb_base"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Recoil			= 1.2
SWEP.Damage			= 20
SWEP.NumShots		= 1
SWEP.Cone			= 0.05
SWEP.IronCone		= 0.015
SWEP.MaxCone		= 0.09
SWEP.ShootConeAdd	= 0.005
SWEP.CrouchConeMul 	= 0.7
SWEP.Primary.ClipSize		= 27
SWEP.Delay			= 0.13
SWEP.DefaultClip	= 27
SWEP.Ammo			= "SMG1"
SWEP.ReloadSequenceTime = 1.85

SWEP.OriginsPos = Vector (3.7641, -4.5592, 1.8507)
SWEP.OriginsAng = Vector (0.9193, -0.2032, 0.9484)

SWEP.AimPos = Vector (6.1008, -5.4248, 2.434)
SWEP.AimAng = Vector (1.62, -0.0844, -0.8102)

SWEP.RunPos =  Vector (-2.4782, -12.7939, 0.6039)
SWEP.RunAng = Vector (-37.786, -77.9068, 37.9085)
