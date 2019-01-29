CreateConVar("gmbots_afk_manager",0,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY},"Makes players be a bot for being AFK.")
CreateConVar("gmbots_afk_manager_time",12000,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY},"How much time for the afk manager? This is not in seconds.")
function GMBots_AFKManChat(ply,text)
	if string.lower( text ) == "!bot" and ply and ply:IsValid() and ply:SteamID() ~= "BOT" then
		if ply.Bot then
			ply.Bot = false
			if ply and ply.FollowerEnt and ply.FollowerEnt:IsValid() then
				ply.FollowerEnt:Remove()
			end
			ply:PrintMessage( HUD_PRINTCENTER, "You are no longer a bot." )
		else
			ply:PrintMessage( HUD_PRINTCENTER, "You can't become a bot." )
		end
	end
end
hook.Add("PlayerSay","GMBots_AFKManChat",GMBots_AFKManChat)

function GMBotsCheckIfAFK(ply)
	if ply and ply:IsValid() and ply:IsPlayer() then
		if ply:EyeAngles() ~= ply.LastAngle or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_LEFT) or ply:KeyDown(IN_RIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_RUN) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_JUMP) or ply:KeyDown(IN_RELOAD) then
			ply.LastAngle = ply:EyeAngles()
			return false
		end
		ply.LastAngle = ply:EyeAngles()
		return true
	end
	return false
end

function GMBots_AFKMan(ply,cmd)
	if GetConVar("gmbots_afk_manager"):GetInt() > 0 and ply and ply:IsValid() and ply:IsPlayer() and ply:SteamID() ~= "BOT" and !ply.Bot then
			local maxafk = GetConVar("gmbots_afk_manager_time"):GetInt()
			if SERVER and not ply.Bot and ply.AFKCheck and ply.AFKCheck > maxafk and GMBotsCheckIfAFK(ply) then
				ply:Say( "I am turning into a bot since I am AFK!", false )
				ply.AFKCheck = 0
				ply.Target = nil
				ply.PosGen = nil
				ply.Bot = true
				
				if ply:Team() == 3 then
					ply:SetTeam(2)
					ply:Spawn()
				end
			elseif SERVER and GMBotsCheckIfAFK(ply) then
				if not ply.AFKCheck then
					ply.AFKCheck = -1
				end
				ply.LastAngle = ply:EyeAngles()
				ply.AFKCheck = ply.AFKCheck + 1
				local msgafk = maxafk/1.25
				if ply.AFKCheck > msgafk then
					ply:PrintMessage( HUD_PRINTCENTER, "You are about to turn into a bot for being AFK." )
				end
			else
				ply.AFKCheck = 0
			end
	else
		ply.AFKCheck = 0
	end
	
	if ply.Bot and ply:SteamID() ~= "BOT" then
		ply:PrintMessage( HUD_PRINTCENTER, "You are playing as a bot. To not be a bot anymore, type '!bot' in chat!" )
	end
end
hook.Add("StartCommand","GMBots_AFKMan",GMBots_AFKMan)

	
cvars.AddChangeCallback( "gmbots_afk_manager", function( convar_name, value_old, value_new )
	local value = tonumber(value_new)
	if ConVarExists("ttt_idle_limit") then
		if value > 0 then
			RunConsoleCommand("ttt_idle_limit",math.huge)
		else
			RunConsoleCommand("ttt_idle_limit",180)
		end
	end
end )