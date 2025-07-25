local player = game:GetService("Players").LocalPlayer

local Character = player.Character

local Humanoid = player.Character:FindFirstChild("Humanoid")


local uis = game:GetService("UserInputService")


local EAbility uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    local playerName = player.Name
    local ability = require(game.ReplicatedStorage.playerName.ability.EAbility.module)
    if not ability then
        print("no e ability")
    end
    if input.KeyCode == Enum.KeyCode.E then
        if ability;CanActivate then
            ability:Activate
        end
    end
end)

local RAbility uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    local playerName = player.Name
    local ability = require(game.ReplicatedStorage.playerName.ability.RAbility.module)
    if not ability then
        print("no R ability")
    end
    if input.KeyCode == Enum.KeyCode.R then
        if ability;CanActivate then
            ability:Activate
        end
    end
end)