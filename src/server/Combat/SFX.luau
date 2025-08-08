--local SFX = game.ReplicatedStorage.Shared.SFX.Abilities.Lighting["Thunder sound 2"]

local SFXRemote = game.ReplicatedStorage.Shared.Remotes.utilityRemotes.SFXRemote
local debris = game:GetService("Debris")
SFXRemote.OnServerEvent:Connect(function (player, stats)
	local sfx:Sound = stats.SFX
	
	local newsfx = sfx:Clone()
	
	newsfx.Parent = player
	
	newsfx:Play()
	debris:AddItem(newsfx, 8)
end)

