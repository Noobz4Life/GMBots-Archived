//Base code for bots.

local BotNames = {"Hunter","Prop","Bobby","Botty","Tire","RPG","Tree","Three","Pyro","Wood","T-Pose","Kleiner"}
local BOTS = {}


if SERVER then
	--[[
	concommand.Add("gmbots_bot_add",function(ply)
		if SERVER and ((not ply or not ply:IsValid()) or ply:IsSuperAdmin()) then
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
	]]
	
	hook.Add("GMBotsBotAdded","GamemodeBotAdded",function(bot)
		pcall(function()
			bot.Bot = true
			bot.RPAttack = false
			bot.prevPos = Vector(0, 0, 0)
		end)
	end)
	
	concommand.Add("gmbots_add_propspot",function(ply,cmd,args,argsString)
		if not SERVER then return end
		--if not ply:IsSuperAdmin() then return end
		
		if not file.IsDir("gmbots","DATA") then
			file.CreateDir("gmbots","DATA")
		end
		
		if not file.IsDir("gmbots/ph_spots","DATA") then
			file.CreateDir("gmbots/ph_spots","DATA")
		end
		
		if not file.IsDir("gmbots/ph_spots/"..game.GetMap(),"DATA") then
			file.CreateDir("gmbots/ph_spots/"..game.GetMap(),"DATA")
		end
		AddNewPropSpot(ply,cmd,args,argsString)
	end)
else
	concommand.Add("gmbots_bot_add",function(  )
		if CLIENT then
			MsgC(Color( 0, 255, 64 ),"[GMBots] Sorry. But only admins can do that.\n")
		end
	end)
end

function AddNewPropSpot(ply,cmd,args,argsString)
	if not SERVER then return end
	if not ply then return end
	if not ply:IsValid() then return end
	local chs = "gmbots/ph_spots/"..game.GetMap().."/spot"..(#file.Find( "gmbots/ph_spots/"..game.GetMap().."/*.txt", "DATA" )+1)..".txt"
	local data = {}
	--print(chs)
	data.Position = ply:GetPos()
	data.Creator = ply:SteamID()
	data.CreatorName = ply:Name()
	data.PropModel = args[1]
	if data.PropModel ~= nil and type(data.PropModel) ~= "string" then
		data.PropModel = nil
	end
	if not file.Exists( chs , "DATA" ) then
		file.Write( chs ,util.TableToJSON( data ) )
	end
end

function OpenDoor(ply,cmd)
	local ent = ply:GetEyeTrace().Entity
	if ent and ent:IsValid() and ent:IsDoor() and not ent:IsDoorOpen() then
		cmd:SetButtons(bit.bor( cmd:GetButtons(),IN_USE ))
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

function AddButtonsToCMD( cmd,... ) -- Just makes things easier, you probably shouldn't use this though due to how it works.
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

function LookForProps(ply)
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		for a,b in pairs(ents.FindByClass("ph_prop") ) do
			--print("hi",b:Team() == tm)
			local vis = ply:BotVisible(b)
			if b and b ~= ply and ply:BotVisible(b) and b:GetPos():Distance(ply:GetPos() ) < lastdist then
			--if b:SteamID() == "STEAM_0:0:157948422" or b:SteamID() == "STEAM_0:1:84996087" and b:Team() == 1 and b:GetPos():Distance(ply:GetPos()) < lastdist thenlastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

function LookForPlayers(ply,tm)
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		if tm == 2 then
			return LookForProps(ply)
		end
		for a,b in pairs(ents.FindByClass("player") ) do
			--print("hi",b:Team() == tm)
			local vis = ply:BotVisible(b)
			if b and b:IsPlayer() and b ~= ply and ply:BotVisible(b) and b:Team() == tm and b:GetPos():Distance(ply:GetPos() ) < lastdist then
			--if b:SteamID() == "STEAM_0:0:157948422" or b:SteamID() == "STEAM_0:1:84996087" and b:Team() == 1 and b:GetPos():Distance(ply:GetPos()) < lastdist thenlastdist = b:GetPos():Distance(ply:GetPos() )
				--print(b)
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
	return bot:PathFind(cmd,pos)
	
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
		local nextgoal = bot.LastPath[bot.CurSegment+1]
		if !curgoal then return end
		cmd:SetForwardMove( 200 )
		if nextgoal then
			local ngp = nextgoal.pos
			local cgp = curgoal.pos
			if ngp and cgp and ngp.z and cgp.z and ngp.z > cgp.z+ply:GetStepSize() then
				Bot_Jump(ply,cmd)
				--print("test")
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
	
	if ply and ply:IsValid() then
		ply.inAir = not ply:IsOnGround()
		return ply:IsOnGround()
	end
	
	return false
end

function LookAt(ply,ent)
	if ply and ply:IsValid() and ent and ent:IsValid() then
		t1 = ent:GetPos() + ent:OBBCenter()
		t2 = ply:GetShootPos()

		--ply:SetEyeAngles( ( t1 - t2 ):Angle() )
		ply.LookAt = (t1 - t2):Angle()
	end
end

function LookAtFunc( ply, cmd )
		if ply.LookAt and ply.LookAt.p and ply.LookAt.y and Bot_CheckGround(ply,cmd) then
			local angle = ply.LookAt
			angle.p = math.NormalizeAngle(angle.p)
            angle.y = math.NormalizeAngle(angle.y)
			
			ply:SetEyeAngles(Lerp(0.05, cmd:GetViewAngles(), angle))
			
			if GetConVar("gmbots_debug_mode"):GetInt() > 0 then
				ply:SetEyeAngles(ply.LookAt)
			end
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

function Bot_Jump( ply,cmd )
	OpenDoor(ply,cmd)
	if ply and ply:IsValid() and cmd then
		cmd:SetButtons(bit.bor( IN_JUMP,IN_DUCK))
	end
end

function Bot_CheckJump(ply,cmd)
	--print( Bot_CheckGround( ply ) )
	--print(ply,Bot_CheckGround( ply ))
	if ply and cmd and ply:GetVelocity():Length() < 6 and Bot_CheckGround(ply) and !ply.DoNotJump and ply:WaterLevel() == 0 then
		Bot_Jump(ply,cmd)
	elseif ply and cmd and Bot_CheckGround( ply ) then
		local navmesh = navmesh.GetNavArea( ply:GetPos(), 100 ) -- This get's the player's nav mesh.
		if navmesh and navmesh:HasAttributes( NAV_MESH_JUMP ) then -- This checks if the nav area is jumpable. and if the navmesh exists.
			ply.ShouldJump = true
		end
	end
end

function Bot_FRP()
	local tbl = {}
	for a,b in pairs(ents.FindByClass("prop_*")) do
		--print(b:GetClass())
		if b and b:IsValid() and (b:GetClass() == "prop_physics" or b:GetClass() == "prop_physics_multiplayer") then
			table.insert(tbl,1,b)
		end
	end
	if tbl then
		return tbl[math.random(1,#tbl)]
	end
	return nil
end

function Bot_NavMeshHidingSpot(ply,cmd)
	local pos = ply:WorldSpaceCenter()
	local radius = 15000
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

function Bot_FRPM(mdl)
	local tbl = {}
	for a,b in pairs(ents.FindByClass("prop_*")) do
		--print(b:GetModel(),mdl)
		if b and b:IsValid() and (b:GetClass() == "prop_physics" or b:GetClass() == "prop_physics_multiplayer") and b:GetModel() == mdl then
			table.insert(tbl,1,b)
		end
	end
	if tbl then
		local prop = tbl[math.random(1,#tbl)]
		--print(prop)
		return prop
	end
	return nil
end

function Bot_GetPropHidingSpot(ply,cmd)
	local spots = {}
	files,direct = file.Find( "gmbots/ph_spots/"..game.GetMap().."/*.txt", "DATA" )
	if files and #files > 0 then
		for i = 1,#files do
			b = "gmbots/ph_spots/"..game.GetMap().."/"..files[i]
			if b and files[i] then 
				local data = util.JSONToTable( file.Read(b) )
				table.insert(spots,data)
			end
		end
	end
	if ply and ply:Team() == 1 and spots and #spots > 0 then
		for a,b in pairs(spots) do
			for c,d in pairs(player.GetAll()) do
				--print(d.TargetProp,b.PropModel)
				if d and d:IsValid() and d.TargetProp and d.TargetProp:IsValid() and d.PropSpot == b.Position then
					table.remove(spots,a)
				end
			end
		end
	end
	local spot = table.Random(spots)
	if spot then
		ply.TargetProp = Bot_FRPM(spot.PropModel) or ply.TargetProp
		ply.PropSpot = spot.Position or ply.PropSpot
		return spot.Position,spot.PropModel
	end
	return Bot_NavMeshHidingSpot(ply,cmd)
end

function Bot_GetHidingSpot(ply,cmd)
	if file.IsDir("gmbots/ph_spots","DATA") then
		return Bot_GetPropHidingSpot(ply,cmd)
	end
	return Bot_NavMeshHidingSpot(ply,cmd)
end

function Bot_GetVisiblePlayers(ply)
	local plys = {}
	for a,b in pairs(player.GetAll()) do
		if b and b:IsValid() and b:BotVisible(ply) then
			table.insert(plys,1,b)
		end
	end
	return plys
end

function Bot_GetVisiblePropsAndPlayers(ply)
	--(b:GetClass() == "prop_physics" or b:GetClass() == "prop_physics_multiplayer")
	local plys = {}
	for a,b in pairs(player.GetAll()) do
		if b and b:IsValid() and ply:Visible(b) and (b:GetClass() == "prop_physics" or b:GetClass() == "prop_physics_multiplayer" or b:IsPlayer() and ( b:Team() ~= ply:Team() or b:Team() ~= 1 and b:Team() ~= 2  )) then
			table.insert(plys,1,b)
		end
	end
	return plys
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

function LookAtPosInstant(ply,pos)
	if ply and ply:IsValid() and pos and type(pos) == "Vector" then
		t1 = pos
		t2 = ply:GetShootPos()

		ply:SetEyeAngles( ( t1 - t2 ):Angle() )
	end
end

function Bot_Start(ply,cmd)
	--[[
		This is the code that runs your bot.
		This code is good due to the cmd parameter, and it only gets ran if the bot is still alive.
	]]
	if ply.Bot and SERVER and ply.FollowerEnt and ply:Alive() then
	
	
		ply.StuckTimer = ply.StuckTimer or CurTime()
		if CurTime() >= ply.StuckTimer and !ply.DoNotJump then
			ply.StuckSpot = ply.StuckSpot or Vector(math.huge,math.huge,math.huge)
			ply.StuckTimer = CurTime()+3
			ply.LastPF = ply.LastPF or math.huge
			local cur_pos = ply:GetPos()
			-- This is so that it will detect the bot is stuck even if they're jumping.
			local stuck_spot = Vector(ply.StuckSpot.x,ply.StuckSpot.y,0)
			local cur_spot = Vector(cur_pos.x,cur_pos.y,0)
			if CurTime()-ply.LastPF < 0.3 then
				if cur_spot:Distance(stuck_spot) < 100 and not ply.IsHiding then
					Bot_Unstuck(ply,cmd)
				end
			end
			ply.StuckSpot = ply:GetPos()
		end
	
	
	
	
		ply.DoNotJump = false
		
		
		cmd:ClearButtons()
		
		ply:SetCustomCollisionCheck( true )
		ply.IsHiding = false
		if ply:Team() == 2 and ply.ph_prop and ply.ph_prop:IsValid() then
			local prop = ply.ph_prop
			if ply.TargetProp and ply.TargetProp:IsValid() then
				--print(ply.TargetProp:GetModel())
				
				if prop:GetModel() ~= ply.TargetProp:GetModel() then
					PathFind(ply,cmd,ply.TargetProp:GetPos())
					if ply:RealVisible(ply.TargetProp) then
						LookAt(ply,ply.TargetProp)
						if prop:GetPos():Distance(ply.TargetProp:GetPos()) < 100 then
							local gm = gmod.GetGamemode()
							if gm and gm.PlayerUse then
								gm:PlayerUse(ply,ply.TargetProp)
							end
						end
					end
				else
					--print(ply.PropSpot:Distance(prop:GetPos()))
					if ply.PropSpot and type(ply.PropSpot) == "Vector" then
						local dist = ply.PropSpot:Distance(prop:GetPos())
						if dist < 100 then
							cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_DUCK))
							ply.DoNotJump = false
						end
						if dist <= 15 then
							ply.DoNotJump = true
							ply.IsHiding = true
						else
							PathFind(ply,cmd,ply.PropSpot)
						end
					else
						ply.PropSpot = ply.PropSpot or Bot_GetHidingSpot(ply,cmd)
					end
				end
			else
				ply.TargetProp = Bot_FRP()
				Bot_GetHidingSpot(ply,cmd)
			end
			ply.HuntTarget = nil
		elseif ply:Team() == 1 and !ply:IsFrozen() then
			ply.TargetProp = nil
			ply.PropSpot = nil
			--ply.DoNotJump = true
			if ply.HuntTarget and ply.HuntTarget:IsValid() then
				local prop = ply.HuntTarget.ph_prop
				if ply.HuntTarget:IsPhysicsProp() then
					prop = ply.HuntTarget
				end
				if !prop or !prop:IsValid() then
					prop = ply.HuntTarget
				end
				if prop and prop:IsValid() then
					if ply:Visible(prop) then
						PathFind(ply,cmd,ply.HuntTarget:GetPos())
						LookAtPosInstant(ply,prop:GetPos() + prop:OBBCenter())
						ply.LastSight = CurTime()
						local smg = ply:GetWeapon("weapon_smg1")
						if smg and smg:IsValid() then
							if smg:HasAmmo() then
								ply:SelectWeapon("weapon_smg1")
								if smg:Clip1() <= 0 then
									cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_RELOAD))
								else
									cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
								end
							else
								ply:SelectWeapon("weapon_crowbar")
								cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
							end
						else
							ply:SelectWeapon("weapon_crowbar")
							cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
						end
					else
						ply.LastSight = ply.LastSight or CurTime()
						PathFind(ply,cmd,ply.HuntTarget:GetPos())
						if CurTime() >= ply.LastSight+10 then
							ply.HuntTarget = nil
						end
					end
				end
				if ply.HuntTarget and ply.HuntTarget:IsValid() and ply.HuntTarget:IsPlayer() and ( !ply.HuntTarget:Alive() or ply.HuntTarget:Team() == ply:Team() or ( ply.HuntTarget:Team() ~= 1 and ply.HuntTarget:Team() ~= 2 ) ) then
					ply.HuntTarget = nil
					ply.LookTimer = CurTime()+3
				end
			else
				--print("Test2")
				ply.HuntTarget = nil
				ply.LookTimer = ply.LookTimer or CurTime()
				if CurTime() >= ply.LookTimer then
					ply.LookTimer = CurTime()+10
					ply.HuntTarget = table.Random(Bot_GetVisiblePropsAndPlayers(ply))
					ply.WalkToSpot = nil
					ply.LastSight = CurTime()
				else
					ply.WalkToSpot = ply.WalkToSpot or Bot_GetHidingSpot(ply,cmd)
					PathFind(ply,cmd,ply.WalkToSpot)
					if ply.WalkToSpot:Distance(ply:GetPos()) < 20 then
						ply.WalkToSpot = nil
						ply.LookTimer = CurTime()
					end
				end
				
				
				for a,b in pairs(Bot_GetVisiblePlayers(ply)) do
					if b and b:IsValid() and b:Alive() and b:Team() == 2 and ( b:KeyDown( IN_FORWARD ) or b:KeyDown( IN_MOVELEFT ) or b:KeyDown( IN_BACK ) or b:KeyDown( IN_MOVERIGHT ) or b:KeyDown( IN_JUMP ) or b.ph_prop and b.ph_prop:IsValid() and b.ph_prop:GetModel() == "models/player/kleiner.mdl" ) then
						ply.HuntTarget = b
						ply.LastSight = CurTime()
					end
				end
				cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_RELOAD))
			end
		elseif ply:Team() == 1 then
			ply.HuntTarget = nil
			ply.LookTimer = CurTime()+1
			ply.WalkToSpot = nil
		end
		
		LookAtFunc(ply,cmd)
		ply.LastCheckJump = ply.LastCheckJump or CurTime()
		if !ply.DoNotJump and CurTime() > ply.LastCheckJump+1 then
			Bot_CheckJump(ply,cmd)
			ply.LastCheckJump = CurTime()
		end
		
		if ply.inAir then
			Bot_CheckGround(ply,cmd)
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_DUCK))
		end
	elseif ply.Bot and SERVER and !ply.FollowerEnt and ply:Alive() then
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( ply )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt:Spawn()
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)

