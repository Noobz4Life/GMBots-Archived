
--[[
	This is only here incase anyone wants the see the old code, or optimize the old code.
]]

if not GMBots then GMBots = {} end
if not BOTS then BOTS = {} end
GMBots.dist = CreateConVar("gmbots_mu_distance",5000)
concommand.Remove("gmbots_bot_add")

local CHECKDIST = 10

local DBotNames = {
	"Joseph",	"Ophelia",	"Winifred",	"Julee",	"Verlie",	"Carolyne",	"Tinisha",	"Monroe",	"Chase",	"Louella",	"Margareta",	"Vern",	"Rigoberto",	"Kiley",	"Verla",	"Edgardo",	"Gabriel",	"Dollie",	"Alberta",	"Filiberto",	"Mei",	"Noel",	"Lorna",	"Darrel",	"Son",	"Deidra",	"Leda",	"Madelene",	"Lissa",	"Katina",	"Herta",	"Joana",	"Kelli",	"Robbyn",	"Yuko",	"Clair",	"Eliseo",	"Catrina",	"Bethany",	"Ghislaine",	"Floretta",	"Allegra",	"Zola", "Garry","Ursula","Francisca","Clint","Essie","Chas","Viola",
}

BotNames = DBotNames

if not file.Exists("gmbots/murder_names.txt","DATA") then
	file.CreateDir( "gmbots" )
	file.Write( "gmbots/murder_names.txt", string.Implode( "\n", DBotNames ) )
	timer.Simple(1,function()
		print("Written file gmbots/murder_names.txt")
	end)
else
	BotNames = string.Explode( "\n",file.Read("gmbots/murder_names.txt","DATA") )
	--print(botnames)
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

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )// Blue Mustache is credit 2 team
	local our_position = self:GetPos()
	local distance = our_position:Distance( pos )
	
	local pitch = math.atan2( -(pos.z - our_position.z), distance )
	local yaw = math.deg(math.atan2(pos.y - our_position.y, pos.x - our_position.x))
	
	self:SetEyeAngles( Angle( pitch, yaw, 0 ) )
	cmd:SetViewAngles( Angle( pitch, yaw, 0 ) )
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

function MU_PathFind(ply,cmd,pos)
	PathFind(ply,cmd,pos)
end

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
		AddNewCheckSpot(ply,cmd,args,argsString)
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

function MU_OpenDoor(ply,cmd)
	if ply:GetEyeTrace().Entity:GetClass() == "prop_door" or ply:GetEyeTrace().Entity:GetClass() == "func_door" or ply:GetEyeTrace().Entity:GetClass() == "prop_door_rotating" or ply:GetEyeTrace().Entity:GetClass() == "func_door_rotating" then
		local eyetrace = ply:GetEyeTrace().Entity
		if eyetrace:GetPos():Distance( ply:GetPos() ) <= 100 and IsDoorOpened( eyetrace ) then
			cmd:SetButtons(IN_USE)
			return true
		end
	end
	return false
end

// 0 not enough players
// 1 playing
// 2 round ended, about to restart
// 4 waiting for map switch

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

