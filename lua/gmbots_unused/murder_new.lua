//Base code for bots.

local BotNames = {"Bobby","Bob","Pyre","Pyro","Snooper","Sniper","Spy","Sphee"}
local BOTS = {}


if SERVER then
	concommand.Add("gmbots_bot_add",function()
		if SERVER then
			if(#player.GetAll() == game.MaxPlayers())then
				error("[GMBots] Server is full, cant spawn bot\n")
			else
				if ply and ply:IsValid() then return end
				
				local bot = player.CreateNextBot("BOT "..BotNames[math.random(#BotNames)])
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

function GetRandomWalkToSpot(rdm)
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
			return GetRandomWalkToSpot( true )
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

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )// Blue Mustache is credit 2 team
	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
	ply.LookAt = Angle( pitch, yaw, 0 )
	cmd:SetViewAngles( Angle( pitch, yaw, 0 ) )
end
--[[
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
			if b and b:IsPlayer() and b ~= ply and b:Visible(ply ) and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
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
		Instead of using vision cones, It uses ents.FindByClass and Vector:Visible( Vector )).
		This looks for the nearest visible player.
		
		You can modify this and the non-simple LookForPlayers to work with teams if you need too.
	]]
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		for a,b in pairs(ents.FindByClass("player") ) do
			if b and b:IsPlayer() and b ~= ply and b:GetPos():Visible(ply:GetPos() ) and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

function PathFind(bot,cmd,pos)
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
		bot:LookatPosXY( cmd, curgoal.pos )
		cmd:SetForwardMove( 200 )
		
		if bot:GetPos():Distance( curgoal.pos ) <= 20 then
			bot.CurSegment = bot.CurSegment + 1
		end
	elseif bot and bot.Bot then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( bot )
		bot.FollowerEnt:Spawn()
	end
end

function Bot_CheckGround(ply)
	if ply then
		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = ply:GetPos() - Vector(0,1,0),
			filter = function( ent ) 
				return ent == ply or ent:GetClass() == "sent_pathfinding"
			end
		} )
		return tr.Hit
	end
	return false
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
	print(cmd,...)
	if not cmd then return end
	if not ... then return end
	local args = { ... }
	local self = cmd
	for a,b in pairs(args) do
		print(type(b))
		if type( b ) == "int" or type(b) == "number" then
			self:SetButtons(bit.bor(self:GetButtons(),...))
		end
	end
end

function AddButtonToCMD( cmd,button)
	--if button and cmd and type(button) == "
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

function Bot_Jump( ply,cmd ) --NEVER use this function unless you have too. This is used by Bot_CheckJump.
	--ply:SetVelocity(Vector(0,0,300))
	cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_JUMP,IN_DUCK))
	--cmd:SetButtons(IN_DUCK)
	OpenDoor(ply,cmd)
	--print(cmd:GetButtons())
end

function Bot_CheckJump(ply,cmd)
	--print( Bot_CheckGround( ply ) )
	--print(ply,Bot_CheckGround( ply ))
	if ply and cmd and ply:GetVelocity():Length() < 3 and Bot_CheckGround(ply) and !ply.DoNotJump and ply:WaterLevel() == 0 then
		Bot_Jump(ply,cmd)
	elseif ply and cmd and Bot_CheckGround( ply ) then
		local navmesh = navmesh.GetNavArea( ply:GetPos(), 100 ) -- This get's the player's nav mesh.
		if navmesh and navmesh:HasAttributes( NAV_MESH_JUMP ) then -- This checks if the nav area is jumpable. and if the navmesh exists.
			Bot_Jump(ply,cmd)
		end
	end
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

