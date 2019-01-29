CreateConVar("gmbots_bot_quota",0,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY},"How many bots automatically join? Bots also get auto-kicked!")

GMBots = GMBots or {}

function GMBots:GetAllBots()
	local bots = {}
	for a,b in pairs(player.GetAll() ) do
		if b and b:IsValid() and b:SteamID() == "BOT" then
			table.insert(bots,b)
		end
	end
	return bots or {}
end

function GMBots:GetAllPlayers()
	local plys = {}
	for a,b in pairs(player.GetAll() ) do
		if b and b:IsValid() and b:SteamID() ~= "BOT" then
			table.insert(plys,b)
		end
	end
	return plys or {}
end

function GMBots:BotQuotaCount()
	if GetConVar("gmbots_bot_quota"):GetInt() > 0 then
		local bot_count = GetConVar("gmbots_bot_quota"):GetInt() or 0
		local ply_count = #GMBots:GetAllPlayers()
		if bot_count and ply_count then
			return math.Clamp( bot_count - ply_count, 0 , game.MaxPlayers() - 1 )
		end
	end
	return 0
end

function GMBots:QuotaBotKick()
	if GetConVar("gmbots_bot_quota"):GetInt() > 0 then
		local bots = self:GetAllBots() or {}
		local bot_count = #bots
		for a,bot in pairs( bots ) do
			local b = bot --Incase I mess up.
			if bot and bot:IsValid() then
				if bot_count > self:BotQuotaCount() then
					bot:Kick("Bot Quota Change")
					bot_count = bot_count-1
				end
			end
		end
	end
end

function GMBots:QuotaBotJoin()
	if GetConVar("gmbots_bot_quota"):GetInt() > 0 then
		local quota_count = self:BotQuotaCount()
		local bot_count = #self:GetAllBots()
		for i = 1,game.MaxPlayers() do
			if bot_count < quota_count then
				RunConsoleCommand("gmbots_bot_add")
				bot_count = bot_count+1
			end
		end
	end
end

hook.Add("PlayerInitialSpawn","gmbots_quota_initspawn",function(ply)
	if SERVER and GetConVar("gmbots_bot_quota"):GetInt() > 0 and ply:SteamID() ~= "BOT" then
		GMBots:QuotaBotKick()
		GMBots:QuotaBotJoin()
	end
end)

hook.Add("PlayerDisconnected","gmbots_quota_disconnect",function(ply)
	if SERVER and GetConVar("gmbots_bot_quota"):GetInt() > 0 and ply:SteamID() ~= "BOT" then
		GMBots:QuotaBotKick()
		GMBots:QuotaBotJoin()
	end
end)

concommand.Add("gmbots_quota_respawn",function(ply)
	if ply and ply:IsValid() and not ply:IsSuperAdmin() then return end
	local bots = GMBots:GetAllBots()
	for a,b in pairs(bots) do
		if b and b:IsValid() then
			b:Kick("Respawning Bots")
		end
	end
	
	timer.Simple(1,function()
		GMBots:QuotaBotKick()
		GMBots:QuotaBotJoin()
	end)
end)

cvars.AddChangeCallback( "gmbots_bot_quota", function( convar_name, value_old, value_new )
	GMBots:QuotaBotKick()
	GMBots:QuotaBotJoin()
end )

GMBots:QuotaBotKick()
GMBots:QuotaBotJoin()

timer.Simple(5,function()
	GMBots:QuotaBotKick()
	GMBots:QuotaBotJoin()
end)