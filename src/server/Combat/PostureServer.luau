
local PostureSystem = require(game.ReplicatedStorage.Shared.UtilityModules.PostureSystem)
local postureRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.postureRemote
local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote


postureRemote.OnServerEvent:Connect(function(player, action, amount)
	local postureSystem = PostureSystem.GetOrCreateInstance(player)

	if action == "damage" or typeof(action) == "number" then

		local damage = typeof(action) == "number" and action or amount
		postureSystem:AddPosture(damage)

		print(player.Name .. " took " .. damage .. " posture damage")
	elseif action == "reduce" then
		postureSystem:ReducePosture(amount)
	elseif action == "reset" then
		postureSystem:ResetPosture()
	end
end)

parryRemote.OnServerEvent:Connect(function(player, action)
	if action == "Parry" then
		local postureSystem = PostureSystem.GetOrCreateInstance(player)
		postureSystem:OnSuccessfulParry()
		print(player.Name .. " successfully parried - posture reduced")
	end
end)
