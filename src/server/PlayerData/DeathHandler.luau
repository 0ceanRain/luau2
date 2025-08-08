
local Players = game:GetService("Players")


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


local function onPlayerDeath(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local killer = getKillCredit(player)
	if killer and killer ~= player then
		
		if _G.AwardKill then
			_G.AwardKill(killer)
		end

		print(killer.Name .. " killed " .. player.Name .. " and received 50 coins!")

	
	end

	
	local combatTag = player:FindFirstChild("CombatTag")
	if combatTag then
		combatTag:Destroy()
	end
end


Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			onPlayerDeath(player)
		end)
	end)
end)


for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				onPlayerDeath(player)
			end)
		end
	end

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			onPlayerDeath(player)
		end)
	end)
end
