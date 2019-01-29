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
		bot.Target = nil
		ply.LastMurder = CurTime()
		ply.CanSayMurderer = true
	end
end)

GMBots_CurrentMurderer = nil -- This is more for optimization. I might replace this incase somebody makes a mod that allows multiple murderers.

function GMBotsStart(ply,cmd)
	local CurrentRoundState = hook.Run( "GetRound" )
	if ply and ply:IsValid() and ply:Alive() and cmd and CurrentRoundState == 1 then
		--print(GMBots_CurrentMurderer)
		if ply:GetMurderer() then
			GMBots_CurrentMurderer = ply
			if ply and ply.Target and ply.Target:IsValid() and ply.Target:IsPlayer() and ply.Target:Alive() and not ply.Target:GetMurderer() and ply.Target ~= ply then
				ply.LastMurder = ply.LastMurder or CurTime()
				ply.NextMurder = ply.NextMurder or ply.LastMurder+math.random(15,60)
				ply.MurderAntistuck = ply.MurderAntistuck or CurTime()+500
				if ply.NextMurder and CurTime() >= ply.NextMurder then
					if CurTime() > ply.MurderAntistuck then
						ply:Say("I am kill binding so that the round isn't stuck!")
						ply:Debug("Resetting round because Murderer is stuck!")
						ply:Kill()
					else
						ply:Debug(ply.MurderAntistuck-CurTime())
					end
					if ply:Visible(ply.Target) then
						local dist = ply:GetPos():Distance(ply.Target:GetPos())
						ply:Pathfind(cmd,ply.Target:GetPos(),false)
						if ply.MurdererRush then
							ply:AddButtonToCMD(cmd,IN_SPEED)
						end
						if dist < 100 then
							ply:SelectWeapon("weapon_mu_knife")
							ply:BotAttack(cmd,ply.Target)
						else
							ply:SelectWeapon("weapon_mu_hands")
						end
					else
						ply:SelectWeapon("weapon_mu_hands")
						ply:Pathfind(cmd,ply.Target:GetPos(),false)
					end
				else
					ply.MurderAntistuck = CurTime() + 60*5
					ply.MurdererRush = false
					if ply.LastMurder and CurTime() > ply.LastMurder+2 then
						ply:SelectWeapon("weapon_mu_hands")
					end
					local active_weapon = ply:GetActiveWeapon()
					if active_weapon and active_weapon:IsValid() and active_weapon:GetClass() == "weapon_mu_knife" then
						for a,b in pairs(player.GetAll()) do
							if b and b:IsValid() and b ~= ply and b:IsPlayer() and b:Alive() and b:Visible(ply) then
								ply.NextMurder = 0
								ply.Target = b
								ply.MurdererRush = true
							end
						end
					end
					ply:BotWander(cmd)
				end
			else
				local targets = player.GetAll()
				ply.Target = targets[math.random(1,#targets)]
				
				ply:Debug("Chosen Target: "..ply.Target:Name())
				ply.LastMurder = CurTime()
				ply.NextMurder = nil
				
				if ply.LastMurder and CurTime() > ply.LastMurder+2 then
					ply:SelectWeapon("weapon_mu_hands")
				end
				
				ply:BotWander(cmd)
			end
		elseif ply:HasWeapon("weapon_mu_magnum") then
			if ply and ply.Target and ply.Target:IsValid() and ply.Target:GetMurderer() and ply.Target:IsPlayer() and ply.Target:Alive() and ply.Target ~= ply and ply.Target:GetActiveWeapon() and ply.Target:GetActiveWeapon():IsValid() and ply.Target:GetActiveWeapon():GetClass() == "weapon_mu_knife" then
				if ply:BotVisible(ply.Target) then
					ply:SelectWeapon("weapon_mu_magnum")
						
					local xoff = math.random(-3,3)
					local yoff = math.random(-3,3)
					local zoff = math.random(-3,3)
					local offset = Vector(xoff,yoff,zoff)
						
					ply:BotFollow(cmd,ply.Target)
					ply:BotAttack(cmd,ply.Target,offset,true)
				else
					ply:SelectWeapon("weapon_mu_magnum")
					ply:BotWander(cmd)
				end
			else
				if GMBots_CurrentMurderer and GMBots_CurrentMurderer:IsValid() and GMBots_CurrentMurderer:IsPlayer() then
					local active_weapon = GMBots_CurrentMurderer:GetActiveWeapon()
					if active_weapon and active_weapon:IsValid() and active_weapon:GetClass() == "weapon_mu_knife" and ply:BotVisible(GMBots_CurrentMurderer) then
						ply.Target = GMBots_CurrentMurderer
					end
				end
				ply:BotWander(cmd)
				ply:SelectWeapon("weapon_mu_hands")
			end
		else
			if not ply.MagnumTarget or ply.MagnumTarget and not ply.MagnumTarget:IsValid() then
				local magnums = ents.FindByClass("weapon_mu_magnum")
				if #magnums > 0 then
					for i = 1,#magnums do
						local magnum = magnums[i]
						if magnum and magnum:IsValid() and not IsValid(magnum:GetOwner()) and ply:BotVisible(magnum) then
							ply.MagnumTarget = magnum
							ply:BotSay("Gun! Give me!")
						end
					end
				end
			end
			
			if ply.MagnumTarget and ply.MagnumTarget:IsValid() then
				if not IsValid(ply.MagnumTarget:GetOwner()) then
					ply:Pathfind(cmd,ply.MagnumTarget:GetPos(),true)
					if ply:Visible(ply.MagnumTarget) then
						ply:LookAtEntity(ply.MagnumTarget)
						ply:AddButtonToCMD(cmd,IN_USE)
					end
				else
					ply.MagnumTarget = nil
				end
			else
				ply:BotWander(cmd)
			end
		end
		if not ( GMBots_CurrentMurderer and GMBots_CurrentMurderer:IsValid() and GMBots_CurrentMurderer:IsPlayer() and GMBots_CurrentMurderer:GetMurderer() ) then
			for _,k in pairs(player.GetAll()) do
				if k and k:IsValid() and k:IsPlayer() and k:GetMurderer() then
					GMBots_CurrentMurderer = k
				end
			end
		end
	elseif ply and ply:IsValid() and cmd then
		GMBots_CurrentMurderer = nil
		ply.Target = nil
		ply.MagnumTarget = nil
		ply.LastMurder = CurTime()
		ply.CanSayMurderer = true
	end
end
hook.Add("GMBotsStart","GMBotsStart",GMBotsStart) -- This hook is basically StartCommand, but it checks if the player is a bot for you, and also handles errors.