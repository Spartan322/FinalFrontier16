

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then
	SWEP.PrintName			= "P228"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
end

SWEP.Base				= "jb_base"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"

SWEP.Primary.Automatic		= false

SWEP.Sound			= Sound( "Weapon_P228.Single" )
SWEP.Recoil			= 1.5
SWEP.Damage			= 15
SWEP.NumShots		= 1
SWEP.Cone			= 0.03
SWEP.IronCone		= 0.008
SWEP.MaxCone		= 0.04
SWEP.ShootConeAdd	= 0.007
SWEP.CrouchConeMul 	= 0.9
SWEP.Primary.ClipSize		= 12
SWEP.Delay			= 0.22
SWEP.DefaultClip	= 12
SWEP.Ammo			= "pistol"
SWEP.ReloadSequenceTime = 1.85

SWEP.OriginsPos = Vector (2.4779, -2.906, 1.9127)
SWEP.OriginsAng = Vector (0.6539, -0.6274, 0.9477)

SWEP.AimPos = Vector (4.7606, -3.2882, 2.8652)
SWEP.AimAng = Vector (-0.3408, 0.0723, 0)

SWEP.RunPos = Vector (3.1112, -8.789, -4.3851)
SWEP.RunAng = Vector (66.805, 5.9639, 7.7062)
