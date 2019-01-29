// This script was made for testing visual things, since before it was using the Entity:Visible( Entity ) function.

local BotNames = {"Bobby","Bob","Pyre","Pyro","Snooper","Sniper","Spy","Sphee"}
local BOTS = {}

local Sight = {
	distance = 768,
	angle = 60
}


if SERVER then
	concommand.Add("gmbots_bot_add",function()
		if SERVER then
			if(#player.GetAll() == game.MaxPlayers())then
				error("[GMBots] Server is full, cant spawn bot\n")
			else
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
DEBUG_MODE = true
debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )// Blue Mustache is credit 2 team
	if not DEBUG_MODE then
		local our_position = self:GetPos()
		local distance = our_position:Distance( pos )
	
		local pitch = math.atan2( -(pos.z - our_position.z), distance )
		local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
		self:SetEyeAngles( Angle( pitch, yaw, 0 ) )
		cmd:SetViewAngles( Angle( pitch, yaw, 0 ) )
	else
		local angle = ( pos - self:GetPos() ):Angle()
		
		self:SetEyeAngles( angle )
		cmd:SetViewAngles( angle )
	end
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
		
		
		local ent = player.GetAll()
		for a,b in pairs(ent) do
			if b and b:IsPlayer() and b ~= ply and Check_Visible(ply,b) and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

function LookForProps(ply)
	--[[
		This is a simple verison of LookForPlayers.
		Instead of using vision cones, It uses ents.FindByClass and Vector:Visible( Vector )).
		This looks for the nearest visible player.
		
		You can modify this and the non-simple LookForPlayers to work with teams if you need too.
	]]
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		
		
		local ent = ents.FindByClass("prop_physics")
		for a,b in pairs(ent) do
			if b and b ~= ply and Check_Visible(ply,b) and b:GetPos():Distance(ply:GetPos() ) < lastdist then
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
		
		bot.FollowerEnt.PosGen = Entity( 1 ):GetPos()
			
		if bot.FollowerEnt.P and IsValid( bot.FollowerEnt.P ) then
			bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
		end
		if bot.FollowerEnt.P and IsValid( bot.FollowerEnt.P ) and bot.CurSegment ~= 2 and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		if !bot.LastPath then
			return
		end
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

function Bot_Jump( ply,cmd ) --NEVER use this function unless you have too. This is used by Bot_CheckJump.
	--ply:SetVelocity(Vector(0,0,300))
	print("test")
	cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_JUMP,IN_DUCK))
	--cmd:SetButtons(IN_DUCK)
	OpenDoor(ply,cmd)
	--print(cmd:GetButtons())
end

function Bot_CheckGround(ply)
	if ply then
		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = ply:GetPos() - Vector(0,10,0),
			filter = function( ent ) return ent == ply end
		} )
		return tr.Hit
	end
	return false
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

function Bot_Start(ply,cmd)
	--[[
		This is the code that runs your bot.
		This code is good due to the cmd parameter, and it only gets ran if the bot is still alive.
	]]
	if ply.Bot and SERVER and ply.FollowerEnt and ply:Alive() then
		if ply.DoNotJump then
			ply.DoNotJump = false
		end
		
		cmd:ClearButtons()
		
		--ply.DoNotJump = true
		
		local lookat = LookForPlayers(ply)
		
		
		if ply and lookat then
			t1 = lookat:GetPos() + lookat:OBBCenter() + lookat:OBBCenter()
			t2 = ply:GetShootPos()


			--ply:SetEyeAngles((t1 - t2):Angle())
		end
		
		PathFind(ply,cmd,Entity(1):GetPos())
		Bot_CheckJump(ply,cmd)
	elseif ply.Bot and SERVER and !ply.FollowerEnt and ply:Alive() then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( ply )
		bot.FollowerEnt:SetPos(ply:GetPos())
		bot.FollowerEnt:Spawn()
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)


function Bot_DeathThink(ply)

	if ply and ply.Bot then
		ply.DeathFrames = ply.DeathFrames or 0
		ply.DeathFrames = ply.DeathFrames+1
		if ply.DeathFrames > 500 then
			ply.DeathFrames = nil
			ply:Spawn()
			return true
		end
	end
end
hook.Add("PlayerDeathThink","Bot_DeathThink",Bot_DeathThink)