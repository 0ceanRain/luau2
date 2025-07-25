local AbilityRemote = game.ReplicatedStorage.Remotes.AbilityRemote
local parryRemote = game.ReplicatedStorage.Remotes.DefenseRemotes.parryRemote

AbilityRemote.OnServerEvent:Connect(function(player, module)
    local Hitbox = game.ReplicatedStorage.Hitboxes.Abilitys.Ability1
    local PostureDamge = module.PostureDamge
    local Damage = module.Damage
    local box = Hitbox:Clone

    box.OnTouched:Connect(function(part)
        if part:FindFirstChild("Humanoid") then
            local victim = part
            local victimPlayer
            local victumHum = part:FindFirstChild("Humanoid")

            if victim:GetAttribute("Parrying") then
                parryRemote:FireServer(player, "Parried")
                parryRemote:FireServer(victimPlayer)
            end

            if victim:GetAttribute("Blocking") then
                postureRemote:FireServer(victim, PostureDamge)
                
            end

        end
    end)
end)




