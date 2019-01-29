-- This file contains functions like IsDoor and Pathfind.
CreateConVar("gmbots_pathfind_proto",0)
CreateConVar("gmbots_debug_mode",0)



function player.CreateGMBot( name ) -- This should work the same as CreateNextBot, but will do some extra stuff.
	if SERVER then
		if(#player.GetAll() == game.MaxPlayers())then
			error("[GMBots] Server is full, cant spawn bot\n")
		else
		
			local bot = player.CreateNextBot(name)
			pcall(function()
				bot.Bot = true
				bot.IsGMBot = true
				
				bot.FollowerEnt = ents.Create("sent_pathfinding")
				bot.FollowerEnt:SetOwner( bot )
				bot.FollowerEnt:Spawn()
				
				if not navmesh.IsGenerating() then
					local nodes = navmesh.GetAllNavAreas()
					if #nodes <= 0 then
						local trace = {
							filter = function(ent)
								if ent and ent:IsValid() and not ent:IsWorld() then
									return true
								end
							end,
							start = bot:GetPos(),
							endpos = bot:GetPos() + ( bot:GetAngles():Up() * -50000 )
						}
					
						bot:Spawn()
						navmesh.AddWalkableSeed(endpos,Angle(0,0,0))
						navmesh.BeginGeneration()
					end
				else
					bot:Kick("Generating a nav mesh")
				end
			end)
			
			return bot
		end
	end
end

function player.GetGMBotName()
	local names = BOTNames or BotNames or {
		"Alpha",
		"Bravo",
		"Charlie",
		"Delta",
		"Echo",
		"Foxtrot",
		"Golf",
		"Hotel",
		"India",
		"Julliet",
		"Kilo",
		"Lima",
		"Miko",
		"Matt",
		"November",
		"Oscar",
		"Papa",
		"Quebec",
		"Romeo",
		"Sierra",
		"Tango",
		"Uniform",
		"Victor",
		"Whiskey",
		"X-ray",
		"Yankee",
		"Zulu"
	}
	local name = nil
	local name_id = 1
				
				
	for a,b in pairs(player.GetAll()) do
		if names[name_id] and b:Name() == "BOT "..names[name_id] then
			name_id = name_id+1
		end
		if name_id > #names then
			name = "#"..tostring( math.random(1,math.random(300,100000)) )
			-- If you still get a duplicate names, congrats, you got something super rare!
		end
	end
	if name == nil then name = names[name_id] end
	return name
end

concommand.Add("gmbots_bot_add",function(ply)
	if ( ply and ply:IsValid() and not ply:IsAdmin() ) then return end
	local name = player.GetGMBotName()
	local bot = player.CreateGMBot("BOT "..name)
	-- It used to be that you had to make your own command, now all you have to do is use this hook to set values.
	if bot and bot:IsValid() then
		bot.Bot = true -- This will be used to check if a Player is a Bot or not.
		bot.GMBot = true -- This should never be set, as this will say whether a bot is a actual bot or not.
		bot:Debug("Added.")
		hook.Run( "GMBotsBotAdded",bot )
	end
end)


local plymeta = FindMetaTable( "Player" )

function plymeta:BotJump(cmd,fr)
	local ply = self
	ply.LBJ = ply.LBJ or 0 -- LBJ stands for "Last Bot Jump"
	if fr then -- I can't remember what FR even stands for.
		ply.LBJ = 0
	end
	if ply.DoNotJump then ply.DoNotJump = false return end
	if ply and ply:IsValid() and cmd and CurTime() > ply.LBJ then
		cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_JUMP,IN_DUCK))
		self:Debug("Jumping...")
		local DivideAmount = math.random(100,200) -- This will try to prevent bots getting stuck on each other.
		ply.LBJ = CurTime() + ply:GetJumpPower()/DivideAmount -- This should (hopefully) give them enough time to land.
	end
end

function plymeta:Debug(msg,color,iserror)
	if not SERVER then return end
	if not self then return end
	if self and not self:IsValid() then return end
	if self and self:IsValid() and not self.Bot then return end
	if self and self:IsValid() and not self:IsPlayer() then return end
	local start_text = "GMBots Debug, "
	if iserror then
		start_text = "[ERROR] GMBots Error, "
	end
	if (GetConVar("gmbots_debug_mode"):GetInt() < 1) then return end
	MsgC( color or Color( 0, 255, 255 ), start_text, self:Name(),":   ", msg, "\n" )