function GetRandomWalkToSpot()
	local spots = {}
	local spot = Vector(0,0,0)
	if SERVER and file.IsDir("gmbots/walkto_spots/"..game.GetMap(),"DATA") then
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
			return GetRandomWalkToSpot()
		end
	elseif SERVER then
		for i = 1,math.random(500,5000) do
			table.insert(spots, Vector(math.random(-10000,10000),math.random(-10000,10000),math.random(-10000,10000) ) )
		end
	end
	spot = spots[math.random(1,#spots)]
	return spot
end


function MU_Start(ply,cmd)
	--print("hi")
	--print(cmd)
	if ply and ply:IsValid() and ply.Bot == true and SERVER and ply:Alive() and ply.FollowerEnt and hook.Run( "GetRound" ) == 1 and !ply:IsFrozen() and ply.FollowerEnt ~= nil then
		--print("is bot")
		if ply.DoNotJump then
			ply.DoNotJump = false
		end
		--print(ply:GetPos().Y+1)
		cmd:ClearButtons()
		--if ply:GetEyeTrace().Entity:GetClass() == "func_door" or ply:GetEyeTrace().Entity:GetClass() == "prop_door" or ply:GetEyeTrace().Entity:GetClass() == "func_door_rotationg" or ply:GetEyeTrace().Entity:GetClass() == "prop_door_rotating" then
			--cmd:SetButtons(IN_USE)
		--end
		--MU_OpenDoor(ply)

		if ply.FollowerEnt:IsValid() and ply.FollowerEnt:GetPos():Distance( ply:GetPos() ) > 500 then
			ply.FollowerEnt.PosGen = ply:GetPos()
		end
		--[[
		if ply.stuck == true then
			--MU_BotJump(ply)
			cmd:SetButtons(IN_DUCK)
		else
			cmd:ClearButtons()
		end
		]]
		
		--MU_CheckIdle( ply )

		if ply:HasWeapon("weapon_mu_magnum") then
			ply.RanBystanderCode = true
			if ply.ScaredOf == ply then
				local target = player.GetAll()[math.random(1,#player.GetAll())]
				ply.ScaredOf = target
			elseif ply.ScaredOf:IsValid() and !ply.ScaredOf:Alive() then
				local target = player.GetAll()[math.random(1,#player.GetAll())]
				ply.ScaredOf = target
			end
			for a,b in pairs(ents.FindInSphere(ply:GetPos(),5000)) do
				if b:IsPlayer() and b:GetActiveWeapon():IsValid() and b:GetActiveWeapon():GetClass() == "weapon_mu_knife" and b:Visible(ply) then
					--print("is player")
					cmd:ClearButtons()
					t1 = b:GetPos() + b:OBBCenter() + Vector(0,0,5)
					t2 = ply:GetShootPos()
					ply:SelectWeapon("weapon_mu_magnum")
					ply.ScaredOf = b

					cmd:SetButtons(IN_ATTACK)
					--cmd:ClearButtons()
					if b:GetPos():Distance(ply:GetPos()) < 500 then
						cmd:SetForwardMove( -1000 )
					else
						cmd:SetForwardMove( 0 )
					end
					if ply:KeyDown(IN_ATTACK) then
						cmd:SetButtons(0)
					end
					t3 = Angle(math.random(1,4),math.random(1,4),math.random(1,4))
					--print(t3)

					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif b:IsPlayer() and b:IsValid() and b:Visible(ply) and ply.ScaredOf == b then
					cmd:ClearButtons()
					t1 = b:GetPos() + b:OBBCenter() + Vector(0,0,5)
					t2 = ply:GetShootPos()
					ply:SelectWeapon("weapon_mu_magnum")
					ply.ScaredOf = b

					cmd:SetButtons(IN_ATTACK)
					--cmd:ClearButtons()
					cmd:SetForwardMove( -1000 )
					if ply:KeyDown(IN_ATTACK) then
						cmd:SetButtons(0)
					end
					t3 = Angle(math.random(1,4),math.random(1,4),math.random(1,4))
					--print(t3)

					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif b:IsPlayer() and b:IsValid() and !b:Visible(ply) and ply.ScaredOf == b then
					cmd:ClearButtons()
					--MU_PathFind(ply,cmd)
					ply.FollowerEnt.PosGen = ply.ScaredOf:GetPos()
					--print(ply.FollowerEnt:GetPos())
					--print(ply:GetPos())
					if ply:GetEyeTrace().Entity:IsValid() and ply:GetEyeTrace().Entity:GetClass() == "func_breakable_surf" then
						cmd:SetButtons(IN_ATTACK)
					end
					ply:SelectWeapon("weapon_mu_magnum")
					cmd:SetButtons(0)
					cmd:SetForwardMove( 1000 )
				elseif b:IsPlayer() and b:IsValid() and b:IsValid() and ply.ScaredOf ~= b and ply:Visible(b) and b:GetMurdererRevealed() then
					cmd:ClearButtons()
					t1 = b:GetPos() + b:OBBCenter() + Vector(0,0,5)
					t2 = ply:GetShootPos()
					ply:SelectWeapon("weapon_mu_magnum")
					ply.ScaredOf = b

					cmd:SetButtons(IN_ATTACK)
					--cmd:ClearButtons()
					cmd:SetForwardMove( -1000 )
					if ply:KeyDown(IN_ATTACK) then
						cmd:SetButtons(0)
					end
					t3 = Angle(math.random(1,4),math.random(1,4),math.random(1,4))
					--print(t3)

					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif b:IsPlayer() and b:KeyDown(IN_SPEED) and b:GetRunSpeed() >= 310 then
					cmd:ClearButtons()
					t1 = b:GetPos() + b:OBBCenter() + Vector(0,0,5)
					t2 = ply:GetShootPos()
					ply:SelectWeapon("weapon_mu_magnum")
					ply.ScaredOf = b

					cmd:SetButtons(IN_ATTACK)
					--cmd:ClearButtons()
					if b:GetPos():Distance(ply:GetPos()) < 500 then
						cmd:SetForwardMove( -1000 )
					else
						cmd:SetForwardMove( 0 )
					end
					if ply:KeyDown(IN_ATTACK) then
						cmd:SetButtons(0)
					end
					t3 = Angle(math.random(1,4),math.random(1,4),math.random(1,4))
					--print(t3)

					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif ply.can_random_pos then
					ply.FollowerEnt.PosGen = ply:GetPos()+Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))
					MU_PathFind(ply,cmd,ply.FollowerEnt.PosGen)
					ply.can_random_pos = false
					timer.Simple(10,function()
						ply.can_random_pos = true
					end)
				elseif ply.can_random_pos == nil then
					ply.can_random_pos = true
				end
			end
		elseif ply:HasWeapon( "weapon_mu_knife" ) then
			--print("has knife")
			--print(ply.ScaredOf)
			--print(target)
			ply.RanBystanderCode = true

			if !ply.ScaredOf:IsValid() then
				local target = player.GetAll()[math.random(1,#player.GetAll())]
				if target ~= ply then
					ply.ScaredOf = target
				end
			end
			
			ply:ConCommand("mu_taunt funny")
			for a,b in pairs(ents.FindInSphere(ply:GetPos(),5000)) do
				if b and b:IsPlayer() and b:Alive() and b != ply and b:Visible(ply) and ply and ply.ScaredOf ~= nil and ply.ScaredOf ~= b and b:GetActiveWeapon():GetClass() == "weapon_mu_magnum" then
					ply.ScaredOf = b
					ply:ConCommand("mu_taunt funny")
				elseif b:IsPlayer() and b ~= ply and b:Visible(ply) and b:Alive() and ply.ScaredOf:IsValid() and b:Alive() and ply.ScaredOf:IsValid() and ply.ScaredOf:Alive() then
					cmd:ClearButtons()
					t1 = ply.ScaredOf:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					--print(ply:GetPos())
					ply:SelectWeapon("weapon_mu_knife")
					--print(ply.ScaredOf)
					--print( "Y:"..b:GetPos().Y )
					cmd:SetButtons(IN_SPEED)
					cmd:SetButtons(IN_ATTACK,IN_SPEED)
					cmd:SetForwardMove( 1000 )

					ply:SetEyeAngles( ( t1 - t2 ):Angle() )
				elseif b:IsValid() and b ~= ply and b:IsPlayer() and b == ply.ScaredOf and !b:Visible(ply) and b:Alive() and ply.ScaredOf:IsValid() and ply.ScaredOf:Alive() then
					cmd:ClearButtons()
					MU_PathFind(ply,cmd)
					ply.FollowerEnt.PosGen = ply.ScaredOf:GetPos()
					ply:SelectWeapon("weapon_mu_hands")
					--print(ply.ScaredOf:GetPos())
					--print("Not Visible")
					--print(ply:GetPos())
					cmd:SetButtons(0)
					cmd:SetButtons(IN_ATTACK)
					cmd:SetForwardMove( 1000 )

				elseif b:IsPlayer() and b:GetActiveWeapon():IsValid() and b ~= ply and b:GetActiveWeapon():GetClass() == "weapon_mu_magnum" and b:Visible(ply) and ply.ScaredOf:IsValid() then
					cmd:ClearButtons()
					t1 = ply.ScaredOf:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					ply:SelectWeapon("weapon_mu_knife")
					cmd:SetButtons(IN_SPEED)
					cmd:SetButtons(IN_ATTACK,IN_SPEED)
					cmd:SetForwardMove( 1000 )

					ply:SetEyeAngles( ( t1 - t2 ):Angle() )
				elseif b:IsPlayer() and b ~= ply and b:GetActiveWeapon():IsValid() and b:Visible(ply) and !ply.ScaredOf:IsValid() and ply.ScaredOf ~= ply then
					--print("is player")
					cmd:ClearButtons()
					local target = player.GetAll()[math.random(1,#player.GetAll())]
					if target ~= ply then
						ply.ScaredOf = target
					end
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					ply:SelectWeapon("weapon_mu_knife")
					cmd:SetButtons(IN_SPEED)
					cmd:SetButtons(IN_ATTACK,IN_SPEED)
					cmd:SetForwardMove( 1000 )



					ply:SetEyeAngles( ( t1 - t2 ):Angle() )
				else
					if ply.ScaredOf == ply then
						local target = player.GetAll()[math.random(1,#player.GetAll())]
						ply.ScaredOf = target
					elseif ply.ScaredOf:IsValid() and !ply.ScaredOf:Alive() then
						local target = player.GetAll()[math.random(1,#player.GetAll())]
						ply.ScaredOf = target
					end
				end
			end
		else
			ply.RanBystanderCode = false
			for a,b in pairs(ents.FindInSphere(ply:GetPos(),5000)) do
				if b:GetClass() == "weapon_mu_magnum" and b ~= ply and !b:GetOwner():IsValid() and b:Visible(ply) then

					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					cmd:SetButtons(IN_SPEED)
					cmd:SetForwardMove( 1000 )

					ply:SetEyeAngles( ( t1 - t2 ):Angle() )
					ply.RanBystanderCode = true
				elseif b:GetClass() == "weapon_mu_magnum" and b ~= ply and !b:GetOwner():IsValid() and !b:Visible(ply) then
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					MU_PathFind(ply,cmd)
					--print("weapon_mu_magnum PLEASE")
					ply.DoNotJump = false
					ply.FollowerEnt.PosGen = b:GetPos()
					cmd:SetButtons(IN_SPEED)
					--cmd:SetForwardMove( 1000 )
					ply.RanBystanderCode = true
					--ply:SetEyeAngles( ( t1 - t2 ):Angle() )
				elseif b:IsPlayer() and b ~= ply and b:GetActiveWeapon():IsValid() and b:GetActiveWeapon():GetClass() == "weapon_mu_knife" and b:Visible(ply) then
					--print("is player")
					--cmd:ClearButtons()
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					t3 = Angle(0,180,0)
					cmd:SetButtons(IN_SPEED)
					cmd:SetForwardMove( 1000 )
					ply.ScaredOf = b
					ply.RanBystanderCode = true
					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif b:IsPlayer() and b ~= ply and b:GetActiveWeapon():IsValid() and b:GetActiveWeapon():GetClass() == "weapon_mu_magnum" and b:Visible(ply) then
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					cmd:SetButtons(IN_SPEED)
					ply:SetEyeAngles( ( t1 - t2 ):Angle() )
					if ply:GetPos():Distance(b:GetPos()) > 55 then
						ply.FollowerEnt.PosGen = b:GetPos()
						MU_PathFind(ply,cmd)
					elseif ply:GetPos():Distance(b:GetPos()) < 45 then
						cmd:SetForwardMove( -1000 )
					else
						cmd:SetForwardMove( 0 )
						--ply.DoNotJump = true
					end
					ply.RanBystanderCode = true
				elseif b:IsPlayer() and b ~= ply and b:GetActiveWeapon():IsValid() and b:GetActiveWeapon():GetClass() == "weapon_mu_magnum" and !b:Visible(ply) and ply.ScaredOf:IsValid() then
					MU_PathFind(ply,cmd)
					ply.FollowerEnt.PosGen = b:GetPos()
				elseif b ~= ply  and b:IsValid() and b:GetClass() == "mu_knife" and b:Visible(ply) then
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					cmd:SetButtons(IN_SPEED)
					cmd:SetForwardMove( -1000 )
					ply.RanBystanderCode = true
					ply:SetEyeAngles( ( t1 - t2 ):Angle() )
				elseif b:IsPlayer() and b:IsValid() and ply.ScaredOf:IsValid() and ply.ScaredOf == b and ply:Visible(ply.ScaredOf) then
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					t3 = Angle(0,180,0)
					cmd:SetButtons(IN_SPEED)
					cmd:SetForwardMove( 1000 )

					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif b:IsPlayer() and b:IsValid() and b:IsValid() and ply.ScaredOf ~= b and ply:Visible(b) and b:GetMurdererRevealed() then
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					t3 = Angle(0,180,0)
					cmd:SetButtons(IN_SPEED)
					cmd:SetForwardMove( 1000 )
					ply.ScaredOf = b
					ply.RanBystanderCode = true
					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				elseif b:IsPlayer() and b:IsValid() and b:IsValid() and ply.ScaredOf ~= b and ply:Visible(b) and b:KeyDown( IN_SPEED ) and b:GetMurderer() then
					t1 = b:GetPos() + b:OBBCenter()
					t2 = ply:GetShootPos()
					t3 = Angle(0,180,0)
					cmd:SetButtons(IN_SPEED)
					cmd:SetForwardMove( 1000 )
					ply.ScaredOf = b
					ply.RanBystanderCode = true
					ply:SetEyeAngles( ( t1 - t2 ):Angle() + t3 )
				--[[
				elseif b and b:Visible(ply) and b:IsValid() and ply.ScaredOf ~= b and b:GetClass() == "mu_loot" then
					if ply.ScaredOf and !ply.ScaredOf:Visible(ply) or not ply.ScaredOf then
						ply.FollowerEnt.PosGen = b:GetPos()
						MU_PathFind(ply,cmd)
					end
				]]
				end
			end
		end

		if ply and not ply.RanBystanderCode and ply.BystanderRT and CurTime() < ply.BystanderRT then
			ply.FollowerEnt.PosGen = GetRandomWalkToSpot()
		elseif not ply.RanBystanderCode and not ply.BystanderRT or not ply.RanBystanderCode and ply.BystanderRT and CurTime() > ply.BystanderRT then
			ply.BystanderRT = CurTime()+10
		elseif not ply.RanBystanderCode then
			PathFind(ply,cmd)
			if ply and ply.FollowerEnt.PosGen and ply:GetPos():Distance( ply.FollowerEnt.PosGen ) < 50 then
				ply.BystanderRT = CurTime()-10
			end
			
		end
		if !ply.DoNotJump then
			Bot_CheckJump(ply,cmd)
		end
		MU_OpenDoor(ply)
		if ply:GetMoveType() == MOVETYPE_LADDER and ply.ScaredOf and ply.ScaredOf:IsValid() then
			if ply.ScaredOf:GetPos().Y < ply:GetPos().Y then
				ply:SetEyeAngles( Angle(-90,0,0) )	
				cmd:SetButtons(IN_FORWARD)	
				--print("above")
			elseif ply.ScaredOf:GetPos().Y > ply:GetPos().Y then
				ply:SetEyeAngles( Angle(90,0,0) )
				cmd:SetButtons(IN_JUMP)	
				--print("below")
			end
		elseif ply:GetMoveType() == MOVETYPE_LADDER then
			cmd:SetButtons(IN_JUMP)
		end
	elseif SERVER and ply.Bot and hook.Run( "GetRound" ) ~= 1 then
		cmd:SetButtons(0)
		if ply.FollowerEnt and ply.FollowerEnt:IsValid() then
			ply.FollowerEnt:Remove()
		end
		
		ply.ScaredOf = nil
	end
end
hook.Add("StartCommand","GMBots_MU_Start",MU_Start)

function Bot_CheckJump(ply,cmd)
	if ply and cmd and ply:GetVelocity():Length() < 3 and ply:IsOnGround() and !ply.DoNotJump and ply:WaterLevel() == 0 then
		ply:SetVelocity(Vector(0,0,300))
		cmd:SetButtons(IN_DUCK)
		--cmd:SetButtons(IN_DUCK)
		MU_OpenDoor(ply,cmd)
		--print(cmd:GetButtons())
		if ply:KeyDown(IN_DUCK) then
			cmd:SetButtons(0)
			--print("clear")
		else
			cmd:SetButtons(IN_DUCK)
			timer.Simple(.1,function()
				cmd:SetButtons(0)
			end)
		end
	end
end

hook.Add( "PlayerSpawn", "GMBots_MU_Spawn", function(ply)
	if ply.Bot then
		--timer.Stop(ply:EntIndex().."idlecheck")
		--timer.Create( ply:EntIndex().."idlecheck", 0.25, 0, function() MU_CheckIdle(ply) end )

		timer.Simple(1,function()
			ply:SelectWeapon("weapon_mu_knife")
			ply:SelectWeapon("weapon_mu_magnum")
		end)
		ply.ScaredOf = NULL
		ply.DoNotJump = true
		ply.prevPos = Vector(0, 0, 0)
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( bot )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.jumpcount = 0
		ply.FollowerEnt:Spawn()
		ply.FollowerEnt:SetPos(ply:GetPos())
		timer.Simple(1,function()
			ply.FollowerEnt:SetPos(ply:GetPos())
		end)
		ply.FollowerEnt:GetPos()
	end
end )

hook.Add( "PlayerDeath", "GMBots_MU_Death", function(ply)
	ply.ScaredOf = nil
	ply.DoNotJump = true
	if ply.Bot then
		if ply.FollowerEnt and ply.FollowerEnt:IsValid() then
			ply.FollowerEnt:Remove()
		end
	end
end )

hook.Add( "PlayerDisconnected", "GMBots_MU_Disconnect", function(ply)
	if ply and ply.FollowerEnt and ply.FollowerEnt:IsValid() and ply.Bot then
		ply.FollowerEnt:Remove()
		timer.Stop(ply:EntIndex().."idlecheck")
	end
end )
MsgC(Color( 0, 255, 64 ),"[GMBots] Successfully Ran Murder Bot Code!\n")