//Base code for bots.

BotNames = {"Base","Name","New Names Here","Bot"}
BOTS = {}

if SERVER then
	concommand.Add("gmbots_bot_add",function()
		if SERVER then
			if(#player.GetAll() == game.MaxPlayers())then
				error("[GMBots] Server is full, cant spawn bot\n")
			else
				local bot = player.CreateNextBot("BOT "..BotNames[math.random(#BotNames)])
				if bot then
					table.insert(BOTS,bot)
					bot.Bot = true
					bot.RealBOT = true
					bot.RPAttack = false
					bot.prevPos = Vector(0, 0, 0)
					bot.FollowerEnt = ents.Create("sent_pathfinding")
					bot.FollowerEnt:SetOwner( bot )
					bot.FollowerEnt:SetPos(bot:GetPos())
					bot.FollowerEnt:Spawn()
				end
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

function CheckIfAFK(ply)
	if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_LEFT) or ply:KeyDown(IN_RIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_RUN) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_JUMP) or ply:KeyDown(IN_RELOAD) then
		return false
	end
	return true
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

function Bot_CheckJump(ply,cmd)
	if ply:GetVelocity():Length() < 5 and ply:IsOnGround() and !ply.DoNotJump then
		ply:SetVelocity(Vector(0,0,300))
		if ply.FollowerEnt then
			ply.FollowerEnt:MU_NBJump()
		end
		cmd:SetButtons(IN_DUCK)
		--print(cmd:GetButtons())
		if ply:KeyDown(IN_DUCK) then
			cmd:SetButtons(0)
			--print("clear")
		end
	end
end

function Bot_Start(ply,cmd)
	if not ply.Bot and not ply.RealBOT then
		if SERVER and not ply.Bot and not ply.RealBOT and ply.AFKCheck and ply.AFKCheck > 2000 and CheckIfAFK(ply) then
			ply:ConCommand("say I am turning into a bot since I'm AFK!")
			--print("test")
			ply.AFKCheck = 0
			ply.Target = ply:GetPos()
			ply.PosGen = ply:GetPos()
			ply.Bot = true
		elseif SERVER and CheckIfAFK(ply) then
			if not ply.AFKCheck then
				ply.AFKCheck = -1
			end
			--print(ply.AFKCheck)
			ply.AFKCheck = ply.AFKCheck + 1
		else
			ply.AFKCheck = 0
		end
	else
		ply.AFKCheck = -500
	end
	
	
	if ply.RealBOT and not ply.Bot then
		ply.Bot = true
	end
	
	if ply.Bot and SERVER and ply.FollowerEnt and ply:Alive() then
		if ply.DoNotJump then
			ply.DoNotJump = false
		end
		
		cmd:ClearButtons()
		
		ply.DoNotJump = true
		
		if !ply.DoNotJump then
			Bot_CheckJump(ply,cmd)
		end
	elseif ply.Bot and SERVER and !ply.FollowerEnt and ply:Alive() then
		ply.FollowerEnt = ents.Create("sent_pathfinding")
		ply.FollowerEnt:SetOwner( ply )
		ply.FollowerEnt:SetPos(ply:GetPos())
		ply.FollowerEnt:Spawn()
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)

function BeABot(ply,text)
	--print(text,text == "!bot")
	
	if text == "!bot" then
	
		if ply.Bot == true then
			ply.Bot = false
			if ply and ply.FollowerEnt and ply.FollowerEnt:IsValid() then
				ply.FollowerEnt:Remove()
			end
		else
			ply.Bot = true
			ply.Target = nil
			ply.PosGen = nil
			ply.LookAt = Angle(0,0,0)
			if ply:Team() == 1 then
				ply.Target = ply:GetPos()
			else
				ply.PosGen = nil
			end
		end
		
	end
end
hook.Add("PlayerSay","BeABot",BeABot)