end

function plymeta:GetAllHidingSpots()
	if not self.NavHidingSpots then
		local navareas = navmesh.GetAllNavAreas
		local navhiding = {}
		if #navareas > 0 then
			for i = 1,#navareas do
				local areahiding = navareas[i]:GetHidingSpots()
				if #areahiding > 0 then
					for o = 1,#areahiding do
						table.insert(navhiding,areahiding[o])
					end
				end
			end
		end
		if #navhiding > 0 then
			self.NavHidingSpots = navhiding
		end
	end
	return self.NavHidingSpots or {}
end

function plymeta:GetHidingSpotInVC(hidingspots)
	local allhiding = allhiding or self:GetAllHidingSpots() or {}
	if #allhiding > 0 then
		local validhiding = {}
		for i = 1,#allhiding do
			local curhide = allhiding[i]
			if curhide and self:BotVisible(curhide) then
				table.insert(validhiding,curhide)
			end
		end
		if #validhiding > 0 then
			self:Debug("Found hiding spot in Visual Cone. Using first one found.")
			return validhiding[1]
		else
			self:Debug("Couldn't find hiding spot in Visual Cone. Defaulting to first hiding spot.")
			return allhiding[1]
		end
	end
	self:Debug("There is no hiding spots on the map, defaulting to 0 0 0.")
	return Vector(0,0,0)
end

function plymeta:RunFromPlayer(cmd,ply)
	if not ply then return end
	if ply and not ply:IsValid() then return end
	if ply and ply:IsValid() and not ply:IsPlayer() then return end
	if not cmd then return end
	
	local allhidingspots = self:GetAllHidingSpots()
	if #allhidingspots > 0 then
		local hidingspot = ply:GetHidingSpotInVC(hidingspots)
		if hidingspot then
			self:PathFind(cmd,hidingspot or allhidingspots[1],false)
		end
	else
		self:Debug("Can't run due to no hiding spots in Nav Mesh.")
	end
end

function plymeta:Error(msg)
	return self:Debug(msg,Color(255,0,0),true)
end

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos ,viewonly )// Blue Mustache is credit 2 team
	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
	local ang = Angle( pitch, yaw, 0 )
	
	if not viewonly then
		local lerpang = LerpAngle(0.15,self:EyeAngles(),ang)
		self:SetEyeAngles( lerpang )
	end
	cmd:SetViewAngles( ang )
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

function plymeta:BreakWindows(cmd)
	local ply = self
	local eyetrace = self:GetEyeTrace().Entity
	
	local windows = {
		["func_breakable_surf"] = true,
		["func_breakable"] = true,
		["prop_physics"] = true,
		["prop_physics_multiplayer"] = true
	}
	if eyetrace and eyetrace:IsValid() and windows[eyetrace:GetClass()] then
		cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
		--print("test",eyetrace,cmd:GetButtons(),IN_ATTACK)
	end
end

function plymeta:BotCheckGround()
	local ply = self
	if ply then
		ply.inAir = not ply:OnGround()
		return ply:OnGround()
	end
	return false
end

function plymeta:BotSay(msg,teamonly,cooldown,time,time_mul)
	self.MessageCooldown = self.MessageCooldown or 0
	if CurTime() > self.MessageCooldown then
		msg = msg or "No message."
		local time_to_type = string.len(msg)/7 * (time_mul or 1)
		local function sayGMBotMessage()
			pcall(function()
				self:Say(msg,teamonly)
				self:Debug("Saying message: "..msg)
			end)
		end
		if time then
			timer.Simple(time_to_type,function()
				sayGMBotMessage()
			end)
		else
			sayGMBotMessage()
		end
		self.MessageCooldown = CurTime() + ( cooldown or 2 )
	end
end

