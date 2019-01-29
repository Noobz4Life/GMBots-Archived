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
			end
		end
	end)
else
	concommand.Add("gmbots_bot_add",function(  )
		if CLIENT then
			MsgC(Color( 0, 255, 64 ),"[GMBots] Sorry. But only the server can do that\n")
		end
	end)
end

function OpenDoor(ply,cmd)
	local ent = ply:GetEyeTrace().Entity
	local doorfuncs = {
		["func_door"] = ( ent:GetSaveTable().m_toggle_state == 1 ),
		["func_door_rotating"] = ( ent:GetSaveTable().m_toggle_state == 1 ),
		["prop_door_rotating"] = ( ent:GetSaveTable().m_eDoorState == 0 )
	}
	--print(doorfuncs[ent:GetClass()])
	if ent and ent:IsValid() and ent.IsDoor and ent:IsDoor() and doorfuncs[ent:GetClass()] then
		--print("open door")
		cmd:SetButtons(bit.bor( cmd:GetButtons(),IN_USE ))
		return true
	end
	return false
end

--[[
	GMBots by Noobz4Life
	Helped playtested by devthederp,and Av3r4ge.
	Pathfinding came from Blue Mustache(and yes I got permission.)
	
	Put Bot Code into Bot_Start function.
	
]]--

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )// Blue Mustache is credit 2 team
	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
	self:SetEyeAngles( Angle( pitch, yaw, 0 ) )
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


function Check_Visible(ply,target)
	return ply:BotVisible( target )
end

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
		for a,b in pairs(player.GetAll() ) do
			if b and b:IsPlayer() and b ~= ply and b:GetPos():Visible(ply:GetPos() ) and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

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

function PathFind(bot,cmd,pos)
	if bot and not pos then
		pos = bot.FollowerEnt.PosGen
	end
	if bot and bot.Bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() then
		cmd:ClearMovement()
		
		if bot.FollowerEnt:GetPos() ~= bot:GetPos() then
			bot.FollowerEnt:SetPos( bot:GetPos() )
		end
		--print(bot,"pathfind!")
		
		 bot.FollowerEnt.PosGen = pos or bot.PosGen or bot.FollowerEnt.PosGen or bot:GetPos()
			
		if bot and bot.FollowerEnt and bot.FollowerEnt:IsValid() and bot.FollowerEnt.P and bot.FollowerEnt.P:IsValid() then
			bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
		end
		if bot and bot.FollowerEnt and bot.FollowerEnt.P and bot.FollowerEnt.P:IsValid() and bot.CurSegment ~= 2 and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		
		if !bot.LastPath then return end
		local curgoal = bot.LastPath[bot.CurSegment]
		if !curgoal then return end
		cmd:SetForwardMove( 1000 )
		--print(bot:GetPos():Distance( curgoal.pos ),bot:IsLineOfSightClear(curgoal.pos))
		if bot:GetPos():Distance( curgoal.pos ) < 20 then
			bot.CurSegment = bot.CurSegment + 1
		else
			bot:LookatPosXY( cmd, curgoal.pos )
		end
	elseif bot and bot.Bot then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt.Owner = bot
		bot.FollowerEnt:Spawn()
	end
end

function Bot_CheckGround(ply)
	if ply then
		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = ply:GetPos() - Vector(0,1,0),
			filter = function( ent ) return ent == ply end
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
	if ply and cmd and ply:GetVelocity():Length() < 6 and Bot_CheckGround(ply) and !ply.DoNotJump and ply:WaterLevel() == 0 then
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

function Bot_GetHidingSpot(ply,cmd)
	return ply:GetHidingSpot()
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

