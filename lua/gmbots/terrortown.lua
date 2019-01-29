BOTNames = {
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

function BotWeaponIsDefault(wep)
	if wep:GetClass() == "weapon_zm_improvised" or wep:GetClass() == "weapon_ttt_unarmed" or wep:GetClass() == "weapon_zm_carry" then
		return true
	end
	
	return false
end

function BotDropKind(ply,wep)
	for a,b in pairs(ply:GetWeapons()) do
		if b and b.Kind == wep.Kind then
			WEPS.DropNotifiedWeapon(ply,b)
			return  true
		end
	end
end

function BotHasGuns(ply,cmd)	
	for a,b in pairs( ply:GetWeapons() ) do
		if not BotWeaponIsDefault(ply,cmd) then
			if b:Ammo1() > 0 or b:Clip1() > 0 and b.Kind ~= WEAPON_NADE then
				return true
			end
		end
	end
end

function BotSwitchGun(ply,cmd)
	for a,b in pairs( ply:GetWeapons() ) do
		if not BotWeaponIsDefault(ply,cmd) and ( b:Ammo1() > 0 or b:Clip1() > 0 ) and b.Kind ~= WEAPON_NADE then
			cmd:SelectWeapon(b)
		end
	end
end

hook.Add("GMBotsBotAdded","GamemodeBotAdded",function(bot)
	if bot and bot:IsValid() then
		bot.TTTBotType = "None"
		
		local types = {
			"Typer",
			"Follower",
			"None"
		}
		bot.TTTBotType = types[math.random(1,#types)]
		bot.TTTReactTime = math.random(5,15)/15
		bot.TTTSuprisedReactTime = bot.TTTReactTime*2
	end
end)

function IsAlive(target)
	if target and target:IsValid() and target:IsPlayer() and target:Alive() and not target:IsSpec() then
		return true
	end
	return false
end

function AttackTarget(ply,cmd,off)
	cmd:ClearButtons()
	cmd:ClearMovement()
	local target = ply.Target
	local offset = off or Vector(0,0,0)
	if target and target:IsValid() and target:IsPlayer() and IsAlive(target) then
		ply.LBJ = CurTime()+3
		ply.DoNotJump = true
		ply:LookAtEntity(target,offset or Vector(0,0,0))
		cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
		
		ply.LastKnownPos = target:GetPos() + target:OBBCenter()
	end
end

function LookForAmmo(ply,cmd)
	local weapon = ply:GetActiveWeapon()
	if not weapon then return end
	if not weapon:IsValid() then return end
	if ply.AmmoTarget and ply.AmmoTarget:IsValid() then
		ply.DoNotJump = false
		ply:Pathfind(cmd,ply.AmmoTarget:GetPos(),true)
		
		ply.AmmoTargetTimeout = ply.AmmoTargetTimeout or CurTime()+5
		if CurTime() > ply.AmmoTargetTimeout then
			ply.AmmoTarget = nil
		end
	else
		local wep = {}
		for a,b in pairs( ents.GetAll() ) do
			if b and b:IsValid() and b.AmmoType and b.AmmoType == weapon.Primary.Ammo then
				table.insert( wep, b )
			end
		end
		ply:BotWander(cmd)
		ply.AmmoTarget = table.Random(wep)
		ply.AmmoTargetTimeout = CurTime()+30
	end
end

function TTTArmC4(ply,cmd)
	ply.NextArmTest = ply.NextArmTest or CurTime()
	if CurTime() > ply.NextArmTest then
		local c4s = ents.FindByClass("ttt_c4")
		local c4 = nil
		for i = 1,#c4s do
			local curc4 = c4s[i]
			if curc4 and curc4:IsValid() and ( ( not curc4:GetArmed() and ply:GetRole() == ROLE_TRAITOR ) or ( curc4:GetArmed() and curc4:Visible(ply) and ply:GetRole() ~= ROLE_TRAITOR ) ) then
				c4 = curc4
			end
		end
		
		if c4 and c4:IsValid() then
			ply.CurrentC4 = c4
		end
		
		ply.NextArmTest = CurTime()+5
		return true
	end
	return false
end

function GMBots_Start(ply,cmd)
	local bot = ply
	if ply and ply:IsValid() and ply.Bot and IsAlive(ply) then
		
		if ply:HasWeapon("weapon_ttt_c4") then
			local c4wep = ply:GetWeapon("weapon_ttt_c4")
			if c4wep and c4wep:IsValid() then
				cmd:ClearButtons()
				cmd:ClearMovement()
				if ply:GetActiveWeapon() ~= c4wep then
					cmd:SelectWeapon(c4wep)
				end
				ply.NextArmTest = CurTime()+15
				cmd:SetButtons(IN_ATTACK)
				return
			end
		end
		
		if TTTArmC4(ply,cmd) then
			return
		else
			if ply.CurrentC4 and ply.CurrentC4:IsValid() then
				if ply:GetRole() == ROLE_TRAITOR then
					local dist = ply:GetPos():Distance(ply.CurrentC4:GetPos())
					if dist < 150 and ply.CurrentC4:Visible(ply) then
						pcall(function()
							ply.CurrentC4:Arm(ply,45)
							ply.CurrentC4 = nil
							ply.NextArmTest = CurTime()+1
						end)
					else
						ply:PathFind(cmd,ply.CurrentC4:GetPos(),true)
					end
					return
				else
					local dist = ply:GetPos():Distance(ply.CurrentC4:GetPos())
					if dist < 80 and ply.CurrentC4:Visible(ply) then
						pcall(function()
							if ply.CurrentC4:GetArmed() then
								local wire_chosen = math.random(1,6)
								if ply.CurrentC4.SafeWires[wire_chosen] then
									ply.CurrentC4:Disarm(ply,45)
									ply.CurrentC4 = nil
								else
									ply.CurrentC4:FailedDisarm(ply)
									ply.CurrentC4 = nil
								end
							else
								ply.CurrentC4 = nil
							end
						end)
					else
						ply:PathFind(cmd,ply.CurrentC4:GetPos(),true)
					end
				end
			else
				ply.CurrentC4 = nil
			end
		end
		
		cmd:ClearButtons()
		ply.DoNotJump = false
		if ply.Target and ply.Target:IsValid() and ply.Target:IsPlayer() and IsAlive(ply.Target) then
			if ply:BotVisible(ply.Target) then
				ply.LoseTarget = CurTime()+25
			else
				ply.LoseTarget = ply.LoseTarget or CurTime()+20
				ply.LastKnownPos = ply.Target:GetPos()
				if CurTime() > ply.LoseTarget then
					ply.Target = nil
					ply.LoseTarget = CurTime()
				end
				pcall(function()
					if ply:GetActiveWeapon():Clip1() <= 0 and ply:GetActiveWeapon():Ammo1() > 0 then
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_RELOAD))
					end
				end)
			end
		end
		if BotHasGuns(ply,cmd) then
			BotSwitchGun(ply,cmd)
			if ply:GetRole() == ROLE_INNOCENT or ply:GetRole() == ROLE_DETECTIVE then
				if ply.Target and ply.Target:IsValid() and IsAlive(ply.Target) then
					if ply:BotVisible(ply.Target) then
						ply:BotCheckJump(cmd)
						local offset = Vector(0,0,0)
						if ply.Suprised then
							ply.SuprisedTimer = ply.SuprisedTimer or CurTime()+5
							ply.LookOffset = ply.LookOffset or Vector(40,0,0)
							ply.LookOffsetTimer = ply.LookOffsetTimer or 0
							if CurTime() > ply.LookOffsetTimer then
								local min,max = -20,20
								ply.LookOffset = Vector(math.random(min,max),math.random(min,max),math.random(min,max))
								ply.LookOffsetTimer = CurTime()+0.5
							end
							
							if CurTime() > ply.SuprisedTimer then
								ply.Suprised = false
								ply.SuprisedTimer = nil
							end
							offset = ply.LookOffset or Vector(0,0,0)
						else
							ply.LookOffset = Vector(0,0,0)
						end
						AttackTarget(ply,cmd,offset)
					else
						ply:LookAtPos(ply.LastKnownPos)
						ply:Pathfind(cmd,ply.LastKnownPos)
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_WALK))
					end
				else
					local activewep = ply:GetActiveWeapon()
					local ammo1 = activewep:Ammo1()
					
					if activewep:Ammo1() and activewep:Ammo1() <= ( activewep.Primary.ClipSize or 0 ) then
						LookForAmmo(ply,cmd)
					else
						ply.Target = nil
						if ply.TTTBotType == "Follower" then
							local lastfollowtarget = ply.FollowTarget
							
							if ply.FollowTarget and ply.FollowTarget ~= ply and ply.FollowTarget.FollowTarget ~= ply and ply.FollowTarget:IsValid() and ply.FollowTarget:IsPlayer() and IsAlive(ply.FollowTarget) then
								if not ply.SaidFollowing then
									if ply:Visible(ply.FollowTarget) then
										ply:Say("I'm with "..ply.FollowTarget:Name())
										ply.SaidFollowing = true
									end
								end
								
								if ply:Visible(ply.FollowTarget) then
									if not ply.Target and ply.FollowTarget.Target then
										ply.Target = ply.FollowTarget.Target
									end
								end
								
								ply:BotFollow(cmd,ply.FollowTarget)
							else
								local validtargets = {}
								local testtargets = player.GetAll()
								for i = 1,#testtargets do
									local target = testtargets[i]
									if target and target ~= ply and target.FollowTarget ~= ply and target:IsValid() and target:IsPlayer() and IsAlive(target) then
										table.insert(validtargets,target)
									end
								end
								if #validtargets >= 1 then
									ply.FollowTarget = validtargets[math.random(1,#validtargets)]
									ply.SaidFollowing = false
								end
								ply:BotWander(cmd)
							end
						else
							ply:BotWander(cmd)
						end
						cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_RELOAD))
					end
				end
			else
			
				if ply.Target and ply.Target:IsValid() and IsAlive(ply.Target) and ply.Target:GetRole() ~= ROLE_TRAITOR then
					if ply:BotVisible(ply.Target) then
						AttackTarget(ply,cmd)
					else
						ply:PathFind(cmd,ply.Target:GetPos())
						ply.DoNotJump = false
						ply:BotCheckJump(cmd)
					end
				else
					local players = {}
					for a,b in pairs(player.GetAll()) do
						if b ~= ply and b and b:IsValid() and b:IsPlayer() and IsAlive(b) and b:GetRole() ~= ROLE_TRAITOR then
							table.insert(players,b)
						end
					end
					ply.Target = table.Random(players)
					ply.LoseTarget = CurTime()+30
				end
				
			end
			pcall(function()
				if ply:GetActiveWeapon():Clip1() <= 0 then
					cmd:SetButtons(IN_RELOAD)
				end
			end)
		else
			if bot.WeaponTarget and bot.WeaponTarget:IsValid() and not IsValid( bot.WeaponTarget:GetOwner() ) then
				bot:Pathfind(cmd,bot.WeaponTarget:GetPos(),true)
				ply.DoNotJump = false
				bot:BotCheckJump(cmd)
				if bot.WeaponTarget:Visible(bot) then
					cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_USE))
				end
				BotDropKind(bot,bot.WeaponTarget)
				ply:SelectWeapon("weapon_zm_improvised")
				bot.WeaponTargetTimeout = bot.WeaponTargetTimeout or CurTime()+5
				if CurTime() > bot.WeaponTargetTimeout then
					bot.WeaponTarget = nil
				end
			else
				local wep = {}
				for a,b in pairs( ents.GetAll() ) do
					if b and b:IsValid() and b:IsWeapon() and not IsValid( b:GetOwner() ) and b.Kind ~= WEAPON_NADE then
						table.insert( wep, b )
					end
				end
				bot.WeaponTarget = table.Random(wep)
				bot.WeaponTargetTimeout = CurTime()+30
			end
		end
		
		if ply.RTTarget and ply.RTTarget:IsValid() then
			ply.RTTime = ply.RTTime or CurTime()+0.5
			if CurTime() > ply.RTTime then
				ply.Target = ply.RTTarget
				ply.RTTarget = nil
				ply.RTTime = nil
				ply.LastKnownPos = ply.Target:GetPos()
				ply:BotSay("Help!",false,5,true,4.2)
			else
				ply:LookAtLerp(cmd,ply.RTTarget:GetPos() + ply.RTTarget:OBBCenter(),0.7,true)
			end
		end
	end