function plymeta:BotAttack(cmd,target,offset,spurts)
	if cmd and self and self:IsValid() and target and target:IsValid() then
		if self:BotVisible(target) then
			self:LookAtEntity(target,offset)
			local shouldattack = true
			if spurts then
				self.NextAttackSpurt = self.NextAttackSpurt or 0
				if CurTime() >= self.NextAttackSpurt then
					shouldattack = true
					self.NextAttackSpurt = CurTime()+0.5
					self:Debug("FIRE!")
				else
					shouldattack = false
				end
			end
			if shouldattack then
				cmd:SetButtons(bit.bor( cmd:GetButtons(),IN_ATTACK ))
			end
		else
			self:Pathfind(cmd,target:GetPos(),false)
		end
	end
end

function plymeta:BotFollow(cmd,target)
	if cmd and target then
		if self:Visible(target) then
			self:LookAtEntity(target)
			local dist = self:GetPos():Distance(target:GetPos())
			if dist > 160 then
				self:BotCheckJump(cmd)
				cmd:SetForwardMove(200)
			elseif dist < 130 then
				cmd:SetForwardMove(-200)
			end
		else
			self:PathFind(cmd,target:GetPos(),true)
		end
	end
end

function plymeta:BotWander(cmd)
	self.WanderSpot = self.WanderSpot or self:GetHidingSpot() or self:GetPos()
	self.WanderTime = self.WanderTime or CurTime()+math.random(10,30)
	local dist = self.WanderSpot:Distance(self:GetPos())
	if dist > 20 then
		self:Pathfind(cmd,self.WanderSpot,true)
		self:BotCheckJump(cmd)
	else
		self.LBJ = CurTime()+3
		if not self.WanderReached then
			self:Debug("Reached wander spot.")
			self.WanderReached = true
		end
	end
	if CurTime() > self.WanderTime then
		self.WanderTime = nil
		self.WanderSpot = nil
		self.WanderReached = false
	end
end

function plymeta:BotCheckJump(cmd)
	local ply = self
	local onground = ply:BotCheckGround()
	if ply and cmd and ply:GetVelocity():Length() < 6 and onground and !ply.DoNotJump and ply:WaterLevel() < 3 then
		ply:BotJump(cmd)
	elseif ply and cmd and onground then
		local navmesh = navmesh.GetNavArea( ply:GetPos(), 100 ) -- This get's the player's nav mesh.
		if navmesh and navmesh:HasAttributes( NAV_MESH_JUMP ) then -- This checks if the nav area is jumpable. and if the navmesh exists.
			ply:BotJump(cmd)
		end
	end
	
	if not onground then
		ply:BotJump(cmd)
	end
end

function plymeta:LookAtEntity(ent,offset)
	if not ent then return end
	if not ent:IsValid() then return end
	if not self then return end
	if not self:IsValid() then return end
	
	local eyepos = self:EyePos()
	local pos = ent:GetPos() + ent:OBBCenter()
	local offset = offset or Vector(0,0,0)
	local angle = (pos - eyepos + offset):Angle()
	
	self:SetEyeAngles(angle)
end

function plymeta:LookAtLerp(cmd,pos,ratio,visualonly)
	local start = self:EyeAngles()
	
	local eyepos = self:EyePos()
	
	local endang = (pos - eyepos):Angle()
	
	local lerped = LerpAngle(ratio or 0.5,start,endang)
	self:SetEyeAngles(lerped)
	if visualonly then
		cmd:SetViewAngles(endang)
	else
		cmd:SetViewAngles(lerped)
	end
end

function plymeta:LookAtPos(pos)
	if not pos then return end
	if not self then return end
	if not self:IsValid() then return end
	
	local eyepos = self:EyePos()
	pos = pos or Vector(0,0,0)
	local angle = (pos - eyepos):Angle()
	
	self:SetEyeAngles(angle)
end

function plymeta:OpenDoors(cmd)
	local ply = self
	if ply and ply:IsValid() then
		local ent = ply:GetEyeTrace().Entity
		if cmd and ent and ent:IsValid() and ent:IsDoor() and not ent:IsDoorOpen() then
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_USE))
		end
	end
	return false
end

function plymeta:LookForPlayers(teams)
	local ply = self
	if ply and ply.Bot and SERVER then
		lastdist = 100000000
		nearest = nil
		local allplayers = player.GetAll()
		if #allplayers > 0 then
			for i = 1,#allplayers do
				local b = allplayers[i]
				if b and b:IsPlayer() and b ~= ply and ply:BotVisible(b) then
					local cont = true
					if teams then
						if b:Team() == ply:Team() then
							cont = false
						end
					end
					if cont then
						local dist = b:GetPos():Distance(ply:GetPos() )
						if dist < lastdist then
							lastdist = dist
							nearest =  b
						end
					end
				end
			end
		else
			ply:Debug("This should never happen. (If it does, look at the LookingForPlayers function.)")
		end
		return nearest
	end
