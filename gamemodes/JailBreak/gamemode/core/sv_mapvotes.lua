-- sv_mapvote.lua
-- mapvoting hurr

--rather than detecting which maps are avalable, let's make a list for it.
local maps = {}

local voteActive = false
local mapVotes = {}
local alreadyVoted = false
local roundCount = 0

function JB:LoadMapFile()
	maps = glon.decode(file.Read("jbMaConfig.txt")) or {}
end
JB:LoadMapFile()

function JB:AddMap(n)
	maps[#maps+1] = tostring(n)

	file.Write("jbMaConfig.txt",glon.encode(maps))

	print("Added map to mapsfile")
end

local h = 0
local count = 5
local function increaseH()
	h= math.random(h+1,#maps-count)
	count = count-1
end

local mapVotes = {}
concommand.Add("jb_votemap",function(p,c,a)
	local m = a[1]
	if not m or not voteActive or not mapVotes[m] then return end

	mapVotes[m] = mapVotes[m]+1
end)

local nextmap
if maps then
nextmap = maps[math.random(1,#maps)]
else
nextmap = "gm_construct"
end
function JB:StartMapVote()
	if voteActive then return end
	if #maps < 5 then
		JB:DebugPrint("Not enough maps for mapvote.")
		PrintTable(maps)
		return
	end

	h=0
	count=5
	local t = {}
	increaseH()
	t[1] = maps[h]
	increaseH()
	t[2] = maps[h]
	increaseH()
	t[3] = maps[h]
	increaseH()
	t[4] = maps[h]
	increaseH()
	t[5] = maps[h]

	net.Start("JSMV")
	net.WriteString(t[1])
	net.WriteString(t[2])
	net.WriteString(t[3])
	net.WriteString(t[4])
	net.WriteString(t[5])
	net.Broadcast()

	count = 5
	h = 0

	mapVotes = {}
	for k,v in pairs(t)do
		mapVotes[v] = 0
	end

	voteActive = true

	timer.Simple(30,function(tbl)
		voteActive = false

		local highest
		for k,v in pairs(mapVotes)do
			if not highest then
				highest = k
			elseif v > mapVotes[highest] then
				highest = k
			elseif v == mapVotes[highest] and math.random(1,2) == 1 then
				highest = k
			end
		end

		nextmap = highest
		print(nextmap)
		net.Start("JNC")
		net.WriteString(highest.." has won the map vote.")
		net.WriteString("undo")
		net.Broadcast()
	end,mapVotes)

	alreadyVoted = true
end
concommand.Add("jb_admin_addmap",function(p,c,a)
	JB:AddMap(tostring(a[1]))
end)
concommand.Add("jb_admin_reloadmapfile",function(p,c,a)
	JB:LoadMapFile()
end)

local timerVoteMade = CurTime()
local function getminsandstuffJByaknow()
		local t= (45*60)-(CurTime()-timerVoteMade)

		local m= tostring(math.floor(t/60))
		local s= tostring(math.floor(t-(m*60)))
		if tonumber(s) < 10 then
			s= "0"..s
		end

		return m..":"..s
	end

function JB:ShouldVoteMap()
	roundCount = roundCount+1
	if roundCount >= 10 then
		print(nextmap)
		game.ConsoleCommand( "changelevel " ..nextmap.. "\n" )
	elseif roundCount == 9 and not alreadyVoted then
		JB:StartMapVote()
		net.Start("JNC")
		net.WriteString("Map will change in "..8-roundCount.." rounds or "..getminsandstuffJByaknow().." minutes.")
		net.WriteString("undo")
		net.Broadcast()
	else
		net.Start("JNC")
		net.WriteString("Map will change in "..8-roundCount.." rounds or "..getminsandstuffJByaknow().." minutes.")
		net.WriteString("undo")
		net.Broadcast()
	end
end

timer.Simple(2700-60,function()
	if alreadyVoted then return end
	JB:StartMapVote()
end)
timer.Simple(1500,function()
	net.Start("JNC")
	net.WriteString("Map will change in 5 minutes.")
	net.WriteString("boom")
	net.Broadcast()
end)
timer.Simple(1740,function()
	net.Start("JNC")
	net.WriteString("Map will change in 1 minute.")
	net.WriteString("boom")
	net.Broadcast()
end)
timer.Simple(2700,function()
	game.ConsoleCommand( "changelevel " ..nextmap.. "\n" )
end)