end
hook.Add("GMBotsStart","GMBots_Start",GMBots_Start)

function GMBots_TTTDamage(target,dmginfo)
	if target.Bot and target and target:IsValid() and target:IsPlayer() and target.Bot and dmginfo:GetAttacker() ~= target.Target then
		local attacker = dmginfo:GetAttacker()
		if attacker and attacker:IsValid() and attacker:IsPlayer() and attacker ~= target and target.RTTarget ~= attacker then
			local damage = dmginfo:GetDamage() or 0
			if attacker and attacker:IsValid() and attacker:IsPlayer() and damage > 0 then
				target.RTTarget = dmginfo:GetAttacker()
				target.RTTime = CurTime()+0.1
			end
			target.Suprised = false
			target.RTTarget = attacker
			if not target:BotVisible(attacker) and damage > 0 then
				target.Suprised = true
				target.RTTime = CurTime()+0.35
				target.SurpisedTimer = CurTime()+3
				target.LookOffset = Vector(40,0,0)
			end
			target.LastDamaged = target.LastDamaged or 0
			target.LoseTarget = CurTime()+30
			--[[
			if attacker:GetRole() ~= ROLE_DETECTIVE then
				if target:GetRole() == ROLE_DETECTIVE then
					for a,b in pairs(player.GetAll()) do
						if b:BotVisible(attacker) and b ~= attacker and b ~= target  then
							target.RTTarget = attacker
							target.RTTime = CurTime()+0.2
						end
					end
				elseif CurTime() < target.LastDamaged+10 then
					for a,b in pairs(player.GetAll()) do
						if b:BotVisible(attacker) and b ~= attacker and b ~= target then
							target.RTTarget = attacker
							target.RTTime = CurTime()+0.2
						end
					end
				end
			end
			]]
		end
		if attacker and attacker:IsValid() and attacker:IsPlayer() then
			attacker.LastDamaged = CurTime()
		end
	end
end
hook.Add("EntityTakeDamage","GMBots_TTTDamage",GMBots_TTTDamage)

function GMBots_TTTStart()
	for a,b in pairs(player.GetAll()) do
		b.Target = nil
		b.RTTarget = nil
		b.RTTime = nil
		b.Suprised = false
		b.SuprisedTimer = nil
		b.LookOffset = Vector(0,0,0)
		b.LookOffsetTimer = nil
		b.LastDamaged = 0
		b.LastKnownPos = Vector(0,0,0)
		b:Debug("TTT Round Start.")
	end
end
hook.Add("TTTBeginRound", "GMBots_TTTStart", function()
	GMBots_TTTStart()
end)
hook.Add("TTTPrepareRound", "GMBots_TTTPrepare", function()
	GMBots_TTTStart()
end)
hook.Add("TTTEndRound", "GMBots_TTTStart", function()
	GMBots_TTTStart()
end)

function GMBots_TTTPickup(ply,wep)
	if ply.Bot and wep and wep:IsValid() then
		if not BotWeaponIsDefault(wep) then
			ply:SetActiveWeapon(wep)
		end
	end
end
hook.Add("PlayerCanPickupWeapon","GMBots_TTTPickup",GMBots_TTTPickup)