function Bot_Start(ply,cmd)
	--[[
		This is the code that runs your bot.
		This code is good due to the cmd parameter, and it only gets ran if the bot is still alive.
	]]
	if ply.Bot and SERVER and ply.FollowerEnt and ply.FollowerEnt:IsValid() and ply:Alive() then
		if ply.DoNotJump then
			ply.DoNotJump = false
		end
		
		cmd:ClearButtons()
		
		ply.DoNotJump = true
		
		ply.LookAt = LookForPlayers(ply)
		
		if !ply.DoNotJump then
			Bot_CheckJump(ply,cmd)
		end
		TEAM_HIDING = TEAM_HIDING or 1
		TEAM_SEEKING = TEAM_SEEKING or 2
		if ply:Team() ~= TEAM_HIDING and ply:Team() ~= TEAM_SEEKING then
			--print(team.BestAutoJoinTeam())
			ply:SetTeam( team.BestAutoJoinTeam() )
		end
		
		if ply:Team() == TEAM_HIDING then
			if ply.ShouldAbility then
				ply.Spot = nil
				ply.SpotTimer = nil
			end
			if ply.RunAfter then
				local target = LookForPlayers(ply,cmd)
				if target and target:IsValid() then
					t1 = ply.Target:GetPos() + ply.Target:OBBCenter()
					t2 = ply:GetShootPos()
					local angle = ( t1 - t2 ):Angle()
					
					cmd:SetForwardMove(1000)
				end
			elseif ply.Spot then
				--ply:SetEyeAngles(ply.FollowerEnt:GetAngles())
				ply.SpotTimer = ply.SpotTimer or 0
				if CurTime() > ply.SpotTimer then
					ply.Spot = nil
					--print("spot timer")
				elseif ply:GetPos():Distance(ply.Spot) < 5 then
					if ply.SpotTimer-CurTime() > 5 then
						ply.SpotTimer = CurTime()+3
						--print("test")
					end
				else
					if ply.ShouldSit then
						cmd:ClearButtons()
						cmd:SetButtons(IN_DUCK)
					else
						PathFind(ply,cmd,ply.Spot)
						if ply.ShouldSprint then
							cmd:SetButtons(bit.bor(IN_SPEED,cmd:GetButtons()))
						end
					end
				end
			else
				ply.Spot = Bot_GetHidingSpot(ply,cmd)
				ply.SpotTimer = CurTime()+10
				ply.ShouldSit = false
				ply.ShouldSprint = false
				if math.random(0,100) <= 50 then
					ply.ShouldSprint = true
				else
					if math.random(0,100) <= 20 then
						ply.ShouldSit = true
					end
					ply.ShouldSprint = false
				end
			end
			if ply.ShouldAbility then
				local active_weapon = ply:GetActiveWeapon()
				if active_weapon and active_weapon:IsValid() then
					if active_weapon.Ability then
						local class = active_weapon:GetClass()
						if class == "weapon_gw_decoy" then
							for a,b in pairs(player.GetAll()) do
								if b.Target == ply then
									b.Target = nil
								end
							end
						elseif class == "weapon_gw_cloak" then
							for a,b in pairs(player.GetAll()) do
								if b.Target == ply then
									b.Target = nil
								end
							end
						elseif class == "weapon_gw_sudoku" then
							ply.RunAfter = true
						end
						active_weapon:SecondaryAttack()
					end
				end
			end
			cmd:SetButtons(bit.bor(IN_ATTACK2,cmd:GetButtons()))
			ply.ShouldSprint = true
			ply.ShouldAbility = false
			ply.SpotTimer = CurTime()+15
		elseif ply:Team() == TEAM_SEEKING and not ply:IsFrozen() then
			ply.TargetTimer = ply.TargetTimer or 0
			ply.ShouldAbility = false
			if ply.Target and ply.Target:IsValid() then
				ply.TargetTimer = CurTime()+math.random(3,10)
				ply:SelectWeapon("weapon_smg1")
				ply:SetAmmo(100,"smg1")
				cmd:SetButtons(bit.bor(IN_SPEED,cmd:GetButtons()))
				PathFind(ply,cmd,ply.Target:GetPos())
				
				if ply.Target:Visible(ply) and ply.Target:GetPos():Distance(ply:GetPos()) < 1000 then
					t1 = ply.Target:GetPos() + ply.Target:OBBCenter()
					t2 = ply:GetShootPos()
					local angle = ( t1 - t2 ):Angle()
					cmd:SetButtons(bit.bor(IN_ATTACK,cmd:GetButtons()))
					ply:SetEyeAngles( angle or Angle(0,0,0) )
				end
				
			elseif CurTime() > ply.TargetTimer then
				local player_chance = math.random(0,100)
				if player_chance < 10 then
					local targets = team.GetPlayers( TEAM_HIDING ) or {}
					ply.Target = table.Random(targets)
					if ply.Target:GetDisguised() then
						ply.Target = nil
					end
				else
					local pvs = ents.FindInPVS( ply ) or {}
					--PrintTable(pvs)
					local targets = {}
					for a,b in pairs(pvs) do
						if b:GetClass() == "npc_walker" then
							table.insert(targets,b)
						end
					end
					
					ply.Target = table.Random(targets)
				end
			else
				
			end
		end
		
		if ply.Target and ply.Target:IsValid() then
			if ply.Target:IsPlayer() and ply.Target:Team() == ply:Team() then
				ply.Target = nil
			end
			
			if ply.Target:IsPlayer() and !ply.Target:Alive() then
				ply.Target = nil
			end
		end
		
		LookAtFunc(ply,cmd)
	elseif ply.Bot and SERVER and ply:Alive() then
		if ply.FollowerEnt and ply.FollowerEnt:IsValid() then
			ply.FollowerEnt:Remove()
		end
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( ply )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt:Spawn()
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)


function Bot_DeathThink(ply)

	if ply and ply.Bot then
		ply.DeathFrames = ply.DeathFrames or 0
		ply.DeathFrames = ply.DeathFrames+1
		if ply.DeathFrames > 500 then
			ply.DeathFrames = nil
			return true
		end
	end
end
hook.Add("PlayerDeathThink","Bot_DeathThink",Bot_DeathThink)


function Bot_WrongNumber(target,dmginfo)
	print(dmginfo:GetAttacker())
	if dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and target and target:IsValid() and dmginfo:GetAttacker().Target == target then
		if !target:IsPlayer() then
			dmginfo:GetAttacker().Target = nil
		end
	end
	
	if dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():IsPlayer() and target and target:IsValid() and target:IsPlayer() and dmginfo:GetAttacker():Team() ~= target:Team() and target.Bot and target:Team() == TEAM_HIDING then 
		target.ShouldAbility = true
	end
end
hook.Add("EntityTakeDamage","Bot_WrongNumber",Bot_WrongNumber)
function Bot_RoundStart()
	print("round start")
	for a,b in pairs(player.GetAll()) do
		b.Target = nil
		b.ShouldAbility = false
		b.RunAfter = false
		b.TargetTimer = CurTime()
		b.Spot = nil
	end
end
hook.Add("GWPreGame","Bot_RoundStart",Bot_RoundStart)

hook.Add("GrabEarAnimation","Bot_Typing",function( ply )
	if ply.Bot then
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 1, FrameTime() * 5.0 )
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 0, FrameTime() * 5.0 )
		

		if ( ply.ChatGestureWeight > 0 ) then
		
			ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
			ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.ChatGestureWeight )
		
		end
	end
end)