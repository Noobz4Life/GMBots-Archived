--[[

	This code is a re-make of a NextBot I made on my Old PC that did something similar to this.
	Obviously instead of NextBot I made it with Player Bots instead.
	Don't expect these to be a auto-gun dealer or something.

	Currnet Behaviour (Last Updated 8/11/2017)
	- Walk Around
	- Run when shot.
	- Change name on death.
	- Change job on death.
]]

local FBotNames = {"Bob","Steven","Squidward","Jake","Alex","Bill","Zulu","Papa","Hotel","John","Steven"}
local LBotNames = {"Tentacles","Tortellini","Gates","Trump","Bills","Martin","Obama","Douglas"}
local BOTS = {}

if SERVER then
	concommand.Add("gmbots_bot_add",function()
		if SERVER then
			if(#player.GetAll() == game.MaxPlayers())then
				error("[GMBots] Server is full, cant spawn bot\n")
			else
				if ply and ply:IsValid() then return end
				
				local name = FBotNames[math.random(#FBotNames)].." "..LBotNames[math.random(#LBotNames)]
				local bot = player.CreateNextBot(name)
				bot:setRPName(name)
				table.insert(BOTS,bot)
				bot.Bot = true
				bot.RPAttack = false
				bot.prevPos = Vector(0, 0, 0)
				bot.FollowerEnt = ents.Create("sent_pathfinding")
				bot.FollowerEnt:SetOwner( bot )
				bot.FollowerEnt:SetPos(bot:GetPos())
				bot.FollowerEnt:Spawn()
				--print(bot)
			end
		end
	end)
	
	concommand.Add("gmbots_add_randomspot",function(ply,cmd,args,argsString)
		if not file.IsDir("gmbots","DATA") then
			file.CreateDir("gmbots","DATA")
		end
		
		if not file.IsDir("gmbots/random_spots","DATA") then
			file.CreateDir("gmbots/random_spots","DATA")
		end
		
		if not file.IsDir("gmbots/random_spots/"..game.GetMap(),"DATA") then
			file.CreateDir("gmbots/random_spots/"..game.GetMap(),"DATA")
		end
		AddNewRandomSpot(ply,cmd,args,argsString)
	end)
else
	concommand.Add("gmbots_bot_add",function(  )
		if CLIENT then
			MsgC(Color( 0, 255, 64 ),"[GMBots] Sorry. But only the server can do that\n")
		end
	end)
end

function IsDoorOpened( ent )
	return ent:GetSaveTable().m_bOpened
end

function OpenDoor(ply,cmd)
	if ply:GetEyeTrace().Entity:GetClass() == "prop_door" or ply:GetEyeTrace().Entity:GetClass() == "func_door" or ply:GetEyeTrace().Entity:GetClass() == "prop_door_rotating" or ply:GetEyeTrace().Entity:GetClass() == "func_door_rotating" then
		local eyetrace = ply:GetEyeTrace().Entity
		if eyetrace:GetPos():Distance( ply:GetPos() ) <= 100 and IsDoorOpened( eyetrace ) then
			cmd:SetButtons(IN_USE)
			return true
		end
	end
	return false
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

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )// Blue Mustache is credit 2 team
	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
	self:SetEyeAngles( Angle( pitch, yaw, 0 ) )
	cmd:SetViewAngles( Angle( pitch, yaw, 0 ) )
end

function PathFind(bot,cmd,pos)
	if not pos then
		pos = Vector(0,0,0)
	end
	if bot and bot.Bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() and pos then
		cmd:ClearMovement()
		cmd:ClearButtons()
		if bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() and bot.FollowerEnt:GetPos() and bot.FollowerEnt:GetPos() ~= bot:GetPos() then
			bot.FollowerEnt:SetPos( bot:GetPos() )
		end
		
		 bot.FollowerEnt.PosGen = pos
			
		if bot.FollowerEnt.P then
			bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
		end
		if bot and bot.FollowerEnt and bot.FollowerEnt.P and bot.CurSegment ~= 2 and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		
		if !bot.LastPath then return end
		local curgoal = bot.LastPath[bot.CurSegment]
		if !curgoal then return end
		bot:LookatPosXY( cmd, curgoal.pos )
		cmd:SetForwardMove( 200 )
		
		if bot:GetPos():Distance( curgoal.pos ) <= 20 then
			bot.CurSegment = bot.CurSegment + 1
		end
		--print(bot.CurSegment)
	elseif bot and bot.Bot then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( bot )
		bot.FollowerEnt:Spawn()
	end
end

function AddNewRandomSpot(ply,cmd,args,argsString)
	local chs = "gmbots/random_spots/"..game.GetMap().."/spot"..(#file.Find( "gmbots/random_spots/"..game.GetMap().."/*.txt", "DATA" )+1)..".txt"
	local data = {}
	--print(chs)
	data.Position = ply:GetPos()
	data.Creator = ply:SteamID()
	data.CreatorName = ply:Name()
	if not file.Exists( chs , "DATA" ) then
		file.Write( chs ,util.TableToJSON( data ) )
	end
end

function GetAllRandomSpots(no_nav,isspot)
	isspot = true
	local spots = {}
	if SERVER and no_nav and file.IsDir("gmbots/random_spots/"..game.GetMap(),"DATA") then
		files,direct = file.Find( "gmbots/random_spots/"..game.GetMap().."/*.txt", "DATA" )
		--print(files,#files)
		if files and #files > 0 then
			--print(#files)
			for i = 1,#files do
				b = "gmbots/random_spots/"..game.GetMap().."/"..files[i]
				if b and files[i] then 
					local data = util.JSONToTable( file.Read(b) )
					table.insert(spots,data.Position)
				end
			end
		end
	end
	return spots
end

function Bot_CheckJump(ply,cmd)
	if ply:GetVelocity():Length() < 5 and ply:IsOnGround() and !ply.DoNotJump then
		ply:SetVelocity(Vector(0,0,300))
		cmd:SetButtons(IN_DUCK)
		--print(cmd:GetButtons())
		if ply:KeyDown(IN_DUCK) then
			cmd:SetButtons(0)
			--print("clear")
		end
	end
end

function OpenDoors(ply)
	for a,b in pairs(ents.FindInSphere(ply:GetPos(),25)) do
		if b and b:isDoor() and not b:GetSaveTable().m_bLocked then
			b:Fire("open","","")
		end
	end
end

function GetRandomSpot(ply)
	if ply and ply:IsValid() then
		local spot = Vector(0,0,0)
		local spots = GetAllRandomSpots(true,false) or {}
		--print(#spots)
		if #spots > 0 then
			spot = spots[math.random(1,#spots)]
			--print(spot)
			--print(spot)
		elseif ply then
			spot = ply:GetPos()+Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))
		end
		return spot
	end
end
can_attack_timer = 0
function Bot_Start(ply,cmd)
	if ply.Bot and SERVER and ply.FollowerEnt and ply.FollowerEnt:IsValid() and ply:Alive() then
		if ply.DoNotJump then
			ply.DoNotJump = false
		end
		
		if ply.FollowerEnt.PosGen and ply.FollowerEnt.PosGen:Distance(ply:GetPos() ) < 25 then
		elseif not ply.FollowerEnt.PosGen then
			ply.FollowerEnt.PosGen = GetRandomSpot(ply)
			timer.Simple(20,function()
				ply.FollowerEnt.PosGen = GetRandomSpot(ply)
			end)
		elseif ply.FollowerEnt.PosGen then
			PathFind(ply,cmd,ply.FollowerEnt.PosGen)
		end
		
		--print(ply.FollowerEnt.PosGen)
		
		cmd:ClearButtons()
		
		ply.DoNotJump = false
		if ply.Running then
			cmd:SetButtons(IN_SPEED)
		else
			cmd:SetButtons(IN_WALK)
		end
		if not ply.can_attack_timer then
			ply.can_attack_timer = 0
		end
		if not ply.can_attack then
			ply.can_attack_timer = ply.can_attack_timer+1
			if ply.can_attack_timer > 20 then
				ply.can_attack = true
			end
		end
		if ply:HasWeapon("arrest_stick") and ply.ScaredOf then
			ply.FollowerEnt.PosGen = ply.ScaredOf:GetPos()
			ply.Running = true
			if not ply.ScaredOf:isWanted() then
				ply.ScaredOf:wanted(ply,"Hurting Someone",120)
			end
			if ply.ScaredOf:Visible(ply) then
				ply:SetEyeAngles( ( ply.ScaredOf:GetPos() - ply:GetShootPos() ):Angle() )
				if ply.can_attack then
					cmd:SetButtons(IN_ATTACK)
					ply.can_attack = false
					ply.can_attack_timer = 0
				else
					cmd:SetButtons(IN_SPEED)
				end
				ply:SelectWeapon("arrest_stick")
			end
		end
		
		if !ply.DoNotJump then
			Bot_CheckJump(ply,cmd)
			OpenDoors(ply)
		end
	elseif ply.Bot and SERVER and ply:Alive() then
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( ply )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt.PosGen = ply:GetPos()+Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))
		ply.FollowerEnt:Spawn()
	elseif ply.Bot and SERVER and !ply:Alive() then
		--print("test")
		ply:SetButtons(IN_ATTACK)
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)

hook.Add("playerArrested","Bot_Arrest",function(ply)
	for a,b in pairs(player.GetAll() ) do
		if b and b.ScaredOf and b.ScaredOf == ply then
			b.ScaredOf = nil
		end
	end
end)

function Bot_Scared(ply,attacker,hp,damage)
	if hp > 0 and attacker and attacker:IsPlayer() and ply and ply.Bot then
		ply.Running = true
	end
	
	for a,b in pairs(player.GetAll() ) do
		if b.Bot and attacker and attacker:IsPlayer() and b:Visible(ply) then
			b.Running = true
			b.ScaredOf = attacker
		end
	end
end
hook.Add("PlayerHurt","Bot_Scared",Bot_Scared)

function Bot_Death(ply,cmd)
	if ply and ply.Bot then
		if ply.FollowerEnt and ply.FollowerEnt:IsValid() then
			ply.FollowerEnt:Remove()
		end
		timer.Simple(59,function()
			pcall(function()
				RandomJob(ply)
				ply:setRPName( FBotNames[math.random(#FBotNames)].." "..LBotNames[math.random(#LBotNames)] )
			end)
		end)
		timer.Simple(60,function()
			pcall(function()
				ply:Spawn()
				ply.Running = false
				ply.ScaredOf = nil
			end)
		end)
	end
end
hook.Add("PlayerDeath","Bot_Death",Bot_Death)

function RandomJob(ply)
	local teams = RPExtraTeams
	if teams and SERVER then
		
		local could_change = ply:changeTeam(math.random(1,#teams),false,true)

		
		return could_change
	end
	return false
end

function Bot_Spawn(ply)
	if SERVER and ply and ply.Bot then
		timer.Simple(1,function()
			ply:SetPlayerColor( Vector(math.random(1,255)/255,math.random(1,255)/255,math.random(1,255)/255 ) )
			ply:SelectWeapon("keys")
		end)
	end
end
hook.Add("PlayerSpawn","Bot_Spawn",Bot_Spawn)