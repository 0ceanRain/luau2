local player = game.Players.LocalPlayer
local refreshAbilities = game.ReplicatedStorage.Shared.Remotes.utilityRemotes.refershAbilites

local playerName = player.Name
local button = script.Parent

button.MouseButton1Down:Connect(function()
	local E_AbilityModule = game.ReplicatedStorage.Shared.Abilities.ability
	local E = E_AbilityModule:Clone()
	
	
	if game.ReplicatedStorage:WaitForChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability"):GetChildren() ~= true then
		E.Parent = game.ReplicatedStorage:WaitForChild(playerName):FindFirstChild("AbilitiesFolder"):FindFirstChild("E_Ability")
		refreshAbilities:Fire()
	end
end)
