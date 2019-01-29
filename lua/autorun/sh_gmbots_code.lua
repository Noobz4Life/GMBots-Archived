CreateConVar("gmbots_debug_mode",0,FCVAR_SERVER_CAN_EXECUTE)
CreateConVar("gmbots_gm_navigation",0,FCVAR_SERVER_CAN_EXECUTE)
CreateConVar("gmbots_afk_manager",0)

GMBots = GMBots or {}
GMBots.Success = false
BotQuotaNames = { 
    "AimBot",
    "AmNot",
    "Archimedes!",
    "BeepBeepBoop",
    "Big Mean Muther Hubbard",
    "Black Mesa",
    "BoomerBile",
    "Cannon Fodder",
    "CEDA",
    "Chell",
    "Chucklenuts",
    "Companion Cube",
    "Crazed Gunman",
    "CreditToTeam",
    "CRITRAWKETS",
    "Crowbar",
    "CryBaby",
    "CrySomeMore",
    "C++",
    "DeadHead",
    "Delicious Cake",
    "Divide by Zero",
    "Dog",
	"Force of Nature",
	"Trash-Can",
	"Trash",
	"Cheeseburgah",
    "GLaDOS",
    "Grim Bloody Fable",
    "GutsAndGlory!",
    "Hat-Wearing MAN",
    "Headful of Eyeballs",
    "Herr Doktor",
    "HI THERE",
    "Hostage",
    "Humans Are Weak",
    "H@XX0RZ",
    "I LIVE!",
    "It's Filthy in There!",
    "IvanTheSpaceBiker",
	"Alex",
	"Vance",
	"Eli",
	"Kleiner",
	"Freeman",
	"G-Man",
	"H-Man",
	"T-Man",
	"B-Man",
	"F-Man",
	"Sphee",
	"Spy",
	"Pybro",
	"Pyro",
	"Pyre",
	"Baby Gun",
	"Baby Man",
	"Engineer"
}
BotNames = BotQuotaNames


function LookForPlayers(ply,teams)
	if ply and ply.Bot and SERVER then
		lastdist = math.huge
		nearest = nil
		for a,b in pairs(ents.FindByClass("player") ) do
			if b and b:IsPlayer() and b ~= ply and ply:IsLineOfSightClear(b) and !b:GetSaveTable( ).m_bLocked and b:GetPos():Distance(ply:GetPos() ) < lastdist then
				local cont = true
				if teams then
					if b:Team() == ply:Team() then
						cont = false
					end
				end
				if cont then
					lastdist = b:GetPos():Distance(ply:GetPos() )
					nearest =  b
				end
			end
		end
		return nearest
	end
end

function GetAllBots()
	local getallbots = {}
	for a,b in pairs(player.GetAll() ) do
		if b:SteamID() == "BOT" then
			b.Bot = true
		end
	
		if b and b.Bot and b:SteamID() == "BOT" then
			table.insert(getallbots,b)
		end
	end
	return getallbots
end

function GetAllPlayers()
	local plys = {}
	for a,b in pairs( player.GetAll() ) do
		if b and b:SteamID() ~= "BOT" then
			table.insert(plys,b)
		end
	end
	return plys
end


if SERVER then
	MsgC(Color( 0, 255, 64 ),"[GMBots] Use ConVar gmbots_bot_quota to add a certain number of bots.(Might not work for custom files)\n")
	
	-- This was made before gmbots_bot_quota, just here incase people wanna use it.
	GMBots.AddBotCount = 0
	concommand.Add("gmbots_bot_add_cfg",function(ply) -- This function will run gmbots_bot_add when the main code gets ran, this is so you can add bots as soon as you can.
		if SERVER and ( not IsValid(ply) or ply:IsSuperAdmin() ) then
			GMBots.AddBotCount = GMBots.AddBotCount or 0
			GMBots.AddBotCount = GMBots.AddBotCount+1
			
			MsgC(Color( 0, 255, 64 ),"[GMBots] Now "..GMBots.AddBotCount.." should spawn when the server is done hibernating!\n")
		end
	end)
end

	concommand.Add("gmbots_kill_all",function(ply)
		if SERVER and ( not IsValid(ply) or ply:IsSuperAdmin() ) then
			for a,b in pairs(player.GetAll()) do
				if b and b.Bot and b:Alive() then
					b:Kill()
				end
			end
		end
	end)
	
	concommand.Add("gmbots_kick_all",function(ply)
		if SERVER and ( not IsValid(ply) or ply:IsSuperAdmin() ) then
			for a,b in pairs(player.GetAll()) do
				if b and b.Bot and b:Alive() then
					b:Kick("Kicking all bots...")
				end
			end
		end
	end)


concommand.Add("gmbots_laglevels",function()
	if SERVER then
		MsgC(Color( 255,0,0 ),"[GMBots] This was from me being stupid and thinking this was a good idea. I'm just leaving this in the addon to show people how dumb I am.\n")
		
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.0,That means no noticable lag.\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.1,That means almost no noticable lag.\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.2,That means a small bit of noticable lag\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.3,That means a small but higher then 0.2 noticable lag\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.4,That means it lags alot in some cases\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.5,That means the same as 0.4 but bigger lag.\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is 0.6,That means you need a pretty good server to run the addon\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is C1, That mean's these bots can crash and may lag at certain cases.\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is C2, That mean's these bots can crash but will not lag.\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is C3, That mean's these bots can crash and may lag alot.\n")
		MsgC(Color( 0, 255, 64 ),"[GMBots] If lag level is EXTREME, That means this gamemode was probably untested and you should not run the addon on that gamemode.\n")
	end
end)

