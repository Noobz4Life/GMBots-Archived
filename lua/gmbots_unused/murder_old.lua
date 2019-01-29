//Base code for bots.

local BotNames = {"Scout","Soldier","Pyro","Demoman","Heavyweapons Guy","Engineer","Medic","Sniper","Spy","Sphee","Fullman","Wild Sphee","Chell","Coach","GlaDOS","Wheatley","Virgil","AEGIS","Ellis"}
local BOTS = {}


if SERVER then
	--[[
	concommand.Add("gmbots_bot_add",function(ply)
		if SERVER and not IsValid(ply) then
			if(#player.GetAll() == game.MaxPlayers())then
				error("[GMBots] Server is full, cant spawn bot\n")
			else
				if ply and ply:IsValid() then return end
				local name = nil
				local name_id = 1
				
				
				for a,b in pairs(player.GetAll()) do
				
					if BotNames[name_id] and b:Name() == "BOT "..BotNames[name_id] then
						name_id = name_id+1
					end
					if name_id > #BotNames then
						name = "#"..tostring( math.random(1,math.random(300,100000)) )
						-- If you still get a duplicate names, congrats, you got something super rare!
					end
				end
				if name == nil then name = BotNames[name_id] end
				local bot = player.CreateNextBot("BOT "..name or BotNames[name_id])
				table.insert(BOTS,bot)
				bot.Bot = true
				bot.RPAttack = false
				bot.prevPos = Vector(0, 0, 0)
				bot.FollowerEnt = ents.Create("sent_pathfinding")
				bot.FollowerEnt.Owner = bot
				bot.FollowerEnt:SetPos(bot:GetPos())
				bot.FollowerEnt:Spawn()
				bot.DisableAI = true
				bot.DisableAIStop = CurTime()+1
				bot.DebugMode = false
				bot.Accuracy = math.random(20,30) -- How accurate are bots with guns? High values = more accurate, atleast that's how it's supposed to be, I probably messed up my math though.
				bot.Intel = math.random(40,100) -- How smart are the bots, lower values will make bots do more stupid things.
				if name == "Sniper" then
					bot.Accuracy = 30 -- Sniping's a good job mate!
				elseif name == "Demoman" then
					bot.Accuracy = 15 -- I'm drunk- you don't have a excuse!
				end
				MsgC(Color( 0, 255, 64 ),"[GMBots] Added bot: "..bot:Name().." with "..bot.Intel.." intelligence and "..bot.Accuracy.." accuracy.\n")
			end
		end
	end)
	]]
	
	hook.Add("GMBotsBotAdded","GamemodeBotAdded",function(bot)
		if bot and bot:IsValid() then
			table.insert(BOTS,bot)
			bot.Bot = true
			bot.RPAttack = false
			bot.prevPos = Vector(0, 0, 0)
			bot.FollowerEnt = ents.Create("sent_pathfinding")
			bot.DisableAI = true
			bot.DisableAIStop = CurTime()+1
			bot.DebugMode = false
			bot.Accuracy = math.random(20,30) -- How accurate are bots with guns? High values = more accurate, at least that's how it's supposed to be, I probably messed up my math though.
			bot.Intel = math.random(40,100) -- How smart are the bots, lower values will make bots do more stupid things.
			if name == "Sniper" then
				bot.Accuracy = 30 -- Sniping's a good job mate!
			elseif name == "Demoman" then
				bot.Accuracy = 15 -- I'm drunk- you don't have a excuse!
			end
		end
	end)
	
	concommand.Add("gmbots_add_walktospot",function(ply,cmd,args,argsString)
		if not SERVER then return end
		if not ply:IsSuperAdmin() then return end
		
		if not file.IsDir("gmbots","DATA") then
			file.CreateDir("gmbots","DATA")
		end
		
		if not file.IsDir("gmbots/walkto_spots","DATA") then
			file.CreateDir("gmbots/walkto_spots","DATA")
		end
		
		if not file.IsDir("gmbots/walkto_spots/"..game.GetMap(),"DATA") then
			file.CreateDir("gmbots/walkto_spots/"..game.GetMap(),"DATA")
		end
		AddNewWalkToSpot(ply,cmd,args,argsString)
	end)
else
	concommand.Add("gmbots_bot_add",function(  )
		if CLIENT then
			MsgC(Color( 0, 255, 64 ),"[GMBots] Sorry. But only the server can do that\n")
		end
	end)
end

function AddNewWalkToSpot(ply,cmd,args,argsString)
	if not SERVER then return end
	local chs = "gmbots/walkto_spots/"..game.GetMap().."/spot"..(#file.Find( "gmbots/walkto_spots/"..game.GetMap().."/*.txt", "DATA" )+1)..".txt"
	local data = {}
	--print(chs)
	data.Position = ply:GetPos()
	data.Creator = ply:SteamID()
	data.CreatorName = ply:Name()
	if not file.Exists( chs , "DATA" ) then
		file.Write( chs ,util.TableToJSON( data ) )
	end
end

function Bot_GetHidingSpot(ply,cmd)
	local pos = ply:WorldSpaceCenter()
	local radius = 5000
	local navmesh = navmesh.Find( pos, radius, 20, 20 )
	
	local found = {}
	
	for _, area in pairs( navmesh ) do

		-- get the spots
		local spots

		spots = area:GetHidingSpots()

		for k, vec in pairs( spots ) do

			table.insert( found, vec )

		end

	end
	return table.Random(found) or false
end

function GetRandomWalkToSpot(ply,cmd,rdm)
	if ( !ply ) then return end
	if ( !ply:IsValid() ) then return end
	if ( !cmd ) then return end
	local spots = {}
	local spot = Vector(0,0,0)
	if SERVER and file.IsDir("gmbots/walkto_spots/"..game.GetMap(),"DATA") and not rdm then
		files,direct = file.Find( "gmbots/walkto_spots/"..game.GetMap().."/*.txt", "DATA" )
		if files and #files > 0 then
			for i = 1,#files do
				b = "gmbots/walkto_spots/"..game.GetMap().."/"..files[i]
				if b and files[i] then 
					local data = util.JSONToTable( file.Read(b) )
					table.insert(spots,data.Position)
				end
			end
		else
			return GetRandomWalkToSpot( ply,cmd,true )
		end
	elseif SERVER then
		return Bot_GetHidingSpot(ply,cmd) or ply:GetPos()
	end
	spot = spots[math.random(1,#spots)]
	return spot
end

function IsDoorOpened( ent )
	return ent:GetSaveTable().m_bOpened
end

function OpenDoor(ply,cmd)
	return ply:OpenDoors(cmd)
end

function Bot_NoCollide(ply,ent)
	if ply and ply:IsValid() and ply.Bot and ent and ent:IsValid() and ent.IsDoor and ent:IsDoor() then
		return false
	end
end
hook.Add("ShouldCollide","Bot_NoCollide", Bot_NoCollide )
--[[
	GMBots by Noobz4Life
	Helped playtested by devthederp,and Av3r4ge.
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
--[[

This was the old LookForPlayers function that was a work in progress.
There is now a better verison that does what this was intended to do better.


This was intended to find players in a cone, but I failed, but later found out how too using a different method, which overrides all bot's "visible" function.

function LookForPlayers(ply)
	--Work In Progress.
	if ply and ply.Bot and SERVER then
		local lastdist = math.huge
		local nearest = nil
		local cone_radius = math.tan(math.rad(Sight.angle)) * Sight.distance
		
		--local ent = ents.FindInCone(ply:GetPos(),ply:GetAimVector(),2000,180 )
		
		local aim_vector = ply:GetAimVector()
		
		local dir_right = aim_vector:Cross(Vector(0, 0, 1))
		local dir_up = dir_right:Cross(aim_vector)
		
		local box_min = Vector(9999999, 9999999, 9999999)
		local box_max = Vector(-9999999, -9999999, -9999999)
		
		local function CheckMinAndMax(v)
			box_min.x = math.min(box_min.x, v.x)
			box_min.y = math.min(box_min.y, v.y)
			box_min.z = math.min(box_min.z, v.z)

			box_max.x = math.max(box_max.x, v.x)
			box_max.y = math.max(box_max.y, v.y)
			box_max.z = math.max(box_max.z, v.z)
		end
		
		CheckMinAndMax(ply:GetPos())
		
		local points = 16
		
		local rad_per_point = math.pi*2 / points
		for i=0,points do
			local endpos = ply:GetPos() + aim_vector * Sight.distance
			+ dir_right * math.cos(rad_per_point * i) * cone_radius
			+ dir_up * math.sin(rad_per_point * i) * cone_radius

			CheckMinAndMax(endpos)
		end
		
		local ent = ents.FindInBox(box_min,box_max)
		
		--local ent = ents.FindInCone(Vector(0,0,0),Vector(0,0,0),2000,180 )
		print(#ent)
		for a,b in pairs(ent) do
			if b and b:IsPlayer() and b ~= ply and b:BotVisible(ply ) and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end
]]

function LookForPlayers(ply)
	--[[
		This is a simple verison of LookForPlayers.
		Instead of using vision cones, It uses ents.FindByClass and Vector:BotVisible( Vector )).
		This looks for the nearest visible player.
		
		You can modify this and the non-simple LookForPlayers to work with teams if you need too.
	]]
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		for a,b in pairs(ents.FindByClass("player") ) do
			if b and b:IsPlayer() and b ~= ply and b:GetPos():BotVisible(ply:GetPos() ) and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

function Pos_Visible(pos1,pos2)
	local plys = player.GetAll()
	local trace_data = {}
	trace_data.start = pos1 or Vector(0,0,0)
	trace_data.endpos = pos2 or Vector(0,0,0)
	trace_data.filter = plys
	local trace = util.TraceLine(trace_data)
	return not trace.Hit
end

function PathFind(bot,cmd,pos)
	return bot:Pathfind(cmd,pos)
end

function Bot_CheckGround(ply)
	return ply:BotCheckGround()
end

function LookAtFunc( ply, cmd )
		if ply.LookAt and ply.LookAt.p and ply.LookAt.y then
			local angle = ply.LookAt
			angle.p = math.NormalizeAngle(angle.p)
            angle.y = math.NormalizeAngle(angle.y)
			
			ply:SetEyeAngles(Lerp(0.05, cmd:GetViewAngles(), angle))
			--print(angle,ply:EyeAngles())
			
			--print(ply:Get
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

function LookAtPos(ply,pos)
	if ply and ply:IsValid() and pos and type(pos) == "Vector" then
		t1 = pos
		t2 = ply:GetShootPos()

		--ply:SetEyeAngles( ( t1 - t2 ):Angle() )
		ply.LookAt = (t1 - t2):Angle()
	end
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

function AddButtonToCMD( cmd,button)
	if cmd and button then
		cmd:SetButtons(bit.bor(cmd:GetButtons(),button or IN_SPEED))
	end
end

function Bot_CheckNavArea( ply,cmd )
	if ply then
		local navmesh = navmesh.GetNavArea( ply:GetPos(), 100 )
		if navmesh then
			if navmesh:HasAttributes( NAV_MESH_RUN  ) then
				AddButtonsToCMD( cmd, IN_SPEED ) -- Makes the bot run in this nav area.
			elseif navmesh:HasAttributes( NAV_MESH_JUMP ) and Bot_CheckGround( ply ) and !ply.DoNotJump then
				Bot_Jump( ply, cmd )
			elseif navmesh:HasAttributes( NAV_MESH_WALK ) then
				AddButtonsToCMD( cmd, IN_WALK )
			elseif navmesh:HasAttributes( NAV_MESH_CROUCH ) then
				AddButtonsToCMD( cmd, IN_DUCK )
			elseif navmesh:HasAttributes( NAV_MESH_STAIRS ) then
				ply.DoNotJump = true
			end
		end
	end
end

function Bot_Jump( ply, cmd ) --NEVER use this function unless you have too. This is used by Bot_CheckJump.
	return ply:BotCheckJump(cmd)
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
			if b and b:IsPlayer() and b ~= ply and ply:IsLineOfSightClear(b) and b:Team() == tm and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
			--if b:SteamID() == "STEAM_0:0:157948422" or b:SteamID() == "STEAM_0:1:84996087" and b:Team() == 1 and b:GetPos():Distance(ply:GetPos()) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
				--print("a")
			end
		end
		return nearest
	end
end



hook.Add("StartNewRound","Bot_DisableAICauseBlind",function()
	--print("test")
	for a,b in pairs(player.GetAll()) do
		if IsValid( b ) then
			if b:Name() == "BOT Sniper" and b.Bot and b:HasWeapon("weapon_mu_magnum") then
				b:Say("Sniping's a good job mate!")
			end
			ply.DisableAIStop = CurTime()+11
			ply.DisableAIStart = CurTime()
			ply.DisableAI = true
		end
	end
end)

function Bot_Start(ply,cmd)
	--[[
		This is the code that runs your bot.
		This code is good due to the cmd parameter, and it only gets ran if the bot is still alive.
	]]	
	if ply.DisableAI == nil then ply.DisableAI = true end
	if ply.DisableAI then
		ply:SelectWeapon("weapon_mu_hands")
		ply.Target = nil
		ply.MagnumTarget = nil
		ply.DisableAIStart = ply.DisableAIStart or CurTime() or 0
		ply.DisableAIStop = ply.DisableAIStop or CurTime() or 0
		ply.StayAwayTarget = nil
		ply.MurdererStealth = CurTime()+math.random(30,60)
		if CurTime() > ply.DisableAIStop then
			ply.DisableAI = false
		end
	end
	
	if ply.Bot then
		ply:SetCustomCollisionCheck( true )
	else
		ply:SetCustomCollisionCheck( false )
	end
	
	if ply.Bot and SERVER and not ply.DisableAI and hook.Run( "GetRound" ) == 1 and IsValid( ply.FollowerEnt ) and ply.FollowerEnt:IsValid() and ply:Alive() then
		ply.DoNotJump = false
		
		ply.Intel = ply.Intel or math.random(40,100)
		ply.Accuracy = ply.Accuracy or math.random(20,30)
		
		LookAtFunc(ply,cmd)
		
		cmd:ClearButtons()
		
		ply.MagnumTimer = ply.MagnumTimer or 0
		ply.MagnumTimer = ply.MagnumTimer+1
		
		ply.CanBeInWater = false
		
		if ply:GetMurderer() then
			local plys = player.GetAll()
			if not ply.Target or not ply.Target:IsValid() or not ply.Target:Alive() or ply.Target == ply then
				ply.Target = plys[math.random(1,#plys)]
				ply.MurdererStealth = nil
			end
			ply.FakeMurderer = ply.FakeMurderer or plys[math.random(1,#plys)]
			--print(ply.Target:RealVisible())
			ply.MurdererStealth = ply.MurdererStealth or CurTime()+math.random(30,60)
			if ply.Target == ply then
				ply.Target = nil
				ply.MurdererStealth = CurTime()
			end
			
			if ply.FakeMurderer == ply then
				ply.FakeMurderer = nil
			end
			if CurTime() < ply.MurdererStealth then
				--[[
				if ply.FakeMurderer and IsValid(ply.FakeMurderer) and ply.SayMurderer then
					ply.SayMurderer = false
					timer.Simple(60,function()
						if ply and IsValid(ply) and ply:Alive() and ply.FakeMurderer and IsValid(ply.FakeMurderer) and ply.FakeMurderer:Alive() then
							ply:Say(ply.FakeMurderer:GetBystanderName().." is the murderer!")
							for a,b in pairs(player.GetAll()) do
								if IsValid(b) and math.random(1,100) < 50 and b.Intel and b.Intel < 70 and b.Target ~= ply then
									b.Target = ply.FakeMurderer
								end
							end
							
						end
					end)
				end
				]]
				ply:SelectWeapon("weapon_mu_hands")
				ply.WalkTime = ply.WalkTime or CurTime()+10
				for a,b in pairs(player.GetAll()) do
					if b and IsValid(b) and b.Target == ply and ply:BotVisible(b) then
						ply.MurdererStealth = 0
						ply.Target = b
						for a,b in pairs(plys) do
							if b and b:IsValid() and b:Alive() and b:IsPlayer() and b:BotVisible(ply) and !b.Bot then
								ply.Target = b
								ply.MurdererStealth = 0
							end
						end
					end
					
					if b and b:IsValid() then
						local active_weapon = b:GetActiveWeapon()
						if active_weapon and active_weapon:IsValid() and active_weapon:GetClass() == "weapon_mu_magnum" then
							ply.MurdererStealth = 0
							ply.Target = b
						end
					end
				end
				if CurTime() > ply.WalkTime then
					ply.FollowerEnt.PosGen = GetRandomWalkToSpot(ply,cmd)
					ply.WalkTime = nil
					ply.DoNotJump = false
					concommand.Run(ply,"mu_taunt",{"funny"})
				elseif ply.FollowerEnt.PosGen and ply.FollowerEnt.PosGen:Distance(ply:GetPos()) > 25 then
					PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
				else
					ply.DoNotJump = true
				end
			elseif ply.Target and ply:RealVisible(ply.Target) then
				local distance = ply.Target:GetPos():Distance(ply:GetPos())
				ply.FollowerEnt.PosGen = ply.Target:GetPos()
				PathFind(ply,cmd,ply.FollowerEnt.PosGen)
				local intel_math = ply.Intel/80
				if distance < 200 then
					ply:SelectWeapon("weapon_mu_knife")
					LookAt(ply,ply.Target)
					LookAtFunc(ply,cmd)
					cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK,IN_SPEED))
					ply.WalkTime = 0
					ply.CanBeInWater = true
				elseif distance > 3000*intel_math then
					cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_SPEED))
					ply:SelectWeapon("weapon_mu_hands")
				elseif distance < 600*intel_math then
					cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_SPEED))
					ply:SelectWeapon("weapon_mu_hands")
				else
					ply:SelectWeapon("weapon_mu_hands")
				end
				ply.DoNotJump = false
				cmd:SetForwardMove(1000)
			elseif ply.Target then
				ply:SelectWeapon("weapon_mu_hands")
				ply.FollowerEnt.PosGen = ply.Target:GetPos()
				PathFind(ply,cmd,ply.FollowerEnt.PosGen)
			else
				ply:SelectWeapon("weapon_mu_hands")
			end
			ply.CanSayGun = false
		elseif ply:HasWeapon("weapon_mu_magnum") then
			ply.CanSayGun = true
			ply.SayMurderer = true
			for a,b in pairs(player.GetAll() ) do
				if b and b:IsPlayer() and b:Alive() and ply:BotVisible(b) then
					local active_weapon = b:GetActiveWeapon()
					if active_weapon and active_weapon:IsValid() and active_weapon:GetClass() == "weapon_mu_knife" then
						ply.Target = b
					elseif b:GetMurdererRevealed() then
						ply.Target = b
					end
				end
			end
			
			for a,b in pairs(ents.FindByClass("mu_knife" )) do
				if b and ply and IsValid(b) and ply:BotVisible(b) and b:GetVelocity():Length() > 0.2 then
					ply.StayAwayTarget = b
				end
			end
			
			if ply.Target == ply then
				ply.Target = nil
			end
			--print("test",ply)
			if ply.StayAwayTarget and IsValid(ply.StayAwayTarget) and ply.StayAwayTarget:GetVelocity():Length() > 0.2 then
				local t1 = ply.StayAwayTarget:GetPos()
				local t2 = ply:GetShootPos()
				local LookAt = (t1 - t2):Angle() +  Angle(0,180,0)
				ply.LookAt = LookAt
				ply.CanBeInWater = true
				LookAtFunc(ply,cmd)
				cmd:SetForwardMove(1000)
				for a,b in pairs(player.GetAll()) do
					if b:GetMurderer() and ply:BotVisible(b) then
						ply.Target = b
					end
				end
			elseif ply.StayAwayTarget then
				ply.StayAwayTarget = nil
			elseif ply.Target and IsValid(ply.Target) and ply:BotVisible(ply.Target) then
				local distance = ply.Target:GetPos():Distance(ply:GetPos())
				ply:SelectWeapon("weapon_mu_magnum")
				
				ply.Accuracy = ply.Accuracy or 30
				ply.Intel = ply.Intel or 100
				local accuracy_math = ply.Accuracy/20
				local intel_math = ply.Intel/80
				
				ply.CanBeInWater = true
				
				local t1 = ply.Target:GetPos() + ply.Target:OBBCenter()
				local t2 = ply:GetShootPos()
				local t3 = Angle(math.random(-3,3) / accuracy_math,math.random(-3,3) / accuracy_math,0)
				--print(accuracy_math)
				
				local LookAt = (t1 - t2):Angle() + t3
				ply:SetEyeAngles(LookAt)
				cmd:SetViewAngles(LookAt)
				if ply.MagnumTimer > 20 then
					cmd:SetButtons(IN_ATTACK)
					ply.MagnumTimer = -5
				else
					cmd:SetButtons(IN_RELOAD)
				end
				local distance = ply.Target:GetPos():Distance(ply:GetPos())
				if distance < 500*intel_math then
					cmd:SetForwardMove( -1000 )
				elseif distance > 800*intel_math then
					cmd:SetForwardMove(1000)
					AddButtonToCMD(cmd,IN_WALK)
				else
					cmd:SetForwardMove( 0 )
					ply.DoNotJump = true
				end
			elseif ply.Target then
				ply:SelectWeapon("weapon_mu_magnum")
				cmd:SetButtons(IN_RELOAD)
				ply.FollowerEnt.PosGen = ply.Target:GetPos()
				PathFind(ply,cmd,ply.FollowerEnt.PosGen)
			else
				ply:SelectWeapon("weapon_mu_hands")
				
				
				ply.WalkTime = ply.WalkTime or CurTime()+10
			
				if IsValid( ply.Target ) and ply:BotVisible(ply.Target) then
					LookAt(ply,ply.Target)
					LookAtFunc(ply,cmd)
				elseif CurTime() > ply.WalkTime then
					ply.FollowerEnt.PosGen = GetRandomWalkToSpot(ply,cmd)
					ply.WalkTime = nil
					ply.DoNotJump = false
					concommand.Run(ply,"mu_taunt",{"funny"})
				elseif ply.FollowerEnt.PosGen and ply.FollowerEnt.PosGen:Distance(ply:GetPos()) > 25 then
					PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
				else
					ply.DoNotJump = true
				end
			end
		else
		
			if not IsValid(ply.MagnumTarget) then
				--[[
				-- Would bug out some times.
				for a,b in pairs(ents.FindByClass("mu_loot") ) do
					if IsValid(b) and ply:BotVisible(b) then
						ply.MagnumTarget = b
						--print(ply)
					end
				end
				]]
				
				
				
				for a,b in pairs(ents.FindByClass("weapon_mu_magnum") ) do
					if b and IsValid(b) and not IsValid(b.Owner) and ply:BotVisible(b) then
						ply.MagnumTarget = b
						if ply.CanSayGun then
							if math.random(1,100) < 25 then
								ply:Say("Gun! Give me!")
							end
							ply.CanSayGun = false
						end
					end
				end
			end
			
			for a,b in pairs(player.GetAll() ) do
				if b and b:IsPlayer() and b:Alive() and ply:BotVisible(b) then
					local active_weapon = b:GetActiveWeapon()
					if active_weapon and active_weapon:IsValid() and active_weapon:GetClass() == "weapon_mu_knife" then
						ply.Target = b
					end
				end
			end
			
			ply.WalkTime = ply.WalkTime or CurTime()+10
			--print(ply.WalkTime-CurTime())
			ply.DoNotJump = false
			
			if ply.SayMurderer == nil then
				ply.SayMurderer = true
			end
			
			if ply.Target and not IsValid(ply.Target) and ply.Target ~= ply then
				ply.Target = nil
			end
			
			if ply.Target == ply then
				ply.Target = nil
			end
			
			if ply.Target and IsValid(ply.Target) and ply:BotVisible(ply.Target) and ply.Target:GetPos():Distance(ply:GetPos()) < 500 then
				if ply.SayMurderer then
					ply.SayMurderer = false
					timer.Simple(5+math.random(2,4),function()
						if ply and IsValid(ply) and ply:Alive() and ply.Target and IsValid(ply.Target) then
							ply:Say(ply.Target:GetBystanderName().." is the murderer!")
							for a,b in pairs(player.GetAll()) do
								if IsValid(b) and math.random(1,100) < 50 then
									b.Target = ply.FakeMurderer
								end
							end
						end
					end)
				end
				
				--concommand.Run(ply,"mu_taunt",{"help"})
				
				LookAt(ply,ply.Target)
				LookAtFunc(ply,cmd)
				ply.CanBeInWater = true
				cmd:SetForwardMove(-1000)
			elseif ply.MagnumTarget and IsValid(ply.MagnumTarget) then
				if IsValid( ply.MagnumTarget.Owner ) then
					ply.MagnumTarget = NULL
				else
					ply.FollowerEnt.PosGen = ply.MagnumTarget:GetPos()
					ply.DoNotJump = false
					PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
					if ply:BotVisible(ply.MagnumTarget) then
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_USE))
						if ply:GetPos():Distance(ply.MagnumTarget:GetPos() ) < 100 then
							local t1 = ply.MagnumTarget:GetPos()
							local t2 = ply:GetShootPos()
							
							ply.DoNotJump = true
							
							cmd:SetForwardMove(1000)
							
							if (ply.MagnumTarget:GetPos() - Vector(0,0,0.1)).y < ply:GetPos().y then
								cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_DUCK))
							end
							
							ply:SetEyeAngles((t1-t2):Angle())
						else
							ply.FollowerEnt.PosGen = ply.MagnumTarget:GetPos()
							PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
						end
					else
						ply.FollowerEnt.PosGen = ply.MagnumTarget:GetPos()
						PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
					end
				end
			elseif ply.MagnumTarget then
				ply.WalkTime = CurTime()
				ply.FollowerEnt.PosGen = GetRandomWalkToSpot(ply,cmd)
				ply.MagnumTarget = nil
				ply.CanSayGun = true
			elseif CurTime() > ply.WalkTime then
				ply.FollowerEnt.PosGen = GetRandomWalkToSpot(ply,cmd)
				ply.WalkTime = nil
				ply.DoNotJump = false
			elseif ply.FollowerEnt.PosGen and ply.FollowerEnt.PosGen:Distance(ply:GetPos()) > 25 then
				PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
			else
				ply.DoNotJump = true
			end
		end
		
		if not ply.CanBeInWater and ply:WaterLevel() > 1 then
			ply:SetEyeAngles(Angle(0,0,0))
			cmd:SetForwardMove(1000)
			cmd:SetButtons(IN_JUMP)
			ply.WalkTime = 0
			ply.WaterTimer = ply.WaterTimer or 0
			ply.WaterTimer = ply.WaterTimer+1
			if ply.WaterTimer > 500 then
				if ply.SayWater then ply:Say("HELP! I'M DROWNING!") end
				if ply.WaterTimer > 1000 then
					ply:Kill() -- At this point the bot should be confirmed stuck.
				end
			end
		elseif not ply.CanBeInWater then
			ply.WaterTimer = 0
			ply.SayWater = true
		end
		
		if ply:GetMoveType() == MOVETYPE_LADDER then
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_JUMP))
		end
		
		--ply.LookAt = LookForPlayers(ply)
		
		if !ply.DoNotJump then
			Bot_CheckJump(ply,cmd)
		end
		OpenDoor(ply,cmd)
		Bot_CheckNavArea(ply,cmd)
	elseif ply.Bot and SERVER and ply:Alive() and not ply.DisableAI and not IsValid(ply.FollowerEnt) then
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt.Owner = ply
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt:Spawn()
	elseif IsValid( ply ) and ply.Bot and hook.Run( "GetRound" ) ~= 1 then
		ply.Target = nil
		ply.MagnumTarget = nil
		ply.DisableAIStop = CurTime()+11
		ply.DisableAIStart = CurTime()
		ply.DisableAI = true
		ply.CanSayGun = false
		ply.StayAwayTarget = nil
		ply.SayMurderer = true
		ply.FakeMurderer = nil
		cmd:SetButtons(IN_WALK)
	end
	--print(IsValid( ply )
end
hook.Add("StartCommand","Bot_Start",Bot_Start)

function Bot_Spawn(ply)
	if ply and ply.Bot then
		ply.Target = nil
		ply.LookAt = Angle(0,0,0)
	end
end
hook.Add("PlayerSpawn","Bot_Spawn",Bot_Spawn)