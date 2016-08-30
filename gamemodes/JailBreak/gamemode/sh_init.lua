JB = GM -- rather than calling gmod.GetGamemode() 100 times

JB.Name = "JailBreak16"
JB.Author = "_NewBee (Excl), Clark (Aide), George (Spartan322)"
JB.Version = "ALPHA 0.1.0"
JB.util = {}
JB.debug = true

util.AddNetworkString("JBH")
util.AddNetworkString("JNC")
util.AddNetworkString("JRSW")
util.AddNetworkString("JSWP")
util.AddNetworkString("JSMV")
util.AddNetworkString("JSHM")
util.AddNetworkString("JOGP")
util.AddNetworkString("JOLR")
util.AddNetworkString("JOMM")
util.AddNetworkString("JCMM")
util.AddNetworkString("JBSYC")
util.AddNetworkString("JBSQC")
util.AddNetworkString("JBOTCM")
util.AddNetworkString("JLRRace")
util.AddNetworkString("JBMCFLR")
util.AddNetworkString("JLRRRRRR")
util.AddNetworkString("JBMCFLRNP")


--Debugprinting
function JB:DebugPrint(...)
	if not JB.debug then return end

	Msg("["..JB.Name.." debug] ")
	print(...)
end
JB:DebugPrint("Initializing "..JB.Name..", the _NewBee gamemode.")
JB:DebugPrint("Created by "..JB.Author.." version "..JB.Version)

--Including files
local function JBInclude(file, folder, run)
	local p = run or "sh"
	if string.Left(file, 2) and (not run) then p = string.Left(file, 2) end
	if p == "sh" then
		JB:DebugPrint("Including file: "..folder..file)
		include(folder..file)
		if SERVER then
			AddCSLuaFile(folder..file)
		end
	elseif p == "sv" and SERVER then
		JB:DebugPrint("Including file: "..folder..file)
		include(folder..file)
	elseif p == "cl" then
		if CLIENT then
			JB:DebugPrint("Including file: "..folder..file)
			include(folder..file)
		elseif SERVER then
			AddCSLuaFile(folder..file)
		end
	end
end

--Automate including
local function JBInitVGUI()
	for k,v in pairs(file.Find("JailBreak/gamemode/vgui/*.lua","LUA" )) do
		JBInclude(v, "vgui/", "cl")
	end
end

local function JBInitCore()
	for k,v in pairs(file.Find("JailBreak/gamemode/core/*.lua","LUA" )) do
		JBInclude(v, "core/")
	end
end

local function JBInitUtil()
	for k,v in pairs(file.Find("JailBreak/gamemode/util/*.lua","LUA" )) do
		JBInclude(v, "util/")
	end
end

--In strict order :3
JBInitUtil()
JBInitVGUI()
JBInitCore()