function Bot_Start(ply,cmd)
	--[[
		This is the code that runs your bot.
		This code is good due to the cmd parameter, and it only gets ran if the bot is still alive.
	]]
	if ply.Bot and SERVER and ply.FollowerEnt and ply.FollowerEnt:IsValid() and ply:Alive() then
		ply.DoNotJump = false
		
		
		LookAtFunc(ply,cmd)
		
		cmd:ClearButtons()
		
		ply.MagnumTimer = ply.MagnumTimer or 0
		ply.MagnumTimer = ply.MagnumTimer+1
		
		
		if ply:GetMurderer() then
			local plys = player.GetAll()
			if not ply.Target or not ply.Target:IsValid() or not ply.Target:Alive() or ply.Target == ply then
				ply.Target = plys[math.random(1,#plys)]
			end
			--print(ply.Target)
			if ply.Target and ply.Target:Visible(ply) then
				ply:SelectWeapon("weapon_mu_knife")
				ply.FollowerEnt.PosGen = ply.Target:GetPos()
				LookAt(ply,ply.Target)
				PathFind(ply,cmd,ply.FollowerEnt.PosGen)
				cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK,IN_SPEED))
				cmd:SetForwardMove(1000)
			elseif ply.Target then
				ply:SelectWeapon("weapon_mu_hands")
				ply.FollowerEnt.PosGen = ply.Target:GetPos()
				PathFind(ply,cmd,ply.FollowerEnt.PosGen)
			else
				ply:SelectWeapon("weapon_mu_hands")
			end
		elseif ply:HasWeapon("weapon_mu_magnum") then
			for a,b in pairs(player.GetAll() ) do
				if b and b:IsPlayer() and b:Alive() then
					local active_weapon = b:GetActiveWeapon()
					if active_weapon and active_weapon:IsValid() and active_weapon:GetClass() == "weapon_mu_knife" then
						ply.Target = b
					end
				end
			end
			
			--print("test",ply)
			
			if ply.Target and ply.Target:Visible(ply) then
				
				ply:SelectWeapon("weapon_mu_magnum")
				LookAt(ply,ply.Target)
				cmd:SetViewAngles(ply.LookAt)
				cmd:SetForwardMove(-1000)
				if ply.MagnumTimer > 20 then
					cmd:SetButtons(IN_ATTACK)
				else
					cmd:SetButtons(IN_RELOAD)
				end
				
				if ply.Target:GetPos():Distance(ply:GetPos()) < 500 then
						cmd:SetForwardMove( -1000 )
					else
						cmd:SetForwardMove( 0 )
					end
			elseif ply.Target then
				ply:SelectWeapon("weapon_mu_hands")
				ply.FollowerEnt.PosGen = ply.Target:GetPos()
				PathFind(ply,cmd,ply.FollowerEnt.PosGen)
			else
				ply:SelectWeapon("weapon_mu_hands")
				
				ply.WalkTime = ply.WalkTime or CurTime()+10
			
				if CurTime() > ply.WalkTime then
					ply.FollowerEnt.PosGen = GetRandomWalkToSpot()
					ply.WalkTime = nil
					ply.DoNotJump = false
				elseif ply.FollowerEnt.PosGen and ply.FollowerEnt.PosGen:Distance(ply:GetPos()) > 25 then
					PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
				else
					ply.DoNotJump = true
				end
			end
		else
			ply.WalkTime = ply.WalkTime or CurTime()+10
			--print(ply.WalkTime-CurTime())
			ply.DoNotJump = false
			if CurTime() > ply.WalkTime then
				ply.FollowerEnt.PosGen = GetRandomWalkToSpot()
				ply.WalkTime = nil
				ply.DoNotJump = false
			elseif ply.FollowerEnt.PosGen and ply.FollowerEnt.PosGen:Distance(ply:GetPos()) > 25 then
				PathFind(ply,cmd,ply.FollowerEnt.PosGen or Vector(0,0,0))
			else
				ply.DoNotJump = true
			end
		end
		
		
		
		--ply.LookAt = LookForPlayers(ply)
		
		if !ply.DoNotJump then
			Bot_CheckJump(ply,cmd)
		end
		Bot_CheckNavArea(ply,cmd)
	elseif ply.Bot and SERVER and ply:Alive() then
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( ply )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt:Spawn()
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)


function Bot_NoCollide(ply,ply2)
	if ply:IsPlayer() and ply2:IsPlayer() and ply.Bot and ply2.Bot then
		return false
	end
end
hook.Add("ShouldCollide","Bot_NoCollide", Bot_NoCollide )

function Bot_Spawn(ply)
	if ply and ply.Bot then
		ply.Target = nil
		ply.LookAt = Angle(0,0,0)
	end
end
hook.Add("PlayerSpawn","Bot_Spawn",Bot_Spawn)