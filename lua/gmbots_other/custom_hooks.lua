hook.Add("StartCommand","GMBots_CustomHookBotStart",function(bot,cmd)
	if bot and bot.Bot and cmd then
		local success,err = pcall(function()
			cmd:ClearButtons()
			hook.Run( "GMBotsStart",bot,cmd )
		end)
		if not success then bot:Error(err) end
	end
end)
--[[
hook.Add("ShouldCollide","GMBots_CustomHookNoCollide",function(ent1,ent2)
	if ent1 and ent2 and ent1:IsValid() and ent2:IsValid() then
		if ent1:IsPlayer() and ent2:IsPlayer() and ent1.Bot and ent2.Bot then
			return false
		elseif ent1:IsPlayer() and ent1.Bot and ent2:IsDoor() and ent2:IsDoorOpen() then
			return false
		elseif ent2:IsPlayer() and ent2.Bot and ent1:IsDoor() and ent1:IsDoorOpen() then
			return false
		end
	end
end)
]]