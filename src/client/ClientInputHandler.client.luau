local player = game:GetService("Players").LocalPlayer
local Character = player.Character
local Humanoid = player.Character:FindFirstChild("Humanoid")
local playerName = player.Name
local uis = game:GetService("UserInputService")
local refreshAbilities = game.ReplicatedStorage.Shared.Remotes.utilityRemotes.refershAbilites

local abilityMap = {
	["E"] = Enum.KeyCode.E,
	["R"] = Enum.KeyCode.R,
	["v"] = Enum.KeyCode.V
}


local loadedAbilities = {}

local function loadAbilities()
	local abilitiesFolder = game.ReplicatedStorage:WaitForChild(playerName):FindFirstChild("AbilitiesFolder")

	if not abilitiesFolder then
		print("AbilitiesFolder not found for player: " .. playerName)
		return
	end


	for abilityName, keyCode in pairs(abilityMap) do
		local abilityFolderName = abilityName .. "_Ability"
		local abilityFolder = abilitiesFolder:FindFirstChild(abilityFolderName)

		if abilityFolder then

			local abilityModule = abilityFolder:FindFirstChildOfClass("ModuleScript")
			if abilityModule then
				local success, ability = pcall(require, abilityModule)
				if success and ability then
					loadedAbilities[abilityName] = ability
					print("Loaded " .. abilityName .. " ability successfully")
				else
					print("Failed to require " .. abilityName .. " ability module")
				end
			else
				print("No ModuleScript found in " .. abilityFolderName)
			end
		else
			print("No " .. abilityFolderName .. " folder found - skipping keybind")
		end
	end
end


loadAbilities()


refreshAbilities.Event:Connect(function()
	loadAbilities()
end)


local inputConnection = uis.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	for abilityName, ability in pairs(loadedAbilities) do
		local keyCode = abilityMap[abilityName]

		if input.KeyCode == keyCode then
			
			loadAbilities()
			
			if ability:CanActivate() then
				ability:Activate()
				print("Activated " .. abilityName .. " ability")
			else
				print(abilityName .. " ability cannot be activated right now")
			end
			break 
		end
	end
end)