--[[
	GMBots by Noobz4Life
]]--

timer.Simple(2,function()
	if SERVER then
		GMBots.Success = false
		local gm_name = string.lower(GAMEMODE_NAME)
		if gm_name == "murder" then
			MsgC(Color( 0, 255, 64 ),"[GMBots] This addon supports Murder!\n")
			MsgC(Color( 0, 255, 64 ),"[GMBots] Murder Support Level: Good\n")
			MsgC(Color( 0, 255, 64 ),"[GMBots] Murder Lag Level: Very Rarely Any Lag\n")
			GMBots.Success = true
			include("gmbots/murder.lua")
		elseif gm_name == "hideandseek" then
			MsgC(Color( 0, 255, 64 ),"[GMBots] This addon supports Hide and Seek!\n")
			MsgC(Color( 0, 255, 64 ),"[GMBots] Hide and Seek Support Level: Great\n")
			MsgC(Color( 0, 255, 64 ),"[GMBots] Hide and Seek Lag: Lags on some maps.\n")
			GMBots.Success = true
			include("gmbots/hideandseek.lua")
		elseif gm_name == "base" then
			MsgC(Color( 0, 255, 64 ),"[GMBots] You're... on the base... gamemode... Guess I'll load the base.lua anyways.\n")
			MsgC(Color( 0, 255, 64 ),"[GMBots] Base Support Level: Awful\n")
			MsgC(Color( 0, 255, 64 ),"[GMBots] Base Lag: None.\n")
			GMBots.Success = true
			include("gmbots/base.lua")
		else
			MsgC(Color( 0, 255, 64 ),"[GMBots] GMBots doesn't support this gamemode by default. Looking for lua/gmbots/"..gm_name..".lua\n")
			if file.Exists( "gmbots/"..gm_name..".lua", "LUA" ) then
				MsgC(Color( 0, 255, 64 ),"[GMBots] Found lua/gmbots/"..gm_name..".lua! Loading...\n")
				
				GMBots.Success = true
				include("gmbots/"..gm_name..".lua")
			else
				MsgC(Color( 0, 255, 64 ),"[GMBots] Failed to find"..gm_name..".lua!\n")
			end
		end
		
		if (ULib and ULib.bans) then
			--ULX has some issue where it tries to Authenticate bots as actual players.
			--[[
			[ERROR] Unauthed player
			  1. query - [C]:-1
			   2. fn - addons/ulx-v3_70/lua/ulx/modules/slots.lua:44
				3. unknown - addons/ulib-v2_60/lua/ulib/shared/hook.lua:110
			]]
			
			--Fix by 
			hook.Add("PlayerDisconnected", "ulxSlotsDisconnect", function(ply)
				--If player is bot.
				if ply:SteamID() == "BOT" then
					--Do nothing.
					return
				end
			end)
		end
		
		if GMBots.Success then
			timer.Simple(1,function()
				GMBots.AddBotCount = GMBots.AddBotCount or 0
				if GMBots.AddBotCount > 1 then
					for i = 1,GMBots.AddBotCount do
						RunConsoleCommand("gmbots_bot_add")
					end
				end
			end)
		end
		
		if GMBots.Success then
			if GetConVar("gmbots_gm_navigation"):GetInt() > 0 then
				include("gmbots_other/pathfind.lua")
			end
			
			include("gmbots_other/afk_manager.lua")
			
			include("gmbots_other/custom_hooks")
			
			cvars.AddChangeCallback( "gmbots_gm_navigation", function( convar_name, value_old, value_new )
				local value = GetConVar("gmbots_gm_navigation"):GetInt()
				if value > 0 then
					include("gmbots_other/pathfind_gmnav.lua")
				elseif value <= 0 then
					include("gmbots_other/unload_pathfind.lua")
				end
			end )
		end
		
		if GMBots.Success == false then
			error("[GMBots] Sorry, The addon doesn't support this gamemode.\n")
		elseif GAMEMODE_ISSUELOG and type(GAMEMODE_ISSUELOG) == "table" then
			MsgC(Color( 0, 255, 64 ),"[GMBots] This gamemode has a issue's log, Type gmbots_issuelog to see it!\n")
			GMBots.IssueLog = GAMEMODE_ISSUELOG
			
			concommand.Add("gmbots_issuelog",function()
				MsgC(Color( 0, 255, 64 ),"GMBots "..GAMEMODE_NAME.." Issue Log\n")
				if SERVER and GMBots.IssueLog and type(GMBots.IssueLog) == "table" then
					for a,b in pairs(GMBots.IssueLog) do
						if b and type(b) == "string" then
							MsgC(Color( 0, 255, 64 ),"- "..b.."\n")
						end
					end
				end
			end)
		end
	elseif CLIENT then

	end
end)

MsgC(Color( 0, 255, 64 ),"[GMBots] Initialized.\n")