end

function plymeta:OpenDoor(cmd)
	return self:OpenDoors(cmd)
end

function plymeta:AddButtonToCMD(cmd,button)
	return cmd:SetButtons(bit.bor(cmd:GetButtons(),button))
end

function plymeta:HandleNMAreas(cmd)
	local ply = self
	if ply then
		local navmesh = navmesh.GetNavArea( ply:GetPos(), 100 )
		if navmesh and IsValid(navmesh) then
			if navmesh:HasAttributes( NAV_MESH_RUN  ) then
				ply:AddButtonToCMD( cmd, IN_SPEED )
				self:Debug("Running in NAV_MESH_RUN.")
			end
			if navmesh:HasAttributes( NAV_MESH_JUMP ) and Bot_CheckGround( ply ) and !ply.DoNotJump then
				ply:BotJump( ply, cmd )
				self:Debug("Jumping in NAV_MESH_JUMP.")
			end
			if navmesh:HasAttributes( NAV_MESH_WALK ) then
				ply:AddButtonToCMD( cmd, IN_WALK )
				self:Debug("Walking in NAV_MESH_WALK.")
			end
			if navmesh:HasAttributes( NAV_MESH_CROUCH ) then
				ply:AddButtonToCMD( cmd, IN_DUCK )
				self:Debug("Crouching in NAV_MESH_CROUCH.")
			end
			if navmesh:HasAttributes( NAV_MESH_STAIRS ) then
				ply.DoNotJump = true
				self:Debug("Don't jump in NAV_MESH_STAIRS.")
			end
			if navmesh:HasAttributes( NAV_MESH_NO_JUMP ) then
				ply.DoNotJump = true
				self:Debug("Don't jump in NAV_MESH_NO_JUMP.")
			end
		end
	end
end

function plymeta:GetHidingSpot()
	local pos = self:WorldSpaceCenter()
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

function plymeta:PathfindWithNodes(cmd,pos,slow) -- Do not use.
	if not AmountOfNodes then
		AmountOfNodes = {}
	end
	
	local bot = self
	local ply = self
	
	pos = pos or ply.PosGen or ply:GetPos()
	
	if AmountOfNodes[game.GetMap()] then
		if #AmountOfNodes <= 0 then
			self:Debug("Nodes failed. Revert to default pathfinding.")
			--return self:Pathfind(cmd,pos,slow,true) -- If there is no nodes, then go back to default pathfinding.
		end
	else
		AmountOfNodes[game.GetMap()] = ents.FindByClass("info_node")
	end
	
	local function ray2positions(pos1,pos2)
		return false
	end
	
	--[[
	local start_node = nil
	local last_start_dist = 10000000
	
	local end_node = nil
	local last_end_dist = last_start_dist

	
	for i = 1,#AmountOfNodes do
		local node = AmountOfNodes[i]
		local startdist = node:GetPos():Distance(self:GetPos())
		if node and node:Visible(self) and dstartist < last_start_dist then
			start_node = node
			last_start_dist = startdist
		end
		
		if ray2positions(node:GetPos(),pos) then
			local enddist = node:GetPos():Distance(pos:GetPos())
			if enddist < last_end_dist then
				end_node = node
				last_end_dist = dist
			end
		end
	end
	
	if start_node and end_node then -- Both nodes exist, start generating path.
		local node_path = {start_node}
		local last_node = start_node
		local last_node_dist = 10000000
		for i = 1,#AmountOfNodes do
			local node = AmountOfNodes[i]
			if node ~= start_node and node ~= end_node and node:Visible(last_node) then
				table.insert(node_path,node)
				last_node = node
			end
		end
	end
	]]
	local last_node_dist_ply = 0
	local last_node_dist_pos = 100000000
	local nextnode = nil
	for i = 1,#AmountOfNodes do
		local node = AmountOfNodes[i]
		local node_dist_to_player = ply:GetPos():Distance(node:GetPos())
		if node and node:IsValid() and node:Visible(ply) and node_dist_to_player > last_node_dist_ply then
			local node_dist_to_pos = pos:Distance(node:GetPos())
			if node_dist_to_pos < last_node_dist_pos then
				last_node_dist_ply = node_dist_to_player
				last_node_dist_pos = node_dist_to_pos
				nextnode = node
			end
		end
	end
	if nextnode then
		cmd:SetForwardMove( 200 )
		if ray2positions(( ply:GetPos() + ply:OBBCenter() ) , pos) then
			ply:LookAtPosXY(cmd,pos)
		else
			ply:LookAtPosXY(cmd,nextnode:GetPos())
		end
	else
		--return self:Pathfind(cmd,pos,slow,true) -- If we couldn't find a next node, then return to default pathfinding.
		self:Debug("Nodes failed. Revert to default pathfinding.")
	end
