function JB:OnSpawnMenuOpen()
	RunConsoleCommand("jb_dropweapon")
end

function JB:OnContextMenuOpen() -- Show mouse on contect menu (for when we're stuck in menus or something....)
	JB:ToggleQCMD(true)
end

function JB:OnContextMenuClose() -- Show mouse on contect menu (for when we're stuck in menus or something....)
	JB:ToggleQCMD(false)
end

local skip_aim = 5
local skip_num = 0
--these vars are for shaking the screen while running (this code is ripped from Excl's PrisonBreak2)
local PitchMod = 0
local YawMod = 0
local RollMod = 0
local PAPR = 0
local YAPR = 0
local RAPR = 0
local PT = 0
local YT = 0
local RT = 0
local PT2 = 0
local RT2 = 0
function JB:ResetSkipMenuMoves()
	skip_aim = 5
	skip_num = 0
end
function JB:CalcView(p, pos, angles, fov) --Calculates the view, for run-view, menu-view, and death from the ragdoll's eyes.
	local view = {}
	if JB.MainMenuEnabled then
		if JB.MainMenuCharacterScreen then
			MenuPos.pos.x = Lerp(0.3,MenuPos.pos.x,MenuCharacter.pos.x)
			if MenuPos.pos.x < MenuCharacter.pos.x + 1 then
				if skip_num >= skip_aim then
					MenuPos.pos.z = math.Clamp(MenuPos.pos.z-1,MenuCharacter.pos.z,MenuMain.pos.z)
					MenuPos.ang = LerpAngle(0.05,MenuPos.ang,MenuCharacter.ang)
				else
					skip_num = skip_num+1
				end
			end
		else
			MenuPos.pos.z = math.Clamp(MenuPos.pos.z+1,MenuCharacter.pos.z,MenuMain.pos.z)
			MenuPos.ang = LerpAngle(0.05,MenuPos.ang,MenuMain.ang)
			if MenuPos.pos.z > MenuMain.pos.z - 1 then
				if skip_num >= skip_aim then
					MenuPos.pos.x = Lerp(0.05,MenuPos.pos.x,MenuMain.pos.x)
				else
					skip_num = skip_num+1
				end
			end
		end

		view.origin = MenuPos.pos
		view.angles = MenuPos.ang
		view.fov = 90

		return view
	end

	if p:OnGround() then --Shake view
		if p:KeyDown(IN_SPEED) and p:GetVelocity():Length() > p:GetWalkSpeed() then
			PAPR = 0.5
			YAPR = 0.5
			RAPR = 0.5
			PT = 1.5 * math.cos(CurTime() * 10)
			YT =  1.5 * math.sin(CurTime() * 10)
			RT = 1.5 * math.cos(CurTime() * 10)

		elseif p:GetVelocity():Length() < p:GetRunSpeed() and p:GetVelocity():Length() > 50 and not p:KeyDown(IN_SPEED) then
			PAPR = 0.25
			YAPR = 0.25
			RAPR = 0.05
			PT = 0.15 * math.cos(CurTime() * 10)
			YT = 0.15 * math.sin(CurTime() * 10)
			RT = 0
		else
			PAPR = 0.05
			YAPR = 0.05
			PAPR = 0.05
			PT = 0
			YT = 0
			RT = 0
		end

		if p:KeyDown(IN_SPEED) and p:GetVelocity():Length() > p:GetWalkSpeed() then
			if p:KeyDown(IN_FORWARD) then
				PT2 = math.Approach(PT2, 3.5, 0.5)
			elseif p:KeyDown(IN_BACK) then
				PT2 = math.Approach(PT2, -3.5, 0.5)
			else
				PT2 = math.Approach(PT2, 0, 0.5)
			end

			if p:KeyDown(IN_MOVELEFT) then
				RT2 = math.Approach(RT2, -3.5, 0.5)
			elseif p:KeyDown(IN_MOVERIGHT) then
				RT2 = math.Approach(RT2, 3.5, 0.5)
			else
				RT2 = math.Approach(RT2, 0, 0.5)
			end
		else
			PT2 = math.Approach(PT2, 0, 0.7)
			RT2 = math.Approach(RT2, 0, 0.7)
		end

	else
		PAPR = 0.05
		YAPR = 0.05
		PAPR = 0.05
		PT = 0
		YT = 0
		RT = 0
		PT2 = math.Approach(PT2, 0, 0.7)
		RT2 = math.Approach(RT2, 0, 0.7)
	end

	PitchMod = math.Approach(PitchMod, PT, PAPR)
	YawMod = math.Approach(YawMod, YT, YAPR)
	RollMod = math.Approach(RollMod, RT, RAPR)
	view.angles = angles + Angle(PitchMod + PT2, YawMod, RollMod + RT2)

	view.origin = pos
	view.fov = fov

	if (IsValid( p:GetActiveWeapon() ) ) then --For weapons in run-mode (code from PrisonBreak2, by _NewBee (Excl))

		local func = p:GetActiveWeapon().GetViewModelPosition
		if ( func ) then
			view.vm_origin,  view.vm_angles = func( p:GetActiveWeapon(), pos * 1, angles * 1 )
		end

		local func = p:GetActiveWeapon().CalcView
		if ( func ) then
			view.origin, view.angles, view.fov = func( p:GetActiveWeapon(), p, pos * 1, angles * 1, fov )
		end

	end
	return view
end

local Blur = 0
function JB:GetMotionBlurValues(x,y,fwd,spin)
	if GetConVarNumber("mat_motion_blur_forward_enabled") < 1 then --This is anti cheat.
		RunConsoleCommand("mat_motion_blur_forward_enabled", "1")
	end

	if LocalPlayer():Health()<25 then
		Blur = math.Approach(Blur, 0.03, 0.015)
		return x, y, Blur, spin
	elseif LocalPlayer():Health()<50 then
		Blur = math.Approach(Blur, 0.01, 0.015)
		return x, y, Blur, spin
	end

	if (not LocalPlayer():GetActiveWeapon()) or (not LocalPlayer():GetActiveWeapon():IsValid()) then return end
	if (not (LocalPlayer():GetVelocity():Length()>LocalPlayer():GetWalkSpeed() and LocalPlayer():KeyDown(IN_SPEED))) and (not (LocalPlayer():GetActiveWeapon():GetDTInt(0) == 1 or LocalPlayer():GetActiveWeapon():GetDTInt(0) == 2) )then
		if Blur <= 0 then return end
		Blur = math.Approach(Blur, 0.0001, 0.015)
		return x, y, Blur, spin
	end

	Blur = math.Approach(Blur, 0.1, 0.015)
	return x, y, Blur, spin
end