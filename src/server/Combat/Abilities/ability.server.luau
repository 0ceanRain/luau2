local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote
local postureRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.postureRemote
local debris = game:GetService("Debris")
AbilityRemote.OnServerEvent:Connect(function(player, Damage, PostureDamge)
	
	local character = player.Character
    local Hitbox = game.ReplicatedStorage.Shared.Hitboxes.Abilities.TestAbilities.TestHitbox

    local box = Hitbox:Clone()
	local weld = Instance.new("WeldConstraint")
    weld.Part0 = box
    weld.Part1 = character.HumanoidRootPart
    weld.Parent = box
	box.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
	debris:AddItem(weld, 0.4)
	debris:AddItem(box, 0.4)
	
    box.OnTouched:Connect(function(part)
        local victim = part.parent
        local victimPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
        local victumHum = part:FindFirstChild("Humanoid")
        if part:FindFirstChild("Humanoid") then
            

            if victim:GetAttribute("Parrying") then
                parryRemote:FireClient(player, "Parried")
				parryRemote:FireClient(victimPlayer, "Parry")
			
			elseif victimPlayer:GetAttribute("Blocking") then
                postureRemote:FireClient(victimPlayer, PostureDamge)
            
            else
                victumHum:TakeDamage(Damage)
            end
			

        end
    end)
end)