end



function plymeta:PathfindProtoType(cmd,pos,slow)
	return self:Pathfind(cmd,pos,slow,true)
end

function plymeta:AvoidDirection() -- This used to do what HL2 npcs do, but it's changed now.
	return
end

function plymeta:PathfindAvoid(cmd) -- Basically, antistuck attempt.
	self.PFLastPath = self.PFLastPath or CurTime()
	if self.PFLastPath+5 < CurTime() then
		self.PathfindAvoidTimer = CurTime()+5
		self.ShouldAvoidPF = false
		return
	end
	self.PFLastPath = CurTime()
	
	self.PathfindAvoidTimer = self.PathfindAvoidTimer or CurTime()+5
	self.LastPFPosition = self.LastPFPosition or self:GetPos()
	
	if CurTime() > self.PathfindAvoidTimer then
		self.ShouldAvoidPF = false
		self.LastPFPosition = self.LastPFPosition or self:GetPos()
		self.PathfindAvoidTimer = CurTime()+math.random(5,15)
		if self.LastPFPosition:Distance(self:GetPos()) < 200 then
			self.ShouldAvoidPF = true
			self.PathfindAvoidTimer = CurTime()+5
			self:Debug("Attempting to backup in pathfinding...")
		end
	elseif self.ShouldAvoidPF then
		cmd:ClearButtons()
		cmd:ClearMovement()
		self:SetEyeAngles(Angle(0,0,0))
		cmd:SetForwardMove(-200)
	end
end

function plymeta:Pathfind(cmd,pos,slow,dontuseproto)
	if not dontuseproto then
		if GetConVar("gmbots_pathfind_proto"):GetInt() > 0 then
			return self:PathfindProtoType(cmd,pos,slow)
			--print("pathfind with nodes")
		end
	end
	local bot = self
	local ply = self
	if ply and not ply.FollowerEnt or ply and not ply.FollowerEnt:IsValid() then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( bot )
		bot.FollowerEnt:SetPos(bot:GetPos())
		bot.FollowerEnt:Spawn()
	end
	
	pos = pos or ply.PosGen or ply:GetPos()
	
	cmd = cmd

	
	if bot and cmd and bot.Bot and pos and bot.FollowerEnt and bot.FollowerEnt:IsValid() then
		--self:PathfindAvoid(cmd)
		if bot.ShouldAvoidPF then
			bot.ShouldAvoidPF = false
			return
		end
		cmd:ClearMovement()
		--cmd:ClearButtons()
		if bot.FollowerEnt:GetPos() ~= bot:GetPos() then
			bot.FollowerEnt:SetPos( bot:GetPos() )
		end
		
		self:BreakWindows(cmd)
		self:OpenDoors(cmd)
		
		
		bot.FollowerEnt.PosGen = pos
		
		if ply:WaterLevel() == 3 then
			ply:Debug("My pathfinding may bug out due to being in water.")
		end
			
		if bot.FollowerEnt.P then
			bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
		end
		if bot.CurSegment ~= 2 and bot.FollowerEnt.P and !table.EqualValues( bot.LastPath, bot.FollowerEnt.P:GetAllSegments() ) then
			bot.CurSegment = 2
		end
		
		if !bot.LastPath then return end
		local curgoal = bot.LastPath[bot.CurSegment]
		local nextgoal = bot.LastPath[bot.CurSegment + 1]
		if !curgoal then return end
		cmd:SetForwardMove( 200 )
		
		if not ply:BotCheckGround() then
			ply:AddButtonToCMD(cmd,IN_DUCK)
		end
		
		if nextgoal then
			local ngp = nextgoal.pos
			local cgp = ply:GetPos()
			--print(ngp.z,cgp.z + ply:GetStepSize())
			if ngp and cgp and ngp.z and cgp.z and ngp.z >= ( cgp.z + ply:GetStepSize()*2 ) then
				self:BotJump(cmd)
				--print("bot jump")
			else
				bot:BotCheckJump(cmd)
			end
		end
		self:BreakWindows(cmd)
		local dist = bot:GetPos():Distance( curgoal.pos )
		if dist <= 20 then
			bot.CurSegment = bot.CurSegment + 1
		end
		local vel_length = ply:GetVelocity():Length()
		if dist > vel_length/10 then
			bot:LookatPosXY( cmd, curgoal.pos )
		end
		
		local posdist = bot:GetPos():Distance( pos )
		if slow and posdist < 300 then
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_WALK))
		end
	end
