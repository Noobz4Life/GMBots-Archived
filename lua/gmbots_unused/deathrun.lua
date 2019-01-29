//This code was very early in development. I might add deathrun support someday.

local BotNames = {"Doctah" , "Maggots!", "Bobby"}
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

function Bot_CheckJump(ply,cmd)
	if ply:GetVelocity():Length() < 15 and ply:IsOnGround() and !ply.DoNotJump then
		ply:SetVelocity(Vector(0,0,300))
		//if ply.FollowerEnt then
		//	ply.FollowerEnt:MU_NBJump()
		//end
		cmd:SetButtons(IN_DUCK)
		--print(cmd:GetButtons())
		if ply:KeyDown(IN_DUCK) then
			cmd:SetButtons(0)
			--print("clear")
		end
	end
end

function LookForButtons(ply)
	if ply and ply.Bot and SERVER then
		lastdist = ents.FindByClass("func_button")[#ents.FindByClass("func_button")]:GetPos():Distance(ply:GetPos() )
		nearest = ents.FindByClass("func_button")[#ents.FindByClass("func_button")]
		for a,b in pairs(ents.FindByClass("func_button") ) do
			if b and b:GetClass() == "func_button" and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

function LookForTeleports(ply)
	if ply and ply.Bot and SERVER then
		lastdist = ents.FindByClass("func_button")[#ents.FindByClass("func_button")]:GetPos():Distance(ply:GetPos() )
		nearest = ents.FindByClass("func_button")[#ents.FindByClass("func_button")]
		for a,b in pairs(ents.FindByClass("trigger_teleport") ) do
			if b and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				lastdist = b:GetPos():Distance(ply:GetPos() )
				nearest =  b
			end
		end
		return nearest
	end
end

function LookAt(ply,ent)
	t1 = ent:GetPos() + ent:OBBCenter()
	t2 = ply:GetShootPos()

	ply:SetEyeAngles( ( t1 - t2 ):Angle() )
end

function Bot_Start(ply,cmd)
	if ply.Bot and SERVER and ply:Alive() then
		if ply.DoNotJump then
			ply.DoNotJump = false
		end
		
		cmd:ClearButtons()
		
		local button = LookForButtons(ply)
		local tele = LookForTeleports(ply)
		
		ply.DoNotJump = true
		
		//print(ply:Team())
		
		if ply:Team() == 2 and tele and button and button:GetPos():Distance(ply:GetPos() ) < 100 and button:GetPos():Distance(ply:GetPos()) < tele:GetPos():Distance(ply:GetPos()) then
			LookAt(ply,button)
			button:Fire("press","")
			button:Fire("lock","")
		elseif ply:Team() == 2 and tele and button:GetPos():Distance(ply:GetPos()) < tele:GetPos():Distance(ply:GetPos())  then
			LookAt(ply,button)
			cmd:SetForwardMove(1000)
		elseif ply:Team() == 2 and tele and button:GetPos():Distance(ply:GetPos()) >= tele:GetPos():Distance(ply:GetPos()) then
			LookAt(ply,tele)
			cmd:SetForwardMove(1000)
		end
		
		
		//ply.DoNotJump = true
		
		Bot_CheckJump(ply,cmd)
		
	elseif ply.Bot and SERVER and !ply.FollowerEnt and ply:Alive() then
		bot.FollowerEnt = ents.Create("sent_pathfinding")
		bot.FollowerEnt:SetOwner( ply )
		bot.FollowerEnt:SetPos(ply:GetPos())
		bot.FollowerEnt:Spawn()
	end
end
hook.Add("StartCommand","Bot_Start",Bot_Start)