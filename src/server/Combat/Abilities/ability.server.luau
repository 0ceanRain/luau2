local AbilityRemote = game.ReplicatedStorage.Shared.Remotes.AbilityRemote
local parryRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.parryRemote
local postureRemote = game.ReplicatedStorage.Shared.Remotes.DefenseRemotes.postureRemote
local debris = game:GetService("Debris")
AbilityRemote.OnServerEvent:Connect(function(player, PostureDamage, Damage)
	
	local character = player.Character
	local Hitbox = game.ReplicatedStorage.Shared.Hitboxes.Abilities.TestAbilities.TestHitbox
	
	
	local box = Hitbox:Clone()
	box.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,0)
	box.Parent = game.Workspace
	
	local weld = Instance.new("Weld")
	weld.Part0 = character.HumanoidRootPart
	weld.Part1 = box
	weld.Parent = box
		
	
	debris:AddItem(box, 0.4)
	debris:AddItem(weld, 0.5)
	box.Touched:Connect(function(part)
		local victumHum = part:FindFirstChild("Humanoid")
		local victim = part.parent
		local victimPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
		if victumHum then
			if victim:GetAttribute("Parrying") then
				parryRemote:FireClient(player,"Parried")
				parryRemote:FireClient(victimPlayer,"Parry")
			elseif victim:GetAttribute("Blocking") then
				postureRemote:FireClient(victimPlayer, PostureDamage)
			else
				victumHum:TakeDamage(Damage)
			end
		end
    end)
end)