end

if SERVER then
	plymeta.RealVisible = plymeta.Visible -- I used RealVisible since before BotVisible would override Visible, this is so that I don't have to update everything.
	
	plymeta.BotVisible = function(self,target)
		local ply = self
		self.RealVisible = self.RealVisible
		if self and target and IsValid(self) and IsValid(target) and self:Visible(target) then
			--[[
			-- Old function. This was removed due to if you weren't looking at them, it would count as them not being able to see you, and sometimes the opposite.
			local aim_vector = self:GetAimVector() or Vector(0,0,0)
			dist_vector = Vector(0,0,0)
			if target:IsPlayer() then
				dist_vector = self:GetAimVector() - target:GetAimVector()
			else
				dist_vector = self:GetAimVector() - target:GetAngles():Forward()
			end
			local dot_product = dist_vector:GetNormalized()
			
			local av = aim_vector:Dot(dot_product or Vector(0,0,0))
			if av > 0.8 then
				return true
			end
			]]
			local target_pos = Vector(0,0,0)
			if target and target:IsValid() and isvector( target ) then
				target_pos = target
			else
				target_pos = target:GetPos()
			end
			local eye_pos = self:EyePos()
			
			local eyeToTarget = (target_pos - eye_pos):GetNormalized()
			local degreeLimit = self:GetFOV() -- We use this incase this is a Player-Bot instead of a Real Bot.
			local dotProduct = eyeToTarget:Dot(self:EyeAngles():Forward()) 
			local aimDegree = math.deg(math.acos(dotProduct)) 
			if (aimDegree >= degreeLimit) then
				-- They're not on the player's screen, return false.
				return false
			else
				-- They're on the player's screen, return true.
				return true
			end
		end
		
		return false
	end
end

plymeta.PathFind = plymeta.Pathfind




local entmeta = FindMetaTable("Entity")
function entmeta:IsDoor()
	if self and self:IsValid() then
		local classes = {
			["func_door_rotating"] = true,
			["func_door"] = true,
			["prop_door_rotating"] = true,
		}
		local class = self:GetClass()
		if class and classes and classes[class] then
			return true
		end
	end
	return false
end

function entmeta:IsPhysicsProp()
	if self and self:IsValid() then
		local classes = {
			["prop_physics"] = true,
			["prop_physics_multiplayer"] = true
		}
		local class = self:GetClass()
		if class and classes and classes[class] then
			return true
		end
	end
	return false
end

function entmeta:IsDoorOpen()
	if self and self:IsValid() and self:IsDoor() then
		local doorfuncs = {
			["func_door"] = ( self:GetSaveTable().m_toggle_state == 0 ),
			["func_door_rotating"] = ( self:GetSaveTable().m_toggle_state == 0 ),
			["prop_door_rotating"] = ( self:GetSaveTable().m_eDoorState == 1 )
		}
		local class = self:GetClass()
		if class and doorfuncs and doorfuncs[class] then
			return true
		end
	end
	return false
end

function entmeta:IsDoorOpened()
	return self:IsDoorOpen()
end

function entmeta:IsProp()
	return self:IsPhysicsProp()
end