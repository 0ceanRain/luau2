
local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote
local postureRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.postureRemote
local debris = game:GetService("Debris")


local COMBAT_TAG_DURATION = 10


local function setCombatTag(victim, attacker)
	if not victim or not attacker then return end


	local oldTag = victim:FindFirstChild("CombatTag")
	if oldTag then
		oldTag:Destroy()
	end

	
	local combatTag = Instance.new("ObjectValue")
	combatTag.Name = "CombatTag"
	combatTag.Value = attacker 
	combatTag.Parent = victim

	
	local expireTime = Instance.new("NumberValue")
	expireTime.Name = "ExpireTime"
	expireTime.Value = tick() + COMBAT_TAG_DURATION
	expireTime.Parent = combatTag

	print(victim.Name .. " was tagged by " .. attacker.Name .. " for " .. COMBAT_TAG_DURATION .. " seconds")

	
	debris:AddItem(combatTag, COMBAT_TAG_DURATION)
end


local function getKillCredit(victim)
	local combatTag = victim:FindFirstChild("CombatTag")
	if not combatTag then return nil end

	local expireTime = combatTag:FindFirstChild("ExpireTime")
	if not expireTime then return nil end

	
	if tick() > expireTime.Value then
		combatTag:Destroy()
		return nil
	end

	return combatTag.Value
end

AbilityRemote.OnServerEvent:Connect(function(player, stats)
	local parryAble = stats.Parryable
	local blockAble = stats.Blockable
	local canBeDodged = stats.CanBeDodged
	local canBeCancelled = stats.CanBeCancelled
	local character = player.Character
	local Hitbox = stats.hitbox
	local OriginalWalkSpeed = character:FindFirstChild("Humanoid").WalkSpeed
	local box = Hitbox:Clone()
	box.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,0)
	box.Parent = game.Workspace
	local weld = Instance.new("Weld")
	weld.Part0 = character.HumanoidRootPart
	weld.Part1 = box
	weld.Parent = box
	character:FindFirstChild("Humanoid").WalkSpeed = 1	
	task.delay(0.3,function()
		character:FindFirstChild("Humanoid").WalkSpeed = 16
	end)
	debris:AddItem(box, 0.4)
	debris:AddItem(weld, 0.5)
	local hitOnce = {}

	box.Touched:Connect(function(part)
		local victimHum = part.Parent:FindFirstChild("Humanoid")
		local victim = part.Parent
		if hitOnce[victim] then return end
		local victimPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
		
	
	

		hitOnce[victim] = true

		if victimHum and victimPlayer then
			
			setCombatTag(victimPlayer, player)

			if victim:GetAttribute("Parrying") and parryAble then
				parryRemote:FireClient(player,"Parried")
				parryRemote:FireClient(victimPlayer,"Parry")
				victimPlayer:SetAttribute("Stunned", true)
				task.delay(0.4, function()
					victim:SetAttribute("Stunned", false)
				end)
			elseif victim:GetAttribute("Blocking") and blockAble then
				postureRemote:FireClient(victimPlayer, stats.postureDamage)
			else
			
				victimHum:TakeDamage(stats.damage)
				
				victim:SetAttribute("Stunned", true)
				task.delay(0.4, function()
					victim:SetAttribute("Stunned", false)
				end)
				local killCred = {}
				if victimHum.Health <= 0 then
					if killCred then return end
					local killer = getKillCredit(victimPlayer)
					
					if killer and killer == player then
						killCred[victimPlayer] = true
						if _G.AwardKill then
							_G.AwardKill(player)
						end
						
						print(player.Name .. " killed " .. victimPlayer.Name .. " and received 50 coins!")
					end
				end
			end
		end
	end)
end)
