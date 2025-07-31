local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote
local postureRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.postureRemote
local debris = game:GetService("Debris")
AbilityRemote.OnServerEvent:Connect(function(player, module)
	
	local character = player.Character
    local Hitbox = game.ReplicatedStorage.Shared.Hitboxes.Abilities.TestAbilities.TestHitbox
    local PostureDamge = module.PostureDamge
    local Damage = module.Damage
    local box = Hitbox:Clone()
	
	box.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
	
	debris:AddItem(box, 0.4)
	
    box.OnTouched:Connect(function(part)
        if part:FindFirstChild("Humanoid") then
            local victim = part.parent
            local victimPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
            local victumHum = part:FindFirstChild("Humanoid")

            if victim:GetAttribute("Parrying") then
                parryRemote:FireClient(player, "Parried")
				parryRemote:FireClient(victimPlayer, "Parry")
			
			end
			if victim:GetAttribute("Blocking") then
				postureRemote:FireClient(victimPlayer, postureRemote)
			
			end

        end
    end)
end)




