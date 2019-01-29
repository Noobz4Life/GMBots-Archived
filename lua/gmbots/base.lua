--[[

	Hello! And welcome to the GMBots base!

	To see all the functions you can do, check the Wiki on GitHub.

	I have left messages that explains what does what.
		
		
	Github Wiki: https://github.com/Noobz4Life/GMBots/wiki
]]

BOTNames = {  -- This will set what the bots will be named, every bot has "BOT" before their name, so keep that in mind.
	"Chase",
	"Jake",
	"Link",
	"Fred",
	"Xander",
	"Alfred",
	"Garry"
}

hook.Add("GMBotsBotAdded","GamemodeBotAdded",function(bot) -- This hook gets ran when a bot is added, from bot quota or the gmbots_bot_add command.
	if bot and bot:IsValid() then
		bot.Example = true
		bot:Say("Hi!")
	end
end)

function GMBotsStart(ply,cmd)
	if ply and ply:IsValid() and cmd then
		if ply.Example then
			ply:Debug("This is how you debug stuff.") -- This will only appear if gmbots_debug_mode is above 0.
			ply.Example = false
		end
		local enemy = ply.Enemy
		if enemy and enemy:IsValid() and not enemy.Bot then -- Make sure you have a enemy, and that the enemy is a bot.
			ply:BotFollow(cmd,enemy) -- Follow Enemy.
		else
			ply.Enemy = ply:LookForPlayers() -- Look for a enemy.
			ply:BotWander(cmd) -- Wander while trying to find a enemy.
		end
    
	end
end
hook.Add("GMBotsStart","GMBotsStart",GMBotsStart) -- This hook is basically StartCommand, but it checks if the player is a bot for you, and also handles errors.