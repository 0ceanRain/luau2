
local PostureSystem = require(game.ReplicatedStorage.Shared.UtilityModules.PostureSystem)
local postureRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.postureRemote
local Players = game:GetService("Players")

local player = Players.LocalPlayer


postureRemote.OnClientEvent:Connect(function(action, amount)
	print("PostureClientHandler: Received remote event -", action, amount)

	local postureSystem = PostureSystem.GetOrCreateInstance(player)

	if action == "damage" or typeof(action) == "number" then

		local damage = typeof(action) == "number" and action or amount
		postureSystem:AddPosture(damage)
		print("PostureClientHandler: Added", damage, "posture damage")

	elseif action == "reduce" then
		postureSystem:ReducePosture(amount)
		print("PostureClientHandler: Reduced", amount, "posture")

	elseif action == "reset" then
		postureSystem:ResetPosture()
		print("PostureClientHandler: Reset posture")
	end
end)