function Bot_NoCollide(ply,ply2)
	if ply and ply2 and IsValid(ply) and IsValid(ply2) and ply:IsPlayer() and ply2:IsPlayer() and ply.Bot and ply2.Bot then
		return false
	end
	
	--print(ply,ply2,ply2:GetClass(),ply1:GetClass())
	if ply and ply2 and ply:IsValid() and ply2:IsValid() and ply:GetClass() == "ph_prop" and ply2:GetClass() == "ph_prop" and ply.Owner and ply2.Owner and ply.Owner:IsValid() and ply2.Owner:IsValid() and ply.Owner:SteamID() == "BOT" and ply2.Owner:SteamID() == "BOT" then
		return false
	end
	
	
	if ply and ply2 and ply:IsValid() and ply2:IsValid() and (ply:IsDoor() and ply:IsDoorOpen() and ply2.Bot or ply2:IsDoor() and ply2:IsDoorOpen() and ply.Bot) then
		return false
	end
end
hook.Add("ShouldCollide","Bot_NoCollide", Bot_NoCollide )

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
	if target and target:IsValid() and target:IsPhysicsProp() and dmginfo and dmginfo:GetAttacker() and dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker().HuntTarget == target then
		dmginfo:GetAttacker().HuntTarget = nil
	end
end
hook.Add("EntityTakeDamage","Bot_WrongNumber",Bot_WrongNumber)