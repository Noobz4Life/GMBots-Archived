//Base code for bots.
--local BotNames = {"Hider","Seeker","Peeker","Creeper","Spider","Cider","Run","Hide","Seek","Hide and Seek","Peek","Over There","Invisible","Not a Bot","Glitchy","hideandseek.lua","GMBots","PMBots","DMBots","Key"}
--local BotNames = {"Trash","Crash","Garbage","Trash-Can","Maggot",
local BOTS = {}
GAMEMODE_ISSUELOG = {"Hiders don't run from seekers.","Unknown crash. If you crash, please tell me what you were doing at the time of the crash!"}

BOTNames = {
	"Chell",
	"Your Precious Moon.",
	"GlaDOS",
	"Companion Cube",
	"Companion Coob",
	"Sasha",
	"Heavyweapons",
	"Aim Boat",
	"Aimbot",
	"Beep Boop Beep",
	"Crowbar",
	"LUA",
	"Not C++",
	"Not A Bot",
	"imbadatthisgame",
	"cookies1992",
	"cookies1993",
	"NYEH",
	"Mego",
	"Blue Eye",
	"Orange Eye",
	"Humans are Smart",
	"Humans are weak",
	"trigger_hurt",
	"trigger_multiple",
	"trigger_once",
	"trigger_teleport",
	"prop_physics",
	"prop_static",
	"prop_dynamic",
	"Hide",
	"Seek",
	"Reap",
	"Creep",
	"Peep",
	"Bad Time",
	"Bad Tom",
	"Who lives in",
	"A pineapple",
	"Under the",
	"Sea?",
	"Nobody.",
	"Imean",
	"Spongebob!",
	"Square",
	"Pants",
	"Shirt",
	"Soul",
	"Monster",
	"Virgil",
	"Nigel",
	"CORE",
	"A.E.G.I.S",
	"AEGIS",
	"Wallhack",
	"H@XX0RZ",
	"Hacker",
	"I AM",
	"GONNA",
	"GET",
	"AAA",
	"CHEESE",
	"BURGER",
	"Policon",
	"Steam Support",
	"Steam Users",
	"Steam",
	"Muffet",
	"Comic Sans",
	"Papyrus",
	"Portal",
	"Wormhole",
	"Turret",
	"Ubercharge",
	"Jarate",
	"Bonk",
	"Sandvich",
	"Steak",
	"Gordon",
	"Freeman",
	"Kablooie!",
	"Scrumpy",
	"Mumble",
	"Devil",
	"Dr. Cheese",
	"Nav Mesh",
	"Where",
	"What",
	"When"
}


function Check_Visible(ply,target)
	return ply:BotVisible( target )
end

--[[
--Old Bot Names.

local BotNames =    { 
    "AimBot",
    "AmNot",
    "Archimedes!",
    "BeepBeepBoop",
    "Big Mean Muther Hubbard",
    "Black Mesa",
    "BoomerBile",
    "Cannon Fodder",
    "CEDA",
    "Chell",
    "Chucklenuts",
    "Companion Cube",
    "Crazed Gunman",
    "CreditToTeam",
    "CRITRAWKETS",
    "Crowbar",
    "CryBaby",
    "CrySomeMore",
    "C++",
    "DeadHead",
    "Delicious Cake",
    "Divide by Zero",
    "Dog",
	"Force of Nature",
	"Trash-Can",
	"Trash",
	"Cheeseburgah",
    "GLaDOS",
    "Grim Bloody Fable",
    "GutsAndGlory!",
    "Hat-Wearing MAN",
    "Headful of Eyeballs",
    "Herr Doktor",
    "HI THERE",
    "Hostage",
    "Humans Are Weak",
    "H@XX0RZ",
    "I LIVE!",
    "It's Filthy in There!",
    "IvanTheSpaceBiker","Peeker","Creeper","Spider","Cider","Run","Hide","Seek","Hide and Seek","Peek","Over There","Invisible","Not a Bot","Glitchy","hideandseek.lua","GMBots","PMBots","DMBots","Key"
}
]]

CreateConVar("gmbots_bot_tag",0)

if SERVER then
	--Creates convars to add bots, Add a spot to hide, or add a spot to check.
	--[[
	concommand.Add("gmbots_bot_add",function(ply)
		local mapnav = file.Find( "maps/"..game.GetMap()..".nav", "MOD")
		if ply and ply:IsValid() then return end
		if SERVER then
			if(#player.GetAll() == game.MaxPlayers())then
				error("[GMBots] Server is full, cant spawn bot\n")
			else
				local BotTag = ""
				if GetConVar("gmbots_bot_tag"):GetInt() > 0 then
					BotTag = "Hider "
					local bottagchance = math.random(1,3)
					if bottagchance == 2 then
						BotTag = "Seeker "
					elseif bottagchance == 3 then
						BotTag = "BOT "
					end
				end
				local bot = player.CreateNextBot(BotTag..BotNames[math.random(#BotNames)])
				table.insert(BOTS,bot)
				bot.Bot = true
				bot.RealBOT = true
				bot.RPAttack = false
				bot.prevPos = Vector(0, 0, 0)
				bot.Target = nil
				bot.ShouldTaunt = true
				bot.LookAt = Angle(0,0,0)
				bot.canLookFor = true
				bot.FollowerEnt = ents.Create("sent_pathfinding")
				bot.FollowerEnt:SetOwner( bot )
				bot.FollowerEnt:Spawn()
				if not(mapnav and #mapnav > 0) then
					navmesh.AddWalkableSeed( player.GetAll()[math.random(1,#player.GetAll())]:GetPos(),Vector(0,0,0) )
					navmesh.BeginGeneration()
					bot:Kick("No NAV Mesh")
				end
			end
		end
	end)
	]]
	
	hook.Add("GMBotsBotAdded","GamemodeBotAdded",function(bot)
		if bot and bot:IsValid() then
			table.insert(BOTS,bot)
			bot.Bot = true
			bot.RealBOT = true
			bot.RPAttack = false
			bot.prevPos = Vector(0, 0, 0)
			bot.Target = nil
			bot.ShouldTaunt = true
			bot.LookAt = Angle(0,0,0)
			bot.canLookFor = true
		end
	end)
	
	concommand.Add("gmbots_add_hidespot",function(ply,cmd,args,argsString)
		if not SERVER then return end
		if not ply:IsSuperAdmin() then return end
		
		if not file.IsDir("gmbots","DATA") then
			file.CreateDir("gmbots","DATA")
		end
		
		if not file.IsDir("gmbots/hiding_spots","DATA") then
			file.CreateDir("gmbots/hiding_spots","DATA")
		end
		
		if not file.IsDir("gmbots/hiding_spots/"..game.GetMap(),"DATA") then
			file.CreateDir("gmbots/hiding_spots/"..game.GetMap(),"DATA")
		end
		AddNewHidingSpot(ply,cmd,args,argsString)
	end)
	
	concommand.Add("gmbots_add_checkspot",function(ply,cmd,args,argsString)
		if not SERVER then return end
		if not ply:IsSuperAdmin() then return end
		
		if not file.IsDir("gmbots","DATA") then
			file.CreateDir("gmbots","DATA")
		end
		
		if not file.IsDir("gmbots/check_spots","DATA") then
			file.CreateDir("gmbots/check_spots","DATA")
		end
		
		if not file.IsDir("gmbots/check_spots/"..game.GetMap(),"DATA") then
			file.CreateDir("gmbots/check_spots/"..game.GetMap(),"DATA")
		end
		AddNewCheckSpot(ply,cmd,args,argsString)
	end)
else
	concommand.Add("gmbots_bot_add",function(  )
		if CLIENT then
			MsgC(Color( 0, 255, 64 ),"[GMBots] Sorry. But only the server can do that\n")
		end
	end)
end
	


function AddNewHidingSpot(ply,cmd,args,argsString)
	if not SERVER then return end
	local chs = "gmbots/hiding_spots/"..game.GetMap().."/spot"..(#file.Find( "gmbots/hiding_spots/"..game.GetMap().."/*.txt", "DATA" )+1)..".txt"
	local data = {}
	--print(chs)
	data.Position = ply:GetPos()
	data.Creator = ply:SteamID()
	data.CreatorName = ply:Name()
	if not file.Exists( chs , "DATA" ) then
		file.Write( chs ,util.TableToJSON( data ) )
	end
end

function AddNewCheckSpot(ply,cmd,args,argsString)
	if not SERVER then return end
	local chs = "gmbots/check_spots/"..game.GetMap().."/spot"..(#file.Find( "gmbots/check_spots/"..game.GetMap().."/*.txt", "DATA" )+1)..".txt"
	local data = {}
	--print(chs)
	data.Position = ply:GetPos()
	data.Creator = ply:SteamID()
	data.CreatorName = ply:Name()
	if not file.Exists( chs , "DATA" ) then
		file.Write( chs ,util.TableToJSON( data ) )
	end
end





function GetAllHidingSpots(no_nav,isspot)
	local spots = {}
	if isspot == nil then
		isspot = false
	end
	if SERVER and not isspot and no_nav and file.IsDir("gmbots/hiding_spots/"..game.GetMap(),"DATA") then
		files,direct = file.Find( "gmbots/hiding_spots/"..game.GetMap().."/*.txt", "DATA" )
		if files and #files > 0 then
			for i = 1,#files do
				b = "gmbots/hiding_spots/"..game.GetMap().."/"..files[i]
				if b and files[i] then 
					local data = util.JSONToTable( file.Read(b) )
					table.insert(spots,data.Position)
				end
			end
		end
	elseif SERVER and not isspot and not file.IsDir("gmbots/hiding_spots/"..game.GetMap(),"DATA") then
		local nav_spots = {}
		for a,b in pairs(navmesh.GetAllNavAreas()) do
			if b and b:GetHidingSpots() then
				for a,b in pairs(b:GetHidingSpots()) do
					table.insert(spots,b)
				end
			end
		end
	elseif SERVER and not isspot then
		local nav_spots = {}
		for a,b in pairs(navmesh.GetAllNavAreas():GetHidingSpots()) do
			if b then
				table.insert(spots,b)
			end
		end
		
		files,direct = file.Find( "gmbots/hiding_spots/"..game.GetMap().."/*.txt", "DATA" )
		for i = 1,#files do
			b = directores[i].."/"..files[i]
			if b and files[i] and direct[i] then 
				local data = util.JSONToTable( file.Read(b) )
				table.insert(spots,data.Position)
			end
		end
	end
	if isspot then
		return spots[math.random(1,#spots)] or Vector( 0,0,0 )
	end
	return spots
end

concommand.Add("gmbots_buckethiding",function(ply)
	if SERVER and (not ply or ply and not ply:IsValid() or ply:IsAdmin()) then
		local hidingspots = GetAllHidingSpots(true)
		if hidingspots then
			for i = 1,#hidingspots do
				local spot = hidingspots[i]
				if spot then
					local Bucket = ents.Create("prop_physics")
					Bucket:SetModel("models/props_junk/plasticbucket001a.mdl")
					Bucket:SetPos(spot)
					Bucket:Spawn()
				end
			end
		end
	end
end)

function GetAllCheckSpots(use_check_spots)
	local spots = {}
	local spot = Vector(0,0,0)
	if use_check_spots == nil then
		use_check_spots = true
	end
	if SERVER and use_check_spots and file.IsDir("gmbots/check_spots/"..game.GetMap(),"DATA") then
		files,direct = file.Find( "gmbots/check_spots/"..game.GetMap().."/*.txt", "DATA" )
		if files and #files > 0 then
			for i = 1,#files do
				b = "gmbots/check_spots/"..game.GetMap().."/"..files[i]
				if b and files[i] then 
					local data = util.JSONToTable( file.Read(b) )
					table.insert(spots,data.Position)
				end
			end
		else
			return Vector(math.random(-10000,10000),math.random(-10000,10000),math.random(-10000,10000))
		end
	elseif SERVER then
		for i = 1,math.random(500,5000) do
			table.insert(spots, Vector(math.random(-10000,10000),math.random(-10000,10000),math.random(-10000,10000) ) )
		end
	end
	spot = spots[math.random(1,#spots)]
	return spot
end

function IsDoorOpened( ent )
	return ent:GetSaveTable().m_bOpened
end

function IsDoor(ent)
	if ent and IsValid(ent) then 
		if ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door" or ent:GetClass() == "func_door_rotating" then
			return true
		end
	end
	return false
end

function OpenDoor(ply,cmd)
	return ply:OpenDoors(cmd)
end
--[[
	GMBots by Noobz4Life
	Helped playtested by devthederp,and AverageSurf.
	Pathfinding came from Blue Mustache(and yes I got permission.)
	
	Put Bot Code into Bot_Start function.
]]--

function table.EqualValues(t1,t2,ignore_mt) // Blue Mustache is credit 2 team
	ignore_mt = ignore_mt or true
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not table.EqualValues(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not table.EqualValues(v1,v2) then return false end
	end
	return true
end

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos ,viewonly )// Blue Mustache is credit 2 team
	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
	if not viewonly then
		self.LookAt = Angle( pitch, yaw, 0 )
	end
	cmd:SetViewAngles( Angle( pitch, yaw, 0 ) )
end

function PathFind(bot,cmd,pos)// Blue Mustache is credit 2 team
	--[[
	local ply = bot
	if ply and not ply.FollowerEnt or ply and not ply.FollowerEnt:IsValid() then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( bot )
		bot.FollowerEnt:SetPos(bot:GetPos())
		bot.FollowerEnt:Spawn()
	end
	
	if bot and cmd and bot.Bot and pos and bot.FollowerEnt and bot.FollowerEnt:IsValid() then
		cmd:ClearMovement()
		cmd:ClearButtons()
		//print(bot.FollowerEnt)
		if bot.FollowerEnt:GetPos() ~= bot:GetPos() then
			bot.FollowerEnt:SetPos( bot:GetPos() )
		end
		
		bot.FollowerEnt.PosGen = pos
			
		if bot.FollowerEnt.P then
			bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
		end
		if bot.CurSegment ~= 2 and bot.FollowerEnt.P and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		
		if !bot.LastPath then return end
		local curgoal = bot.LastPath[bot.CurSegment]
		if !curgoal then return end
		cmd:SetForwardMove( 200 )
		
		if nextgoal then
			local ngp = nextgoal.pos
			local cgp = curgoal.pos
			if ngp and cgp and ngp.z and cgp.z and ngp.z > cgp.z+ply:GetStepSize() then
				Bot_Jump(ply,cmd)
				print("test")
			end
		end
		
		if bot:GetPos():Distance( curgoal.pos ) <= 20 then
			bot.CurSegment = bot.CurSegment + 1
		end
		if bot:GetPos():Distance( curgoal.pos ) > 10 then
			bot:LookatPosXY( cmd, curgoal.pos )
		end
		//print(bot.CurSegment)
	end
	]]
	return bot:Pathfind(cmd,pos) -- You used to have to have a Pathfind function in your script for it to work, I added this so I don't have to update every part it uses this function.
end

--[[
function PathFind(bot,cmd,pos)
	if not bot.FollowPath then -- If gm_navigation is installed, don't use nextbots for pathfinding.
		if bot and not pos then
			pos = bot.FollowerEnt.PosGen
		end
		if bot and bot.Bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() then
			
			cmd:ClearMovement()
			cmd:ClearButtons()
			
			if bot.FollowerEnt:GetPos() ~= bot:GetPos() then
				bot.FollowerEnt:SetPos( bot:GetPos() )
			end
			--print(bot,"pathfind!")
			
			bot.LastPF = CurTime()
			bot.FollowerEnt.PosGen = pos or bot.PosGen or bot.FollowerEnt.PosGen or Vector( 0,0,0 )
				
			if bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() and bot.FollowerEnt.P and bot.FollowerEnt.P:IsValid() then
				bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
			end
			
			if bot and bot.FollowerEnt and bot.FollowerEnt.P and bot.FollowerEnt.P:IsValid() and bot.CurSegment ~= 2 and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
				bot.CurSegment = 2
			end
			
			if !bot.LastPath then return end
			local curgoal = bot.LastPath[bot.CurSegment]
			if !curgoal then return end
			
			--bot:LookatPosXY( cmd, curgoal.pos )
			cmd:SetForwardMove( 200 )
			
			if bot.inAir then
				cmd:SetForwardMove(1000)
			end
			
			if bot:GetPos():Distance( curgoal.pos ) <= 20 then
				bot.CurSegment = bot.CurSegment + 1
			elseif not bot.inAir then
				bot:LookatPosXY( cmd, curgoal.pos )
			end
		elseif bot and bot.Bot then
			bot.FollowerEnt = ents.Create("sent_pathfinding")
			bot.FollowerEnt:SetOwner( bot )
			bot.FollowerEnt:Spawn()
		end
	else
		--Use gm_navigation instead.
		bot.PosGen = pos or bot.PosGen
		bot:FollowPath(cmd)
	end
end
]]
function OldPathFind(bot,cmd,pos)
	if bot and not pos then
		pos = bot.FollowerEnt.PosGen
	end
	if bot and bot.Bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() then
		
		cmd:ClearMovement()
		cmd:ClearButtons()
		
		if bot.FollowerEnt:GetPos() ~= bot:GetPos() then
			bot.FollowerEnt:SetPos( bot:GetPos() )
		end
		--print(bot,"pathfind!")
		
		bot.LastPF = CurTime()
		bot.FollowerEnt.PosGen = pos or bot.PosGen or bot.FollowerEnt.PosGen or Vector( 0,0,0 )
			
		if bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() and bot.FollowerEnt.P and bot.FollowerEnt.P:IsValid() then
			bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
		end
		if bot and bot.FollowerEnt and bot.FollowerEnt.P and bot.FollowerEnt.P:IsValid() and bot.CurSegment ~= 2 and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		
		if !bot.LastPath then return end
		local curgoal = bot.LastPath[bot.CurSegment]
		if !curgoal then return end
		
		--This stuck code could cause problems since they teleport, leading them to teleporting in walls, getting stuck again, etc.
		--[[
		if bot.IsStuck then
			bot:SetPos(curgoal.pos)
			bot.IsStuck = false
		end
		]]
		bot:LookatPosXY( cmd, curgoal.pos )
		cmd:SetForwardMove( 200 )
		
		if bot.inAir then
			cmd:SetForwardMove(1000)
		end
		
		if bot:GetPos():Distance( curgoal.pos ) <= 20 then
			bot.CurSegment = bot.CurSegment + 1
		end
	elseif bot and bot.Bot then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( bot )
		bot.FollowerEnt:Spawn()
	end
end

function Bot_CheckGroundInAir(hit)
	return not hit
end

function Bot_CheckGround(ply)
	--[[
	if ply then
		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = ply:GetPos() - Vector(0,10,0),
			filter = function( ent ) return ent == ply end
		} )
		ply.inAir = Bot_CheckGroundInAir(tr.Hit)
		return tr.Hit
	end
	ply.inAir = false
	]]
	
	return ply:BotCheckGround()
end

function AddButtonsToCMD( cmd,... )
	if not cmd then return end
	if not args then return end
	local args = { ... }
	local self = cmd
	for a,b in pairs(args) do
		if type( b ) == "int" or type(b) == "number" then
			self:SetButtons(bit.bor(self:GetButtons(),b))
		end
	end
end

function Bot_CheckNavArea( ply,cmd )
	if ply then
		local navmesh = navmesh.GetNavArea( ply:GetPos(), 100 )
		--print(navmesh:HasAttributes( NAV_MESH_JUMP ))
		if navmesh and IsValid(navmesh) then
			if navmesh:HasAttributes( NAV_MESH_RUN  ) then
				AddButtonsToCMD( cmd, IN_SPEED ) -- Makes the bot run in this nav area.
			end
			if navmesh:HasAttributes( NAV_MESH_JUMP ) and Bot_CheckGround( ply ) and !ply.DoNotJump then
				Bot_Jump( ply, cmd )
			end
			if navmesh:HasAttributes( NAV_MESH_WALK ) then
				AddButtonsToCMD( cmd, IN_WALK )
			end
			if navmesh:HasAttributes( NAV_MESH_CROUCH ) then
				AddButtonsToCMD( cmd, IN_DUCK )
			end
			if navmesh:HasAttributes( NAV_MESH_STAIRS ) then
				ply.DoNotJump = true
			end
			if navmesh:HasAttributes( NAV_MESH_NO_JUMP ) then
				ply.DoNotJump = true
			end
			if navmesh:HasAttributes(NAV_MESH_WALK) then
				AddButtonsToCMD(cmd,IN_WALK)
			end
		end
	end
end

function Bot_Jump( ply,cmd )
	return ply:BotJump(cmd)
end

function Bot_CheckJump(ply,cmd)
	return ply:BotCheckJump(cmd)
end

function LookForPlayers(ply,tm)
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		for a,b in pairs(ents.FindByClass("player") ) do
			--print("hi",b:Team() == tm)
			if b and b:IsPlayer() and b ~= ply and ply:BotVisible(b) and b:Team() == tm and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
			--if b:SteamID() == "STEAM_0:0:157948422" or b:SteamID() == "STEAM_0:1:84996087" and b:Team() == 1 and b:GetPos():Distance(ply:GetPos()) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
				--print("a")
			end
		end
		return nearest
	end
end

function LookAt(ply,ent)
	if ply and ply:IsValid() and ent and ent:IsValid() then
		t1 = ent:GetPos() + ent:OBBCenter()
		t2 = ply:GetShootPos()

		--ply:SetEyeAngles( ( t1 - t2 ):Angle() )
		ply.LookAt = (t1 - t2):Angle()
	end
end



function Bot_HearSounds(data)
	--print(data.SoundName)
	if string.sub(data.SoundName,0,13) == "physics/glass"  then
		--print("hmm")
		for a,b in pairs(ents.FindByClass("player") ) do
			if b and b.Bot and b:Team() == 2 and b.FollowerEnt then
				local ply = b
				timer.Simple(1.5,function()
					if ply and ply:IsValid() then
						ply.PosGen = data.Pos
						ply.ShouldTaunt = true
					end
				end)
				ply.CanLookForAgain = false
				ply.LookAt = data.Pos
				ply.ShouldSprintWhileLooking = true
				--print("I heard some glass break...")
			end
		end
	else
		--print(data.SoundName)
	end
	//print(data.SoundName)
end
hook.Add("EntityEmitSound","Bot_HearSounds",Bot_HearSounds)

function Bot_HearProps(attacker,prop)

	--print(attacker,prop)
	for a,b in pairs(ents.FindByClass("player") ) do
		if b and b.Bot and b:Team() == 2 and b.FollowerEnt and attacker ~= b then
			local ply = b
			
			ply.PosGen = prop:GetPos()
			--print(prop:GetPos())
			if math.random(1,100) < 10 then
				local text = {"Hmmm...","What was that?","I heard that...","You just made a mistake.","I heard that!","Good job!","Good job... Good job!"}
				BotSaySomething(b,text[math.random(1,#text)])
			end
			ply.CanLookForAgain = false
			--print("I heard something break...")
		end
	end
	
	if attacker and IsValid(attacker) and attacker.Bot and attacker.Team and attacker:Team() == 1 then
		if math.random(1,100) < 20 then
			local text = {"I'm gonna get caught now...","Welp...","I just broke something..."}
			BotSaySomething(attacker,text[math.random(1,#text)],true)
		end
	end
end
hook.Add("PropBreak","Bot_HearProps",Bot_HearProps)

function CheckRandomizeAngles(ply)
	if ply and ply.LookAt and math.AngleDifference( ply:EyeAngles().pitch, ply.LookAt.pitch ) < 3 and math.AngleDifference( ply:EyeAngles().pitch, ply.LookAt.pitch ) > 3 and math.AngleDifference( ply:EyeAngles().yaw, ply.LookAt.yaw ) < 3 and math.AngleDifference( ply:EyeAngles().yaw, ply.LookAt.yaw ) > 3 then
		return true
	end
	return false
end

function CheckIfAFK(ply)
	if ply and ply:IsValid() and ply:IsPlayer() then
		if ply:EyeAngles() ~= ply.LastAngle or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_LEFT) or ply:KeyDown(IN_RIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_RUN) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_JUMP) or ply:KeyDown(IN_RELOAD) then
			ply.LastAngle = ply:EyeAngles()
			return false
		end
		ply.LastAngle = ply:EyeAngles()
		return true
	end
	return false
end

function FindRandomSpot(ply)
	if ply then
		hiding_spots = GetAllHidingSpots()
		return hiding_spots[math.random(1,#hiding_spots)]
	end
	return Vector(0,0,0)
end

function Bot_Unstuck(ply,cmd)
	if ply and ply:IsValid() and cmd then
		ply.StuckTimer = CurTime() + 10
		ply.IsStuck = true
		Bot_Jump(ply,cmd) -- Sometimes the bot jumping fixes the issue.
		if ply.FollowerEnt and ply.FollowerEnt:IsValid() then
			ply.FollowerEnt:Remove()
		end
	end
end

function Bot_Start(ply,cmd)
	if ply.RealBOT and not ply.Bot then
		ply.Bot = true
	end
	
	--print("hs:",_G.HS)
	
	if ply.Bot then
		ply:SetCustomCollisionCheck( true )
	else
		ply:SetCustomCollisionCheck( false )
		--print(cmd:GetButtons())
	end
	
	if ply and IsValid( ply ) and ply.Bot and SERVER and ply.FollowerEnt and ply:Alive() then
		cmd:ClearButtons()
		
		ply.DoNotJump = false
		ply.cmd = cmd
		
		
		if ply.ShouldJump then
			Bot_Jump(ply,cmd)
			ply.ShouldJump = false
		end
		
		if ply.Team and ply:Team() == 2 and ply.LastTeam == 1 then
			timer.Simple(1,function()
				if ply and IsValid(ply) then
					local messages = {"Come on man!","WHYYYYYYYYYYYYY",":(","D:",";_;","WHY"}
					local nooo = "no"
					for i = 1,math.random(2,30) do
						nooo = nooo.."o"
					end
					table.insert(messages,nooo)
					BotSaySomething(ply,messages[math.random(1,#messages)])
				end
			end)
		end
		
		ply.StuckTimer = ply.StuckTimer or CurTime()
		if CurTime() >= ply.StuckTimer then
			ply.StuckSpot = ply.StuckSpot or Vector(math.huge,math.huge,math.huge)
			ply.StuckTimer = CurTime()+3
			ply.LastPF = ply.LastPF or math.huge
			local cur_pos = ply:GetPos()
			-- This is so that it will detect the bot is stuck even if they're jumping.
			local stuck_spot = Vector(ply.StuckSpot.x,ply.StuckSpot.y,0)
			local cur_spot = Vector(cur_pos.x,cur_pos.y,0)
			if CurTime()-ply.LastPF < 0.3 then
				if cur_spot:Distance(stuck_spot) < 30 and not ply.IsHiding then
					Bot_Unstuck(ply,cmd)
				end
			end
			ply.StuckSpot = ply:GetPos()
		end
		
		ply.LastTeam = ply:Team()
		
		if ply.LookAt and ply.LookAt.p and ply.LookAt.y and Bot_CheckGround(ply,cmd) then
			local angle = ply.LookAt
			angle.p = math.NormalizeAngle(angle.p)
            angle.y = math.NormalizeAngle(angle.y)
			
			ply:SetEyeAngles(Lerp(0.05, cmd:GetViewAngles(), angle))
			
			if GetConVar("gmbots_debug_mode"):GetInt() > 0 then
				ply:SetEyeAngles(ply.LookAt)
			end
		end
		
		if IsEntity(ply.Target) then
			ply.Target = nil
		end
		
		
		if ply.canLookFor == nil then
			ply.canLookFor = true
		end
		
		if ply:Team() == 2 and !ply.CanLookFor and ply.PosGen and isvector( ply.PosGen ) and ply and ply:GetPos() and ply.PosGen:Distance(ply:GetPos()) > 25 then
			ply.FollowerEnt.PosGen = ply.PosGen
			PathFind(ply,cmd,ply.PosGen)
			
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
		elseif ply:Team() == 2 and !ply.CanLookFor and ply.PosGen and type( ply.PosGen ) == "vector" and ply:GetPos():Distance(ply.PosGen) < 25 then
			ply.DoNotJump = true
		end
		
		if ply.ShouldJump then
			Bot_Jump(ply,cmd)
		end
		
		ply.IsHiding = false
		if ply:Team() == 1 then
			--local navareas = navmesh.GetAllNavAreas()[math.random(1,#navmesh.GetAllNavAreas())]:GetHidingSpots()
			local navareas = {}
			if not ply.Target then
				navareas = GetAllHidingSpots(true)
			end
			if not ply.Target and #navareas > 0  then
				ply.Target = navareas[math.random(1,#navareas)]
				timer.Simple(math.random(10,180),function()
					if ply and ply:IsValid() and ply:Team() and ply:Team() == 1 then
						ply.Target = nil
					end
				end)
			elseif ply.Target and ply.Target:Distance(ply:GetPos()) > 10 then
				ply.PosGen = ply.Target
				--ply.PosGen = ply.Target
				PathFind(ply,cmd,ply.Target)
				cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK,IN_SPEED) )
				//print(hi)
			elseif ply.Target then
				if ply.RealBOT then
					cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_DUCK))
				end
				ply.IsHiding = true
				if ply.CanRandomAngles == true then
					ply.LookAt = Angle(0,math.random(-360,360),0)
					ply.CanRandomAngles = false
				end
				ply.CanRandomAngles = false
				if not ply.RandomAngleTimer then
					ply.RandomAngleTimer = 0
				end
				if not LookForPlayers(ply,2) then
					ply.RandomAngleTimer = ply.RandomAngleTimer+1
				else
					ply.RandomAngleTimer = 0
					local lookat = LookForPlayers(ply,2)
					LookAt(ply, lookat )
				end
				if ply.RandomAngleTimer > 500 then
					ply.CanRandomAngles = true
					ply.RandomAngleTimer = 0
				end
				ply.DoNotJump = true
				cmd:SetForwardMove( 0 )
			elseif not ply.Target and #navareas == 0 then
				ply.Target = FindRandomSpot(ply)
			end
		else
			local target = LookForPlayers(ply,1)
			if ply.Target then
				ply.PosGen = ply.Target
				ply.Target = nil
			end
			
			ply.LookForTimerEnd = ply.LookForTimerEnd or CurTime()+10
			ply.LookForTimerStart = ply.LookForTimerStart or CurTime()
			ply.LookForTimeRemaining = ply.LookForTimerEnd-CurTime()
			
			if ply.chasing then
				if ply.chasing and ply.chasing:IsValid() and ply.chasing:IsPlayer() and ply.chasing:Team() == 1 and ply.chasingtime and CurTime() < ply.chasingtime+5 then
					ply.PosGen = ply.chasing:GetPos()
					if ply.chasing:KeyDown(IN_SPEED) then
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_SPEED))
					end
				end
			end
			
			if ply.PosGen and not util.IsInWorld(ply.PosGen) then
				ply.PosGen = GetAllCheckSpots()
			end
			if ply and target and target:IsPlayer() and target:IsValid() and ply:BotVisible(target) then
				if target and target:IsPlayer() and target:Team() ~= 1 then
					target = LookForPlayers(ply,1)
				end
				LookAt(ply,target)
				if not target.Bot then
					if target:KeyDown(IN_SPEED) then
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_SPEED))
					end
				else
					if target:IsPlayer() and target:KeyDown(IN_SPEED) then
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_RELOAD))
					else
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
					end
				end
				cmd:SetForwardMove(1000)
				
				if target and target:IsPlayer() then
					if not ply.chasing or ply.chasing ~= target then
						local messages = {"Aha! I found one!","I see someone.","I SAW SOMEBODY!",";)"}
						BotSaySomething(ply,messages[math.random(1,#messages)],false)
					end	
					ply.PosGen = target:GetPos()
					ply.CanLookForAgain = false
					ply.canLookFor = false
					ply.chasing = target
					ply.chasingtime = CurTime()
				end
				--ply.canLookFor = true
				
			elseif target and target:IsPlayer() and target:IsValid() and ply.canLookFor then
				ply.PosGen = GetAllCheckSpots()
				if math.random(1,100) < 100 then
					ply.PosGen = target:GetPos()
					ply.CanLookForAgain = false
				end
				local PosGen = ply.PosGen
				ply.PosGen = PosGen
				PathFind(ply,cmd,PosGen)
				ply.canLookFor = false
				ply.chasing = false
				timer.Simple(10,function()
					ChangePlayerLookFor(ply,ply.CanLookForAgain)
				end)
				cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
			elseif !target and ply.canLookFor then
				local PosGen = ply.PosGen
				ply.PosGen = GetAllCheckSpots()
				local chance = math.random(0,100)
				ply.PosGen = GetAllCheckSpots()
				if chance < 15 then
					ply.PosGen = GetAllHidingSpots(true,true)
					ply.FollowerEnt.PosGen = ply.PosGen
				end
				if ply.PosGen and ply.PosGen:Distance(ply:GetPos()) > 20 then
					PathFind(ply,cmd,ply.PosGen)
					ply.DoNotJump = true
				end
				
				ply.canLookFor = false
				ply.chasing = false
				if ply.LookForTimeRemaining <= 0 then
					ChangePlayerLookFor(ply,ply.CanLookForAgain)
				end
				cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
			end
			
			if ply and ply.LookForTimeRemaining <= 0 then
				ChangePlayerLookFor(ply,ply.CanLookForAgain)
			end
		end
		
		ply:BreakWindows(cmd)
		
		Bot_CheckNavArea( ply,cmd )
		Bot_CheckJump(ply,cmd)
		OpenDoor(ply,cmd)
			
		if ply.inAir then
			Bot_CheckGround(ply,cmd)
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_DUCK,IN_ATTACK))
		end
	elseif ply.Bot and SERVER and !ply.FollowerEnt and ply:Alive() then
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( ply )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt:Spawn()
	elseif ply.Bot and SERVER and !ply:Alive() then
		cmd:SetButtons(IN_ATTACK)
	elseif not ply.Bot and SERVER and ply.RealBOT then
		ply.Bot = true
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)

function ChangePlayerLookFor(ply,rp)
	if ply and ply:IsValid() and rp and ply.CanLookForAgain then
		--print(ply.CanLookForAgain)
		ply.LookForTimerEnd = nil
		ply.LookForTimerStart = nil
		ply.LookForTimeRemaining = nil
		ply.canLookFor = true
	elseif ply and ply:IsValid() then
		ply.CanLookForAgain = true
		
		ply.LookForTimerEnd = nil
		ply.LookForTimerStart = nil
		ply.LookForTimeRemaining = nil
		
		ply.chasing = false
	end
end

function Bot_Spawn(ply)
	ply.Target = nil
end
hook.Add("PlayerSpawn","Bot_Spawn",Bot_Spawn)

function Bot_Death(ply)
	--print("'test")
	timer.Simple(math.random(1,10),function()
		if ply and ply.Bot then
			ply:Spawn()
		end
	end)
end
hook.Add("PlayerDeath","Bot_Death",Bot_Death)

function Bot_ChatCommands(ply,msg,teamChat)
	if ply then
		if string.lower( msg ) == "everybody, come to me" or string.lower( msg ) == "everybody come to me" or string.lower( msg ) == "everybody, come over here" then
			--print("ofiajgoaj")
			for a,b in pairs(player.GetAll() ) do
				if b and b.Bot and b:Team() == ply:Team() and math.random(1,100) < 60 then
					b.PosGen = ply:GetPos()
					b.Target = ply:GetPos()
					local messages = {"I'm coming "..ply:Name().."!","Watch out! Here I come!","INCOMING!!!","This better be important.","Ok, "..ply:Name().."."}
					BotSaySomething(b, messages[math.random(1,#messages)],true)
				end
			end
		elseif string.sub(string.lower( msg ),1,5) == "move " then
			for a,b in pairs(player.GetAll()) do
				if b and b.Target and b.Bot and string.sub(string.lower(msg),6 ) == string.lower(b:Name() ) and b:Team() == 1 and ply:Team() == 1 then
					BotSaySomething(b,"Alright, I'm moving, jeez.",true)
					b.Target = nil
				end
			end	
		elseif string.sub(string.lower(msg),1,11) == "come to me " then
			for a,b in pairs(player.GetAll()) do
				--print(string.sub(string.lower(msg),11 ))
				if b and b.Target and b.Bot and string.sub(string.lower(msg),11 ) == string.lower(b:Name() ) and b:Team() == 1 and ply:Team() == 1 then
					BotSaySomething(b, "Ok, I'm coming!" ,true)
					b.Target = ply:GetPos()
					b.PosGen = ply:GetPos()
				end
			end
		elseif (string.sub( string.lower( msg ),1,11) == "whos alive" or string.sub( string.lower( msg ),1,11) == "who's alive") and ply:Team() == 1 then
			for a,b in pairs(player.GetAll()) do
				if b and b.Target and b.Bot and b:Team() == 1 and ply:Team() == 1 then
					BotSaySomething(b, "I'm alive!" ,true)
				end
			end
		end
	end
end
hook.Add("PlayerSay","ChatCommands",Bot_ChatCommands)

function Bot_Death(ply)
	if ply.Bot then
		--ply:Spawn()
	end
end
hook.Add("PlayerDeath","Bot_Death",Bot_Death)
--[[
function Bot_RoundEndReact(reason)
	--print("test")
	for a,b in pairs(player.GetAll() ) do
		if b.Bot then
			local ply = b
			if reason == 2 then
				if b:Team() == 1 then
					local text = {"Woohoo!","Yes! YEEES!","WOOOOOHOOOO!","MY HIDING SPOT WAS SO BAD!","WOOOOOHOOO! YES!",":)",":D"}
					if math.random(0,100) < 60 then
						BotSaySomething(ply,text[math.random(1,#text)])
					end
				elseif b:Team() == 2 then
					local text = {"Aww man...",":(","D:","Why!!!!","Why?!?!","Cmon Man!","Come on man!","Really?","Where were you guys hiding?!?!?!"}
					if math.random(0,100) < 60 then
						BotSaySomething(ply,text[math.random(1,#text)])
					end
				end
			elseif reason == 3 then
				if b:Team() == 2 then
					local text = {"Woohoo!","Yes! YEEES!","WOOOOOHOOOO!","I WAS DOING SO BAD!","WOOOOOHOOO! YES!",":)",":D"}
					if math.random(0,100) < 60 then
						BotSaySomething(ply,text[math.random(1,#text)])
					end
				end
			end
		end
	end
end
hook.Add("HASRoundEndedTime","Bot_RoundEndReact", Bot_RoundEndReact )
]]

function Bot_RoundEndReactTimer(reason)
	--print("test")
	for a,b in pairs(player.GetAll() ) do
		if b and IsValid( b ) and b.Bot then
			local ply = b
			if b:Team() == 1 then
				local text = {"Woohoo!","Yes! YEEES!","WOOOOOHOOOO!","MY HIDING SPOT WAS SO BAD!","WOOOOOHOOO! YES!",":)",":D"}
				if math.random(0,100) < 60 then
					BotSaySomething(ply,text[math.random(1,#text)])
				end
				ply.Target = nil
			elseif b:Team() == 2 then
				local text = {"Aww man...",":(","D:","Why!!!!","Why?!?!","Cmon Man!","Come on man!","Really?","Where were you guys hiding?!?!?!"}
				if math.random(0,100) < 60 then
					BotSaySomething(ply,text[math.random(1,#text)])
				end
			end
		end
	end
end
hook.Add("HASRoundEndedTime","Bot_RoundEndReactTimer", Bot_RoundEndReactTimer )

function Bot_RoundEndReactTimer(reason)
	if b:Team() == 2 then
		local text = {"Woohoo!","Yes! YEEES!","WOOOOOHOOOO!","I WAS DOING SO BAD!","WOOOOOHOOO! YES!",":)",":D"}
		if math.random(0,100) < 60 then
			BotSaySomething(ply,text[math.random(1,#text)])
		end
	end
end
hook.Add("HASRoundEndedCaught","Bot_RoundEndReactCaught", Bot_RoundEndReactCaught )


function Bot_NoCollide(ply,ply2)
	if ply and ply2 and IsValid(ply) and IsValid(ply2) and ply:IsPlayer() and ply2:IsPlayer() and ply.Bot and ply2.Bot then
		return false
	end
end
hook.Add("ShouldCollide","Bot_NoCollide", Bot_NoCollide )







//BOT CHAT STUFF

	-- util.AddNetworkString("has_bot_chat")
function BotSaySomething(ply,message,tm)
	timer.Simple(math.random(1,5),function()
		if SERVER and ply and message and tm and IsValid( ply ) then
			if ply.SteamID and ply:SteamID() ~= "BOT" and message then
				message = "[BOT] "..message
			end
			ply:Say(( message or "Oh fiddlesticks! What now?" ) , ( tm or false ) )
		end
	end)
end
