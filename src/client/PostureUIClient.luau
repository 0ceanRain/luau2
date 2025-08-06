-- src/client/PostureClientInit.client.luau
local PostureUI = require(game.ReplicatedStorage.Shared.UtilityModules.PostureUI)
local HealthUI = require(game.ReplicatedStorage.Shared.UtilityModules.HealthUI)
local PostureSystem = require(game.ReplicatedStorage.Shared.UtilityModules.PostureSystem)
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Store UI globally so it doesn't get garbage collected
_G.PostureUI = nil
_G.HealthUI = nil
_G.PostureSystem = nil

-- Initialize posture and health systems for local player
local function initializeBars()
	-- Clean up existing instances
	if _G.PostureUI then
		_G.PostureUI:Destroy()
	end
	if _G.HealthUI then
		_G.HealthUI:Destroy()
	end

	-- Create posture system instance
	_G.PostureSystem = PostureSystem.GetOrCreateInstance(player)

	-- Create UIs
	_G.PostureUI = PostureUI.new()
	_G.HealthUI = HealthUI.new()

	print("Posture and Health systems initialized for " .. player.Name)
end

-- Initialize when character spawns
if player.Character then
	initializeBars()
end

player.CharacterAdded:Connect(initializeBars)
